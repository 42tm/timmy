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
Procedure ProcessRecord;
Const
    ROutFilename = 'inputs.rec';
Var
    RecordOutF: Text;
    Flag: String;
Begin
    If Length(InputRec.Args) > 1
      then Begin
             ShLog.Put(TLogger.ERROR, 'record: Wrong number of arguments');
             If Recorder.Recording
               then SetLength(Recorder.RecdInps, Length(Recorder.RecdInps) - 1);
             Exit;
           End;

    If Length(InputRec.Args) = 0
      then Begin
             Recorder.Recording := Not Recorder.Recording;
             If Recorder.Recording
               then Begin
                      Writeln('Input recording started, type ''record'' again ',
                              'or ''record --end'' to stop recording.');
                      Exit;
                    End
           End
      else Begin
             Case InputRec.Args[0] of
               'status':
                  Begin
                    If Recorder.Recording
                      then Writeln('Recorded ', Length(Recorder.RecdInps),
                                   ' and still recording...')
                      else Writeln('Not recording.');
                    Exit;
                  End;
                'start', 'begin':
                  Begin
                    If Recorder.Recording
                      then Begin
                             ShLog.Put(TLogger.WARNING, 'Already recording');
                             SetLength(Recorder.RecdInps,
                                       Length(Recorder.RecdInps) - 1);
                           End
                      else Begin
                             Recorder.Recording := True;
                             Writeln('Input recording started, type ''record''',
                                     ' again or ''record end'' to stop ',
                                     'recording.');
                           End;
                    Exit;
                  End;
               'stop', 'quit', 'end':
                 If not Recorder.Recording
                   then Begin
                          ShLog.Put(TLogger.WARNING,
                                      'No active recording session running.');
                          Exit;
                        End
                   else Recorder.Recording := False;
               Else Begin
                      ShLog.Put(TLogger.ERROR, 'record: Invalid argument'
                                + ' ''' + InputRec.Args[0] + '''.');
                      If Recorder.Recording
                        then SetLength(Recorder.RecdInps,
                                       Length(Recorder.RecdInps) - 1);
                      Exit;
                    End;
             End;
           End;

    // Stop recording
    // By now, if the user wants to start recording, the procedure
    // should have quitted.

    // Exclude the input that quits the recorder
      SetLength(Recorder.RecdInps, Length(Recorder.RecdInps) - 1);

    If Length(Recorder.RecdInps) = 0
      then Begin
             ShLog.Put(TLogger.LIGHTWARNING, 'No recorded input.');
             Exit;
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
               else {$I+} Exit;
             End;
           End
      else Rewrite(RecordOutF);

    {$I+}
    If IOResult <> 0
      then Begin
             ShLog.Log(TLogger.ERROR, 'record: Failed to write recorded '
                       + 'inputs to ' + ROutFilename);
             Close(RecordOutF);
             Exit;
           End;

    For Flag in Recorder.RecdInps do Writeln(RecordOutF, Flag);

    Close(RecordOutF);

    ShLog.Log(TLogger.INFO, 'record: Input record has been written to '
              + ROutFilename + '.');
End;
