{
    core.pas - Timmy-related core utilities for Timmy Interative Shell

    Copyright (C) 2018 42tm Team <fourtytwotm@gmail.com>

    This file is part of Timmy Interactive Shell.

    Timmy Interactive Shell is free software: you can redistribute it
    and/or modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation, either version 3
    of the License, or (at your option) any later version.

    Timmy Interactive Shell is distributed in the hope that it will be
    useful, but WITHOUT ANY WARRANTY; without even the implied warranty
    of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Timmy Interactive Shell.
    If not, see <http://www.gnu.org/licenses/>.
}
{$mode ObjFPC} {$H+}
Unit Core;

Interface

Uses
     Crt, SysUtils, StrUtils,
     ArgsParser,
     Timmy_Debug in '../../variants/timmy_debug.pas',
     Logger in '../logger/logger.pas';
Const
    TIMMYVERSION = '1.2.0';
Var
    Env: Record  // Shell environment variables
           InputHistory: TStrArray;  // Array to store user's entered inputs (in current session)
           ItprBackslash: Boolean;  // Option whether to interpret backslash in user's input
         End;
    UserInput: String;     // User's input to the shell
    TestSubj: TTimmy;      // Subject TTimmy instance
    ShellLogger: TLogger;  // Logger for Timmy Interactive Shell
    InputRec: Record       // User input data record
                Command: String;
                Args: TStrArray;
              End;
    InstanceName: String;  // Name of the test subject instance
    Initiated: Boolean;    // State of initialization of the test subject

    // Arguments parsing mechanisms
      ArgParser: TArgumentParser;
      OutParse: TParseResult;

Function BoolToStr(AnyBool: Boolean): String;
Procedure ShellExec(ShellInput: String);
Procedure PrintHelp;
Procedure Init;

Implementation

{
    Convert boolean value to string.
    Boolean is true -> Return 'True'. Otherwise return 'False'.
}
Function BoolToStr(AnyBool: Boolean): String;
Begin
    If AnyBool then Exit('True');
    Exit('False');
End;

{ Execute command ShellInput. }
Procedure ShellExec(ShellInput: String);
Var
    FlagSplit: TStrArray;  // Command split result
Begin
    FlagSplit := StrSplit(ShellInput, ' ', Env.ItprBackslash);
    InputRec.Command := FlagSplit[0];
    InputRec.Args := Copy(FlagSplit, 1, High(FlagSplit));
    Writeln;
    Case InputRec.Command of
      'exit', 'quit': Begin TextColor(7); Halt; End;
      'clear': ClrScr;
      'help': PrintHelp;
      'init': If not Initiated then Init
                else ShellLogger.Log(TLogger.INFO, 'Instance already initiated', True);
      'add': Begin

             End;
      Else Begin
             ShellLogger.Log(TLogger.ERROR, 'Invalid command ''' + InputRec.Command + '''', True);
             // Remove command from command history because it's invalid
               If not OutParse.HasArgument('record-all')
                 then SetLength(Env.InputHistory, Length(Env.InputHistory) - 1);
           End;
    End;
End;

Procedure PrintHelp;
Var
    ManFileName, ManLine: String;
    ManF: Text;
Begin
    If Length(InputRec.Args) = 0
      then ManFileName := 'shell'
      else ManFileName := InputRec.Args[0];

    If not FileExists('man/' + ManFileName + '.txt')
      then Begin
             ShellLogger.Log(TLogger.ERROR, 'Could not find the manual entry for that');
             Exit;
           End
      else Begin
             Assign(ManF, 'man/' + ManFileName + '.txt');
             {$I-}
             Reset(ManF);
             {$I+}
             If IOResult <> 0
               then Begin
                      ShellLogger.Log(TLogger.ERROR, 'Failed to read manual entry');
                      Exit;
                    End;
             TextColor(7);
             While not EOF(ManF)
               do Begin
                    Readln(ManF, ManLine);
                    Writeln(ManLine);
                  End;
             Close(ManF);
           End;
End;

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
                        then ShellLogger.Log(TLogger.WARNING, 'Invalid value for ' + InstanceName + '.TPercent', True);
                    End;
             // Get value for TTimmy.NoUdstdRep
               TextColor(1); Write(InstanceName);
               TextColor(White); Write('.');
               TextColor(9); Write('NoUdstdRep');
               TextColor(White); Write(' = ');
               Readln(Input);
               FlagDefaultRep := Input;
               If Input = ''
                 then ShellLogger.Log(TLogger.LIGHTWARNING, 'Default reply should not be empty', True);
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
                        then ShellLogger.Log(TLogger.WARNING, 'Expected a boolean value (true|false)', True);
                    End;
               If Input = 'true'
                 then FlagDpCheck := True
                 else FlagDpCheck := False;
           End
    else Begin
           If (Length(InputRec.Args) < 3)
             then Begin
                    ShellLogger.Log(TLogger.ERROR, 'init: Wrong number of arguments to init', True);
                    Exit;
                  End;
           // Get value for TTimmy.TPercent
             Val(InputRec.Args[0], FlagPercent, ValErrorCode);
             If ValErrorCode <> 0
               then Begin
                      ShellLogger.Log(TLogger.ERROR, 'Invalid value for '
                                                   + InstanceName
                                                   + '.TPercent', True);
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
                                                   + InstanceName
                                                   + '.DupesCheck', True);
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

End.
