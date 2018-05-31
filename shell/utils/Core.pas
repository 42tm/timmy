{
    core.pas - Timmy-related core utilities for Timmy Interative Shell

    Copyright (C) 2018 42tm Team <fourtytwotm@gmail.com>

    This file is part of Timmy Interactive Shell.

    Timmy Interactive Shell is free software: you can redistribute it
    and/or modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation, either version 3
    of the License, or (at your option) any later version.

    Timmy Interactive Shell is distributed in the hope that it will be
    useful, but WITHOUT ANY WARRANTY; without even the implied warranty
    of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Timmy Interactive Shell.
    If not, see <http://www.gnu.org/licenses/>.
}
{$mode ObjFPC} {$H+}
Unit Core;

Interface

Uses
     Timmy_Debug in '../../variants/timmy_debug.pas',
     Logger in '../logger/logger.pas';
Type
    TUserCmd = Record
                 Command: String;
                 Args: TStrArray;
               End;
Var
    TestSubject: TTimmy;    // Subject TTimmy instance
    ShellLogger: TLogger;   // Logger for Timmy Interactive Shell
    InputRec: TUserCmd;     // User input data record
    Initiated: Boolean;     // State of initialization of the test subject

Procedure ShellExec(ShellInput: String);
Procedure Init;

Implementation

Procedure ShellExec(ShellInput: String);
Var FlagSplit: TStrArray;
Begin
    FlagSplit := StrSplit(ShellInput, ' ', True);
    InputRec.Command := FlagSplit[0];
    InputRec.Args := Copy(FlagSplit, 1, High(FlagSplit));

    Case InputRec.Command of
      'init': If not Initiated then Init
                else ShellLogger.Log(TLogger.INFO, 'Instance already initiated.');
    End;
End;

Procedure Init;
Begin

End;

End.
