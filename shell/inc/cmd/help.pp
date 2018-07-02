{
    help.pp - help command's method for shell/utils/core.pas

    Copyright (C) 2018 42tm Team <fourtytwotm@gmail.com>

    This file is part of Timmy Interactive Shell.

    Timmy Interactive Shell is free software: you can redistribute it
    and/or modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation, either version 3
    of the License, or (at your option) any later version.
}

{
    The help command.
    If there's no argument, it prints the shell's overall guides.
    If an argument is specified, and it's the name of a command,
    then print the manual page of that command.

    Manual pages are found in /shell/man in form of text files (.txt)
}
Function PrintHelp(ManName: String): TExitCode;
Var
    ManLine: String;
    ManF: Text;
Begin
    If not FileExists('man/' + ManName + '.txt')
      then Begin
             ShLog.Log(TLogger.ERROR,
                       'help: Could not find the manual entry for that');
             Exit(21);
           End;

    Assign(ManF, 'man/' + ManName + '.txt');
    {$I-}
    Reset(ManF);
    {$I+}
    If IOResult <> 0
      then Begin
             ShLog.Log(TLogger.ERROR, 'Failed to read manual entry');
             Exit(22);
           End;

    TextColor(7);
    While not EOF(ManF)
      do Begin
           Readln(ManF, ManLine);
           Writeln(ManLine);
        End;

    Close(ManF);
    Exit(20);
End;

Function PrintHelp(ManPages: TStrArray): TExitCode;
Var
    Iter: String;
    GotError: Boolean;
Begin
    GotError := False;

    For Iter in ManPages
      do Begin
           If PrintHelp(Iter) <> 20 then GotError := True;
           Writeln;
         End;

    If GotError then Exit(23) else Exit(20);
End;
