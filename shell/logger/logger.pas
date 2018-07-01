{
    logger.pas - Logger component for Timmy Interactive Shell

    Copyright (C) 2018 42tm Team <fourtytwotm@gmail.com>

    This file is part of Timmy Interactive Shell.

    Timmy Interactive Shell is free software: you can redistribute it
    and/or modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation, either version 3
    of the License, or (at your option) any later version.
}
{$mode ObjFPC} {$H+}
Unit Logger;

Interface

Uses
    Crt, SysUtils, StrUtils,
    Timmy in '../../timmy.pas';
Type
    TLogger = Object
                Constructor Init(ACslOutMin: Integer = 0;
                                 AFileOutMin: Integer = -1;
                                 ALogPath: String = '');
                Public
                  LeadingStr: String;   // The first string in the console output
                  CslOutMin: Integer;   // Minimum level of logging for console output
                  FileOutMin: Integer;  // Minimum level of logging for file output
                  Procedure SetLogFilePath(LogFilePath: String);
                  Procedure Log(Severity: Integer; LogMsg: String);               overload;
                  Procedure Log(Severity: Integer; LogMsgArray: Array of String); overload;
                  Procedure Put(Severity: Integer; Msg: String);                  overload;
                  Procedure Put(Severity: Integer; MsgArray: Array of String);    overload;
                  Procedure Enable;
                  Procedure Disable;
                Private
                  LogPath: String;
                  Enabled: Boolean;
                  Function PickColor(LLevel: Integer): Byte;
                  Function TimeNow: String;
                Public Const
                  CORRECT = 0;
                  INFO = 10;
                  LIGHTWARNING = 20;
                  WARNING = 30;
                  ERROR = 40;
                  CRITICAL = 50;
                  FATAL = 60;
              End;

Function CreateFile(FilePath: String): Boolean;

Implementation

{
    Create a new file. If the file exists, do nothing.

    If directory path is also given, check if the directory exists.
    If it doesn't, exit without creating a file.

    Parameter:
        FilePath [String]: File name (or path) to create

    Return [Boolean]:
        True if operation success
        False if directory does not exist (if given) or IOResult is not 0
}
Function CreateFile(FilePath: String): Boolean;
Var FileName: String;
    F: Text;
Begin
    If Pos(PathDelim, FilePath) = 0
      then FileName := FilePath
      else Begin
             FileName := Copy(FilePath,
                              Length(FilePath) - Pos(PathDelim, ReverseString(FilePath)) + 1,
                              Pos(PathDelim, ReverseString(FilePath)) - 1);
             If not DirectoryExists(Copy(FilePath, 1, Length(FilePath) - Length(FileName) - 1))
               then Exit(False);
           End;

    If (not FileExists(FilePath))
      then Begin
             Assign(F, FilePath);
             {$I-}
             Rewrite(F);
             {$I+}
             If IOResult <> 0 then Exit(False);
             Close(F);
           End;

    Exit(True);
End;

{
    Initiate the logger

    Parameters:
      ACslOutMin: The minimum level for the logger to write log to console
      AFileOutMin: The minimum level for the logger to write log to log file
      ALogPath: The path of the log file to write to
}
Constructor TLogger.Init(ACslOutMin: Integer = 0;
                         AFileOutMin: Integer = -1; ALogPath: String = '');
Begin
    CslOutMin := ACslOutMin;
    FileOutMin := AFileOutMin;
    LogPath := ALogPath;
    LeadingStr := '';
    If (not CreateFile(ALogPath)) then LogPath := '';
    Enabled := True;
End;

{ Procedure to enable the logger }
Procedure TLogger.Enable;
Begin Enabled := True; End;

{ Procedure to disable the logger }
Procedure TLogger.Disable;
Begin Enabled := False; End;

{
    Set path of file to write output to.

    The function uses CreateFile(), so that means if the specified log file
    does not exist, it will be created. If parent directory's path is given
    and it does not exist, no file will be created, and TLogger.LogPath
    remains the same.

    Parameter:
        LogFilePath [String]: Path of log file to write log messages to
}
Procedure TLogger.SetLogFilePath(LogFilePath: String);
Begin
    If (not CreateFile(LogFilePath)) then Exit;

    LogPath := LogFilePath;
