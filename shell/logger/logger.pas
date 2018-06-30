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
    Timmy_Debug in '../../variants/timmy_debug.pas';
Type TLogger = Object
                 Constructor Init(ACslOutMin: Integer = 0;
                                  AFileOutMin: Integer = -1; ALogPath: String = '');
               Public
                 LeadingStr: String;
                 CslOutMin: Integer;
                 FileOutMin: Integer;
                 Procedure SetLogFilePath(LogFilePath: String);
                 Procedure Log(Severity: Integer; LogMsgArray: Array of String);
                 Procedure Put(Severity: Integer; MsgArray: Array of String);
                 Procedure Enable;
                 Procedure Disable;
               Private
                 LogPath: String;
                 Enabled: Boolean;
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
Const DIRDELIM = {$IFDEF MSWINDOWS} '\' {$ELSE} '/' {$ENDIF};

Implementation

{
    Create a new file. If the file exists, do nothing.

    If directory path is also given, check if the directory exists.
    If it doesn't, exit without creating a file.

    Return: True if operation success
            False if directory does not exist (if given) or IOResult is not 0
}
Function CreateFile(FilePath: String): Boolean;
Var FileName: String;
    F: Text;
Begin
    If Pos(DIRDELIM, FilePath) = 0
      then FileName := FilePath
      else Begin
             FileName := Copy(FilePath,
                              Length(FilePath) - Pos(DIRDELIM, ReverseString(FilePath)) + 1,
                              Pos(DIRDELIM, ReverseString(FilePath)) - 1);
             If not DirectoryExists(Copy(FilePath, 1, Length(FilePath) - Length(FileName) - 1))
               then Begin
                      Exit(False);
                    End;
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
}
Procedure TLogger.SetLogFilePath(LogFilePath: String);
Begin
    If (not CreateFile(LogFilePath)) then Exit;

    LogPath := LogFilePath;
End;

{
    Log

    Parameters:
      Severity [Integer]: The severity of the event that needs logging
      LogMsgArray [Array of String]: Strings appended to make the log message
}
Procedure TLogger.Log(Severity: Integer; LogMsgArray: Array of String);
Var
    LogMsg, StrIter: String;
    CslMsgColor: Byte;
    F: Text;
Begin
    LogMsg := '';
    For StrIter in LogMsgArray do LogMsg := LogMsg + StrIter;

    If (Severity >= CslOutMin) and (CslOutMin > -1)
      then Begin
             Case Severity of
               0..9: CslMsgColor := 10;
               10..19: CslMsgColor := 15;
               20..29: CslMsgColor := 6;
               30..39: CslMsgColor := 14;
               40..49: CslMsgColor := 12;
               50..59: CslMsgColor := 28;
               Else CslMsgColor := 4;
             End;
             TextColor(CslMsgColor);
             Writeln(LeadingStr + LogMsg);
           End;

    If (Severity >= FileOutMin) and (FileOutMin > -1) and (LogPath <> '')
      then Begin
             Assign(F, LogPath);
             {$I-}
             Append(F);
             {$I+}
             If IOResult = 0
             then Writeln(F, '[' + StrSplit(DateTimeToStr(Now), ' ')[1]
                             + ' ' + StrJoin(
                                       StrSplit(
                                         StrSplit(DateTimeToStr(Now), ' ')[0],
                                                '-'),
                                                     '/')
                             + '] ' + LogMsg);
             Close(F);
           End;
End;

{
    Print out a message to the console with text color
    that hints the severity, regardless of CslOutMin.
}
Procedure TLogger.Put(Severity: Integer; MsgArray: Array of String);
Var
    Str: String;
    MsgColor: Byte;
Begin
    Case Severity of
      0..9: MsgColor := 10;
      10..19: MsgColor := 15;
      20..29: MsgColor := 6;
      30..39: MsgColor := 14;
      40..49: MsgColor := 12;
      50..59: MsgColor := 28;
      Else MsgColor := 4;
    End;

    TextColor(MsgColor);
    For Str in MsgArray do Write(Str);
    Writeln;
End;

End.
