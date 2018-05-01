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
    MONTHSALIAS: Array[1..12] of String = ('jan', 'feb', 'mar', 'apr', 'may', 'jun',
                                           'jul', 'aug', 'sep', 'oct', 'nov', 'dec');
Var
    PP: TTimmy;  // Bot instance
    BDays: Array of String;  // Array holding birthdays data in form of strings
    UserCmd: String;  // User's input to the bot

{
    Convert the alias of a month's name to its (full) name
    and return the alias, or the month's full name to its alias name.
    In case the input is invalid, an empty string is returned.
    Not case-sensitive.
    Examples: - ConvertName('aug') = 'August'
              - ConvertName('April') = 'apr'
              - ConvertName('Oct') = 'October'
              - ConvertName('january') = 'jan'
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
    Given a date string in form of date-month (month's name in alias),
    return true if it's today.
}
Function Today(DateStr: String): Boolean;
Begin
    DateStr := LowerCase(DateStr);
    If ( StrSplit(DateStr, '-')[0] = StrSplit(DateToStr(Now), '-')[0] )
       and ( LowerCase(StrSplit(DateStr, '-')[1]) = MONTHSALIAS[StrToInt(StrSplit(DateToStr(Now), '-')[1])] )
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
    Add birthday to array BDays.
    Needs user's command to get the person's name and his/her birthday.
    Returns bot's reply to use with Add().
}
Function AddBDays(UserMsg: String): String;
Begin

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
    Given a user's message, attempts to convert it to the bot's language so that
    the bot "understands" the message.
    This requires removing words that the bot does not understand and convert
    month names to their aliases.
}
Function ProcessedMsg(UserMessage: String): String;
Var Month: String;
Begin
    ProcessedMsg := LowerCase(UserMessage);
    For Month in MONTHS
      do ProcessedMsg := StringReplace(ProcessedMsg,
                                       Month,
                                       LowerCase(Copy(Month, 1, 3)), []);

End;

BEGIN
    // Setting up the bot
    PP.Init;
    PP.TPercent := 40;
    PP.NoUdstdRep := 'Uhhh...I don''t understand. I''m just a bot after all';
    PP.Add('list bdays', GetBDaysStr);

    // Begin user session
    While True
      do Begin
         End;
END.
