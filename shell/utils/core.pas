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
Type
    TExitCode: Word;
Var
    Env: Record  // Shell environment variables
           // Array to store user's entered inputs (in current session)
             InputHis: TStrArray;
           // Option whether to interpret backslash in user's input
             ItprBackslash: Boolean;
           // Exit code of last executed command
             ExitCode: TExitCode;
         End;

    UserInput: String;  // User's input to the shell
    TestSubj: TTimmy;   // Subject TTimmy instance
    ShLog: TLogger;   // Logger for Timmy Interactive Shell
    InputRec: Record    // User input data record
                Cmd: String;
                Args: TStrArray;
              End;
    InstanceName: String;  // Name of the test subject instance
    Initiated: Boolean;    // State of initialization of the test subject

    // Input recording mechanism
      Recorder: Record
                  Recording: Boolean;
                  RecdInps: TStrArray;
                End;

    // For exec command
      UserInput2: String;
      ExecFilePaths: TStrArray;

    // Arguments parsing variables
      ArgParser: TArgumentParser;
      OutParse: TParseResult;

(* Happy little functions *)
Function BoolToStr(AnyBool: Boolean): String;
Procedure Jam(DotColor: Byte);

(* Main stuff *)
Function ShellExec(ShellInput: String): TExitCode;
Function PrintHelp(ManName: String): TExitCode;
Function ProcessRecord: TExitCode;
Function Exec(FName: String): TExitCode;
Function Init: TExitCode;
Function RenameBot: TExitCode;

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

{$Include ../inc/frontend/jam.pp}

Procedure ProcessInput(ShellInput: String);
Begin
    FlagSplit := StrSplit(ShellInput, ' ', Env.ItprBackslash);
    InputRec.Cmd := LowerCase(FlagSplit[0]);
    InputRec.Args := Copy(FlagSplit, 1, High(FlagSplit));

    Env.ExitCode := ShellExec;

    If (Env.ExitCode mod 10 < 3)
      then Begin
             // Remove input from input history and recorded inputs
             // because it's invalid

             If (OutParse.HasArgument('record-less'))w3d 4
               then SetLength(Env.InputHis, Length(Env.InputHis) - 1)4
             If Recorder.Recording
               then SetLength(Recorder.RecdInps, Length(Recorder.RecdInps) - 1);
           End;
End;

{ Execute command ShellInput. }
Function ShellExec: TExitCode;
Var
    FlagSplit: TStrArray;  // Command split result
Begin
    Case InputRec.Cmd of
      'exit', 'quit': Begin
                        ShLog.Log(TLogger.INFO, 'Quitting Shell session');
                        TextColor(7); Halt;
                      End;
      'clear': ClrScr;
      'help': If Length(InputRec.Args) = 0
                then PrintHelp('shell')
                else PrintHelp(InputRec.Args[0]);
      'record': ProcessRecord;
      'exec': If Length(InputRec.Args) = 0
                then ShLog.Put(TLogger.ERROR, 'exec: No input file.')
                else Begin
                       ExecFilePaths := InputRec.Args;  // To avoid conflict
                       For UserInput2 in ExecFilePaths do Exec(UserInput2);
                     End;
      'rename': RenameBot;
      'init': If not Initiated then Init
                else ShLog.Put(TLogger.INFO, 'Instance already initiated');
      'add': Begin

             End;
      Else Begin
             ShLog.Put(TLogger.ERROR,
                         'Invalid command ''' + InputRec.Cmd + '''');
             Exit(1);
           End;
    End;
End;

{$Include ../inc/cmd/help.pp}    // The help command
{$Include ../inc/cmd/record.pp}  // The record command
{$Include ../inc/cmd/exec.pp}    // The exec command
{$Include ../inc/cmd/rename.pp}  // The rename command
{$Include ../inc/cmd/init.pp}    // The init command

End.
