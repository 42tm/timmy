{
    Timmy - Pascal unit for creating chat bots
    Version 1.2.0

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
{$mode ObjFPC}
Unit Timmy;

Interface
Type
    PStr = ^String;
    TStrArray = Array of String;
    PStrArray = Array of PStr;

    {
    Metadata refers to three arrays holding data:
    MsgKeywordsList which holds keywords,
    ReplyList which holds replies, and
    PReplyList which also functions like ReplyList,
    but holds pointers to replies

      MsgKeywordsList [                                 ReplyList [
                     [*keywords for message 1*],                 [*possible answers for message 1*],
                     [*keywords for message 2*],                 [*possible answers for message 2*],
                                 ...                                             ...                ]
                                 ...                  PStrArray [
                     [*keywords for message n*],                 [*pointer points to answer for message n*]
                     [*keywords of message n + 1*]               [*pointer points to answer for message n + 1*]
                                 ...              ]                               ...                         ]

    Variables (see also the README file):

      Enabled            : Bot's state. If Enabled is True, the bot
                           is ready to work
      NOfEntries         : Number of entries (elements) in MsgKeywordsList
      DupesCheck         : Check for duplicate or not
                           (might be time-saving if we don't check)
      TPercent           : Minimum percentage of the number of keywords over
                           all the words of the message so that the bot object
                           can "understand" and have a reply.
                           (Sorry I don't have a good way to explain it)
      NoUdstdRep         : String to assign to TTimmy.Answer() in case
                           there's no possible answer to the given message
    }
    TTimmy = Object
               Constructor Init(Percent: Integer; DefaultRep: String; DpCheck: Boolean);
               Public
                 DupesCheck: Boolean;
                 TPercent: Integer;
                 NoUdstdRep: String;
                 Procedure Enable;
                 Procedure Disable;
                 Function  Add    (MsgKeywords, Replies: TStrArray):                Integer; overload;
                 Function  Add    (KeywordsStr, RepStr: String;
                                   KStrDeli: String = ' '; MStrDeli: String = ';'): Integer; overload;
                 Function  Add    (MsgKeywords: TStrArray; PAnswer: PStr):          Integer; overload;
                 Function  Add    (KeywordsStr: String; PAnswer: PStr;
                                   KStrDeli: String = ' '):                         Integer; overload;
                 Function  Remove (MsgKeywords: TStrArray):                         Integer; overload;
                 Function  Remove (KeywordsStr: String; KStrDeli: String = ' '):    Integer; overload;
                 Function  Remove (AIndex: Integer):                                Integer; overload;
                 Function  Answer (TMessage: String):                               String;
               Private
                 Enabled: Boolean;
                 NOfEntries: Integer;
                 MsgKeywordsList: Array of TStrArray;
                 ReplyList: Array of TStrArray;
                 PReplyList: PStrArray;
                 Function IsDupe(CheckMsgKeywords: TStrArray): Boolean;
             End;

Function StrTrim(S: String): String;
Function StrSplit(S: String; Delimiter: String = ' '): TStrArray;
Function StrJoin(StrList: TStrArray; Linker: String): String;
Function CompareStrArrays(ArrayA, ArrayB: TStrArray): Boolean;

Implementation

{
    Given a string, process it so that the first and the last
    character are not space, and there is no multiple spaces
    character in a row.
}
Function StrTrim(S: String): String;
Var iter: Integer;
    SpaceOn: Boolean;
Begin
    While S[1] = ' ' do Delete(S, 1, 1);
    While S[Length(S)] = ' ' do Delete(S, Length(S), 1);
    StrTrim := '';
    SpaceOn := False;
    For iter := 1 to Length(S)
      do If S[iter] <> ' '
           then Begin
                  StrTrim := StrTrim + S[iter];
                  SpaceOn := False;
                End
           else Case SpaceOn of
                  True: Continue;
                  False: Begin
                           StrTrim := StrTrim + ' ';
                           SpaceOn := True;
                         End;
                End;
End;

{
    Given a string, split the string using the delimiter
    and return an array containing the separated strings.
    If no delimiter Delimiter is found in string S,
    a TStrArray of only one value is returned, and that
    only one value is the original string S.
}
Function StrSplit(S: String; Delimiter: String = ' '): TStrArray;
Var
    iter,     // String S iterator
    SkipLeft: // Number of iteration left to skip (skip by doing Continue)
              Integer;
    Flag: String;  // Medium string
Begin
    S := S + Delimiter;

    SetLength(StrSplit, 0);
    SkipLeft := 0;
    Flag := '';

    // Split the string using running and skipping method
    For iter := 1 to Length(S)
      do Begin
           If SkipLeft > 0
             then Begin
                    Dec(SkipLeft);
                    Continue;
                  End
             else If Copy(S, iter, Length(Delimiter)) = Delimiter
                    then Begin
                           If Flag <> ''
                             then Begin
                                    SetLength(StrSplit, Length(StrSplit) + 1);
                                    StrSplit[Length(StrSplit) - 1] := Flag;
                                    Flag := '';
                                  End;
                           // Set number of iteratations to skip next
                           // (because the following characters are part of Delimiter)
                             SkipLeft := Length(Delimiter) - 1;
                         End
             else Flag := Flag + S[iter];
         End;
End;

{
    Given an array of string, join them using Linker.
    StrJoin(['this', 'is', 'an', 'example'], '@@')
      -> 'this@@is@@an@@example'
}
Function StrJoin(StrList: TStrArray; Linker: String): String;
Var iter: String;
Begin
    StrJoin := '';
    For iter in StrList do StrJoin := StrJoin + iter + Linker;
    Delete(StrJoin, Length(StrJoin) - Length(Linker) + 1, Length(Linker));
End;

{
    Given two arrays of strings, compare them.
    Return true if they are the same, false otherwise.
}
Function CompareStrArrays(ArrayA, ArrayB: TStrArray): Boolean;
Var iter: Integer;
Begin
    If Length(ArrayA) <> Length(ArrayB) then Exit(False);
    For iter := 0 to Length(ArrayA) - 1
      do If ArrayA[iter] <> ArrayB[iter] then Exit(False);
    Exit(True);
End;

{
    Initialize object with some default values set.
}
Constructor TTimmy.Init(Percent: Integer; DefaultRep: String; DpCheck: Boolean);
Begin
    DupesCheck := DpCheck;
    NoUdstdRep := DefaultRep;
    TPercent := Percent;
    NOfEntries := 0;
    SetLength(MsgKeywordsList, NOfEntries);
    SetLength(ReplyList, NOfEntries);
    SetLength(PReplyList, NOfEntries);
    Enable;
End;

{ Enable the instance. }
Procedure TTimmy.Enable;
Begin Enabled := True; End;

{ Disable the instance. }
Procedure TTimmy.Disable;
Begin Enabled := False; End;

{
    Check if given keywords clue is a duplicate of one
    that is already presented in MsgKeywordsList.

    Return true if duplication check is enabled and
    a duplicate is found, false otherwise.
}
Function TTimmy.IsDupe(CheckMsgKeywords: TStrArray): Boolean;
Var iter: Integer;
Begin
    If (not DupesCheck) or (NOfEntries = 0) then Exit(False);

    For iter := Low(MsgKeywordsList) to High(MsgKeywordsList)
      do If CompareStrArrays(MsgKeywordsList[iter], CheckMsgKeywords)
           then Exit(True);

    Exit(False);
End;

{
    Add data to bot object's metadata base.
    Data include message's keywords and possible replies to the message.
    *** PRIMARY ADD FUNCTION ***

    Return: 102 if object is not enabled
            202 if DupesCheck = True and found a match to MsgKeywords in MsgKeywordsList
            200 if the adding operation succeed
}
Function TTimmy.Add(MsgKeywords, Replies: TStrArray): Integer;
Var iter: Integer;
Begin
    If not Enabled then Exit(102);
    For iter := Low(MsgKeywords) to High(MsgKeywords)
      do MsgKeywords[iter] := LowerCase(MsgKeywords[iter]);
    If IsDupe(MsgKeywords) then Exit(202);

    Inc(NOfEntries);
    SetLength(MsgKeywordsList, NOfEntries);
    SetLength(ReplyList, NOfEntries);
    MsgKeywordsList[High(MsgKeywordsList)] := MsgKeywords;
    ReplyList[High(ReplyList)] := Replies;
    Exit(200);
End;

{
    Add data, but this one takes strings instead of TStrArray.
    The strings are delimited using delimiters to create TStrArray,
    and these TStrArray are then passed to the primary TTimmy.Add().

    Return: TTimmy.Add(TStrArray, TStrArray)
}
Function TTimmy.Add(KeywordsStr, RepStr: String;
                    KStrDeli: String = ' '; MStrDeli: String = ';'): Integer;
Begin
    Exit(Add(StrSplit(KeywordsStr, KStrDeli), StrSplit(RepStr, MStrDeli)));
End;

{
    Add data, takes TStrArray for keywords clue and a pointer which
    pointes to the possible answer for the messages that contain the keywords.

    Return: 102 if the bot is not enabled
            202 if dupes check is enabled and a duplication is found
            203 if the operation is successful
}
Function TTimmy.Add(MsgKeywords: TStrArray; PAnswer: PStr): Integer;
Begin
    If not Enabled then Exit(102);
    If IsDupe(MsgKeywords) then Exit(202);

    Inc(NOfEntries);
    SetLength(MsgKeywordsList, NOfEntries);
    SetLength(PReplyList, NOfEntries - Length(ReplyList));
    MsgKeywordsList[High(MsgKeywordsList)] := MsgKeywords;
    PReplyList[High(PReplyList)] := PAnswer;

    Exit(203);
End;

{
    Functions like the above one but takes string instead of TStrArray.
    THe string is delimited using a delimiter to create a TStrArray,
    and the rest is for TTimmy.Add(TStrArray, PStr)

    Return: TTimmy.Add(TStrArray, PStr)
}
Function TTimmy.Add(KeywordsStr: String; PAnswer: PStr; KStrDeli: String = ' '): Integer;
Begin
    Exit(Add(StrSplit(KeywordsStr, KStrDeli), PAnswer));
End;

{
    Given a set of keywords, find matches to that set in MsgKeywordsList,
    remove the matches, and remove the correspondants in ReplyList as well.
    This function simply saves offsets of the matching arrays in MsgKeywordsList
    and then call TTimmy.Remove(AIndex: Integer).

    Return: 102 if object is not enabled
            308 if the operation succeed
}
Function TTimmy.Remove(MsgKeywords: TStrArray): Integer;
Var iter, counter: Integer;
    Indexes: Array of Integer;
Begin
    If not Enabled then Exit(102);

    For iter := Low(MsgKeywords) to High(MsgKeywords)
      do MsgKeywords[iter] := LowerCase(MsgKeywords[iter]);
    counter := -1;  // Matches counter in 0-based
    SetLength(Indexes, Length(MsgKeywordsList));

    // Get offsets of keywords set that match the given MsgKeywords parameter
    // and later deal with them using TTimmy.Remove(AIndex: Integer)
      For iter := Low(ReplyList) to Length(ReplyList) + High(PReplyList)
        do If CompareStrArrays(MsgKeywordsList[iter], MsgKeywords)
             then Begin
                    Inc(counter);
                    Indexes[counter] := iter;
                  End;

    Inc(counter);
    SetLength(Indexes, counter);
    While counter > 0
      do Begin
           Remove(Indexes[Length(Indexes) - counter] - Length(Indexes) + counter);
           Dec(counter);
         End;
    Exit(308);
End;

{
    The same as the above implementation of Remove, but allows
    use of custom string delimiter.

    Return TTimmy.Remove(MsgKeywords: TStrArray)
}
Function TTimmy.Remove(KeywordsStr: String; KStrDeli: String = ' '): Integer;
Begin
    Exit(Remove(StrSplit(KeywordsStr, KStrDeli)));
End;

{
    Remove data from MsgKeywordsList at MsgKeywordsList[AIndex]
    and answer(s) corresponding to the keywords at that offset.

    Return: 102 if the bot is not enabled
            305 if the given index is invalid (out of bound)
            300 if operation successful
}
Function TTimmy.Remove(AIndex: Integer): Integer;
Var iter: Integer;
Begin
    If not Enabled then Exit(102);
    If (AIndex < 0) or (AIndex >= NOfEntries) then Exit(305);

    If (AIndex < Length(ReplyList))
      then Begin  // Remove target is in ReplyList
             For iter := AIndex to High(ReplyList) - 1
               do ReplyList[iter] := ReplyList[iter + 1];
             SetLength(ReplyList, Length(ReplyList) - 1);
           End
      else Begin  // Remove target is in PReplyList
             For iter := Abs(NOfEntries - Length(PReplyList) - AIndex) to High(PReplyList) - 1
               do PReplyList[iter] := PReplyList[iter + 1];
             SetLength(PReplyList, Length(PReplyList) - 1);
           End;

    For iter := AIndex to High(MsgKeywordsList) - 1
      do MsgKeywordsList[iter] := MsgKeywordsList[iter + 1];

    Dec(NOfEntries);
    SetLength(MsgKeywordsList, NOfEntries);

    Exit(300);
End;

{
    Answer the given message, using assets in the metadata
}
Function TTimmy.Answer(TMessage: String): String;
Var MetaIter, MKIter, MWIter, counter, MaxMatch: Integer;
    FlagM: String;
    FlagWords: TStrArray;
Begin
    If not Enabled then Exit;

    // Pre-process the message
      FlagM := LowerCase(StrTrim(TMessage));
      // Delete punctuation at the end of the message (like "?" or "!")
        While True do Begin
                        Case FlagM[Length(FlagM)] of
                          'a'..'z', 'A'..'Z', '0'..'9': Break;
                        Else Delete(FlagM, Length(FlagM), 1);
                        End;
                      End;

    MaxMatch := -1;
    FlagWords := StrSplit(FlagM, ' ');
    For MetaIter := Low(MsgKeywordsList) to High(MsgKeywordsList)
      do Begin
           counter := 0;
           // Iterate over each keyword in each array in MsgKeywordsList
           For MKIter := Low(MsgKeywordsList[MetaIter]) to High(MsgKeywordsList[MetaIter])
             do For MWIter := Low(FlagWords) to High(FlagWords)
                  do If FlagWords[MWiter] = MsgKeywordsList[MetaIter][MKIter]
                       then Inc(counter);

           // Compare to TPercent
           If counter / Length(MsgKeywordsList[MetaIter]) * 100 >= TPercent
             then MaxMatch := MetaIter;
         End;

    // Not understood
    If MaxMatch = -1 then Exit(NoUdstdRep);

    // Understood
    If MaxMatch < Length(ReplyList)
      then Begin
             Randomize;
             Exit(ReplyList[MaxMatch][Random(Length(ReplyList[MaxMatch]))]);
           End
      else Exit(PReplyList[Abs(NOfEntries - Length(PReplyList) - MaxMatch)]^);

    Exit(NoUdstdRep);
End;

End.
