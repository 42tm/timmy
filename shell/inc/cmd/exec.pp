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
Procedure Exec;
Var
    FPIter, FIgnored: Byte;
    FObj: Text;
    FName, FLine: String;
    ProcArgs: TStrArray;
Begin
    If Length(InputRec.Args) = 0
      then Begin
             ShellLg.Put(TLogger.ERROR, 'exec: No input file specified.');
             Exit;
           End;

    If Length(InputRec.Args) > High(FPIter)
      then Begin
             ShellLg.Put(TLogger.ERROR, 'exec: Too many input files, at most '
                       + IntToStr(High(FPIter)) + ' input files only.');
             Exit;
           End;

    FIgnored := 0;
    // Use ProcArgs to iterate over arguments that are originally passed.
    // As the procedure is reading and executing lines in the file(s),
    // InputRec.Args is changed
      ProcArgs := InputRec.Args;
    For FPIter := 0 to High(ProcArgs)
      do Begin
           FName := ProcArgs[FPIter];
           Assign(FObj, FName);
           {$I-}
           Reset(FObj);
           {$I+}
           If IOResult <> 0
             then Begin
                    If FileExists(FName)
                      then Begin
                             ShellLg.Log(TLogger.ERROR, 'exec: Failed to read'
                                       + ' from ' + FName + ', ignoring...');
                             Close(FObj);
                           End
                      else ShellLg.Log(TLogger.ERROR, 'exec: File ''' + FName
                                     + ''' doesn''t exist, ignoring...');
                    Inc(FIgnored);
                    Continue;
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

    ShellLg.Log(TLogger.INFO, 'exec: Read '
             + IntToStr(Length(ProcArgs) - FIgnored) + ' file(s), ignored '
             + IntToStr(FIgnored) + ' file(s).');
End;
