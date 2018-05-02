{
    timmy - Pascal unit for creating chat bots
    Version 1.1.0

    Copyright (C) 2018 42tm Team <fourtytwotm@gmail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
}
Unit timmy;

Interface
Type
    TStrArray = Array of String;

    {
    Metadata refers to two arrays holding data:
    MKeywordsList which holds keywords, and
    ReplyList which holds replies

      MKeywordsList [                                 ReplyList [
                     [*keywords for message 1*],                [*possible answers for message 1*],
                     [*keywords for message 2*],                [*possible answers for message 2*],
                                 ...                                             ...
                                                 ]                                                   ]

    Variables (see also the README file):

      Initialized        : State of initialization
      Enabled            : Acts like Initialized but used in fewer number of functions
      NOfEntries         : Number of entries (elements) in MKeywordsList or ReplyList
      DupesCheck         : Check for duplicate or not (might be time-saving if we don't check for duplicate)
      TPercent           : Minimum percentage of the number of keywords over all the words of the message
                           so that the bot object can "understand" and have a reply.
                           (Sorry I don't have a good way to explain it)
      NoUdstdRep : String to assign to TTimmy.Answer in case there's no possible answer to the given message
    }
    TTimmy = Object
                 Initialized: Boolean;
                 Enabled: Boolean;
                 NOfEntries: Integer;
                 MKeywordsList: Array of TStrArray;
                 ReplyList: Array of TStrArray;
                 DupesCheck: Boolean;
                 TPercent: Integer;
                 NoUdstdRep: String;
                 Function Init: Integer;
                 Function Add(MKeywords, Replies: TStrArray): Integer; overload;
                 Function Add(KeywordsStr, RepStr: String): Integer; overload;
                 Function Add(KeywordsStr, RepStr: String; KStrDeli, MStrDeli: Char): Integer; overload;
                 Function Remove(MKeywords: TStrArray): Integer; overload;
                 Function Remove(KeywordsStr: String): Integer; overload;
                 Function Remove(KeywordsStr: String; KStrDeli: Char): Integer; overload;
                 Function Remove(AIndex: Integer): Integer; overload;
                 Procedure Update;
                 Function Answer(TMessage: String): String;
             End;

Function StrTrim(S: String): String;
Function StrSplit(S: String; delimiter: Char): TStrArray;
Function CompareStrArrays(ArrayA, ArrayB: TStrArray): Boolean;

Implementation

{
    Given a string, process it so that the first and the last
    character are not space, and there is no multiple spaces
    character in a row.
}
Function StrTrim(S: String): String;
Var iter: Integer;
    FlagStr: String;
    SpaceOn: Boolean;
Begin
    While S[1] = ' ' do Delete(S, 1, 1);
    While S[Length(S)] = ' ' do Delete(S, Length(S), 1);
    FlagStr := '';
    For iter := 1 to Length(S)
    do If S[iter] <> ' '
       then Begin FlagStr := FlagStr + S[iter]; SpaceOn := False; End
       else Case SpaceOn of
              True: Continue;
              False: Begin FlagStr := FlagStr + ' '; SpaceOn := True; End;
            End;

    StrTrim := FlagStr;
End;

{
    Given a string, split the string using the delimiter
    and return an array containing the seperated strings.
}
Function StrSplit(S: String; delimiter: Char): TStrArray;
Var iter, counter: Integer;
    FlagStr: String;
Begin
    S := S + delimiter;
    FlagStr := '';
    counter := -1;

    For iter := 1 to Length(S)
    do If S[iter] <> delimiter
       then FlagStr := FlagStr + S[iter]
       else Begin
              If FlagStr = '' then Continue;
              Inc(counter);
              SetLength(StrSplit, counter + 1);
              StrSplit[counter] := FlagStr;
              FlagStr := '';
            End;

    If counter = -1 then Begin
                           SetLength(StrSplit, 1);
                           StrSplit[0] := S;
                         End;
End;

{
    Given two arrays of strings, compare them.
    Return true if they are the same, false otherwise.
}
Function CompareStrArrays(ArrayA, ArrayB: TStrArray): Boolean;
Var iter: Integer;
Begin
    If Length(ArrayA) <> Length(ArrayB) then Exit(False);
    For iter := 0 to Length(ArrayA) - 1 do If ArrayA[iter] <> ArrayB[iter] then Exit(False);
    Exit(True);
End;

{
    Initialize object with some default values set.
    Return 101 if object is initialized, 100 otherwise.
}
Function TTimmy.Init: Integer;
Begin
    If Initialized then Exit(101);

    DupesCheck := True;
    NoUdstdRep := 'Sorry, I didn''t get that';
    TPercent := 70;
    NOfEntries := 0;
    Update;
    Enabled := True;
    Initialized := True;
    Exit(100);
End;

{
    Add data to bot object's metadata base.
    Data include message's keywords and possible replies to the message.

    Return: 102 if object is not initialized or enabled
            202 if DupesCheck = True and found a match to MKeywords in MKeywordsList
            200 if the adding operation succeed
}
Function TTimmy.Add(MKeywords, Replies: TStrArray): Integer;
Var iter: Integer;
Begin
    If (not Initialized) or (not Enabled) then Exit(102);
    For iter := Low(MKeywords) to High(MKeywords) do MKeywords[iter] := LowerCase(MKeywords[iter]);
    If (DupesCheck) and (NOfEntries > 0)
    then For iter := Low(MKeywordsList) to High(MKeywordsList) do
           If CompareStrArrays(MKeywordsList[iter], MKeywords) then Exit(202);

    Inc(NOfEntries); Update;
    MKeywordsList[High(MKeywordsList)] := MKeywords;
    ReplyList[High(ReplyList)] := Replies;
    Exit(200);
End;

{
    Add data to bot but this one gets string inputs instead of TStrArray inputs.
    This use StrSplit() to split the string inputs (with a space character as the delimiter
    for the message keywords string input and a semicolon character for the replies string input).
    The main work is done by the primary implementation of TTimmy.Add().

    Return: TTimmy.Add(MKeywords, Replies: TStrArray)
}
Function TTimmy.Add(KeywordsStr, RepStr: String): Integer;
Begin
    Exit(Add(StrSplit(KeywordsStr, ' '), StrSplit(RepStr, ';')));
End;

{
    Just like the above implementation of TTimmy.Add() but this one is with custom delimiters.

    Return: TTimmy.Add(MKeywords, Replies: TStrArray)
}
Function TTimmy.Add(KeywordsStr, RepStr: String; KStrDeli, MStrDeli: Char): Integer;
Begin
    Exit(Add(StrSplit(KeywordsStr, KStrDeli), StrSplit(RepStr, MStrDeli)));
End;

{
    Given a set of keywords, find matches to that set in MKeywordsList,
    remove the matches, and remove the correspondants in ReplyList as well.
    This function simply saves offsets of the matching arrays in MKeywordsList
    and then call TTimmy.RemoveByIndex().

    Return: 102 if object is not initialized or not enabled
            308 if the operation succeed
}
Function TTimmy.Remove(MKeywords: TStrArray): Integer;
Var iter, counter: Integer;
    Indexes: Array of Integer;
Begin
    If (not Initialized) or (not Enabled) then Exit(102);

    For iter := Low(MKeywords) to High(MKeywords) do MKeywords[iter] := LowerCase(MKeywords[iter]);
    counter := -1;  // Matches counter in 0-based
    SetLength(Indexes, Length(MKeywordsList));

    // Get offsets of keywords set that match the given MKeywords parameter
    // and later deal with them using TTimmy.RemoveByIndex
      For iter := Low(MKeywordsList) to High(MKeywordsList) do
        If CompareStrArrays(MKeywordsList[iter], MKeywords)
        then Begin
      	       Inc(counter);
               Indexes[counter] := iter;
             End;

    Inc(counter);
    SetLength(Indexes, counter);
    While counter > 0 do
    Begin
      Remove(Indexes[Length(Indexes) - counter] - Length(Indexes) + counter);
      Dec(counter);
    End;
    Exit(308);
End;

{
    An implementation of Remove that uses string as an argument
    instead of a TStrArray. The string is delimited using the space character
    to form a TStrArray, and then pass that TStrArray to the
    common Remove function.

    Return TTimmy.Remove(MKeywords: TStrArray)
}
Function TTimmy.Remove(KeywordsStr: String): Integer;
Begin
    Exit(Remove(StrSplit(KeywordsStr, ' ')));
End;

{
    The same as the above implementation of Remove, but allows
    use of custom string delimiter.

    Return TTimmy.Remove(MKeywords: TStrArray)
}
Function TTimmy.Remove(KeywordsStr: String; KStrDeli: Char): Integer;
Begin
    Exit(Remove(StrSplit(KeywordsStr, KStrDeli)));
End;

{
    Remove data from MKeywordsList at MKeywordsList[AIndex].

    Return - 305 if the given index is invalid (out of bound)
           - 300 if operation successful
}
Function TTimmy.Remove(AIndex: Integer): Integer;
Var iter: Integer;
Begin
    If (not Initialized) or (not Enabled) then Exit(102);
    If (AIndex < 0) or (AIndex >= NOfEntries) then Exit(305);

    For iter := AIndex to High(MKeywordsList) - 1
    do MKeywordsList[iter] := MKeywordsList[iter + 1];
    For iter := AIndex to High(ReplyList) - 1
    do ReplyList[iter] := ReplyList[iter + 1];

    Dec(NOfEntries); Update;
    Exit(300);
End;

{
    Update metadata to match up with number of entries
}
Procedure TTimmy.Update;
Begin
    If not Initialized then Exit;

    SetLength(MKeywordsList, NOfEntries);
    SetLength(ReplyList, NOfEntries);
End;

{
    Answer the given message, using assets in the metadata
}
Function TTimmy.Answer(TMessage: String): String;
Var MetaIter, MKIter, MWIter, counter, GetAnswer: Integer;
    FlagM: String;
    LastChar: Char;
    FlagWords: TStrArray;
Begin
    If (not Initialized) or (not Enabled) then Exit;

    // Pre-process the message
      FlagM := LowerCase(StrTrim(TMessage));
      // Delete punctuation at the end of the message (like "?" or "!")
        While True do Begin
                        LastChar := FlagM[Length(FlagM)];
                        Case LastChar of
                          'a'..'z', 'A'..'Z', '0'..'9': Break;
                        Else Delete(FlagM, Length(FlagM), 1);
                        End;
                      End;

    FlagWords := StrSplit(FlagM, ' ');
    For MetaIter := 0 to NOfEntries - 1
    do Begin
         counter := 0;
         For MKIter := Low(MKeywordsList[MetaIter]) to High(MKeywordsList[MetaIter])
         do For MWIter := Low(FlagWords) to High(FlagWords)
            do If FlagWords[MWiter] = MKeywordsList[MetaIter][MKIter] then Inc(counter);

         If counter / Length(MKeywordsList[MetaIter]) * 100 >= TPercent  // Start getting answer
         then Begin
     	        Randomize;
                GetAnswer := Random(Length(ReplyList[MetaIter]));
                Exit(ReplyList[MetaIter][GetAnswer]);
     	      End;
       End;

    Exit(NoUdstdRep);
End;

End.
