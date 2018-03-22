{
	timmy - Pascal unit for creating chat bots

	Created by Nguyen Hoang Duong (@NOVAglow) @ 42tm
	on 19 March, 2018.

    Copyright (C) 2018, 42tm

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
}
Unit timmy;

Interface
Type
	TStrArray = Array of String;

	{
		Metadata refers to two arrays holding data:
			QKeywordsList which holds keywords, and
			ReplyList which holds replies

		  QKeywordsList [                                 ReplyList [
                         [*keywords for question 1*],                [*possible answers for question 1*],
                         [*keywords for question 2*],                [*possible answers for question 2*],
		                             ...                                             ...
		                                             ]                                                   ]

	  Variables:

		Initialized        : State of initialization
		Enabled            : Acts like Initialized but used in fewer number of functions
		NOfEntries         : Number of entries (elements) in QKeywordsList or ReplyList
		DupesCheck         : Check for duplicate or not (might be time-saving if we don't check for duplicate)
		TPercent           : Minimum percentage of the number of keywords over all the words of the question
							 so that the bot object can "understand" and have a reply.
						     Sorry I don't have a good way to explain it.
		NotUnderstandReply : String to assign to TTimmy.Answer in case there's no possible answer to the given question
	}
    TTimmy = Object
				 Initialized: Boolean;
                 Enabled: Boolean;
				 NOfEntries: Integer;
                 QKeywordsList: Array of Array of String;
				 ReplyList: Array of Array of String;
				 DupesCheck: Boolean;
				 TPercent: Integer;
				 NotUnderstandReply: String;
                 Function Init: Integer;
                 Function Add(QKeywords, Replies: TStrArray): Integer;
                 Function Remove(QKeywords: TStrArray): Integer;
				 Function RemoveByIndex(AIndex: Integer):Integer;
				 Procedure Update;
                 Function Answer(TQuestion: String): String;
             End;

Function StrProcessor(S: String):String;
Function StrSplit(S: String; delimiter: Char):TStrArray;
Function CompareStrArrays(ArrayA, ArrayB: TStrArray):Boolean;

Implementation

{
	Given a string, process it so that the first and the last
	character are not space, and there is no multiple spaces
	character in a row.
}
Function StrProcessor(S: String):String;
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

	StrProcessor := FlagStr;
End;

{
	Given a string, split the string using the delimiter
	and return an array containing the seperated strings.
}
Function StrSplit(S: String; delimiter: Char):TStrArray;
Var iter, counter: Integer;
	FlagStr: String;
Begin
	While S[1] = delimiter do Delete(S, 1, 1);
	While S[Length(S)] = delimiter do Delete(S, Length(S), 1);
	FlagStr := '';
	counter := -1;

	For iter := 1 to Length(S)
	do If S[iter] <> delimiter
	   then FlagStr := FlagStr + S[iter]
	   else Begin
	   		  If FlagStr = '' then Continue;
	   		  Inc(counter);
			  SetLength(StrSplit, counter);
			  StrSplit[counter] := FlagStr;
			  FlagStr := '';
	   	    End;
End;

{
	Given two arrays of strings, compare them.
	Return true if they are the same, false otherwise.
}
Function CompareStrArrays(ArrayA, ArrayB: TStrArray):Boolean;
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
   NotUnderstandReply := 'Sorry, I didn''t get that';
   TPercent := 70;
   NOfEntries := 0;
   Update;
   Enabled := True;
   Initialized := True;
   Exit(100);
End;

{
	Add data to bot object's metadata base.
	Data include question's keywords and possible replies to the question.

	Return: 102 if object is not initialized or enabled
			202 if DupesCheck = True and found a match to QKeywords in QKeywordsList
			200 if the adding operation succeed
}
Function TTimmy.Add(QKeywords, Replies: TStrArray): Integer;
Var iter: Integer;
Begin
	If (not Initialized) or (not Enabled) then Exit(102);
	If (DupesCheck) and (NOfEntries > 0)
	then For iter := Low(QKeywordsList) to High(QKeywordsList) do
		   If CompareStrArrays(QKeywordsList[iter], QKeywords) then Exit(202);

	Inc(NOfEntries); Update;
	QKeywordsList[High(QKeywordsList)] := QKeywords;
	ReplyList[High(ReplyList)] := Replies;
	Exit(200);
End;

{
	Given a set of keywords, find matches to that set in QKeywordsList,
	remove the matches, and remove the correspondants in ReplyList as well.
	This function simply saves offsets of the matching arrays in QKeywordsList
	and then call TTimmy.RemoveByIndex().

	Return: 102 if object is not initialized or not enabled
		    308 if the operation succeed
}
Function TTimmy.Remove(QKeywords: TStrArray): Integer;
Var iter, counter: Integer;
	Indexes: Array of Integer;
Begin
	If (not Initialized) or (not Enabled) then Exit(102);

	counter := -1;  // Matches counter in 0-based
	SetLength(Indexes, Length(QKeywordsList));

	// Get offsets of keywords set that match the given QKeywords parameter
	// and later deal with them using TTimmy.RemoveByIndex
	  For iter := Low(QKeywordsList) to High(QKeywordsList) do
	    If CompareStrArrays(QKeywordsList[iter], QKeywords)
		then Begin
	  	       Inc(counter);
			   Indexes[counter] := iter;
			 End;

	Inc(counter);
	SetLength(Indexes, counter);
	While counter > 0 do Begin
						   RemoveByIndex(Indexes[Length(Indexes) - counter] - Length(Indexes) + counter);
						   Dec(counter);
						 End;
	Exit(308);
End;

{
	Delete array at offset AIndex in QKeywordsList and in ReplyList

	Return: 102 if not initialized or enabled
			305 if AIndex is invalid
			300 if the operation succeed
}
Function TTimmy.RemoveByIndex(AIndex: Integer):Integer;
Var iter: Integer;
Begin
	If (not Initialized) or (not Enabled) then Exit(102);
	If (AIndex < 0) or (AIndex >= NOfEntries) then Exit(305);

	For iter := AIndex to High(QKeywordsList) - 1
	do QKeywordsList[iter] := QKeywordsList[iter + 1];
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

	SetLength(QKeywordsList, NOfEntries);
	SetLength(ReplyList, NOfEntries);
End;

Function TTimmy.Answer(TQuestion: String): String;
Var MetaIter, QKIter, QWIter, counter, GetAnswer: Integer;
	FlagQ: String;
	LastChar: Char;
	FlagWords: TStrArray;
Begin
	// Pre-process the question
	  FlagQ := StrProcessor(TQuestion);
	  // Delete punctuation at the end of the question (like "?" or "!")
	    While True do Begin
		  		        LastChar := FlagQ[Length(FlagQ)];
					    Case LastChar of
					      'a'..'z', 'A'..'Z': Break;
					    Else Delete(FlagQ, Length(FlagQ), 1);
					    End;
				      End;

	FlagWords := StrSplit(FlagQ, ' ');
	For MetaIter := 0 to NOfEntries - 1
	do Begin
		 counter := 0;
	     For QKIter := Low(QKeywordsList[MetaIter]) to High(QKeywordsList[MetaIter])
		 do For QWiter := Low(FlagWords) to High(FlagWords)
			do If FlagWords[QWiter] = QKeywordsList[MetaIter][QKIter] then Inc(counter);
	     If counter / Length(QKeywordsList[MetaIter]) * 100 >= TPercent
		 then Begin
		 	    Randomize;
				Repeat GetAnswer := Random(Length(ReplyList[MetaIter]) + 1) Until GetAnswer > 0;
				Exit(ReplyList[MetaIter][GetAnswer]);
		 	  End;
	   End;

	Exit(NotUnderstandReply);
End;

End.