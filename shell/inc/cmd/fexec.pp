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
    Given a file's path FName, take the lines in that file
    as Shell inputs.
}
Function FExec(FName: String): TExitCode;
Var
    FObj: Text;
Begin
    If not FileExists(FName)
      then Begin
             ShLog.Log(TLogger.ERROR,
                       'fexec: File ''' + FName + ''' does not exist');
             Exit(41);
           End;

    Assign(FObj, FName);
    {$I-}
    Reset(FObj);
    {$I+}
    If IOResult <> 0
      then Begin
             ShLog.Log(TLogger.ERROR, 'fexec: Failed to read from ' + FName);
             Exit(42);
           End;

    Jam(9); ShLog.Log(TLogger.INFO, 'fexec: Executing from ' + FName + '...');
    If not OutParse.HasArgument('record-more') then Env.ExecF := True;


    TextColor(White); Writeln(DupeString('=', 40 + Length(FName)));

    While not EOF(FOBj)
      do Begin
           Readln(FObj, UserInput);
           ProcessInput;
         End;

    Close(FObj);
    Env.ExecF := False;
    TextColor(White); Writeln(DupeString('=', 40 + Length(FName)));


    Jam(10); ShLog.Log(TLogger.INFO, 'Finished executing inputs from file');
    Exit(40);
End;

{
    Just like the above function, but this one takes many file paths.
}
Function FExec(FList: TStrArray): TExitCode;
Var
    FPath: String;
    // Counters for number of each exit code values when calling FExec(String)
      counter1, counter2, counter3: Word;
Begin
    counter1 := 0; counter2 := 0; counter3 := 0;

    For FPath in FList
      do Begin
           FExec := FExec(FPath);
           Case FExec of
             40: Inc(counter1);
             41: Inc(counter2);
             42: Inc(counter3);
           End;
         End;

    ShLog.Log(TLogger.INFO,
              ['Executed ', IntToStr(Length(FList)), ' files, ',
              IntToStr(counter1), ' succeed, ', IntToStr(counter2),
              ' did not exist, ', IntToStr(counter3), ' failed to read from.']);

    // If all files were executed successfully, return 40
      If counter1 = Length(FList) then Exit(40) else Exit(43);
End;
