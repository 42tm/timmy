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
{$mode ObjFPC} {$H+}
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
               Constructor Init(Percent: Byte; DefaultRep: String; DpCheck: Boolean);
               Public
                 DupesCheck: Boolean;
                 TPercent: Byte;
                 NoUdstdRep: String;
                 Procedure Enable;
                 Procedure Disable;
                 Function  Add    (MsgKeywords, Replies: TStrArray):       Word; overload;
                 Function  Add    (KeywordsStr, RepStr: String;
                                                RepStrDeli: String = ';'): Word; overload;
                 Function  Add    (MsgKeywords: TStrArray; PAnswer: PStr): Word; overload;
                 Function  Add    (KeywordsStr: String; PAnswer: PStr):    Word; overload;
                 Function  Remove (MsgKeywords: TStrArray):                Word; overload;
                 Function  Remove (KeywordsStr: String):                   Word; overload;
                 Function  Remove (AIndex: LongWord):                      Word; overload;
                 Function  Answer (TMessage: String):                      String;
               Private
                 Enabled: Boolean;
                 NOfEntries: LongWord;
                 MsgKeywordsList: Array of TStrArray;
                 ReplyList: Array of TStrArray;
                 PReplyList: PStrArray;
                 Function IsDupe(CheckMsgKeywords: TStrArray): Boolean;
             End;

Function StrTrim(S: String; RmMultSpace: Boolean = True): String;
Function StrReplace(S, OrgSubStr, NewSubStr: String; CaseSensitive: Boolean = True): String;
Function StrSplit(S: String; Delim: String = ' '; ItprBackslash: Boolean = False): TStrArray;
Function StrJoin(StrList: TStrArray; Linker: String): String;
Function CompareStrArrays(ArrayA, ArrayB: TStrArray): Boolean;

Implementation

{
    Given string S, process it so that the first and the last
    characters are not space.
    If RmMultSpace parameter is true (by default it is), remove
    multiple space characters in a row within the string too.

    Example:
        Input:  '     some    string   '
        Output (with RmMultSpace = True): 'some string'
        Output (with RmMultSpace = False): 'some    string'
}
Function StrTrim(S: String; RmMultSpace: Boolean = True): String;
Var iter: Integer;
    SpaceOn: Boolean;
Begin
    While Pos(' ', S) = 1 do Delete(S, 1, 1);
    If S = '' then Exit(S);
    While S[Length(S)] = ' ' do Delete(S, Length(S), 1);
    If not RmMultSpace then Exit(S);
    StrTrim := '';
    SpaceOn := False;
    For iter := 1 to Length(S)
      do If S[iter] <> ' '
           then Begin
                  StrTrim := StrTrim + S[iter];
                  SpaceOn := False;
                End
           else Begin
                  If SpaceOn then Continue;
                  StrTrim := StrTrim + ' ';
                  SpaceOn := True;
                End;
End;

{
    Find OrgSubStr in S and replace them with NewSubStr.
    Option for case-sensitivity is also allowed, by default
    the search is not case-sensitive.
    Note: This function replaces ALL of the occurrences.

    Parameters:
        S: The string to search in
        OrgSubStr: Substring in string S to be replaced
        NewSubStr: Replacement for OrgSubStr in S
        CaseSensitive: Option to specify whether the search should be case-sensitive
    Return:
        The new string
}
Function StrReplace(S, OrgSubStr, NewSubStr: String; CaseSensitive: Boolean = True): String;
Var
    SIter, SkipLeft, Idx: LongWord;
    Flag: String;
    StartPoints: Array of LongWord;
Begin
    If S = '' then Exit(S);
    If not CaseSensitive then OrgSubStr := LowerCase(OrgSubStr);
    SetLength(StartPoints, 0);
    SkipLeft := 0;

    // Iterate over string S to find original string (OrgSubStr)
      For SIter := 1 to Length(S) - Length(OrgSubStr) + 1
        do Begin
             // Skip the iteration because the current character at this index
             // in string S (S[SIter]) is a part of a found original substring.
               If SkipLeft > 0
                 then Begin
                        Dec(SkipLeft);
                        Continue;
                      End;

             // Assign Flag, is used later to compare if it matches the
             // original substring.
               Flag := Copy(S, SIter, Length(OrgSubStr));
               If not CaseSensitive then Flag := LowerCase(Flag);

             // Compare Flag to original substring. If the two strings are
             // the same, save its starting position in S (which is SIter)
             // and later replace using Delete and Insert methods.
               If Flag = OrgSubStr
                 then Begin
                        SetLength(StartPoints, Length(StartPoints) + 1);
                        StartPoints[Length(StartPoints) - 1] := SIter;
                        SkipLeft := Length(OrgSubStr) - 1;
                      End;
           End;

    // If no match is found, exit to avoid run-time error
      If Length(StartPoints) = 0 then Exit(S);

    StrReplace := S;
    For SIter := 0 to High(StartPoints)
      do Begin
           Idx := StartPoints[SIter]
                + (Length(NewSubStr) - Length(OrgSubStr)) * (SIter);
           // Delete original sub-string
             Delete(StrReplace, Idx, Length(OrgSubStr));
           // Insert new sub-string
             Insert(NewSubStr, StrReplace, Idx);
         End;
