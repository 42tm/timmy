Program TimeBot;
Uses SysUtils, timmy;
Var TmBot: TTimmy;
    UserIn: String;

Begin
    TmBot.Init;
    TmBot.Add('Hello', 'Greetings!;Hi!;Welcome back!');
    TmBot.Add('Count 1 to 10', '1 2 3 4 5 6 7 8 9 10');
    TmBot.Add('Exit', 'Goodbye!');
    
    UserIn := '';
    While LowerCase(UserIn) <> 'exit'
      do Begin
           Write('>> ');
           Readln(UserIn);
           TmBot.Remove(StrSplit('What time', ' '));
           TmBot.Add('What time', DateTimeToStr(Now));
           Writeln('TimeBot: ' + TmBot.Answer(UserIn));
         End;
End.
