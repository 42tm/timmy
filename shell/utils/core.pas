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
     Crt, SysUtils,
     ArgsParser,
     Timmy_Debug in '../../variants/timmy_debug.pas',
     Logger in '../logger/logger.pas';
Type
    TUserCmd = Record
                 Command: String;
                 Args: TStrArray;
               End;
Const
    TIMMYVERSION = '1.2.0';
Var
    TestSubj: TTimmy;         // Subject TTimmy instance
    ShellLogger: TLogger;     // Logger for Timmy Interactive Shell
    InputRec: TUserCmd;       // User input data record
    InstanceName: String;     // Name of the test subject instance
    Initiated: Boolean;       // State of initialization of the test subject
    InputHistory: TStrArray;  // Array to store user's entered inputs (in current session)

    // Arguments parsing mechanisms
      ArgParser: TArgumentParser;
      OutParse: TParseResult;

Function BoolToStr(AnyBool: Boolean): String;
Procedure ShellExec(ShellInput: String);
Procedure Init;

Implementation

Function BoolToStr(AnyBool: Boolean): String;
Begin
    If AnyBool then Exit('True');
    Exit('False');
End;

Procedure ShellExec(ShellInput: String);
Var
    FlagSplit: TStrArray;  // Command split result
Begin
    If OutParse.HasArgument('esc-space')
      then FlagSplit := StrSplit(ShellInput, ' ', True)
      else FlagSplit := StrSplit(ShellInput, ' ', False);
    InputRec.Command := FlagSplit[0];
    InputRec.Args := Copy(FlagSplit, 1, High(FlagSplit));
    Writeln;
    Case InputRec.Command of
      'exit', 'quit': Begin Writeln; Halt; End;
      'clear': ClrScr;
      'init': If not Initiated then Init
                else ShellLogger.Log(TLogger.INFO, 'Instance already initiated', True);
      'add': Begin

             End;
      Else Begin
             ShellLogger.Log(TLogger.ERROR, 'Invalid command ''' + InputRec.Command + '''', True);
             // Remove command from command history because it's invalid
               SetLength(InputHistory, Length(InputHistory) - 1);
           End;
    End;
End;

Procedure Init;
Var
    Input: String;
    FlagPercent: Integer;
    FlagDefaultRep: String;
    FlagDpCheck: Boolean;
    ValErrorCode, FlagSeverity: Integer;
Begin
    If Length(InputRec.Args) = 0
      then Begin
             // Get value for TTimmy.TPercent
               ValErrorCode := 1;
               While ValErrorCode <> 0
                 do Begin
                      TextColor(9); Write(InstanceName + '.TPercent');
                      TextColor(White); Write(' = ');
                      Readln(Input);
                      If Input = ''
                        then Exit
                        else Val(Input, FlagPercent, ValErrorCode);
                      If ValErrorCode <> 0
                        then ShellLogger.Log(TLogger.WARNING, 'Invalid value for ' + InstanceName + '.TPercent', True);
                    End;
             // Get value for TTimmy.DefaultRep
               TextColor(9); Write(InstanceName + '.NoUdstdRep');
               TextColor(White); Write(' = ');
               Readln(Input);
               If Input = ''
                 then ShellLogger.Log(TLogger.LIGHTWARNING, 'Default reply should not be empty', True);
               FlagDefaultRep := Input;
             // Get value for TTimmy.DupesCheck
               Input := '';
               While (Input <> 'true') and (Input <> 'false')
                 do Begin
                      TextColor(9); Write(InstanceName + '.DupesCheck');
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
           Val(InputRec.Args[0], FlagPercent, ValErrorCode);
           If ValErrorCode <> 0
             then Begin
                    ShellLogger.Log(TLogger.ERROR, 'Invalid value for ' + InstanceName + '.TPercent', True);
                    Exit;
                  End;
           FlagDefaultRep := StrJoin(Copy(InputRec.Args, 1, Length(InputRec.Args) - 2), ' ');
           Input := LowerCase(InputRec.Args[High(InputRec.Args)]);
           Case Input of
             'true': FlagDpCheck := True;
             'false': FlagDpCheck := False;
             Else Begin
                    ShellLogger.Log(TLogger.ERROR, 'Invalid value for ' + InstanceName + '.DupesCheck', True);
                    Exit;
                  End;
           End;
         End;

    TestSubj.Init(FlagPercent, FlagDefaultRep, FlagDpCheck);
    ShellLogger.Log(TLogger.INFO, 'Instance initiated');
    ShellLogger.Log(TLogger.INFO, 'Expected: ' + InstanceName + '.TPercent = '
                  + IntToStr(FlagPercent) + '; ' + InstanceName + '.NoUdstdRep = '
                  + FlagDefaultRep + '; ' + InstanceName + '.DupesCheck = '
                  + BoolToStr(FlagDpCheck));
    FlagSeverity := TLogger.CORRECT;
    If (TestSubj.TPercent <> FlagPercent) or (TestSubj.NoUdstdRep <> FlagDefaultRep)
       or (TestSubj.DupesCheck <> FlagDpCheck)
      then FlagSeverity := TLogger.ERROR;

    ShellLogger.Log(FlagSeverity, 'Got: ' + InstanceName + '.TPercent = '
                  + IntToStr(TestSubj.TPercent) + '; ' + InstanceName + '.NoUdstdRep = '
                  + TestSubj.NoUdstdRep + '; ' + InstanceName + '.DupesCheck = '
                  + BoolToStr(TestSubj.DupesCheck));
End;

End.
