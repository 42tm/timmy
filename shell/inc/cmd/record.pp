{
    record.pp - record command's method for shell/utils/core.pas

    Copyright (C) 2018 42tm Team <fourtytwotm@gmail.com>

    This file is part of Timmy Interactive Shell.

    Timmy Interactive Shell is free software: you can redistribute it
    and/or modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation, either version 3
    of the License, or (at your option) any later version.
}

{ The record command }
Function ProcessRecord: TExitCode;
Const
    ROutFilename = 'inputs.rec';
Var
    RecordOutF: Text;
    Flag: String;  // Iterator for Recorder.RecdInps when writing record to file
Begin
    Case Length(InputRec.Args) of
      0: Begin
           Recorder.Recording := Not Recorder.Recording;
           If Recorder.Recording
             then Begin
                    ShLog.Log(TLogger.INFO, 'Input recording started');
                    ShLog.Put(TLogger.INFO, 'Type ''record'' again or '
                            + '''record --end'' to stop recording.');
                    Exit(30);
                  End;
           // Else, proceed to writting record to inputs.rec
         End;
      1: Begin
           Case InputRec.Args[0] of
             'status':
                Begin
                  If Recorder.Recording
                    then ShLog.Put(TLogger.INFO,
                                   ['Recorded ', IntToStr(Length(Recorder.RecdInps)),
                                    ' and still recording...'])
                    else ShLog.Put(TLogger.INFO, 'Not recording.');
                  Exit(30);
                End;
              'start', 'begin':
                Begin
                  If Recorder.Recording
                    then Begin
                           ShLog.Put(TLogger.WARNING, 'Already recording');
                           Exit(31);
                         End
                    else Begin
                           Recorder.Recording := True;
                           ShLog.Log(TLogger.INFO, 'Input recording started');
                           ShLog.Put(TLogger.INFO, 'Type ''record'' again or '
                                   + '''record end'' to stop recording.');
                           Exit(30);
                         End;
                End;
              'stop', 'quit', 'end':
                If not Recorder.Recording
                  then Begin
                         ShLog.Put(TLogger.WARNING,
                                   'No active recording session running.');
                         Exit(32);
                       End
                  else Begin
                         Recorder.Recording := False;
                         Exit(30);
                       End;
             Else Begin
                    ShLog.Put(TLogger.ERROR, 'record: Invalid argument'
                            + ' ''' + InputRec.Args[0] + '''.');
                    Exit(35);
                  End;
             End;
         End;  // End second case
      Else Begin
             ShLog.Put(TLogger.ERROR, 'record: Wrong number of arguments');
             Exit(34);
           End;
    End;


    // ************************
    // *    STOP RECORDING    *
    // ************************

    // By now, if the user wants to start recording, the function
    // should have exited.

    // Exclude the input that quits the recorder
    // Note that the recorder is still running at this point, so we don't need
    // to check whether the recorder is running or not
      SetLength(Recorder.RecdInps, Length(Recorder.RecdInps) - 1);

    If Length(Recorder.RecdInps) = 0
      then Begin
             ShLog.Put(TLogger.LIGHTWARNING, 'No recorded input.');
             Exit(30);
           End;

    Assign(RecordOutF, ROutFilename);
    {$I-}

    If FileExists(ROutFilename)
      then Begin
             ShLog.Log(TLogger.LIGHTWARNING, ROutFilename + ' exists.');
             TextColor(White);
             Write('Do you want to append or overwrite it? [a|o] ');
             Readln(Flag);
             Case Flag of
               'a', 'append': Append(RecordOutF);
               'o', 'overwrite': Rewrite(RecordOutF);
               else Begin
                      {$I+}
                      ShLog.Put(TLogger.ERROR, 'Invalid input, quitting without'
                              + ' writing to file');
                      Exit(33);
                    End;
             End;
           End
      else Rewrite(RecordOutF);

    {$I+}
    If IOResult <> 0
      then Begin
             ShLog.Log(TLogger.ERROR, 'record: Failed to write recorded '
                     + 'inputs to ' + ROutFilename);
             Exit(36);
           End;

    For Flag in Recorder.RecdInps do Writeln(RecordOutF, Flag);

    Close(RecordOutF);

    ShLog.Log(TLogger.INFO, 'record: Input record has been written to '
              + ROutFilename + '.');

    Exit(30);
End;
