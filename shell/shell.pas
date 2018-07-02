{
    Timmy Interactive Shell - Interactive interface for working with Timmy

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
{$mode ObjFPC} {$H+} {$Warnings ON}
Program TimmyInteractiveShell;

Uses
     Crt, SysUtils,
     Core in 'utils/core.pas',
     ArgsParser in 'utils/argsparser.pas',
     Logger in 'logger/logger.pas',
     Timmy_Debug in '../variants/timmy_debug.pas';
Const
    {$Warning Have you checked SHELLVERSION and TIMMYVERSION constants yet?}
    SHELLVERSION = '1.0.0';  // Current version of Timmy Interactive Shell
    TIMMYVERSION = '1.2.0';  // Current version of Timmy that the Shell's using

{$Include inc/frontend/drawbar.pp}
{$Include inc/frontend/inputprompt.pp}

BEGIN
    ShLog.Init(TLogger.CORRECT, TLogger.CORRECT, 'log');

    ShLog.Put(10, 'Timmy Interactive Shell ' + SHELLVERSION);
    ShLog.Put(10, 'Copyright (C) 2018 42tm Team <fourtytwotm@gmail.com>');
    ShLog.Put(10, 'Using Timmy version ' + TIMMYVERSION);

    // *******************************
    // *       GENERIC OPTIONS       *
    // *******************************

    Case ParamStr(1) of
      '-h', '--help': Halt(PrintHelp('options'));
      '--info': Halt(PrintHelp('program'));
    End;

    // **************************************
    // *     ADD COMMAND LINE ARGUMENTS     *
    // **************************************

    ArgParser := TArgumentParser.Create;
    ArgParser.AddArgument('-l', 'load', saStore);
    ArgParser.AddArgument('--load', 'load', saStore);
    ArgParser.AddArgument('--no-esc', saBool);
    ArgParser.AddArgument('--quiet', saBool);
    ArgParser.AddArgument('--less-log', saBool);
    ArgParser.AddArgument('--record-less', saBool);
    ArgParser.AddArgument('--record-more', saBool);

    // ****************************************
    // *     PARSE COMMAND LINE ARGUMENTS     *
    // ****************************************

    Try
        OutParse := ArgParser.ParseArgs;
    Except
        On EInvalidArgument
          Do Begin
               ShLog.Put(TLogger.FATAL, 'Found invalid option.');
               TextColor(7); Halt(3);
             End;
        On EParameterMissing
          Do Begin
               ShLog.Put(TLogger.FATAL, 'Missing argument.');
               TextColor(7); Halt(4);
             End;
    End;

    // ***************************************
    // *     PREPARE FOR INPUT EXECUTION     *
    // ***************************************

    If OutParse.HasArgument('quiet') then ShLog.CslOutMin := TLogger.ERROR;
    If OutParse.HasArgument('less-log') then ShLog.FileOutMin := TLogger.ERROR;

    CursorBig;

    Initiated := False;
    InstanceName := 'TestSubj';

    Jam(10);
    ShLog.Log(TLogger.INFO,
              'Declared an instance with the name ''' + InstanceName + '''.');

    Env.ItprBackslash := Not OutParse.HasArgument('no-esc');
    Env.ExecF := False;
    Recorder.Recording := False;


    If OutParse.HasArgument('load') then Exec(OutParse.GetValue('load'));


    // ***************************
    // *       NEW SESSION       *
    // ***************************

    SetLength(Env.InputHis, 0);
    Jam(10); ShLog.Log(TLogger.INFO, 'New Shell session started');

    While True
      do Begin
           TextColor(White);
           UserInput := InputPrompt;  // Prompt the user for input
           Writeln;
           ProcessInput(UserInput);  // Pass input over to Core to process
         End;
END.
