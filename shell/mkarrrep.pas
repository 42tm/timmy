{
    Create string representation of array, with length limit.

    Parameters:
        InputArr [TStrArray]: Array that needs a string representation
        LLimit: Length limit of the string representation.
    Return [String]: String representation.

    NOTE: This function does not handle the case where, InputArr is empty,
    because this function is mainly used by some parent Timmy Interactive Shell
    processes and there's no event where InputArr is empty.

    Examples (result strings are in double quotes):
      TestArray: ['a string', 'another string']

        MkArrayRep(TestArray, 30) -> "['a string','another string']"
        MkArrayRep(TestArray, 25) -> "['a string',...]"
        MkArrayRep(TestArray, 5)  -> "[...]"
        MkArrayRep(TestArray, 3)  -> "[]"
}
Function MkArrayRep(InputArr: TStrArray; LLimit: Word): String;
Var
    AIter: String;
Begin
    // This one isn't in the while loop (below) to increase loop execution speed
      MkArrayRep := '';
      For AIter in InputArr
        do MkArrayRep := Concat(MkArrayRep, '''', AIter, '''', ',');
      MkArrayRep := '[' + Copy(MkArrayRep, 1, Length(MkArrayRep) - 1) + ']';
      Writeln(Length(MkArrayRep));

    While (Length(MkArrayRep) > LLimit) and (Length(InputArr) > 0)
      do Begin
           MkArrayRep := '';
           SetLength(InputArr, High(InputArr));  // Decrease array's length by 1
           For AIter in InputArr
             do MkArrayRep := Concat(MkArrayRep, '''', AIter, '''', ',');
           MkArrayRep := '[' + Copy(MkArrayRep, 1, Length(MkArrayRep)) + '...]';
         End;

    If Length(InputArr) = 0
      then Begin If LLimit < 5 then Exit('') else Exit('[...]'); End;
End;
