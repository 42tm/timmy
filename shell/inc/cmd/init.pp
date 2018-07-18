{
    init.pp - init command's method for shell/utils/core.pas

    Copyright (C) 2018 42tm Team <fourtytwotm@gmail.com>

    This file is part of Timmy Interactive Shell.

    Timmy Interactive Shell is free software: you can redistribute it
    and/or modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation, either version 3
    of the License, or (at your option) any later version.
}

{
    The init command, which initiates the bot.
    Needs arguments. If no argument is given,
    this function will prompt for them.
}
Function Init: TExitCode;
Var
    // User's inputs for TTimmy.TPercent, TTimmy.NoUdstdRep,
    // and TTimmy.DupesCheck
      FlagPercent: Integer;
      FlagDefaultRep: String;
      FlagDpCheck: Boolean;

    ValErrorCode,  // Error code for Val()
    FlagSeverity   // Severity for logging message at the end
                 : Integer;
Begin
    If Initiated
      then Begin
             ShLog.Put(TLogger.INFO, 'Instance already initiated');
             Exit(101);
           End;

    Case Length(InputRec.Args) of
      0:  // init with no argument -> Prompt for inputs from the user
        Begin
          // *************************************
          // *   Get value for TTimmy.TPercent   *
          // *************************************

          Repeat
            TextColor(1); Write(InstanceName); TextColor(White); Write('.');
            TextColor(9); Write('TPercent'); TextColor(White); Write(' = ');

            Readln(UserInput);

            If UserInput = '' then Exit(102);

            Val(UserInput, FlagPercent, ValErrorCode);
            If ValErrorCode <> 0
              then ShLog.Put(TLogger.WARNING,
                             'Invalid value for ' + InstanceName + '.TPercent');
          Until ValErrorCode = 0;

          // ***************************************
          // *   Get value for TTimmy.NoUdstdRep   *
          // ***************************************

          TextColor(1); Write(InstanceName); TextColor(White); Write('.');
          TextColor(9); Write('NoUdstdRep'); TextColor(White); Write(' = ');

          Readln(UserInput);

          FlagDefaultRep := UserInput;
          If UserInput = '' then ShLog.Put(TLogger.LIGHTWARNING,
                                           'Default reply should not be empty');

          // ***************************************
          // *   Get value for TTimmy.DupesCheck   *
          // ***************************************

          Repeat
            TextColor(1); Write(InstanceName); TextColor(White); Write('.');
            TextColor(9); Write('DupesCheck'); TextColor(White); Write(' = ');

            Readln(UserInput);

            If UserInput = '' then Exit(102);
            UserInput := LowerCase(UserInput);

            Case UserInput of
              'true', '0': FlagDpCheck := True;
              'false', '-1', '1': FlagDpCheck := False;
              Else ShLog.Put(TLogger.WARNING,
                             'Expected a boolean value (true|false)');
            End;
          Until (UserInput = 'true') or (UserInput = 'false');
        End;
      3:
        Begin
          FlagDefaultRep := InputRec.Args[1];

          Val(InputRec.Args[0], FlagPercent, ValErrorCode);
          If ValErrorCode <> 0
            then Begin
                   ShLog.Put(TLogger.ERROR,
                             'Invalid value for ' + InstanceName + '.TPercent');
                   Exit(105);
                 End;

          InputRec.Args[2] := LowerCase(InputRec.Args[2]);

          Case InputRec.Args[2] of
            'true', '0': FlagDpCheck := True;
            'false', '1', '-1': FlagDpCheck := False;
            Else Begin
                   ShLog.Put(TLogger.ERROR, 'Invalid value for ' + InstanceName
                        + '.DupesCheck, expected a boolean value (true|false)');
                   Exit(106);
                 End;
          End;
        End;
      Else Begin
             ShLog.Put(TLogger.ERROR, 'init: Wrong number of arguments');
             Exit(104);
           End;
    End;

    TestSubj.Init(FlagPercent, FlagDefaultRep, FlagDpCheck);
    Initiated := True;
    ShLog.Log(TLogger.INFO, 'Instance initiated');

    // Check if TTimmy.Init() works fine
    ShLog.Log(TLogger.INFO, 'Expected: ' + InstanceName + '.TPercent = '
              + IntToStr(FlagPercent) + '; ' + InstanceName + '.NoUdstdRep = '''
              + FlagDefaultRep + '''; ' + InstanceName + '.DupesCheck = '
              + BoolToStr(FlagDpCheck));

    FlagSeverity := TLogger.CORRECT;
    If (TestSubj.TPercent <> FlagPercent) or (TestSubj.NoUdstdRep <> FlagDefaultRep)
       or (TestSubj.DupesCheck <> FlagDpCheck)
      then FlagSeverity := TLogger.ERROR;

    ShLog.Log(FlagSeverity, 'Got:      ' + InstanceName + '.TPercent = '
              + IntToStr(TestSubj.TPercent) + '; ' + InstanceName + '.NoUdstdRep = '''
              + TestSubj.NoUdstdRep + '''; ' + InstanceName + '.DupesCheck = '
              + BoolToStr(TestSubj.DupesCheck));

    If FlagSeverity = TLogger.CORRECT then Exit(100) Else Exit(114);
End;
