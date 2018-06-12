{
    core.pas - Timmy-related core utilities for Timmy Interative Shell

    Copyright (C) 2018 42tm Team <fourtytwotm@gmail.com>

    This file is part of Timmy Interactive Shell.

    Timmy Interactive Shell is free software: you can redistribute it
    and/or modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation, either version 3
    of the License, or (at your option) any later version.
}
{$mode ObjFPC} {$H+}
Unit Core;

Interface

Uses
     Crt, SysUtils, StrUtils,
     ArgsParser, Logger in '../logger/logger.pas',
     Timmy_Debug in '../../variants/timmy_debug.pas';
Const
    TIMMYVERSION = '1.2.0';
Var
    Env: Record  // Shell environment variables
           // Array to store user's entered inputs (in current session)
             InputHistory: TStrArray;
           // Option whether to interpret backslash in user's input
             ItprBackslash: Boolean;
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

    Recorder: Record  // Input recording mechanism
                Recording: Boolean;
                RecdInps: TStrArray;
              End;

    // Arguments parsing variables
      ArgParser: TArgumentParser;
      OutParse: TParseResult;

Function BoolToStr(AnyBool: Boolean): String;
Procedure ShellExec(ShellInput: String);
Procedure PrintHelp;
Procedure Init;
Procedure ProcessRecord;

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
      'exit', 'quit': Begin
                        ShellLogger.Log(TLogger.INFO, 'Quitting Shell session');
                        TextColor(7); Halt;
                      End;
      'clear': ClrScr;
      'help': PrintHelp;
      'record': ProcessRecord;
      'init': If not Initiated then Init
                else ShellLogger.Put(TLogger.INFO, 'Instance already initiated');
      'add': Begin

             End;
      Else Begin
             ShellLogger.Put(TLogger.ERROR, 'Invalid command '''
                           + InputRec.Command + '''');
             // Remove input from input history and recorded inputs
             // because it's invalid
               If not OutParse.HasArgument('record-all')
                 then SetLength(Env.InputHistory, Length(Env.InputHistory) - 1);
               If Recorder.Recording
                 then SetLength(Recorder.RecdInps, Length(Recorder.RecdInps) - 1);
           End;
    End;
End;

{$Include ../inc/help.pp}  // The help command

{$Include ../inc/record.pp}  // The record command

{$Include ../inc/init.pp}  // The init command

End.
