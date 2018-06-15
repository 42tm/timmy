{
    Timmy Interactive Shell - Interactive interface for working with Timmy
    Always gets upstreamed with the latest version of Timmy.

    Copyright (C) 2018 42tm Team <fourtytwotm@gmail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
}
{$mode ObjFPC} {$H+}
Program TimmyInteractiveShell;

Uses
     Crt, SysUtils,
     Core in 'utils/core.pas',
     ArgsParser in 'utils/argsparser.pas',
     Logger in 'logger/logger.pas',
     Timmy_Debug in '../variants/timmy_debug.pas';
Const
    SHELLVERSION = '1.0.0';
    TIMMYVERSION = '1.2.0';
Var
    CmdF: Text;
    LoadFilename, CmdRead: String;
Label
    StartIntf;

{$Include inc/frontend/drawbar.pp}

// InputPrompt() function is here
// Later used in the main program of shell.pas
{$Include inc/frontend/inputprompt.pp}

BEGIN
    If (ParamStr(1) = '-h') or (ParamStr(1) = '--help')
      then Begin
             PrintHelp('program');
             Halt;
           End;

    If ParamStr(1) = '--version'
      then Begin
             Writeln('Timmy Interactive Shell version ' + SHELLVERSION);
             Writeln('Using Timmy version ' + TIMMYVERSION);
             Halt;
           End;

    ShellLg.Init(TLogger.CORRECT, TLogger.CORRECT, 'log');

    ArgParser := TArgumentParser.Create;
    ArgParser.AddArgument('-l', 'load', saStore);
    ArgParser.AddArgument('--load', 'load', saStore);
    ArgParser.AddArgument('--no-esc', saBool);
    ArgParser.AddArgument('--quiet', saBool);
    ArgParser.AddArgument('--less-log', saBool);
    ArgParser.AddArgument('--record-less', saBool);

    CursorBig;
    TextColor(White);
    Writeln('Timmy Interactive Shell ' + SHELLVERSION);
    Writeln('Using Timmy version ' + TIMMYVERSION);
    Writeln('Type ''help'' for help.');

    Try
        OutParse := ArgParser.ParseArgs;
    Except
      On EInvalidArgument
        Do Begin
             ShellLg.Put(TLogger.FATAL, 'Found invalid option.');
             TextColor(7); Halt;
           End;
      On EParameterMissing
        Do Begin
             ShellLg.Put(TLogger.FATAL, 'Missing argument.');
             TextColor(7); Halt;
           End;
    End;

    Initiated := False;
    InstanceName := 'TestSubj';

    Jam(10);
    ShellLg.Log(TLogger.INFO, 'Declared an instance with the name '''
              + InstanceName + '''.');
    If OutParse.HasArgument('quiet')
      then ShellLg.CslOutMin := TLogger.ERROR;
    If OutParse.HasArgument('less-log')
      then ShellLg.FileOutMin := TLogger.ERROR;

    Env.ItprBackslash := Not OutParse.HasArgument('no-esc');
    Recorder.Recording := False;

    If OutParse.HasArgument('load')
      then Begin
             LoadFilename := OutParse.GetValue('load');
             If not FileExists(LoadFilename)
               then Begin
                      ShellLg.Put(TLogger.ERROR, 'File ''' + LoadFilename
                                + ''' does not exist, ignoring...');
                      GoTo StartIntf;
                    End;
             Assign(CmdF, LoadFilename);
             {$I-}
             Reset(CmdF);
             {$I+}
             If IOResult <> 0
               then Begin
                      ShellLg.Log(TLogger.ERROR, 'Failed to read commands from file');
                      Close(CmdF);
                      GoTo StartIntf;
                    End;
             Jam(9);
             Env.SfFReading := True;
             ShellLg.Log(TLogger.INFO, 'Reading and executing commands from file...');
             Writeln('===========================================');
             While not EOF(CmdF)
               do Begin
                    Readln(CmdF, CmdRead);
                    Jam(11); Writeln(CmdRead);
                    ShellExec(CmdRead);
                  End;
             Close(CmdF);
             TextColor(15);
             Writeln('===========================================');
             Env.SfFReading := False;
             Jam(10);
             ShellLg.Log(TLogger.INFO, 'Finished reading and executing commands'
                       + ' from file');
           End;

    // Start interface
    StartIntf:
        SetLength(Env.InputHis, 0);
        Jam(10); ShellLg.Log(TLogger.INFO, 'New Shell session started');
        While True
          do Begin
               TextColor(White);
               UserInput := InputPrompt;
               If UserInput = '' then Continue;
               // Add command to input history, if this input is not the same
               // as the previous input
                 If ((Length(Env.InputHis) > 0)
                     and (not (UserInput = Env.InputHis[High(Env.InputHis)])))
                     or (Length(Env.InputHis) = 0)
                          then Begin
                                 SetLength(Env.InputHis,
                                           Length(Env.InputHis) + 1);
                                 Env.InputHis[High(Env.InputHis)] := UserInput;
                               End;
               If Recorder.Recording
                 then Begin  // Record input
                        SetLength(Recorder.RecdInps,
                                  Length(Recorder.RecdInps) + 1);
                        Recorder.RecdInps[High(Recorder.RecdInps)] := UserInput;
                      End;
               Writeln;
               // Pass input over to Core to process
                 ShellExec(UserInput);
             End;
END.
