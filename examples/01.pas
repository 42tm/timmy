{
    Timmy example 1: The basics
    Original author: Nguyen Hoang Duong (@NOVAglow).
    This example is similar to the one demonstrated in the README file.

    This simple example demonstrates the basic usage of Timmy, which involves
    declaring a TTimmy type, initiating the bot, add data and get the bot
    to response some messages.
}
Program TimmyExample1;
Uses timmy in '../timmy.pas';
Var MyBot: TTimmy;

BEGIN
    MyBot.Init(70, 'I gave up', False);
    MyBot.Add(StrSplit('Hello', ' '), StrSplit('Greetings!|Hello to you!|Hi!', '|'));
    MyBot.Add('How are you', 'I am fine!;Never better!;I''m doing great.');

    Writeln(MyBot.Answer('Hello!'));  // -> "Greetings!" or "Hello to you!" or "Hi!" (randomly selected)
    Writeln(MyBot.Answer('How are you?'));  // -> "I am fine!" or "Never better!" or "I'm doing great."
    Writeln(MyBot.Answer('What is 2 + 2?'));  // -> "The answer is 4"
    Writeln(MyBot.Answer('What is the meaning of life?'));  // -> "I gave up"
END.
