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
    Crt, SysUtils, StrUtils, FrontEnd;

Type
    TCmpr = Object
              Constructor Init(TestingProc, UsrInput: String);
              Destructor EndCmprProc;
              Public
                Procedure AddData(eint, gint: LongInt; VarName: String);               overload;
                Procedure AddData(ebool, gbool: Boolean; VarName: String);             overload;
                Procedure AddData(estr, gstr, VarName: String);                        overload;
                Procedure AddData(estrarr, gstrarr: Array of String; VarName: String); overload;
                Procedure MkTable;
              Private
                TestProcName, UserInput, NormLine, SpcLine: String;
                Col1Width, Col2Width, Col3Width: Word;
                Order: String;
                TCmprData: Record
                             VarNames: Array of String;
                             IntArr: Array of LongInt;
                             BoolArr: Array of Boolean;
                             StrArr: Array of String;
                             StrArrArr: Array of Array of String;
                             ResultCache: Array of Boolean;
                           End;
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
Constructor TCmpr.Init(TestingProc, UsrInput: String);
Begin
    // Just setting up some variables
    TestProcName := TestingProc;
    UserInput := UsrInput;
    Order := '';
    SetLength(VarNames, 0);
End;

{ Print out the comparing result, end the comparing session. }
Destructor TCmpr.EndCmprProc;
Var
    CIter: Boolean;   // Iterator for TCmpr.CmprData.ResultCache;
    // Number of correct results (i.e. booleans that are true)
    // in TCmpr.CmprData.ResultCache;
      FlagResult: Byte = 0;
Begin
    Writeln;
    TextColor(14); Writeln('Testing results');
    TextColor(7);  Writeln('===============');
    Writeln;
    Jam(9); Write('Input: '); TextColor(15); Writeln(UserInput);
    Jam(9); Write('Method tested: '); TextColor(15); Writeln(TestProcName);

    For CIter in CmprData.ResultCache do If CIter then Inc(FlagResult);

    // Print result
      Jam(9); Write('Results: '); TextColor(15); Write('Got ');
      If FlagResult = Length(CmprData.ResultCache)
        then TextColor(10) else TextColor(12);
      Write(FlagResult, ' out of ', Length(CmprData.ResultCache));
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

    If (ESig = '') or (ESig = 'FIRSTBOX')
      then Exit;

    Writeln;
    If ESig = 'LASTBOX' then Writeln(NormLine) else Writeln(SpcLine);
End;

{
    Convert boolean to numeric type, for TCmpr.MkBox().

    Parameter:
        ABool [Boolean]: Boolean value to be converted
    Return [ShortInt]: 0 if ABool is true, -1 otherwise
}
Function TCmpr.BoolToInt(ABool: Boolean): ShortInt;
Begin If ABool then Exit(0); Exit(-1); End;

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

{
    Convert boolean to string type.

    Parameter:
        ABool [Boolean]: Boolean value to be converted
    Return [String]: "True" if ABool is true, "False" otherwise.
}
Function TCmpr.BoolToStr(ABool: Boolean): String;
Begin If ABool then Exit('True'); Exit('False'); End;

// *******************************************************
// *                  ADD DATA ROUTINES                  *
// *                  -----------------                  *
// *                                                     *
// * 1. Add variable's name to VarNames array            *
// * 2. Append a character to the string Order:          *
// *     - Append 'i' if data's type is integer          *
// *     - Append 'b' if data's type is boolean          *
// *     - Append 's' if data's type is string           *
// *     - Append 'a' if data's type is array of string  *
// * 3. Add the value of data to                         *
// *    TCmprData.ARRAY_OF_CORRESPONDING_DATA            *
// * 4. Compare two variables. Add a TRUE boolean to     *
// *    TCmprData.ResultCache if their values are the    *
// *    the same, FALSE boolean otherwise                *
// *                                                     *
// *******************************************************


Procedure TCmpr.AddData(eint, gint: LongInt; VarName: String);
Begin
    SetLength(VarNames, Length(VarNames) + 1);
    VarNames[High(VarNames)] := VarName;
    Order := Order + 'i';
    SetLength(TCmprData.IntArr, Length(TCmprData.IntArr) + 2);
    TCmprData.IntArr[High(TCmprData.IntArr) - 1] := eint;
    TCmprData.IntArr[High(TCmprData.IntArr)] := gint;
    SetLength(TCmprData.ResultCache, Length(TCmprData.ResultCache) + 1);
    TCmprData.ResultCache[High(TCmprData.ResultCache)] := (eint = gint);
End;

