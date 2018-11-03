{
    Timmy example 3: Using pointers with Timmy
    Original author: Nguyen Hoang Duong (@NOVAglow).

    This example demonstrates the use of pointers in Timmy,
    or more specifically , TTimmy.Add().
}
Program TimmyExample3;
Uses Timmy in '../timmy.pas';
Var MyBot: TTimmy;
    MyString: AnsiString;
    PMyStr: PStr;

BEGIN
    MyString := 'asdf';
    PMyStr := @MyString;

    MyBot.Init(50, 'Question not understood :/', False);
    MyBot.Add('what my string', PMyStr);
    Writeln(MyBot.Answer('what is my string?'));  // -> 'asdf'

    MyString := 'something else';  // Changing MyString, not PMyStr or PMyStr^
    Writeln(MyBot.Answer('what is my string?'));  // -> 'something else'
END.