End;


{
    Color of log message output to console, depending
    on the severity of the event, given as LLevel.

    Parameter:
        LLevel [Integer]: Severity of event, to determine the right text color
    Return [Byte]:
        The value of the text color corresponds to the given event severity
}
Function TLogger.PickColor(LLevel: Integer): Byte;
Begin
     Case LLevel of
       0..9:   Exit(10);
       10..19: Exit(15);
       20..29: Exit(6);
       30..39: Exit(14);
       40..49: Exit(12);
       50..59: Exit(28);
       Else Exit(4);
     End;
End;

{
    Return the leading string for writing to log file, which is
    the current time in the format [hh:mm:ss dd/mm/yy]
}
Function TLogger.TimeNow: String;
Begin
    Exit('['
       + StrSplit(DateTimeToStr(Now), ' ')[1]
       + ' ' + StrJoin(
                       StrSplit(
                                StrSplit(DateTimeToStr(Now), ' ')[0],
                                '-'
                               ),
                       '/')
       + '] ' );
End;

{
    Log

    Parameters:
      Severity [Integer]: The severity of the event that needs logging
      LogMsg [String]: The log message
}
Procedure TLogger.Log(Severity: Integer; LogMsg: String);
Var
    F: Text;
Begin
    If (Severity >= CslOutMin) and (CslOutMin > -1)
      then Begin
             TextColor(PickColor(Severity));
             Writeln(LeadingStr + LogMsg);
           End;

    If (Severity >= FileOutMin) and (FileOutMin > -1) and (LogPath <> '')
      then Begin
             Assign(F, LogPath);
             {$I-}
             Append(F);
             {$I+}
             If IOResult = 0
               then Writeln(F, TimeNow + LogMsg)
               else Begin
                      Put(TLogger.ERROR, 'logger: Failed to write to log file');
                      Exit;
                    End;
             Close(F);
           End;
End;

{
    Log, but this one takes an array of strings instead of a string.

    Parameters:
      Severity [Integer]: The severity of the event that needs logging
      LogMsgArray [Array of String]: Strings appended to make the log message
}
Procedure TLogger.Log(Severity: Integer; LogMsgArray: Array of String);
Var
    StrIter: String;
    F: Text;
Begin
     If (Severity >= CslOutMin) and (CslOutMin > -1)
       then Begin
              TextColor(PickColor(Severity));
              For StrIter in LogMsgArray do Write(StrIter);
              Writeln;
            End;

    If (Severity >= FileOutMin) and (FileOutMin > -1) and (LogPath <> '')
      then Begin
             Assign(F, LogPath);
             {$I-}
             Append(F);
             {$I+}
             If IOResult = 0
               then Begin
                      Write(F, TimeNow);
                      For StrIter in LogMsgArray do Write(F, StrIter);
                      Writeln(F);
                    End
               else Begin
                      Put(TLogger.ERROR, 'logger: Failed to write to log file');
                      Exit;
                    End;
             Close(F);
           End;
End;

{
    Print out a message to the console with text color
    that hints the severity, regardless of CslOutMin.

    Parameters:
      Severity [Integer]: The severity of the event that needs to be informed
      Msg [String]: String to be printed
}
Procedure TLogger.Put(Severity: Integer; Msg: String);
Begin
    TextColor(PickColor(Severity));
    Writeln(Msg);
End;

{
    The same as the above implementation, which writes any thing to console
    regardless of CslOutMin, but this one takes a array of string instead of
    a string.

    Parameters:
      Severity [Integer]: The severity of the event that needs to be informed
      MsgArray [Array of String]: Strings appended to make the output message
}
Procedure TLogger.Put(Severity: Integer; MsgArray: Array of String);
Var
    StrIter: String;
Begin
    TextColor(PickColor(Severity));
    For StrIter in MsgArray do Write(StrIter);
    Writeln;
End;

End.
