{
    Timmy example 2: Birthday bot
    Original author: Nguyen Hoang Duong (@NOVAglow).

    This is a simple birthday bot, made possible with the Timmy library plus
    some manual Pascal instructions.
}
Program TimmyExample2;
Uses SysUtils, timmy in '../src/timmy.pas';
Const
    MONTHS: Array[1..12] of String = ('January', 'February', 'March', 'April', 'May', 'June',
                                      'July', 'August', 'September', 'October', 'November', 'December');
    MONTHSALIAS: Array[1..12] of String = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                           'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
Var
    PP: TTimmy;  // Bot instance
    BDays: Array of String;

{
    Convert the alias of a month's name to its (full) name
    and return the alias, or the month's full name to its alias name.
    Not case-sensitive.
    Example: - ConvertName('Aug') = 'August'
             - ConvertName('Oct') = 'October'
             - ConvertName('something else') = ''
}
Function ConvertName(MonthName: String):String;
Var Mon: Integer;
Begin
    MonthName := LowerCase(MonthName);
    If Length(MonthName) = 3  // Check if input is alias instead of full name
    then For Mon := 1 to 12 do If LowerCase(MONTHSALIAS[Mon]) = MonthName
                               then Exit(MONTHS[Mon]);
    For Mon := 1 to 12 do If LowerCase(MONTHS[Mon]) = MonthName
                          then Exit(MONTHSALIAS[Mon]);
    Exit('');
End;

{
    Given a date string in form of date-month (all lowercase, month's name in alias),
    return true if it's today.
}
Function Today(DateStr: String): Boolean;
Begin
    If ( StrSplit(DateStr, '-')[0] = StrSplit(DateToStr(Now), '-')[0] )
       and ( LowerCase(StrSplit(DateStr, '-')[1]) = LowerCase(MONTHSALIAS[StrToInt(StrSplit(DateToStr(Now), '-')[1])]) )
    then Exit(True)
    else Exit(False);
End;

{
    Fetch birthdays data from file.
    Each line in the file is in format PERSON_NAME@DAY-MONTH_ALIAS
    (example: 'John Doe@20-feb')
}
Procedure FetchBDays;
Var BDaysDataF: Text;
    Line: String;
Begin
    SetLength(BDays, 0);
    Assign(BDaysDataF, 'bdays.txt');
    {$I-}
    Reset(BDaysDataF);
    {$I+}
    If IOResult <> 0 then Exit;
    While not EOF(BDaysDataF)
      do Begin
           SetLength(BDays, Length(BDays) + 1);
           Readln(BDaysDataF, Line);
           Bdays[Length(BDays) - 1] := Line;
         End;
End;

{
    Compose the birthday strings (including the names)
    into one string to print out. This string includes linefeed (ASCII 10).
}
Function GetBDaysStr: String;
Var BDay: String;
Begin
    GetBDaysStr := '';
    For BDay in BDays
      do GetBDaysStr := StrSplit(BDay, '@')[0] + ': '  // Name
                        + StrSplit(StrSplit(BDay, '@')[1], '-')[0] + ' '  // Birth date
                        + ConvertName(StrSplit(StrSplit(BDay, '@')[1], '-')[1])  // Birth month (full, not alias)
                        + #10;  // Break line/Linefeed
End;

{
    Replace full words with aliases and words that the bot understands.
}
Function ProcessedMsg(UserMessage: String): String;
Begin
    ProcessedMsg := LowerCase(UserMessage);
    For Month in MONTHS do ProcessedMsgStringReplace(ProcessedMsg, Month, LowerCase(Copy(Month, 1, 3)), []);
End;

BEGIN
    // Setting up the bot
    PP.Init;
    PP.NoUdstdRep := 'Uhhh...I don''t understand. I''m just a bot after all';
    PP.Add('list bdays', GetBDaysStr);

    // Begin user session
    While True
      do Begin
         End;
END.
