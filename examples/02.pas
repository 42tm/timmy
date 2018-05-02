{
    Timmy example 2: Birthday bot
    Original author: Nguyen Hoang Duong (@NOVAglow).

    This is a simple birthday bot, made possible with the Timmy library plus
    some manual Pascal instructions.

    This example demonstrates:
    - Use of StrSplit function provided by the Timmy unit
    - Passing function as argument in TTimmy.Add()
    - Removing using index (TTimmy.Remove())
    - Power of removing and adding the same set of keywords again

    The main thing is demonstrated clearly in the main program.

    ============
    INSTRUCTIONS
    ============

    Note:
        Things inside square brackets ("[]") are optional,
        Things inside the pipes ("||") are different possibilities
        This bot can't help if you type something wrong (e.g. plural instead of
        singular, past form instead of present form...). It's a bot, not an AI.

    Adding a birthday
    -----------------
    PERSON_NAME['s] |birthday/bday| is [on] |MONTH/MONTH_ALIAS| |DATE|
    PERSON_NAME['s] |birthday/bday| is [on] |DATE| |MONTH/MONTH_ALIAS|

    Examples: - "John birthday is 12 October"
              - "Mom's birthday is on Dec 9"
              - "My friend bday is 10 Apr"
              - "my birthday is on today"

    Note: To add your own birthday, type "my" instead of "My" or anything else.

    Removing a birthday
    -------------------
    forget PERSON_NAME['s] [|bday/birthday|]

    Examples: - forget Liz's bday
              - forget the person I hate birthday

    See all birthdays
    -----------------
    list |bdays/birthdays|
}
Program TimmyExample2;
Uses SysUtils, timmy in '../src/timmy.pas';
Const
    MONTHS: Array[1..12] of String = ('January', 'February', 'March', 'April', 'May', 'June',
                                      'July', 'August', 'September', 'October', 'November', 'December');
    MONTHSALIAS: Array[1..12] of String = ('jan', 'feb', 'mar', 'apr', 'may', 'jun',
                                           'jul', 'aug', 'sep', 'oct', 'nov', 'dec');
    MONTHSNDAYS: Array[1..12] of Integer = (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
    DEFAULTREP = 'Uhhh...I don''t understand. I''m just a bot after all';
Var
    PP: TTimmy;  // Bot instance
    BDays: Array of String;  // Array holding birthdays data in form of strings
    UserCmd: String;  // User's input to the bot
    Entry: String;  // Iterator for BDays in main program

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
    Given a date string in form of date-month (month's name is alias),
    return true if it's today.
}
Function IsToday(DateStr: String): Boolean;
Begin
    DateStr := LowerCase(DateStr);
    If ( StrSplit(DateStr, '-')[0] = StrSplit(DateToStr(Now), '-')[0] )
       and ( LowerCase(StrSplit(DateStr, '-')[1]) = MONTHSALIAS[StrToInt(StrSplit(DateToStr(Now), '-')[1])] )
    then Exit(True)
    else Exit(False);
End;

{
    Return today's date in the format date-month_alias
}
Function Today: String;
Begin
    Exit(StrSplit(DateToStr(Now), '-')[0] + '-' + MONTHSALIAS[StrToInt(StrSplit(DateToStr(Now), '-')[1])]);
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
    Close(BDaysDataF);
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
    ProcessedMsg := UserMessage;
    For Month in MONTHS
      do ProcessedMsg := StringReplace(ProcessedMsg,
                                       Month, LowerCase(Copy(Month, 1, 3)),
                                       [rfReplaceAll, rfIgnoreCase]);
    ProcessedMsg := StringReplace(ProcessedMsg,
                                  'today',
                                  StrSplit(Today, '-')[0] + ' ' + StrSplit(Today, '-')[1],
                                  [rfReplaceAll, rfIgnoreCase]);
    ProcessedMsg := StringReplace(ProcessedMsg,
                                  'birthday', 'bday',
                                  [rfReplaceAll, rfIgnoreCase]);
    ProcessedMsg := StringReplace(ProcessedMsg,
                                  'birthdays', 'bdays',
                                  [rfReplaceAll, rfIgnoreCase]);
    ProcessedMsg := StringReplace(ProcessedMsg,
                                  '''s', '',
                                  [rfReplaceAll, rfIgnoreCase]);
    ProcessedMsg := StringReplace(ProcessedMsg,
                                  ' on', '',
                                  [rfReplaceAll, rfIgnoreCase]);
    ProcessedMsg := StringReplace(ProcessedMsg,
                                  ' of', '',
                                  [rfReplaceAll, rfIgnoreCase]);
End;

{
    Add birthday to array BDays.
    Needs user's command to get the person's name and his/her birthday.
    Returns bot's reply to use with Add().
}
Function AddBDay(UserMsg: String): String;
Var
    Iter: Integer;
    WIter: String;
    PersonName, BirthDate, BirthMonth: String;
Begin
    PersonName := '';

    // Get person's name
    For WIter in StrSplit(UserMsg, ' ') do Begin
                                             If LowerCase(WIter) = 'bday'
                                             then Break;
                                             PersonName := PersonName + WIter + ' ';
                                           End;
    Delete(PersonName, Length(PersonName), 1);
    If PersonName = '' then Exit(DEFAULTREP);

    // Get birthdate & birth month
    BirthDate := LowerCase(StrSplit(UserMsg, ' ')[Length(StrSplit(UserMsg, ' ')) - 1]);
    BirthMonth := LowerCase(StrSplit(UserMsg, ' ')[Length(StrSplit(UserMsg, ' ')) - 2]);
    If Length(StrSplit(UserMsg, ' ')[Length(StrSplit(UserMsg, ' ')) - 1]) = 3
    then Begin
           BirthMonth := BirthDate + BirthMonth;
           BirthDate := Copy(BirthMonth, 4, Length(BirthMonth) - 3);
           BirthMonth := Copy(BirthMonth, 1, 3);
         End;

    // Check if birth date and birth month are valid
    While BirthDate[1] = '0' do Delete(BirthDate, 1, 1);  // Removing leading 0s
    AddBDay := '';  // Utilizing the function value so we don't need another local variable
    For WIter in MONTHSALIAS do If WIter = BirthMonth then AddBDay := AddBDay + ' ';
    If Length(AddBDay) <> 1 then Exit('It seems like there''s no month called ' + BirthMonth + '.');
    For Iter := 1 to 12 do Begin
                             If BirthMonth = MONTHSALIAS[Iter]
                             then Begin AddBDay := IntToStr(Iter); Break; End;
                           End;

    // Check if the birth date is valid for the month
    If (StrToInt(BirthDate) < 1) or (StrToInt(BirthDate) > MONTHSNDAYS[StrToInt(AddBDay)])
    then Exit('Umm...Are you sure that ' + ConvertName(BirthMonth)
              + ' has the day ' + BirthDate + '?');

    // Add birthday to bot's data (array BDays) and exit with a confirmation
    SetLength(BDays, Length(BDays) + 1);
    BDays[Length(BDays) - 1] := PersonName + '@' + BirthDate + '-' + BirthMonth;
    If PersonName = 'my'
    then Exit('Okay, your birthday is on ' + BirthDate + ' of ' + ConvertName(BirthMonth) + '.')
    else Exit('Okay, ' + PersonName + '''s birthday is on ' + BirthDate + ' of ' + ConvertName(BirthMonth) + '.');
End;

{
    Given a user message with the command 'forget',
    remove the birthday from bot's database.
}
Function ForgetBDay(UserMsg: String): String;
Var Iter, AIter: Integer;
    PersonName: String;
Begin
    If Length(BDays) = 0 then Exit('You haven''t add the birthday of anyone yet.');

    PersonName := '';
    For Iter := 1 to Length(StrSplit(UserMsg, ' ')) - 2
      do PersonName := PersonName + StrSplit(UserMsg, ' ')[Iter] + ' ';

    Delete(PersonName, Length(PersonName), 1);
    For Iter := Low(BDays) to High(BDays)
      do If PersonName = StrSplit(BDays[Iter], '@')[0] then Break;

    If (Iter = High(BDays)) and (StrSplit(BDays[Iter], '@')[0] <> PersonName)
    then Exit('It seems'' like you haven''t add this person''s birthday yet.');

    For AIter := Iter to High(BDays) - 1 do BDays[AIter] := BDays[AIter + 1];
    SetLength(BDays, Length(BDays) - 1);
    If PersonName = 'my'
    then Exit('Okay, I forgot your birthday.')
    else Exit('No problem, I forgot this person''s birthday.');
End;

{
    Save the data and exit.
}
Procedure BotExit;
Var Iter: Integer;
    BDaysDatF: Text;
Begin
    If FileExists('bdays.txt') then DeleteFile('bdays.txt');
    Assign(BDaysDatF, 'bdays.txt');
    {$I-}
    Rewrite(BDaysDatF);
    {$I+}
    If IOResult <> 0 then Begin
                            Writeln('ERROR: Failed to save data to bdays.txt.');
                            Writeln('Goodbye!'); Halt;
                          End;
    For Iter := Low(BDays) to High(BDays) do Writeln(BDaysDatF, BDays[Iter]);
    Close(BDaysDatF);
    Writeln('Goodbye!'); Halt;
End;

{
    Compose the birthday strings (including the names)
    into one string to print out. This string includes break line.
}
Function GetBDaysStr: String;
Var BDay: String;
Begin
    GetBDaysStr := '';
    For BDay in BDays
      do GetBDaysStr := GetBDaysStr
                        + StrSplit(BDay, '@')[0] + ': '  // Name
                        + StrSplit(StrSplit(BDay, '@')[1], '-')[0] + ' '  // Birth date
                        + ConvertName(StrSplit(StrSplit(BDay, '@')[1], '-')[1])  // Birth month (full, not alias)
                        + sLineBreak;  // Break line/Linefeed
    Delete(GetBDaysStr, Length(GetBDaysStr), 1);
End;

BEGIN
    If (ParamStr(1) = '--help') or (ParamStr(1) = '-h') or (ParamStr(1) = '?')
    then Begin
           Writeln('Birthday Bot (example 2 of Timmy unit)');
           Writeln;
           Writeln('[ ]: Optional, | |: Can be any');
           Writeln;
           Writeln('Add a birthday: PERSON_NAME[''s] |birthday/bday| is [on] |MONTH/MONTH_ALIAS| |DATE|'
                 + sLineBreak
                 + '                PERSON_NAME[''s] |birthday/bday| is [on] |DATE| |MONTH/MONTH_ALIAS|');
           Writeln('Remove a birthday: forget PERSON_NAME[''s] [|bday/birthday|]');
           Writeln('List all saved birthdays: list |bdays/birthdays|');
           Halt;
         End;

    // Setting up the bot
    PP.Init;
    PP.TPercent := 30;
    PP.NoUdstdRep := DEFAULTREP;
    PP.Add('hello', 'Greetings!;Hi!;Nice to see you!');
    PP.Add('hi', 'Greetings!;Hi!;Nice to see you!');
    PP.Add('how are you', 'I''m fine! Now, how can I help you?');
    PP.Add('yes', 'That''s what I thought.');
    PP.Add('no', 'Okay then.');

    FetchBDays;
    // Check if today is someone's birthday
    For Entry in BDays
      do If IsToday(StrSplit(Entry, '@')[1])
         then Begin
                If StrSplit(Entry, '@')[0] = 'my'
                then Writeln('Hooray! It''s your birthday today!'
                             + ' Happy birthday!')
                else Writeln('Let''s party! Today is '
                             + StrSplit(Entry, '@')[0] + '''s birthday!');
              End;


    // Begin user session
    While True
      do Begin
           Write('>> '); Readln(UserCmd);
           UserCmd := ProcessedMsg(UserCmd);
           Entry := LowerCase(StrSplit(UserCmd, ' ')[0]);
           Case Entry of
               'list': If Length(BDays) = 0
                       then Begin
                              Writeln('There''s no birthday to list. Add one now!');
                              Continue;
                            End
                       else Begin
                              PP.Remove(5);
                              PP.Add('list bdays', GetBDaysStr);
                            End;
               'forget': Begin
                           PP.Remove(5);
                           PP.Add('forget', ForgetBDay(UserCmd));
                         End;
               'exit', 'goodbye', 'quit': BotExit;
               else Begin
                      PP.Remove(5);
                      PP.Add('bday is', AddBDay(UserCmd));
                    End;
           End;
           Writeln(PP.Answer(UserCmd));
         End;
END.