End;

{
    Given a string S, split the string using Delimiter
    and return an array containing the separated strings.
    If no delimiter Delimiter is found in string S,
    a TStrArray of only one value is returned, and that
    only one value is the original string S.
    Delimiter has a default value of a space character.
    Support backslash interpretation. Does not interpret
    backslash by default.

    Parameters:
        S: String to be delimited
	Delimiter: Delimiter for string S
	ItprBackslash: Option whether to interpret backslash or not

    Return: A TStrArray holding delimited parts of string S
}
Function StrSplit(S: String; Delim: String = ' '; ItprBackslash: Boolean = False): TStrArray;
Var
    jiter, backiter: LongWord;
    Flag: String;
Begin
    SetLength(StrSplit, 0);
    Flag := '';

    // Jump to the first delimiter substring of string S
    // The characters preceding the it will be processed
      jiter := Pos(Delim, S);
    While jiter <> 0
      do Begin
           backiter := jiter - 1;
           // Add all the characters preceding the delimiter to Flag
             Flag := Flag + Copy(S, 1, backiter);

           If ItprBackslash
             then Begin
                    // backiter helps count the number of backslashes
                    // that precede the delimiter
                      While (backiter > 0) and (S[backiter] = '\')
                        do Dec(backiter);

                    // jiter - 1 - backiter is the number of backslashes that
                    // precede the delimiter. A backslash escapes a backslash,
                    // hence, 2 backslashes make only 1 backslash. If the number
                    // of backslashes is even, that means there's actually no
                    // backslash that escapes the delimiter, only backslashes
                    // that escape other backslashes, thus add them (the
                    // backslashes) to Flag. If the number of backslashes is odd
                    // , however, that means there's one backslash that escapes
                    // the delimiter. Thus, add the delimiter to Flag.
                      If (jiter - 1 - backiter) mod 2 = 1
                        then Begin
                               // There's a backslash character that escapes the
                               // delimiter, and it is not supposed to get added
                               // to Flag. However, we did add it in a previous
                               // Copy() statement. So we need to remove it.
                                 Delete(Flag, Length(Flag), 1);
                               // Delimiter is escaped by backslash.
                               // Add the delimiter to Flag, then.
                                 Flag := Flag + Delim;
                               // This is special case
                                 If jiter = Length(S)
                                   then Begin
                                          SetLength(StrSplit, Length(StrSplit) + 1);
                                          StrSplit[High(StrSplit)] := Flag;
                                          Exit;
                                        End;
                               Delete(S, 1, jiter + Length(Delim) - 1);
                               jiter := Pos(Delim, S);
                               Continue;
                             End;
                  End;

           // Delete the first substring of the original string S, so that the
           // delimiter that is the closest to the head of the string (S[1])
           // is gone. jiter later gets assigned to the index of the
           // delimiter (closest to head) in the partly-deleted S string.
           // The process begins again.
             Delete(S, 1, jiter + Length(Delim) - 1);
           // A backslash escapes a backslash if backslash interpretation is on
             If ItprBackslash then Flag := StrReplace(Flag, '\\', '\');
           // If Flag is not an empty string, add it to output TStrArray
             If Flag <> ''
               then Begin
                      SetLength(StrSplit, Length(StrSplit) + 1);
                      StrSplit[High(StrSplit)] := Flag;
                    End;
           Flag := '';
           // The string was previously partly-deleted. Now jiter gets assigned
           // to the index of the new delimiter in the new string S.
             jiter := Pos(Delim, S);
         End;

    // Add the rest of the string to the output TStrArray
      If S <> ''
        then Begin
               If ItprBackslash then S := StrReplace(S, '\\', '\');
               SetLength(StrSplit, Length(StrSplit) + 1);
               StrSplit[High(StrSplit)] := S;
             End;
End;

{
    Given a TStrArray (array of string), join them using Linker.
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
Var iter: LongWord;
Begin
    If Length(ArrayA) <> Length(ArrayB) then Exit(False);
    For iter := 0 to Length(ArrayA) - 1
      do If ArrayA[iter] <> ArrayB[iter] then Exit(False);
    Exit(True);
End;

{
    Initialize object with some default values set.
}
Constructor TTimmy.Init(Percent: Byte; DefaultRep: String; DpCheck: Boolean);
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
    Check if given keywords clue CheckMsgKeywords
    is a duplicate of one that is already presented
    in MsgKeywordsList.

    Return true if duplication check is enabled and
    a duplicate is found, false otherwise.
}
Function TTimmy.IsDupe(CheckMsgKeywords: TStrArray): Boolean;
Var iter: LongWord;
Begin
    If (not DupesCheck) or (NOfEntries = 0) then Exit(False);

    For iter := 0 to High(MsgKeywordsList)
      do If CompareStrArrays(MsgKeywordsList[iter], CheckMsgKeywords)
           then Exit(True);

    Exit(False);
End;

{
    Add data to bot object's metadata base.
    Data include 2 TStrArray: message's keywords (MsgKeywords)
    and possible replies to the message (Replies).
    *** PRIMARY ADD FUNCTION ***

    Return: 102 if object is not enabled
            202 if DupesCheck = True and found a match to MsgKeywords in MsgKeywordsList
            200 if the adding operation succeed
}
Function TTimmy.Add(MsgKeywords, Replies: TStrArray): Word;
Var iter: LongWord;
Begin
    If not Enabled then Exit(102);
    For iter := 0 to High(MsgKeywords)
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

    Parameters:
        KeywordsStr [String]: String input for keywords, will be delimited
                              using a space character to get a TStrArray
        RepStr [String]: String input for possible replies for messages
                         containing those in KeywordsStr, will be delimited
                         using RStrDeli (semicolon by default) to
                         form a TStrArray
        RStrDeli [String]: Delimiter for RepStr, default is a semicolon
    Return: TTimmy.Add(TStrArray, TStrArray)
}
Function TTimmy.Add(KeywordsStr, RepStr: String; RepStrDeli: String = ';'): Word;
Begin
    Exit(Add(StrSplit(KeywordsStr), StrSplit(RepStr, RepStrDeli)));
End;

{
    Add data, takes MsgKeywords (a TStrArray) for keywords clue
    and pointer PAnswer (a String^) which points to the possible answer
    for the messages that contain the keywords.

    Return: 102 if the bot is not enabled
            202 if dupes check is enabled and a duplication is found
            203 if the operation is successful
}
Function TTimmy.Add(MsgKeywords: TStrArray; PAnswer: PStr): Word;
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
    Functions like the TTimmy.Add(TStrArray, PStr) but takes string
    instead of TStrArray. The string is delimited using space character
    to create a TStrArray, and the rest of the work
    is for TTimmy.Add(TStrArray, PStr)

    Return: TTimmy.Add(TStrArray, PStr)
}
Function TTimmy.Add(KeywordsStr: String; PAnswer: PStr): Word;
Begin
    Exit(Add(StrSplit(KeywordsStr), PAnswer));
End;

{
    Given a set of keywords MsgKeywords, find matches to that set
    in MsgKeywordsList, remove the matches, and remove the correspondants
    in ReplyList as well.
    This function simply saves offsets of the matching arrays in MsgKeywordsList
    and then call TTimmy.Remove(Integer).

    Return: 102 if object is not enabled
            308 if the operation succeed
}
Function TTimmy.Remove(MsgKeywords: TStrArray): Word;
Var iter, counter: LongWord;
    Indexes: Array of Integer;
Begin
    If not Enabled then Exit(102);

    For iter := 0 to High(MsgKeywords)
      do MsgKeywords[iter] := LowerCase(MsgKeywords[iter]);
    counter := 0;
    SetLength(Indexes, Length(MsgKeywordsList));

    // Get offsets of keywords set that match the given MsgKeywords parameter
    // and later deal with them using TTimmy.Remove(AIndex: Integer)
      For iter := 0 to Length(ReplyList) + High(PReplyList)
        do If CompareStrArrays(MsgKeywordsList[iter], MsgKeywords)
             then Begin
                    Indexes[counter] := iter;
                    Inc(counter);
                  End;

    SetLength(Indexes, counter);
    While counter > 0
      do Begin
           Remove(Indexes[Length(Indexes) - counter] - Length(Indexes) + counter);
           Dec(counter);
         End;
    Exit(308);
End;

{
    Remove data, this function takes a string. The string
    is delimited using the space character to get a TStrArray,
    and the rest of the task is passed to TTimmy.Remove(TStrArray).

    Return TTimmy.Remove(TStrArray)
}
Function TTimmy.Remove(KeywordsStr: String): Word;
Begin
    Exit(Remove(StrSplit(KeywordsStr)));
End;

{
    Remove data from MsgKeywordsList at MsgKeywordsList[AIndex]
    and answer(s) corresponding to the keywords at that offset.

    Return: 102 if the bot is not enabled
            305 if the given index is invalid (out of bound)
            300 if operation successful
}
Function TTimmy.Remove(AIndex: LongWord): Word;
Var iter: LongWord;
Begin
    If not Enabled then Exit(102);
    If AIndex >= NOfEntries then Exit(305);

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
    Answer the given message TMessage, using assets in the metadata.
}
Function TTimmy.Answer(TMessage: String): String;
Var MetaIter, MKIter, MWIter, counter, MaxMatch: LongWord;
    FlagM: String;
    FlagWords: TStrArray;
    FoundReply: Boolean;
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

    MaxMatch := 0;
    FoundReply := False;
    FlagWords := StrSplit(FlagM);
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
             then Begin
                    MaxMatch := MetaIter;
                    FoundReply := True;
                  End;
         End;

    // Not understood
    If not FoundReply then Exit(NoUdstdRep);

    // Understood
    If MaxMatch < Length(ReplyList)
      then Begin
             Randomize;
             Exit(ReplyList[MaxMatch][Random(Length(ReplyList[MaxMatch]))]);
           End
      else Exit(PReplyList[MaxMatch - Length(ReplyList)]^);

    Exit(NoUdstdRep);
End;

End.
