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
               Constructor Init(Percent: Integer; DefaultRep: String; DpCheck: Boolean);
               Public
                 DupesCheck: Boolean;
                 TPercent: Integer;
                 NoUdstdRep: String;
                 Procedure Enable;
                 Procedure Disable;
                 Function  Add    (MsgKeywords, Replies: TStrArray):       Integer; overload;
                 Function  Add    (KeywordsStr, RepStr: String;
                                                RepStrDeli: String = ';'): Integer; overload;
                 Function  Add    (MsgKeywords: TStrArray; PAnswer: PStr): Integer; overload;
                 Function  Add    (KeywordsStr: String; PAnswer: PStr):    Integer; overload;
                 Function  Remove (MsgKeywords: TStrArray):                Integer; overload;
                 Function  Remove (KeywordsStr: String):                   Integer; overload;
                 Function  Remove (AIndex: Integer):                       Integer; overload;
                 Function  Answer (TMessage: String):                      String;
               Private
                 Enabled: Boolean;
                 NOfEntries: Integer;
                 MsgKeywordsList: Array of TStrArray;
                 ReplyList: Array of TStrArray;
                 PReplyList: PStrArray;
                 Function IsDupe(CheckMsgKeywords: TStrArray): Boolean;
             End;

Function StrTrim(S: String): String;
Function StrReplace(S, OrgSubStr, NewSubStr: String; CaseSensitive: Boolean = True): String;
Function StrSplit(S: String; Delim: String = ' '; ItprBackslash: Boolean = False): TStrArray;
Function StrJoin(StrList: TStrArray; Linker: String): String;
Function CompareStrArrays(ArrayA, ArrayB: TStrArray): Boolean;

Implementation

{
    Given a string, process it so that the first and the last
    characters are not space, and there is no multiple space
    characters in a row.

    Example:
        Input:  '     some    string   '
        Output: 'some string'
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
    Support backslash interpreting. Does not interpret
    backslash by default.

    Parameters:
        S: String to be delimited
	Delimiter: Delimiter for string S
	ItprBackslash: Option whether to interpret backslash or not

    Return: A TStrArray holding delimited parts of string S
}
Function StrSplit(S: String; Delim: String = ' '; ItprBackslash: Boolean = False): TStrArray;
Var
    iter, backiter, BackslashCount: Integer;
    NOfSkip: Byte;
    Flag: String;
Begin
    S := S + Delim;

    SetLength(StrSplit, 0);
    NOfSkip := 0;
    Flag := '';

    For iter := 1 to Length(S)
      do Begin
           // Skip current iteration if NOfSkip is not zero
             If NOfSkip > 0 then Begin
                                   Dec(NOfSkip);
                                   Continue;
                                 End;
           // If next characters make a delimiter, prepare to skip
           // Whether to add the delimiter to Flag or not is depended
           // on the backslash interpretion.
             If Copy(S, iter, Length(Delim)) = Delim
               then Begin
                      NOfSkip := Length(Delim) - 1;
                      If ItprBackslash
                        then Begin
                               // Count number of backslashes that precede
                               // the delimiter substring
                                 backiter := iter - 1;
                                 BackslashCount := 0;
                                 While (S[backiter] = '\') and (backiter > 0)
                                   do Begin
                                        Inc(BackslashCount);
                                        Dec(backiter);
                                      End;

                               // Add up the escaped backslash to Flag
                                 While BackslashCount > 1
                                   do Begin
                                        Flag := Flag + '\';
                                        Dec(BackslashCount, 2);
                                      End;

                               // If BackslashCount is 1 by now, that means
                               // the delimiter is escaped. Hence, add the
                               // delimiter string to Flag.
                                 If BackslashCount = 1
                                   then Begin
                                          Flag := Flag + Delim;
                                          Continue;
                                        End;
                           End;

                      // If Flag is not nothing, add it to return array
                        If Flag <> ''
                          then Begin
                                 Flag := StrReplace(Flag, '\\', '\');
                                 SetLength(StrSplit, Length(StrSplit) + 1);
                                 StrSplit[Length(StrSplit) - 1] := Flag;
                                 Flag := '';
                               End;
                  End
             else Begin
                    BackslashCount := 0;
                    backiter := iter;
                    While (Copy(S, backiter, Length(Delim)) <> Delim)
                      and (backiter < Length(S) + 1)
                      do Begin
                           If S[backiter] <> '\' then Inc(BackslashCount);
                           Inc(backiter);
                         End;
                    If BackslashCount > 0
                      then Flag := Flag + S[iter];
                  End;
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
    Check if given keywords clue CheckMsgKeywords
    is a duplicate of one that is already presented
    in MsgKeywordsList.

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
    Data include 2 TStrArray: message's keywords (MsgKeywords)
    and possible replies to the message (Replies).
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
Function TTimmy.Add(KeywordsStr, RepStr: String; RepStrDeli: String = ';'): Integer;
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
    Functions like the TTimmy.Add(TStrArray, PStr) but takes string
    instead of TStrArray. The string is delimited using space character
    to create a TStrArray, and the rest of the work
    is for TTimmy.Add(TStrArray, PStr)

    Return: TTimmy.Add(TStrArray, PStr)
}
Function TTimmy.Add(KeywordsStr: String; PAnswer: PStr): Integer;
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
    Remove data, this function takes a string. The string
    is delimited using the space character to get a TStrArray,
    and the rest of the task is passed to TTimmy.Remove(TStrArray).

    Return TTimmy.Remove(TStrArray)
}
Function TTimmy.Remove(KeywordsStr: String): Integer;
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
    Answer the given message TMessage, using assets in the metadata.
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
      else Exit(PReplyList[MaxMatch - Length(ReplyList)]^);

    Exit(NoUdstdRep);
End;

End.
