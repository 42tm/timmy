{
    exec.pp - exec command's method for shell/utils/core.pas

    Copyright (C) 2018 42tm Team <fourtytwotm@gmail.com>

    This file is part of Timmy Interactive Shell.

    Timmy Interactive Shell is free software: you can redistribute it
    and/or modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation, either version 3
    of the License, or (at your option) any later version.
}

{
    The exec command, which reads a file at a specified path, and
    takes the lines in that file as Shell inputs. Can read commands from
    many files.
}
Procedure Exec(FName: String);
Var
    FObj: Text;
    FLine: String;
Begin
    Assign(FObj, FName);
    {$I-}
    Reset(FObj);
    {$I+}
    If IOResult <> 0
      then Begin
             If FileExists(FName)
               then Begin
                      ShellLg.Log(TLogger.ERROR, 'exec: Failed to read from '
                                + FName + ', ignoring...');
                      Close(FObj);
                    End
               else ShellLg.Log(TLogger.ERROR, 'exec: File ''' + FName
                              + ''' doesn''t exist, ignoring...');
           If Recorder.Recording
             then SetLength(Recorder.RecdInps, Length(Recorder.RecdInps) - 1);
           End;

    Jam(9); ShellLg.Log(TLogger.INFO, 'exec: Reading and executing from '
                      + FName + '...');
    Writeln(DupeString('=', 40 + Length(FName)));
    While not EOF(FOBj)
      do Begin
           Readln(FObj, FLine);
           ShellExec(FLine);
         End;
    Close(FObj);
    TextColor(White); Writeln(DupeString('=', 40 + Length(FName)));
End;
