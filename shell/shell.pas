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
{$mode ObjFPC} {$H+}
Program TimmyInteractiveShell;

Uses
     Crt, SysUtils,
     Core in 'utils/core.pas',
     ArgsParser in 'utils/argsparser.pas',
     Logger in 'logger/logger.pas',
     Timmy_Debug in '../variants/timmy_debug.pas';
Const
    SHELLVERSION = '1.0.0';
Var
    CmdF: Text;
    CmdRead: String;
Label
    StartIntf;

{
    User command prompt for Timmy Shell.
    This prompt highlights the command with a blue color.
    Also let the user go to previous/next command.
}
Function InputPrompt: String;
Var Flag,                 // String on display
    FlagCurrent: String;  // Current user input string
    InputKey: Char;       // Character to assign ReadKey to
    CursorX,              // Current X position of the cursor
    HistoryPos,           // Position in Env.InputHis, used when user press up/down
    FlagIter:             // Iteration for the string Flag (local)
              LongWord;
Begin
    Flag := ''; FlagCurrent := '';
    CursorX := 4;
    HistoryPos := Length(Env.InputHis);
    While True
      do Begin
           If (HistoryPos = Length(Env.InputHis)) then Flag := FlagCurrent;
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
                  Case InputKey of
                    #75: If CursorX > 4 then Dec(CursorX);
                    #77: If CursorX < Length(Flag) + 4 then Inc(CursorX);
                    #72: // Go back to previous command only if
                         // the input history is not empty
                           If Length(Env.InputHis) > 0
                             then Begin
                                    If HistoryPos = Length(Env.InputHis)
                                      then FlagCurrent := Flag;  // Save the current input
                                    If HistoryPos > 0
                                      then Begin
                                             Dec(HistoryPos);
                                             Flag := Env.InputHis[HistoryPos];
                                             CursorX := 4 + Length(Flag);
                                           End;
                                  End;
                    #80: // Go to next command
                           If HistoryPos < Length(Env.InputHis)
                             then Begin
                                    Inc(HistoryPos);
                                    If HistoryPos = Length(Env.InputHis)
                                      then CursorX := 4 + Length(FlagCurrent)
                                      else Begin
                                             Flag := Env.InputHis[HistoryPos];
                                             CursorX := 4 + Length(Flag);
                                           End;
                                  End;
                  End;
                End;
             13: Exit(Flag);  // Enter key
             32..126: Begin  // A text character
                        Flag := Copy(Flag, 1, CursorX - 4)
                                     + InputKey
                                     + Copy(Flag, CursorX - 3,
                                            Length(Flag) - CursorX + 4);
                        If HistoryPos = Length(Env.InputHis)
                          then FlagCurrent := Flag;
                        Inc(CursorX);
                      End;
             8: Begin  // Backspace key
                  If CursorX = 4 then Continue;
                  Delete(Flag, CursorX - 4, 1);
                  If HistoryPos = Length(Env.InputHis) then FlagCurrent := Flag;
                  Dec(CursorX);
                End;
           End;
         End;
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
             Writeln('  -h, --help       : Print this help and exit');
             Writeln('      --version    : Print the Shell''s version and the version of Timmy it is using');
             Writeln('  -l, --load=FILE  : Load Timmy Interactive Shell commands from FILE');
             Writeln('      --no-esc     : Disable backslash interpretation in Shell inputs');
             Writeln('      --quiet      : Only write log messages with severity of TLogger.ERROR and up to console');
             Writeln('      --less-log   : Only record events with severity of TLogger.ERROR and up to log file');
             Writeln('                     (not recommended)');
             Writeln('      --record-all : Record all inputs to temporary input history, even the ones');
             Writeln('                     that are erroneous');
             Halt;
           End;

    If ParamStr(1) = '--version'
      then Begin
             Writeln('Timmy Interactive Shell version ' + SHELLVERSION);
             Writeln('Using Timmy version ' + TIMMYVERSION);
             Halt;
           End;

    ShellLg.Init(TLogger.CORRECT, TLogger.CORRECT, 'log');

    ArgParser := TArgumentParser.Create;
    ArgParser.AddArgument('-l', 'load', saStore);
    ArgParser.AddArgument('--load', 'load', saStore);
    ArgParser.AddArgument('--no-esc', saBool);
    ArgParser.AddArgument('--quiet', saBool);
    ArgParser.AddArgument('--less-log', saBool);
    ArgParser.AddArgument('--record-all', saBool);

    CursorBig;
    TextColor(White);
    Writeln('Timmy Interactive Shell ' + SHELLVERSION);
    Writeln('Using Timmy version ' + TIMMYVERSION);
    Writeln('Type ''help'' for help.');

    Try
        OutParse := ArgParser.ParseArgs;
    Except
      On EInvalidArgument
        Do Begin
             ShellLg.Put(TLogger.FATAL, 'Found invalid option.');
             TextColor(7); Halt;
           End;
      On EParameterMissing
        Do Begin
             ShellLg.Put(TLogger.FATAL, 'Missing argument.');
             TextColor(7); Halt;
           End;
    End;

    Initiated := False;
    InstanceName := 'TestSubj';

    ShellLg.Log(TLogger.INFO, 'Declared an instance with the name '''
              + InstanceName + '''.');
    If OutParse.HasArgument('quiet')
      then ShellLg.CslOutMin := TLogger.ERROR;
    If OutParse.HasArgument('less-log')
      then ShellLg.FileOutMin := TLogger.ERROR;

    Env.ItprBackslash := Not OutParse.HasArgument('no-esc');
    Recorder.Recording := False;

    If OutParse.HasArgument('load')
      then Begin
             If not FileExists(OutParse.GetValue('load'))
               then Begin
                      ShellLg.Put(TLogger.ERROR, 'File '''
                                + OutParse.GetValue('load') + ''' does not'
                                + ' exist, ignoring...');
                      GoTo StartIntf;
                    End;
             Assign(CmdF, OutParse.GetValue('load'));
             {$I-}
             Reset(CmdF);
             {$I+}
             If IOResult <> 0
               then Begin
                      ShellLg.Log(TLogger.ERROR, 'Failed to read commands from file');
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
        SetLength(Env.InputHis, 0);
        ShellLg.Log(TLogger.INFO, 'New Shell session started');
        While True
          do Begin
               TextColor(White);
               UserInput := StrTrim(InputPrompt, False);
               If UserInput = '' then Continue;
               // Add command to input history, if this input is not the same
               // as the previous input
                 If ((Length(Env.InputHis) > 0)
                     and (not (UserInput = Env.InputHis[High(Env.InputHis)])))
                     or (Length(Env.InputHis) = 0)
                          then Begin
                                 SetLength(Env.InputHis,
                                           Length(Env.InputHis) + 1);
                                 Env.InputHis[High(Env.InputHis)] := UserInput;
                               End;
               If Recorder.Recording
                 then Begin  // Record input
                        SetLength(Recorder.RecdInps,
                                  Length(Recorder.RecdInps) + 1);
                        Recorder.RecdInps[High(Recorder.RecdInps)] := UserInput;
                      End;
               // Pass input over to Core to process
                 ShellExec(UserInput);
             End;
END.
