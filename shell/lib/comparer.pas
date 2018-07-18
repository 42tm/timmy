{
    comparer.pas - Comparer for the Timmy Interactive Shell's frontend.

    Copyright (C) 2018 42tm Team <fourtytwotm@gmail.com>

    This file is part of Timmy Interactive Shell.

    Timmy Interactive Shell is free software: you can redistribute it
    and/or modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation, either version 3
    of the License, or (at your option) any later version.
}
{$Mode ObjFPC} {$H+}

Unit Comparer;

Interface

Uses
    Crt, SysUtils, StrUtils,
    Core in '../core.pas';

Type
    TCmpr = Object
              Constructor Init(TestingProc: String);
              Destructor EndCmprProc;
              Public
                Procedure Cmpr(eint, gint: LongInt; VarName: String);               overload;
                Procedure Cmpr(ebool, gbool: Boolean; VarName: String);             overload;
                Procedure Cmpr(estr, gstr, VarName: String);                        overload;
                Procedure Cmpr(estrarr, gstrarr: Array of String; VarName: String); overload;
              Private
                TestProcName: String;
                NormLine, SpcLine: String;
                CorrectCprs, TotalCprs: Byte;
                Col2Width, Col3Width: Word;
                Procedure MkBox(BoxWidth: Word; BoxText: String;
                                BoxTextColor: ShortInt = 15; ESig: String = '');
                Function BoolToInt(ABool: Boolean): ShortInt;
                Function ArrayRepr(InputArray: Array of String; LLimit: Word): String;
            End;

Implementation

{
    Initiate the comparing process.

    Timmy Interactive Shell use TCmpr to compare values to test methods in the
    Timmy library. The output is in the form of table. This constructor draws
    the head of a table (much like the <thead> tag in HTML).
}
Constructor TCmpr.Init(TestingProc: String);
Begin
    // *** SETTING UP SOME VARIABLES *** \\

    TestProcName := TestingProc;

    // Timmy Interactive Shell uses a 3-column table for comparing.
    // The first column holds the variable names, the second for the expected
    // values, and the third is for the 'got' values. The first column is always
    // 24 in width. Width of the second column and the third column, however,
    // vary depend on the user's command prompt window's width. Col2Width is the
    // width of the second column, and Col2Width is the width of the third one.
      Col2Width := Trunc((WindMaxX - 28) / 2);
      Col3Width := Round((WindMaxX - 28) / 2);

    // Lines between the rows of the table. SpcLine will appear above and under
    // the table's head, and under the whole table. NormLine will appear between
    // normal rows.
      SpcLine := Concat('*', DupeString('-', 24), '*',
                        DupeString('-', Col2Width), '*',
                        DupeString('-', Col3Width), '*');
      NormLine := ReplaceStr(SpcLine, '*', '|');

    // *** DRAW TABLE'S HEAD ***
      TextColor(7); Writeln(SpcLine);
      MkBox(24, 'Variable', 11, 'FIRSTBOX');   // First column
      MkBox(Col2Width, 'Expected', 11);        // Second column
      MkBox(Col3Width, 'Got', 11, 'ENDHEAD');  // Third column
End;

{ Print out the comparing result, end the comparing session. }
Destructor TCmpr.EndCmprProc;
Begin
    Writeln;
    TextColor(14); Writeln('Testing results');
    TextColor(7);  Writeln('===============');
    Writeln;
    Jam(9); Write('Input: '); TextColor(15); Writeln(UserInput);
    Jam(9); Write('Method tested: '); TextColor(15); Writeln(TestProcName);

    // Print result
      Jam(9); Write('Results: '); TextColor(15); Write('Got ');
      If CorrectCprs = TotalCprs then TextColor(10) else TextColor(12);
      Write(CorrectCprs, ' out of ', TotalCprs);
      TextColor(15); Write(' compared values correctly as expected');

    Writeln;
End;

{
    Draw a new box in the current row

    Parameters:
        BoxWidth [Word]: Width of the box to be drawn.
        BoxText [AnsiString]: Text inside the box.
        BoxTextColor [Byte]: Text color's value for the text inside the box.
                             0 and -1 values are reserved for BoolToInt()
        ESig [AnsiString]: Signal acting as options to the procedure.

    Valid signals for Esig parameter:
        1. 'FIRSTBOX' : The box to be drawn is the first box in the row, which,
                        the pipe character ("|") also need to be drawn first
        2. 'LASTBOX'  : The box to be drawn is the last box in the row, so after
                        drawing the box, move the cursor to the next line
        3. 'ENDHEAD'  : The box to be drawn is the last box in the table's head
        4. 'ENDTABLE' : The box to be drawn is the last box in the table
}
Procedure TCmpr.MkBox(BoxWidth: Word; BoxText: String;
                      BoxTextColor: ShortInt = 15; ESig: String = '');
