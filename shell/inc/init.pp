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
    this procedure will prompt for them.
}
Procedure Init;
Var
    Input: String;

    // User's inputs for TTimmy.TPercent, TTimmy.NoUdstdRep, and TTimmy.DupesCheck
      FlagPercent: Integer;
      FlagDefaultRep: String;
      FlagDpCheck: Boolean;

    ValErrorCode,  // Error code for Val()
    FlagSeverity   // Severity for logging message at the end
                 : Integer;
Begin
    If Length(InputRec.Args) = 0  // init with no argument -> Prompt for inputs
      then Begin
             // Get value for TTimmy.TPercent
               ValErrorCode := 1;
               While ValErrorCode <> 0
                 do Begin
                      TextColor(1); Write(InstanceName);
                      TextColor(White); Write('.');
                      TextColor(9); Write('TPercent');
                      TextColor(White); Write(' = ');
                      Readln(Input);
                      If Input = ''
                        then Exit
                        else Val(Input, FlagPercent, ValErrorCode);
                      If ValErrorCode <> 0
                        then ShellLogger.Put(TLogger.WARNING,
                                             'Invalid value for ' + InstanceName
                                           + '.TPercent');
                    End;
             // Get value for TTimmy.NoUdstdRep
               TextColor(1); Write(InstanceName);
               TextColor(White); Write('.');
               TextColor(9); Write('NoUdstdRep');
               TextColor(White); Write(' = ');
               Readln(Input);
               FlagDefaultRep := Input;
               If Input = ''
                 then ShellLogger.Put(TLogger.LIGHTWARNING,
                                      'Default reply should not be empty');
             // Get value for TTimmy.DupesCheck
               Input := '';
               While (Input <> 'true') and (Input <> 'false')
                 do Begin
                      TextColor(1); Write(InstanceName);
                      TextColor(White); Write('.');
                      TextColor(9); Write('DupesCheck');
                      TextColor(White); Write(' = ');
                      Readln(Input);
                      If Input = '' then Exit;
                      Input := LowerCase(Input);
                      If (Input <> 'true') and (Input <> 'false')
                        then ShellLogger.Put(TLogger.WARNING,
                                       'Expected a boolean value (true|false)');
                    End;
               If Input = 'true'
                 then FlagDpCheck := True
                 else FlagDpCheck := False;
           End
    else Begin
           If (Length(InputRec.Args) < 3)
             then Begin
                    ShellLogger.Put(TLogger.ERROR,
                                    'init: Wrong number of arguments to init');
                    If Recorder.Recording
                      then SetLength(Recorder.RecdInps,
                                     Length(Recorder.RecdInps) - 1);
                    Exit;
                  End;
           // Get value for TTimmy.TPercent
             Val(InputRec.Args[0], FlagPercent, ValErrorCode);
             If ValErrorCode <> 0
               then Begin
                      ShellLogger.Put(TLogger.ERROR, 'Invalid value for '
                                    + InstanceName + '.TPercent');
                      If Recorder.Recording
                        then SetLength(Recorder.RecdInps,
                                       Length(Recorder.RecdInps) - 1);
                      Exit;
                    End;
           // Modify UserInput to get the user's input for default reply
             Delete(UserInput, 1, 4);  // Remove the string 'init'
             // Remove the TTimmy.TPercent input
               UserInput := StrTrim(UserInput, False);
               Delete(UserInput, 1, Pos(' ', UserInput));
             // Remove TTimmy.DupesCheck input
               UserInput := ReverseString(UserInput);
               Delete(UserInput, 1, Pos(' ', UserInput));
             UserInput := ReverseString(UserInput);
           FlagDefaultRep := UserInput;
           // Get value for TTimmy.DupesCheck
             Input := LowerCase(InputRec.Args[High(InputRec.Args)]);
             Case Input of
               'true': FlagDpCheck := True;
               'false': FlagDpCheck := False;
               Else Begin
                      ShellLogger.Log(TLogger.ERROR, 'Invalid value for '
                                    + InstanceName + '.DupesCheck');
                      If Recorder.Recording
                        then SetLength(Recorder.RecdInps,
                                       Length(Recorder.RecdInps) - 1);
                      Exit;
                    End;
           End;
         End;

    TestSubj.Init(FlagPercent, FlagDefaultRep, FlagDpCheck);
    Initiated := True;
    ShellLogger.Log(TLogger.INFO, 'Instance initiated');

    // Check if TTimmy.Init works fine
    ShellLogger.Log(TLogger.INFO, 'Expected: ' + InstanceName + '.TPercent = '
                  + IntToStr(FlagPercent) + '; ' + InstanceName + '.NoUdstdRep = '''
                  + FlagDefaultRep + '''; ' + InstanceName + '.DupesCheck = '
                  + BoolToStr(FlagDpCheck));

    FlagSeverity := TLogger.CORRECT;
    If (TestSubj.TPercent <> FlagPercent) or (TestSubj.NoUdstdRep <> FlagDefaultRep)
       or (TestSubj.DupesCheck <> FlagDpCheck)
      then FlagSeverity := TLogger.ERROR;

    ShellLogger.Log(FlagSeverity, 'Got:      ' + InstanceName + '.TPercent = '
                  + IntToStr(TestSubj.TPercent) + '; ' + InstanceName + '.NoUdstdRep = '''
                  + TestSubj.NoUdstdRep + '''; ' + InstanceName + '.DupesCheck = '
                  + BoolToStr(TestSubj.DupesCheck));
End;
