{$mode ObjFPC}
Unit Logger;

Interface

Uses Crt, SysUtils, StrUtils, Timmy in '../../timmy.pas';
Type TLogger = Object
                 Constructor Init(ACslOutMin: Integer = 0;
                                  AFileOutMin: Integer = -1; ALogPath: String = '');
               Public
                 LeadingStr: String;
                 CslOutMin: Integer;
                 FileOutMin: Integer;
                 Procedure SetLogFilePath(LogFilePath: String);
                 Procedure Log(Severity: Integer; LogMsg: String);
               Private
                 LogPath: String;
               Public Const
                 INFO = 0;
                 LIGHTWARNING = 10;
                 WARNING = 20;
                 ERROR = 30;
                 CRITICAL = 40;
                 FATAL = 50;
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

Constructor TLogger.Init(ACslOutMin: Integer = 0;
                         AFileOutMin: Integer = -1; ALogPath: String = '');
Begin
    CslOutMin := ACslOutMin;
    FileOutMin := AFileOutMin;
    LogPath := ALogPath;
    LeadingStr := '';

    If (not CreateFile(ALogPath)) then FileOutMin := -1;
End;

Procedure TLogger.SetLogFilePath(LogFilePath: String);
Begin
    If (not CreateFile(LogFilePath)) then Exit;

    LogPath := LogFilePath;
End;

Procedure TLogger.Log(Severity: Integer; LogMsg: String);
Var CslMsgColor: Integer;
    F: Text;
Begin
    If (Severity >= CslOutMin) and (CslOutMin > -1)
      then Begin
             Case Severity of
               0..9: CslMsgColor := 15;
               10..19: CslMsgColor := 6;
               20..29: CslMsgColor := 14;
               30..39: CslMsgColor := 4;
               40..49: CslMsgColor := 20
               Else CslMsgColor := 12;
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

End.
