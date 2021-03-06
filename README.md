Timmy
=====

[![Project on SourceForge](https://sourceforge.net/sflogo.php?type=11&group_id=2954046)](https://sourceforge.net/p/timmy-unit/)
![Number of Downloads on SourceForge](https://img.shields.io/sourceforge/dt/timmy-unit.svg)

Timmy is a Pascal unit for creating chat bots. It provides the `TTimmy` object, which is a data type that you can assign your variables to to make bots. Once that is done, you can start adding keywords for messages, and get the bot answers to the end user's messages.

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
    MyBot.Init(70, 'I gave up', False);
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

For more examples, check out the `examples` folder.

Variables, functions and procedures of `TTimmy`
-----------------------------------------------

### constructor `Init(Percent: Integer; DefaultRep: String; DpCheck: Boolean)`
- **Source**: Line 143 ([reference](http://github.com/42tm/timmy/blob/v1.2.0/timmy.pas#L143))
- **Parameters**:
    - `Percent` \[Integer\]: Desired initial value for [`TTimmy.TPercent`](#tpercent)
    - `DefaultRep` \[String\]: Initial value for [`TTimmy.NoUdstdRep`](#noudstdrep)
    - `DpCheck` \[Boolean\]: Initial value for [`TTimmy.DupesCheck`](#dupescheck)
- **Availability**: v1.2.0
- **Description**: Constructor of the `TTimmy` instance, which prepares the instance for being used. In this constructor, `TTimmy.TPercent`, `TTimmy.NoUdstdRep`, and `TTimmy.DupesCheck` get assigned to the values of the arguments `Percent`, `DefaultRep` and `DpCheck`, respectively. `TTimmy.Enabled` is set to true, and the bot starts with nothing in its metadata. **You must run this constructor before performing any other operation with your bot instance, or else the bot won't work properly.**

### function `Init()`
- **Source**:
    - v1.0.0: Line 142 ([reference](http://github.com/42tm/timmy/blob/v1.0.0/src/timmy.pas#L142))
    - v1.1.0: Line 144 ([reference](http://github.com/42tm/timmy/blob/v1.1.0/timmy.pas#L144))
- **Parameters**: None
- **Return**: Integer
    - 101: The instance is already initialized
    - 100: The operation is successful
- **Availability**: v1.0.0 to v1.1.0
- **Description**: Acts like v1.2.0's `TTimmy.Init()` constructor, but this one is a function. `TTimmy.TPercent`, `TTimmy.NoUdstdRep`, `TTimmy.DupesCheck` get assigned to 70, "Sorry, I didn't get that", and `True`, respectively. **You must run this function before performing any other operation with your bot instance, or else the bot won't work properly.**

### `Enabled`
- **Type**: Boolean variable
- **Visibility**: Private
- **Availability**: v1.0.0 to v1.2.0
- **Description**: `TTimmy.Enabled` tells other functions of `TTimmy` whether if the bot instance is ready to work. If `TTimmy.Enabled` is false, all major functions of `TTimmy` won't perform their operations and will exit right away, usually with the return code 102. The value of this boolean variable can be set by using [`TTimmy.Enable()`](#procedure-enable) or [`TTimmy.Disable()`](#procedure-disable).

### procedure `Enable()`
- **Source**: Line 154 ([reference](http://github.com/42tm/timmy/blob/v1.2.0/timmy.pas#L154))
- **Parameters**: None
- **Visibility**: Public
- **Availability**: v1.2.0
- **Description**: Procedure that sets `TTimmy.Enabled` to true. In other words, it enables the bot.

### procedure `Disable()`
- **Source**: Line 158 ([reference](http://github.com/42tm/timmy/blob/v1.2.0/timmy.pas#L158))
- **Parameters**: None
- **Visibility**: Public
- **Availability**: v1.2.0
- **Description**: Procedure that sets `TTimmy.Enabled` to false, as oppose of `TTimmy.Enable()`. You may disable the bot if you somehow want it to stop working temporarily.

### `MKeywordsList`
- **Type**: Dynamic array of `TStrArray`
- **Visibility**: Private
- **Availability**: v1.0.0 to v1.2.0 (In v1.0.0, it's `QKeywordsList`)
- **Description**: This is an array of arrays. Each array in this array holds strings, which are keywords for a message. Keywords help the bot (or more specifically, [`TTimmy.Answer()`](#function-answertmessage-string)) to understand the end-user's messages and have replies for the messages.

### `ReplyList`
- **Type**: Dynamic array of `TStrArray`
- **Visibility**: Private
- **Availability**: v1.0.0 to v1.2.0
- **Description**: Just like `TTimmy.MKeywordsList`, `TTimmy.ReplyList` is an array of arrays. Each array in `TTimmy.ReplyList` holds strings, which are possible replies for a message. If an array in `TTimmy.ReplyList` has more than two strings, the bot will pick one, randomly. Arrays in `TTimmy.ReplyList` are correspond to arrays in `TTimmy.MKeywordsList` in terms of position. For example, the replies at offset 2 of `TTimmy.ReplyList` are replies for the message with the keywords at offset 2 of `TTimmy.MKeywordsList`.

### `NOfEntries`
- **Type**: Integer
- **Visibility**: Private
- **Availability**: v1.0.0 to v1.2.0
- **Description**: `TTimmy.NOfEntries` is the number of elements in `TTimmy.MKeywordsList`, or `TTimmy.ReplyList` (the length of `TTimmy.MKeywordsList` is the same as the length of `TTimmy.ReplyList` at all times anyway). We implement this instead of doing `Length(MKeywordsList)` (or `Length(ReplyList)`) because it's more convenient.

### procedure `Update()`
- **Source**:
    - v1.0.0: Line 258 ([reference](http://github.com/42tm/timmy/blob/v1.0.0/src/timmy.pas#L258))
    - v1.1.0: Line 290 ([reference](http://github.com/42tm/timmy/blob/v1.1.0/timmy.pas#L290))
    - v1.2.0: Line 293 ([reference](http://github.com/42tm/timmy/blob/v1.2.0/timmy.pas#L293))
- **Parameters**: None
- **Visibility**: Private
- **Availability**: v1.0.0 to v1.2.0
- **Description**: Procedure that sets the lengths of `TTimmy.MKeywordsList` and `TTimmy.ReplyList` to `TTimmy.NOfEntries`. This procedure is called whenever the bot takes or remove data within its metadata (either by `TTimmy.Add()` or `TTimmy.Remove()`), in which the length of `TTimmy.MKeywordsList` (and `TTimmy.ReplyList` as well) is changed.

### `TPercent`
- **Type**: Integer
- **Visibility**: Public
- **Availability**: v1.0.0 to v1.2.0
- **Description**: `TTimmy.TPercent` specifies the minimum percentage of the number of matching keywords over the total number of words in the message that the bot needs in order to "understand" the message.

### `NoUdstdRep`
- **Type**: String
- **Visibility**: Public
- **Availability**: v1.0.0 to v1.2.0
- **Description**: `TTimmy.NoUdstdRep` is the default reply of the bot. It is returned to `TTimmy.Answer()` whenever the bot does not "understand" the user's message.

### function `Add(MKeywords, Replies: TStrArray)`
- **Source**:
    - v1.0.0: Line 164 ([reference](http://github.com/42tm/timmy/blob/v1.0.0/src/timmy.pas#L164))
    - v1.1.0: Line 166 ([reference](http://github.com/42tm/timmy/blob/v1.1.0/timmy.pas#L166))
    - v1.2.0: Line 169 ([reference](http://github.com/42tm/timmy/blob/v1.2.0/timmy.pas#L169))
- **Parameters**:
    - `MKeywords` (`QKeywords` in v1.0.0) \[`TStrArray`\]: New keywords clue for a message
    - `Replies` \[`TStrArray`\]: Possible replies to the message that contains the keywords clue in `MKeywords`
- **Return**: Integer
    - 102: The instance is not enabled (or initialized)
    - 202: Duplication check is enabled ([`TTimmy.DupesCheck`](#dupescheck) = true) and a match of `MKeywords` is presented in `TTimmy.MKeywordsList`
    - 200: The operation is successful
- **Visibility**: Public
- **Availability**: v1.0.0 to v1.2.0
- **Description**: `TTimmy.Add()` adds new data to the bot's metadata, which means it adds `MKeywords` to `TTimmy.MKeywordsList` and `Replies` to `TTimmy.ReplyList`. It takes two arguments, one is keywords clue for a message, and two is possible responses to that message. **`TTimmy.Add()` is overloaded and this implementation of it is considered the original implementation.**

### function `Add(KeywordsStr, RepStr: String)`
- **Source**:
    - v1.0.0: Line 187 ([reference](http://github.com/42tm/timmy/blob/v1.0.0/src/timmy.pas#L187))
    - v1.1.0: Line 189 ([reference](http://github.com/42tm/timmy/blob/v1.1.0/timmy.pas#L189))
    - v1.2.0: Line 192 ([reference](http://github.com/42tm/timmy/blob/v1.2.0/timmy.pas#L192))
- **Parameters**:
    - `KeywordsStr` \[String\]: New keywords clue for a message, joined by the space character
    - `RepStr` \[String\]: Possible replies to the message that contains the keywords presented in `KeywordsStr`, joined by the semicolon
- **Return**: The same as the original implementation of `TTimmy.Add()`.
- **Visibility**: Public
- **Availability**: v1.0.0 to v1.2.0
- **Description**: Yet another function to add new data, but this one takes string arguments instead of `TStrArray`s. These strings will then be delimited using a delimiter with the help of the [`StrSplit()`](#function-strsplits-string-delimiter-char) function to form `TStrArray`s, and these `TStrArray`s will be passed over to the original implementation of `TTimmy.Add()`.

### function `Add(KeywordsStr, RepStr: String; KStrDeli, MStrDeli: Char)`
- **Source**:
    - v1.0.0: Line 197 ([reference](http://github.com/42tm/timmy/blob/v1.0.0/src/timmy.pas#L197))
    - v1.1.0: Line 199 ([reference](http://github.com/42tm/timmy/blob/v1.1.0/timmy.pas#L199))
    - v1.2.0: Line 202 ([reference](http://github.com/42tm/timmy/blob/v1.2.0/timmy.pas#L202))
- **Parameters**:
    - `KeywordsStr` \[String\]: New keywords clue for a message, joined by `KStrDeli`
    - `RepStr` \[String\]: Possible replies to the message that contains the keywords presented in `KeywordsStr`, joined by `MStrDeli`
    - `KStrDeli` \[Character\]: Delimiter for `KeywordsStr`
    - `MStrDeli` (`QStrDeli` in v1.0.0) \[Character\]: Delimiter for `RepStr`
- **Return**: The same as the original implementation of `TTimmy.Add()`.
- **Visibility**: Public
- **Availability**: v1.0.0 to v1.2.0
- **Description**: This implementation of `TTimmy.Add()` is the same as the above one (which takes string arguments). However, the difference is, this one allows you to use custom delimiters for the strings.

### `DupesCheck`
- **Type**: Boolean
- **Visibility**: Public
- **Availability**: v1.0.0 to v1.2.0
- **Description**: `TTimmy.DupesCheck` specifies whether `TTimmy.Add()` should check for duplicate before adding new data or not. If the new data matches any of those already persisted in `TTimmy.ReplyList`, `TTimmy.Add()` stops its operation and returns 202, indicating that the operation is not successful.

### function `Remove(MKeywords: TStrArray)`
- **Source**:
    - v1.0.0: Line 211 ([reference](http://github.com/42tm/timmy/blob/v1.0.0/src/timmy.pas#L211))
    - v1.1.0: Line 213 ([reference](http://github.com/42tm/timmy/blob/v1.1.0/timmy.pas#L213))
    - v1.2.0: Line 216 ([reference](http://github.com/42tm/timmy/blob/v1.2.0/timmy.pas#L216))
- **Parameters**: `MKeywords` (`QKeywords` in v1.0.0) \[`TStrArray`\]: Keywords clue to delete from the bot's metadata.
- **Return**: Integer
    - 102: The instance is not enabled (or initialized)
    - 308: The operation is successful
- **Visibility**: Public
- **Availability**: v1.0.0 to v1.2.0
- **Description**: `TTimmy.Remove()` removes data from the bot's metadata, and as of version 1.2.0, there are 4 overloaded `TTimmy.Remove()`. This one takes a `TStrArray`, find matching arrays (arrays with the same elements in the same order) in `TTimmy.MKeywordsList`, and delete those matching arrays. It also deletes the array(s) in `ReplyList` that is/are bond to those matching array(s) of keywords.

### function `Remove(KeywordsStr: String)`
- **Source**:
    - v1.1.0: Line 250 ([reference](http://github.com/42tm/timmy/blob/v1.1.0/timmy.pas#L250))
    - v1.2.0: Line 253 ([reference](http://github.com/42tm/timmy/blob/v1.2.0/timmy.pas#L253))
- **Parameters**: `KeywordsStr` \[String\]: Keywords clue to delete from the bot's metadata, joined by the space character.
- **Return**: The same as the above implementation of `TTimmy.Remove()`.
- **Visibility**: Public
- **Availability**: v1.1.0 to v1.2.0
- **Description**: Another overloaded `TTimmy.Remove()`, this one takes one and only string argument. The string is then delimited using the space character to get a `TStrArray` output, and this `TStrArray` is processed by the above `TTimmy.Remove(MKeywords: TStrArray)`.

### function `Remove(KeywordsStr: String; KStrDeli: Char)`
- **Source**:
    - v1.1.0: Line 261 ([reference](http://github.com/42tm/timmy/blob/v1.1.0/timmy.pas#L261))
    - v1.2.0: Line 264 ([reference](http://github.com/42tm/timmy/blob/v1.2.0/timmy.pas#L264))
- **Parameters**:
    - `KeywordsStr` \[String\]: Keywords clue to delete from the bot's metadata, joined by `KStrDeli`
    - `KStrDeli` \[Character\]: Delimiter for `KeywordsStr`
- **Return**: The same as the top implementation of `TTimmy.Remove()` (`TTimmy.Remove(MKeywords: TStrArray)`).
- **Visibility**: Public
- **Availability**: v1.1.0 to v1.2.0
- **Description**: Yet another overloaded `TTimmy.Remove()` which is quite similar to the above one, but this one allows you to use any delimiter you like instead of the space character.

### function `Remove(AIndex: Integer)`
- **Source**:
    - v1.0.0: Line 240 ([reference](http://github.com/42tm/timmy/blob/v1.0.0/src/timmy.pas#L240))
    - v1.1.0: Line 272 ([reference](http://github.com/42tm/timmy/blob/v1.1.0/timmy.pas#L272))
    - v1.2.0: Line 275 ([reference](http://github.com/42tm/timmy/blob/v1.2.0/timmy.pas#L275))
- **Parameters**: `AIndex` \[Integer\]: Offset of elements in `TTimmy.MKeywordsList` and `TTimmy.ReplyList` that need to be removed
- **Return**: Integer
    - 305: `AIndex` is an invalid offset in `TTimmy.MKeywordsList` (or `TTimmy.ReplyList`)
    - 300: The operation is successful
- **Visibility**: Public
- **Availability**: v1.0.0 to v1.2.0
- **Description**: This is the major implementation of `TTimmy.Remove()` due to the fact that other overloaded `TTimmy.Remove()` rely on this one, whether directly or indirectly. This one removes the array at offset `AIndex` in `TTimmy.MKeywordsList` and in `TTimmy.ReplyList`. In other words, it removes `MKeywordsList[AIndex]` and `ReplyList[AIndex]`.

### function `Answer(TMessage: String)`
- **Source**:
    - v1.0.0: Line 269 ([reference](http://github.com/42tm/timmy/blob/v1.0.0/src/timmy.pas#L269))
    - v1.1.0: Line 301 ([reference](http://github.com/42tm/timmy/blob/v1.1.0/timmy.pas#L301))
    - v1.2.0: Line 302 ([reference](http://github.com/42tm/timmy/blob/v1.1.0/timmy.pas#L302))
- **Parameters**: `TMessage` (`TQuestion` in v1.0.0) \[String\]: End-user's message to the bot
- **Return**: String. Bot's response to `TMessage`.
- **Visibility**: Public
- **Availability**: v1.0.0 to v1.2.0
- **Description**: Given the end-user's message, returns the bot instance's response to that message. The message is first pre-processed (like removing extra white-spaces or punctuations like ! or ?). Then, it is splitted into many words using the space character. The function will then iterate through `TTimmy.MKeywordsList`, and compute the percentage of the keywords in each of the array in `TTimmy.MKeywordsList` to the user message's splitted words. If the percentage is larger then `TTimmy.TPercent`, a random reply in the corresponding array in `TTimmy.ReplyList` will be returned to `TTimmy.Answer()`. In this case, we say that the bot has "understood" the end-user's message. In the case that it could not understand, `TTimmy.NoUdstdRep` is returned.

Other functions provided by the unit & `TStrArray`
--------------------------------------------------
### `TStrArray`
`TStrArray` is `Array of Array of String`. In Timmy, it is used instead of `Array of Array of String` to avoid type incompatible compile error.

### function `StrTrim(S: String)`
- **Source**:
    - v1.0.0: Line 78 ([reference](http://github.com/42tm/timmy/blob/v1.0.0/src/timmy.pas#L78))
    - v1.1.0: Line 80 ([reference](http://github.com/42tm/timmy/blob/v1.1.0/timmy.pas#L80))
    - v1.2.0: Line 82 ([reference](http://github.com/42tm/timmy/blob/v1.2.0/timmy.pas#L82))
- **Parameters**: `S` \[String\]: String to be processed.
- **Return**: String. The processed string.
- **Availability**: v1.0.0 to v1.2.0 (In v1.0.0, it's `StrProcessor()`)
- **Description**: `StrTrim()` deletes extra white spaces in the string `S`.

### function `StrSplit(S: String; delimiter: Char)`
- **Source**:
    - v1.0.0: Line 101 ([reference](http://github.com/42tm/timmy/blob/v1.0.0/src/timmy.pas#L101))
    - v1.1.0: Line 103 ([reference](http://github.com/42tm/timmy/blob/v1.1.0/timmy.pas#L103))
    - v1.2.0: Line 103 ([reference](http://github.com/42tm/timmy/blob/v1.2.0/timmy.pas#L103))
- **Parameters**:
    - `S` \[String\]: String to be splitted
    - `delimiter` \[Character\]: Delimiter for `S`
- **Return**: `TStrArray`, contains the strings of `S` after being splitted.
- **Availability**: v1.0.0 to v1.2.0
- **Description**: `StrSplit()` splits the string `S` using `delimiter` as delimiter, and returns a `TStrArray` holding the delimited strings.

### function `CompareStrArrays(ArrayA, ArrayB: TStrArray)`
- **Source**:
    - v1.0.0: Line 130 ([reference](http://github.com/42tm/timmy/blob/v1.0.0/src/timmy.pas#L130))
    - v1.1.0: Line 132 ([reference](http://github.com/42tm/timmy/blob/v1.1.0/timmy.pas#L132))
    - v1.2.0: Line 132 ([reference](http://github.com/42tm/timmy/blob/v1.2.0/timmy.pas#L132))
- **Parameters**: Two `TStrArray`s to be compared, `ArrayA` and `ArrayB`.
- **Return**: Boolean. True if `ArrayA` is the same as `ArrayB`, false otherwise.
- **Availability**: v1.0.0 to v1.2.0
- **Description**: This function compares two `TStrArray`s to see if they have the exact same elements. The order of elements in the arrays does matter.

License
-------

![License logo](https://www.gnu.org/graphics/lgplv3-147x51.png)

Timmy is licensed under the [GNU LGPL v3](http://github.com/IQAndreas/markdown-licenses/blob/master/gnu-lgpl-v3.0.md#gnu-lesser-general-public-license).
