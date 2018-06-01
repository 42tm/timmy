{
    Timmy Interactive Shell - Interactive interface for working with Timmy
    Always gets upstreamed with the latest version of Timmy.

    Copyright (C) 2018 42tm Team <fourtytwotm@gmail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
}
{$H+}
Program TimmyInteractiveShell;
Uses Crt, SysUtils,
     Timmy_Debug in '../variants/timmy_debug.pas',
     Core in 'utils/core.pas',
     ArgsParser in 'utils/argsparser.pas',
     Logger in 'logger/logger.pas';
Const
    SHELLVERSION = '1.0.0';
Var
    CmdF: Text;
    CmdRead, UserInput: String;
Label
    StartIntf;

{
    User command prompt for Timmy Shell.
    This prompt highlights the command with a blue color.
}
Function InputPrompt: String;
Var Flag: String;      // Current user input string
    InputKey: Char;    // Character to assign ReadKey to
    CursorX,           // Current X position of the cursor
    FlagIter:          // Iteration for the string Flag (local)
              Integer;
Begin
    Flag := '';
    CursorX := 4;
    While True
      do Begin
           Delline; Insline;
           GoToXY(1, WhereY);
           TextColor(15);
           Write('>> ');  // Prompt string

           // Print command with blue color
             TextColor(11);
             Flag := Flag + ' ';
             For FlagIter := 1 to Pos(' ', Flag) - 1 do Write(Flag[FlagIter]);
           // Print rest of the current user's command string (with white color)
             TextColor(15);
             For FlagIter := Pos(' ', Flag) to Length(Flag) - 1
               do Write(Flag[FlagIter]);

           Delete(Flag, Length(Flag), 1);
           GoToXY(CursorX, WhereY);
           InputKey := Readkey;
           Case Ord(InputKey) of
             0: Begin
                  InputKey := Readkey;
                  If (InputKey = #75) and (CursorX > 4) then Dec(CursorX); // Left
                  If (InputKey = #77) and (CursorX < Length(Flag) + 4) then Inc(CursorX); // Right
                End;
             13: Exit(Flag);  // Enter key
             32..126: Begin  // A text character
                        Flag := Copy(Flag, 1, CursorX - 4)
                                     + InputKey
                                     + Copy(Flag, CursorX - 3,
                                            Length(Flag) - CursorX + 4);
                        Inc(CursorX);
                      End;
             8: Begin  // Backspace key
                  If CursorX = 4 then Continue;
                  Delete(Flag, CursorX - 4, 1);
                  Dec(CursorX);
                End;
           End;
         End;

    InputPrompt := Flag;
End;

BEGIN
    If (ParamStr(1) = '-h') or (ParamStr(1) = '--help')
      then Begin
             Writeln('Timmy Interactive Shell - An environment for testing the Timmy unit');
             Writeln('Version ' + SHELLVERSION);
             Writeln('Using Timmy version ' + TIMMYVERSION);
             Writeln('Copyright (C) 2018 42tm Team');
             Writeln;
             Writeln('USAGE: shell [options]');
             Writeln;
             Writeln('OPTIONS:');
             Writeln('  -h, --help      : Print this help and exit');
             Writeln('      --version   : Print the Shell''s version and the version of Timmy it is using');
             Writeln('  -l, --load=FILE : Load Timmy Interactive Shell commands from FILE');
             Writeln('      --backslash : Enable backslash interpretation when splitting user''s input')
             Writeln('      --esc-space : Enable backslash interpretation in shell commands: The space character');
             Writeln('                    and the backslash character can then be escaped with a backslash.');
             Writeln('      --quiet     : Only write log messages with severity of TLogger.ERROR and up to console');
             Writeln('      --less-log  : Only record events with severity of TLogger.ERROR and up to log file');
             Halt;
           End;

    If ParamStr(1) = '--version'
      then Begin
             Writeln('Timmy Interactive Shell version ' + SHELLVERSION);
             Writeln('Using Timmy version ' + TIMMYVERSION);
             Halt;
           End;

    ShellLogger.Init(TLogger.INFO, TLogger.WARNING, 'history.dat');

    ArgParser := TArgumentParser.Create;
    ArgParser.AddArgument('-l', 'load', saStore);
    ArgParser.AddArgument('--load', 'load', saStore);
    ArgParser.AddArgument('--backslash', saBool);
    ArgParser.AddArgument('--esc-space', saBool);
    ArgParser.AddArgument('--quiet', saBool);
    ArgParser.AddArgument('--less-log', saBool);

    Initiated := False;

    CursorBig;
    TextColor(White);
    Writeln('Timmy Interactive Shell ' + SHELLVERSION);
    Writeln('Using Timmy version ' + TIMMYVERSION);
    Writeln('Type ''help'' for help.');
    InstanceName := 'TestSubj';
    ShellLogger.Log(TLogger.INFO, 'Declared an instance with the name ''TestSubj''');

    OutParse := ArgParser.ParseArgs;

    If OutParse.HasArgument('quiet')
      then ShellLogger.CslOutMin := TLogger.ERROR;
    If OutParse.HasArgument('less-log')
      then ShellLogger.FileOutMin := TLogger.ERROR;
    If (OutParse.HasArgument('load')) and FileExists(OutParse.GetValue('load'))
      then Begin
             Assign(CmdF, ParamStr(2));
             {$I-}
             Reset(CmdF);
             {$I+}
             If IOResult <> 0
               then Begin
                      ShellLogger.Log(TLogger.ERROR, 'Failed to read commands from file');
                      Close(CmdF);
                      GoTo StartIntf;
                    End;
             While not EOF(CmdF)
               do Begin
                    Readln(CmdF, CmdRead);
                    ShellExec(CmdRead);
                  End;
             Close(CmdF);
           End;

    // Start interface
    StartIntf:
        While True
          do Begin
               TextColor(White);
               UserInput := InputPrompt;
               ShellExec(UserInput);
             End;
END.