Begin
    TextColor(7); If ESig = 'FIRSTBOX' then Write('|');
    Write(DupeString(' ', Trunc((BoxWidth - Length(BoxText)) / 2)));
    Case BoxTextColor of
      0: TextColor(10);   // Reserved for BoolToInt()
      -1: TextColor(12);  // Reserved for BoolToInt()
      Else TextColor(BoxTextColor);
    End;
    If Length(BoxText) > BoxWidth
      then Begin
             Write(Copy(BoxText, 1, Length(BoxText) - 5));
             If BoxTextColor = 15 then TextColor(7) else TextColor(15);
             Write('...');
           End
      else Write(BoxText);
    Write(DupeString(' ', Round((BoxWidth - Length(BoxText)) / 2)));
    TextColor(7); Write('|');

    If ESig = ''
      then Exit
      else Begin
             Writeln;
             If ESig = 'LASTBOX' then Writeln(NormLine) else Writeln(SpcLine);
           End;
End;

{
    Convert boolean to numeric type.

    Parameter:
        ABool [Boolean]: Boolean value to be converted
    Return [ShortInt]: 0 if ABool is true, -1 otherwise
}
Function TCmpr.BoolToInt(ABool: Boolean): ShortInt;
Begin If ABool then Exit(0); Exit(-1); End;

{
    Create string representation for array of string such that it is only
    LLimit or shorter in length.

    ArrayRepr(['some string', 'another string'], 35)
      -> '['some string','another string']'

    ArrayRepr(['some string', 'another string'], 20)
      -> '['some string', ...]'

    Parameters:
        InputArray [Array of String]: Input array
        LLimit [Word]: Length limit (in characters) for the output string
    Return [String]: String representation of InputArray
}
Function TCmpr.ArrayRepr(InputArray: Array of String; LLimit: Word): String;
Var
    iter: LongWord;
Begin
    // String representation. Will be exitted with "[" and "]" characters later
      ArrayRepr := '';

    { The last element does not need a comma after it, so only itererate to
    Length(InputArray) - 2. Special case with the last element is dealt
    later. }

    For iter := 0 to Length(InputArray) - 2
      do { If we take the current string representation, and add the next
         string in the array to it, and the thing does not exceed the LLimit,
         add it to the string representation. The "5" in the first clause in
         the if statement are the total length of the comma (put after every
         array element in the representation), the square brackets pair
         ("[" and "]") at the start and end of the representation, and the
         single quotes wrap around the string element, so those add up to 5
         characters in length. }
           If Length(ArrayRepr) + 5 + Length(InputArray[iter]) < LLimit
             then ArrayRepr := ArrayRepr + '''' + InputArray[iter] + ''','
             else Break;

    {
        If we are at the final element in the array, and the final element can
        be added to the string representation without having the representation
        size to exceed LLimit, then add it.
        The "4" in "Length(InputArray[iter + 1]) + 4" is the total length of the
        pair of square brackets ("[" and "]") must be added at the start and end
        of the string, plus the single quotes around the last string element.
    }
    If (iter = Length(InputArray) - 2) and (Length(ArrayRepr)
      + Length(InputArray[iter + 1]) + 4 <= LLimit)
      then Exit('[' + ArrayRepr + '''' + InputArray[iter + 1] + ''']');

    { We cannot add more to the representation, as it would make the length of
    the representation to exceed LLimit. So we return with an ellipsis
    ("...") to indicate that there are still more elements in the array }
    Exit('[' + ArrayRepr + '...]');
End;

Procedure TCmpr.Cmpr(eint, gint: LongInt; VarName: String);
Begin
    MkBox(24, VarName, 14, 'FIRSTBOX');
    MkBox(Col2Width, IntToStr(eint));
    MkBox(Col3Width, IntToStr(gint), BoolToInt(eint = eint), 'LASTBOX');
End;

Procedure TCmpr.Cmpr(ebool, gbool: Boolean; VarName: String);
Begin
    MkBox(24, VarName, 14, 'FIRSTBOX');
    MkBox(Col2Width, BoolToStr(ebool, True));
    MkBox(Col3Width, BoolToStr(gbool, True), BoolToInt(ebool = gbool),
          'LASTBOX');
End;

Procedure TCmpr.Cmpr(estr, gstr, VarName: String);
Begin
    MkBox(24, VarName, 14, 'FIRSTBOX');
    MkBox(Col2Width, estr);
    MkBox(Col3Width, gstr, BoolToInt(estr = gstr), 'LASTBOX');
End;

Procedure TCmpr.Cmpr(estrarr, gstrarr: Array of String; VarName: String);
Var
    SameArrays: Boolean;
    AIter: LongWord;
Begin
    SameArrays := True;
    If Length(estrarr) <> Length(gstrarr)
      then SameArrays := False
      else For AIter := 0  to High(estrarr)
             do If estrarr[AIter] <> gstrarr[AIter]
                  then Begin
                         SameArrays := False;
                         Break;
                       End;

    MkBox(24, VarName, 14, 'FIRSTBOX');
    MkBox(Col2Width, ArrayRepr(estrarr, Col2Width));
    MkBox(Col3Width, ArrayRepr(gstrarr, Col3Width),
          BoolToInt(SameArrays), 'LASTBOX');
End;

End.
