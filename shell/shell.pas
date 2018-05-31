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
     Core in 'utils/core.pas',
     Timmy_Debug in '../variants/timmy_debug.pas',
     ArgsParser in 'argparse/src/common/ArgsParser.pas',
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
    CursorBig;
    ShellLogger.Init(TLogger.INFO, TLogger.WARNING, 'history.dat');

    Initiated := False;

    TextColor(White);
    Writeln('Timmy Interactive Shell ' + SHELLVERSION);
    Writeln('Using Timmy version 1.2.0');
    Writeln('Type ''help'' for help.');

    If (ParamStr(1) = '-load') and FileExists(ParamStr(2))
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
