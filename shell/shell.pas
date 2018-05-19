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
Program TimmyInteractiveShell;
Uses Crt,
     Timmy in '../timmy.pas',
     Timmy_Debug in '../variants/timmy_debug.pas',
     Logger in 'logger/logger.pas';
Var TestSubject: TTimmy;          // Subject TTimmy instance
    ShellLogger: TLogger;         // Logger for Timmy Interactive Shell
    UserInput, Command: String;   // UserInput: user's input. Command: Command (the first word) in user's input
    Initiated: Boolean;           // State of initialization of the test subject
    InArgs: TStrArray;            // Arguments (that follows the command) in user's input

Procedure PrintHelp;
Begin
End;

Function InputPrompt: String;
Var Flag: String;
    InputKey: Char;
    CursorX, FlagIter: Integer;
Begin
    Flag := '';
    CursorX := 4;
    While True
      do Begin
           Delline; Insline;
           GoToXY(1, WhereY);
           TextColor(15);
           Write('>> ');
           TextColor(11);
           Flag := Flag + ' ';
           For FlagIter := 1 to Pos(' ', Flag) - 1 do Write(Flag[FlagIter]);
           TextColor(15);
           For FlagIter := Pos(' ', Flag) to Length(Flag) - 1 do Write(Flag[FlagIter]);
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
    ShellLogger.Init(TLogger.INFO, TLogger.INFO, 'history.dat');

    UserInput := '';
    Initiated := False;

    TextColor(White);
    Writeln('Timmy Interactive Shell');
    Writeln('Timmy version 1.2.0');
    Writeln('Type ''help'' for help.');

    // Start interface
    While True
      do Begin
           TextColor(White);
           UserInput := InputPrompt;
           Writeln;
           If Length(StrSplit(UserInput)) > 0
             then Command := LowerCase(StrSplit(UserInput)[0])
             else Continue;
           If (Command <> 'init') and (Command <> 'set') and (Command <> 'help')
               and (not Initiated)
             then Begin

                  End;
           Case Command of
             'exit': Begin Writeln; Halt; End;
             'help': PrintHelp;
             'init': Begin
                       Initiated := True;
                       ShellLogger.Log(TLogger.INFO, 'Instance initiated.');
                     End;
           Else Begin
                  ShellLogger.FileOutMin := -1;
                  ShellLogger.Log(TLogger.ERROR, 'Invalid command. Type ''help'' for help');
                  ShellLogger.FileOutMin := TLogger.INFO;
                End;
           End;
         End;
END.
