{
    rename.pp - rename command's method for shell/utils/core.pas

    Copyright (C) 2018 42tm Team <fourtytwotm@gmail.com>

    This file is part of Timmy Interactive Shell.

    Timmy Interactive Shell is free software: you can redistribute it
    and/or modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation, either version 3
    of the License, or (at your option) any later version.
}

{
    The rename command - Rename the test instance

    Perform various checks for user input, see if it's a valid name.
}
Procedure RenameBot;
Const
    Alpha = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
Var
    SIter: Byte;
Begin
    If Length(InputRec.Args) > 1
      then Begin
             ShellLg.Log(TLogger.ERROR, 'rename: Too many arguments');
             If Recorder.Recording
               then SetLength(Recorder.RecdInps, Length(Recorder.RecdInps) - 1);
             Exit;
           End;

    If Length(InputRec.Args) = 1
      then UserInput := InputRec.Args[0]
      else Begin
             Write('New name for test instance: ');
             Readln(UserInput);
           End;

    UserInput := StrTrim(UserInput);

    SIter := Length(Alpha);
    If Length(UserInput) > 0  // To avoid run-time error
      then While SIter > 0
             do Begin
                  If Alpha[SIter] = UserInput[1] then Break;
                  Dec(SIter);
                End;

    If (SIter = 0) or (Pos(' ', UserInput) <> 0)
       or (Length(UserInput) > 15) or (Length(UserInput) = 0)
      then Begin
             ShellLg.Put(TLogger.ERROR, 'rename: Invalid name');
             Jam(2); TextColor(White); Write('See manual entry for rename');
             Writeln(', section "Errors" to see why');
             If Recorder.Recording
               then SetLength(Recorder.RecdInps, Length(Recorder.RecdInps) - 1);
             Exit;
           End;

    InstanceName := UserInput;
    Jam(10);
    ShellLg.Put(TLogger.INFO, 'rename: Test instance renamed to '''
              + UserInput + '''.');
End;
