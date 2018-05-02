Release Notes for Timmy 1.1.0
=============================

What is Timmy?
--------------
Timmy is a Pascal unit for creating chat bots. It provides the `TTimmy` object, which is a data type that you can assign your variables to to make bots. Once that is done, you can start adding keywords for questions, and get the bot answers to the end user's questions.

What's in this release?
----------------------------
This stable release (1.1.0) provides the `TTimmy` object with 3 ways to add keywords clues, and 4 ways to remove keywords clues, along with `TStrArray` - Array of String, and several helper functions like `StrSplit` and `StrTrim` that aren't part of the `TTimmy` object. See the included README file to know all what this Timmy release offers.

Change log (from 1.0.0 to 1.1.0)
--------------------------------
- Overload two more `TTimmy.Remove()`
- Add examples (see them in the `examples` folder)
- Put Release Notes in RELEASE.md

What new features will be in the next _major_ release?
------------------------------------------------------
> **Disclaimer**: We do not know exactly what will the next major release offers, we are just expecting.

This release (1.1.0) provides primitive functions that you can do just about anything with it. However, there are a few inconveniences. For example, a typical "What is" question may vary, like "What is GitHub?", "What is an apple?" and "What is FooBar?". To handle that, you may have to add (using `TTimmy.Add()`) multiple times, each time for a different object.

```pascal
Uses timmy;
Var Bot: TTimmy;

Begin
    Bot.Init;
    Bot.Add('What is GitHub', 'GitHub is a platform for developers.');
    Bot.Add('What is apple', 'It''s a thing.');
    Bot.Add('What is FooBar', 'Some string that programmers particularly like.');
End.
```

This is an inconvenient, and in the next release, we hope to solve this problem by making `TTimmy` aware of certain question structures/types like What questions, Who questions, etc...Developers using Timmy in their programs can add their own question structures too!

Also, there are questions whose answers may vary over time. For example, "What time is it?". Again, for such questions, you can use the primitive functions of `TTimmy` to help you deal with that. You can do a `Remove` and then `Add` again, like the program below.

```pascal
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
```

It is inconvenient (and somewhat ugly) to do that, however. In our next major release, we seek to offer custom functions/procedures: Developers using this library can throw `TTimmy` their custom function (or procedure) and the bot will execute that function (or procedure). Timmy won't be a Pascal unit for _chat_ bots anymore, then.

License
-------
![License logo](https://www.gnu.org/graphics/lgplv3-147x51.png)

Users of this library are bound to the GNU LGPL v3.0 license.