Procedure TCmpr.AddData(ebool, gbool: Boolean; VarName: String);
Begin
    SetLength(VarNames, Length(VarNames) + 1);
    VarNames[High(VarNames)] := VarName;
    Order := Order + 'b';
    SetLength(TCmprData.BoolArr, Length(TCmprData.BoolArr) + 2);
    TCmprData.BoolArr[High(TCmprData.BoolArr) - 1] := ebool;
    TCmprData.BoolArr[High(TCmprData.BoolArr)] := gbool;
    SetLength(TCmprData.ResultCache, Length(TCmprData.ResultCache) + 1);
    TCmprData.ResultCache[High(TCmprData.ResultCache)] := (ebool = gbool);
End;

Procedure TCmpr.AddData(estr, gstr, VarName: String);
Begin
    SetLength(VarNames, Length(VarNames) + 1);
    VarNames[High(VarNames)] := VarName;
    Order := Order + 's';
    SetLength(TCmprData.StrArr, Length(TCmprData.StrArr) + 2);
    TCmprData.StrArr[High(TCmprData.StrArr) - 1] := estr;
    TCmprData.StrArr[High(TCmprData.StrArr)] := gstr;
    SetLength(TCmprData.ResultCache, Length(TCmprData.ResultCache) + 1);
    TCmprData.ResultCache[High(TCmprData.ResultCache)] := (estr = gstr);
End;

Procedure TCmpr.AddData(estrarr, gstrarr: Array of String; VarName: String);
Var
    TestIter: LongWord;
Begin
    SetLength(VarNames, Length(VarNames) + 1);
    VarNames[High(VarNames)] := VarName;
    Order := Order + 'a';
    SetLength(TCmprData.StrArr, Length(TCmprData.StrArr) + 2);
    TCmprData.StrArr[High(TCmprData.StrArr) - 1] := estrarr;
    TCmprData.StrArr[High(TCmprData.StrArr)] := gstrarr;
    SetLength(TCmprData.ResultCache, Length(TCmprData.ResultCache) + 1);
    If Length(estrarr) <> Length(gstrarr)
      then TCmprData.ResultCache[High(TCmprData.ResultCache)] := False
      else Begin
             For TestIter := 0 to High(estrarr)
               do If estrarr[TestIter] <> gstrarr[TestIter] then Break;
             TCmprData.ResultCache[High(TCmprData.ResultCache)]
                    := ( (TestIter = High(estrarr))
                       and (estrarr[High(estrarr)] = gstrarr[High(gstrarr)]) );
           End;
End;

Procedure TCmpr.MkTable;
Var
    Iter: LongWord;   // General iterator
    OrderIter: Byte;  // Iterator for TCmpr.Order
    // Total computed length of the three columns with inputed data,
    // use in compare with WindMaxX
      FlagTotalLen: Word;
    // Iterators for IntArr, BoolArr, StrArr, StrArrArr in TCmpr.TCmprData
      IntDIter, BoolDIter, StrDIter, AStrDIter: Byte;
    StrReps: Array of String;
Lable
    PrintRawResult;
Begin
    // ******************************************
    // *      DETERMINE THE COLUMNS' WIDTH      *
    // ******************************************

    Col1Width := 0;

    For Iter := 0 to High(TCmprData.VarNames)
      do If Length(TCmprData.VarNames[Iter]) > Col1Width
           then Col1Width := Length(TCmprData.VarNames[Iter]);

    If Pos('a', Order) + Pos('s', Order) = 0
      then Begin
             Col2Width := 0;
             IntDIter := 0; BoolDIter := 0; StrDIter := 0; AStrDIter := 0;

             For OrderIter in Order
               do Begin
                    Case OrderIter of
                      'i': Begin
                             If Length(IntToStr[IntDIter]) > Col2Width
                               then Col2Width := Length(IntToStr[IntDIter]);
                             Inc(IntDIter);
                           End;
                      'b': Begin
                             If Length(BoolToStr[BoolDIter]) > Col2Width
                               then Col2Width := Length(BoolToStr[BoolDIter]);
                             Inc(BoolDIter);
                           End;
                    End;

                    If Col2Width * 2 > WindMaxX
                      then Begin
                             TextColor(12);
                             Write('Cmpr: Window''s width isn''t wide enough.');
                             Writeln; Exit;
                           End;
                  End;
           End
      Else Begin
             Col2Width := Trunc((WindMaxX - Col1Width) / 2);
             Col3Width := Round((WindMaxX - Col1Width) / 2);

             For OrderIter in Order
               do Begin
                    Case OrderIter of
                      'i': Begin
                             If Length(IntToStr[IntDIter]) > Col2Width
                               then Col2Width := Length(IntToStr[IntDIter]);
                             Inc(IntDIter);
                           End;
                      'b': Begin
                             If Length(BoolToStr[BoolDIter]) > Col2Width
                               then Col2Width := Length(BoolToStr[BoolDIter]);
                             Inc(BoolDIter);
                           End;
                      's': Begin
                             If Length()
                           End;
                    End;
           End;
End;

End.
