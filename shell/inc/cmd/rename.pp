{
    rename.pp - The rename command

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
    Write('New name for test instance: ');
    Readln(UserInput);

    UserInput := StrTrim(UserInput);

    If Length(UserInput) > 15
      then Begin
             ShellLg.Put(TLogger.ERROR, 'rename: Name too long. '
                       + 'At most 15 characters only.');
             Exit;
           End;

    If Pos(' ', UserInput) <> 0
      then Begin
             ShellLg.Put(TLogger.ERROR, 'rename: Invalid name for test instance;'
                       + ' Space character is not allowed');
             Exit;
           End;

    SIter := Length(Alpha);
    While SIter > 0
      do Begin
           If Alpha[SIter] = UserInput[1] then Break;
           Dec(SIter);
         End;

    If SIter = 0
      then Begin
             ShellLg.Put(TLogger.ERROR, 'rename: Name must start with '
                       + 'an alphabetical ASCII character');
             Exit;
           End;

    InstanceName := UserInput;
    Jam(10);
    ShellLg.Put(TLogger.INFO, 'rename: Test instance renamed to '''
              + UserInput + '''.');
End;
