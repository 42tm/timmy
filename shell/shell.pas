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
Uses Timmy_Debug in '../variants/timmy_debug.pas';
Var TestSubject: TTimmy;
    UserInput, Command: String;
    Initiated: Boolean;
    Params: TStrArray;



BEGIN
    UserInput := '';
    Initiated := False;

    // Start interface
    While LowerCase(UserInput) <> 'exit'
      do Begin
           Write('>> '); Readln(UserInput);
           Command := LowerCase(StrSplit(UserInput)[0]);
           If (Command <> 'init') and (Command <> 'set') and (not Initiated)
             then Begin
                    
                  End;
           Case Command of
             'init': Begin
                       Initiated := True;
                     End;
           Else Writeln('')
           End;
         End;
END.
