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
Begin
    Assign(FObj, FName);
    {$I-}
    Reset(FObj);
    {$I+}
    If IOResult <> 0
      then Begin
             If FileExists(FName)
               then ShLog.Log(TLogger.ERROR, 'exec: Failed to read from '
                              + FName + ', ignoring...');
               else ShLog.Log(TLogger.ERROR, 'exec: File '''
                            + FName + ''' doesn''t exist, ignoring...');
             Exit;
           End;

    Jam(9); ShLog.Log(TLogger.INFO,
                      'exec: Reading and executing from ' + FName + '...');
    If not OutParse.HasArgument('record-more') then Env.ExecF := True;
    Writeln(DupeString('=', 40 + Length(FName)));

    While not EOF(FOBj)
      do Begin
           Readln(FObj, UserInput);
           ProcessInput(UserInput);
         End;

    Close(FObj);
    Env.ExecF := False;
    TextColor(White); Writeln(DupeString('=', 40 + Length(FName)));
    Jam(10); ShLog.Log(TLogger.INFO,
                       'Finished reading and executing commands from file');
End;