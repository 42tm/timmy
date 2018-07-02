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
Function RenameBot: TExitCode;
Const
    // String that contains the valid characters for the first character of
    // the test instance's name, will be used later for validation.
      Alpha = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
Begin
    Case Length(InputRec.Args) of
      0: Begin
           TextColor(White);
           Write('New name for test instance: ');
           Readln(UserInput);
         End;
      1: UserInput := InputRec.Args[0];
      Else Begin
             ShLog.Put(TLogger.ERROR, 'rename: Too many arguments');
             Exit(84);
           End;
    End;

    UserInput := StrTrim(UserInput);

    // ************************  VALIDATE NEW NAME  ************************
    // *                                                                   *
    // * Name is invalid when                                              *
    // *  1. It's empty string                                             *
    // *  2. The first character is not in the constant Alpha              *
    // *     defined above                                                 *
    // *  3. It is more than 15 characters in length                       *
    // *  4. It contains at least 1 space character                        *
    // *                                                                   *
    // *********************************************************************

    If (Length(UserInput) = 0) or (Pos(UserInput[1], Alpha) = 0)
        or (Length(UserInput) > 15) or (Pos(' ', UserInput) <> 0)
      then Begin
             ShLog.Put(TLogger.ERROR, 'rename: Invalid name');
             Jam(2); ShLog.Put(TLogger.INFO, 'See manual entry for rename, '
                             + 'section "Errors"');

             // If the new name was taken from the input prompt
             // (InputRec.Args = 1), exit 85 so that the recorder, if recording,
             // removes the input, to prevent errors when executing from record.
             // Else, exit 82 as a light warning.
               If Length(InputRec.Args) = 1 then Exit(85) else Exit(82);
           End;

    InstanceName := UserInput;
    Jam(10);
    ShLog.Log(TLogger.INFO,
              'rename: Test instance renamed to ''' + InstanceName + '''.');
End;
