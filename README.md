Timmy
=====

Timmy is a Pascal unit (i.e. library) for creating chat bots.
Creating bots with Timmy is as easy as 1 2 3.

How to create a bot with Timmy
------------------------------

1. Declare `timmy` unit
2. Declare a `TTimmy` variable
3. Initialize your `TTimmy`
4. Add some keywords for your messages, and possible replies to those messages
5. Start answering

Example program
---------------

```pascal
Program MyFirstBot;
Uses timmy;
Var MyBot: TTimmy;

BEGIN
    MyBot.Init;
    MyBot.NoUdstdRep := 'I gave up.';
    MyBot.Add(StrSplit('Hello', ' '), StrSplit('Greetings!|Hello to you!|Hi!', '|'));
    MyBot.Add('How are you', 'I am fine!;Never better!;I''m doing great.');
    MyBot.Add('What 2 + 2', 'The answer is 4', ' ', '@');

    Writeln(MyBot.Answer('Hello!'));
    Writeln(MyBot.Answer('How are you?'));
    Writeln(MyBot.Answer('What is 2 + 2?'));
    Writeln(MyBot.Answer('What is the meaning of life?'));
END.
```

If we compile and execute the program, we should get something like this as the output:
```
Hi!
I'm doing great
The answer is 4
I gave up.
```

Variables of `TTimmy`
---------------------

|Name|Type|Description|Notes|
|:---:|:---:|---|---|
|`Initialized`|Boolean|The state of initialization. Is true if you've done `.Init`.|**Do not set the value of this variable manually.**|
|`Enabled`|Boolean|Determine if the bot is enabled. Acts like `Initialized` but at a smaller scale.|You can manually set the value of this variable. If you set it to `False`, you should not add or remove data in between the bot's saved message keywords and replies, and you should not let the bot answers any message, until you set `Enabled` to `True` again. Upon bot initialization (`.Init`), the value for this variable is set to `True`.|
|`NOfEntries`|Integer|The number of elements in `MKeywordsList` (or `ReplyList`).|**Do not set the value of this variable manually.**|
|`MKeywordsList`|Dynamic matrix of strings|Array holding keywords for messages. This is an array of arrays. Each array inside `MKeywordsList` contains keywords for a message.|**Do not set the value of this variable manually.**|
|`ReplyList`|Dynamic matrix of strings|Just like `MKeywordsList` but for replies instead of keywords.|**Do not set the value of this variable manually.**|
|`DupesCheck`|Boolean|If set to `True`, the bot will check `MKeywordsList` when performing a `.Add`. If an array in `MKeywordsList` matches with `MKeywords` (parameter of `Add` function), the `Add` routine will halt.|You can set the variable to `True` if you want your bot to check for duplicates when adding new keywords, however, if you have lots of data already, the operation might be slow. Upon bot initialization (`.Init`), the value for this variable is set to `True`.|
|`TPercent`|Integer|A value that determines the minimum percentage value of occurrences of keywords in a message so that the bot can actually "understand" and have a reply to the message.|Upon bot initialization (`.Init`), the value for this variable is set to 70.|
|`NoUdstdRep`|String|Reply that is used in case the bot cannot answer the given message via `Answer`.|Upon bot initialization (`.Init`), the value for this variable is set to "Sorry, I didn't get that".|

Functions and procedures of `TTimmy`
------------------------------------

|Name|Return|Parameters|Description|Notes|
|:---:|:---:|---|---|---|
|`Init`|Integer|None.|Initiate the bot (`TTimmy` instance). Return 101 if already initiated, 100 otherwise. In this function, `TTimmy` gets some variables set, like `DupesCheck`, `NOfEntries`, `Enabled`. In case the bot is already initiated, the variable-setting operation will not be performed.|Must use this function before doing other things like adding or removing data. Should only initiate once.|
|`Add`|Integer|`MKeywords`, `Replies`: `TStrArray`|Add keywords clue for a message. Return 102 if the bot is not initialized or not enabled, 202 if `DupesCheck` is true and a match with `MKeywords` is presented in `MKeywordsList`, and 200 if the operation is successful.|You can use `StrSplit` (see in later section) to help you perform the adding operation. Consider the example program above.|
|`Add`|Integer|`KeywordsStr`, `RepStr`: String|Just like the above implementation of `Add()`, but this one gets string inputs instead of `TStrArray` inputs. The strings will then be delimited and passed to the above `Add()` function. `KeywordsStr` is delimited using a space character as the delimiter, and `RepStr` is delimited using a semicolon.||
|`Add`|Integer|`KeywordsStr`, `RepStr`: String; `KStrDeli`, `MStrDeli`: `Char`|Another implementation of `Add()`. This one is like the above one, which uses string inputs as oppose to `TStrArray` inputs. The difference is, with this one, you get to have custom delimiter. `KStrDeli` is delimiter for `KeywordsStr`, and `MStrDeli` is delimiter for `RepStr`.||
|`Remove`|Integer|`MKeywords`: `TStrArray`|Remove keywords clue from the bot's metadata by keywords. The function searches `MKeywordsList` to see if there is any match with `MKeywords`. If there is, remove it. It there are many matches, remove them. Return 102 if the bot is not initialized or not enabled, 308 if the operation is successful.||
|`Remove`|Integer|`KeywordsStr`: String|Has the same functionality as the above `Remove()`, but this one takes a string argument (`KeywordsStr`) instead of a `TStrArray` argument. `KeywordsStr` is delimited using a space character, resulting in a `TStrArray`, and this `TStrArray` is then passed to the primary `Remove()`.||
|`Remove`|Integer|`KeywordsStr`: String; `KStrDeli`: `Char`|Just like the above implementation of `Remove()`, but this one takes one more argument, which is the custom delimiter for `KeywordsStr`, which is `KStrDeli`.||
|`Remove`|Integer|`AIndex`: Integer|Does the same job as the above `Remove` but requires an integer as the (only) argument instead of a `TStrArray`. This integer is the offset for the keyword clues array in `MKeywordsList` that you wish to delete. Return 102 if the bot is not initialized or not enabled, 305 if `AIndex` is an invalid offset, 300 if the operation is successful.|The integer is 0-based.|
|`Update`||None.|Update the lengths of `MKeywordsList` and `ReplyList` to be equal to `NOfEntries`.|This procedure is **not** for you to execute.|
|`Answer`|String|`TMessage`: String|Return a random possible answer to the given message `TMessage`. If the message cannot be answered by the bot then `NoUdstdRep` is returned.||

Other variables and functions provided by the library
-----------------------------------------------------

1. `TStrArray`: Which is actually `array of string`
2. `StrTrim`
    - Type: Function -> String
    - Parameters:
        - `S`: String - the string that needs to be processed
    - Description:
        `StrTrim` removes space characters at the start and at the end of the string, if there are. Also remove space characters that appear multiple times in a row in the processing string.
3. `StrSplit`
    - Type: Function -> `TStrArray`
    - Parameters:
        - `S`: String - the string that needs to be splitted
        - `delimiter`: Character - the delimiter to split the string `S`
    - Description:
        `StrSplit` splits the string `S` according to the delimiter `delimiter`.
4. `CompareStrArrays`
    - Type: Function -> Boolean
    - Parameters:
        - `ArrayA`: `TStrArray`
        - `ArrayB`: `TStrArray`
    - Description:
        Compare `ArrayA` and `ArrayB`. Return `True` if they are the same (including the order of the elements), return `False` otherwise.

License
-------

![License logo](https://www.gnu.org/graphics/lgplv3-147x51.png)

Timmy is licensed under the [GNU LGPL v3](COPYING.LESSER).
