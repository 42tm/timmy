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
		NotUnderstandReply : String to assign to TTimmy.Answer in case there's no possible answer to the given question
	}
    TTimmy = Object
				 Initialized: Boolean;
                 Enabled: Boolean;
				 NOfEntries: Integer;
                 QKeywordsList: Array of Array of String;
				 ReplyList: Array of Array of String;
				 DupesCheck: Boolean;
				 NotUnderstandReply: String;
                 Function Init: Integer;
                 Function Add(QKeywords, Replies: Array of String): Integer;
                 Function Remove(QKeywords: Array of String): Integer;
				 Function RemoveByIndex(AIndex: Integer):Integer;
				 Procedure Update;
                 Function Answer(TQuestion: String): String;
             End;

Function CompareStrArrays(ArrayA, ArrayB: Array of String):Boolean;

Implementation

{
	Given two arrays of strings, compare them.
	Return true if they are the same, false otherwise.
}
Function CompareStrArrays(ArrayA, ArrayB: Array of String):Boolean;
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
	If Initialized then Init := 101
	else Begin
		   DupesCheck := True;
		   NOfEntries := 0;
		   Update;
	       Enabled := True;
		   Initialized := True;
		   Init := 100;
	     End;
End;

{
	Add data to bot object's metadata base.
	Data include question's keywords and possible replies to the question.

	Return: 102 if object is not initialized or enabled
			202 if DupesCheck = True and found a match to QKeywords in QKeywordsList
			200 if the adding operation succeed
}
Function TTimmy.Add(QKeywords, Replies: Array of String): Integer;
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

	Return: 102 if object is not initialized or not enabled
		    308 if the operation succeed
}
Function TTimmy.Remove(QKeywords: Array of String): Integer;
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

End.
