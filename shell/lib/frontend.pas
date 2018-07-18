{
    frontend.pas - Front-end utilities for the Timmy Interactive Shell

    Copyright (C) 2018 42tm Team <fourtytwotm@gmail.com>

    This file is part of Timmy Interactive Shell.

    Timmy Interactive Shell is free software: you can redistribute it
    and/or modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation, either version 3
    of the License, or (at your option) any later version.
}
{$mode ObjFPC} {$H+}
Unit FrontEnd;

Interface

Uses Crt;

Procedure Jam(DotColor: Byte);
Procedure Put(S: String; TextCl: ShortInt = -1;
              BreakLine: Boolean = False); overload;
Procedure Put(S: String; TextCl: ShortInt = -1; PosX: Word = 0; PosY: Word = 0;
              BreakLine: Boolean = False); overload;

Implementation

{
    Various log messages of level TLogger.INFO are in the Shell.
    Some of them indicate that a process has been done successfully,
    some of them just tell the user something. To make log messages
    of TLogger.INFO even more suggestive, this procedure is here to help.
    It prints a pair of square brackets, and a small square between those
    square brackets. This small square is written in the text color DotColor
    (the one and only parameter to this procedure). The text color is what
    makes the log message more suggestive.

    Parameters:
        DotColor [Byte]: Numeric input for TextBackground() to write the "dots"
}
Procedure Jam(DotColor: Byte);
Begin
    TextColor(7); Write('[');
    TextColor(DotColor); Write('▪');
    TextColor(7); Write('] ');
End;

{
    Write a string with custom text color

    Parameters:
        S [String]: The string to be written.
        TextCl [ShortInt]: Text color for S. Default is -1. If TextCl is
                           negative, then no change in text color.
        BreakLine: Use Write() to write the string if this value is false, use
                   Writeln() otherwise. Default is False.
}
Procedure Put(S: String; TextCl: ShortInt = -1; BreakLine: Boolean = False);
Begin
    If TextCl > -1 then TextColor(TextCl);
    If BreakLine then Writeln(S) else Write(S);
End;

{
    Write a string with custom text color, at custom position

    Note about position: There are PosX and PosY parameters for the position,
    which are then thrown at GoToXY() in Crt unit (GoToXY(PosX, PosY),
    basically). If PosX and PosY are both 0 (which they are by default),
    GoToXY() won't take effect. If one of these two is 0 (and the other one is
    not), the one with zero is set to 1 when thrown to GoToXY().

    Parameters:
        S [String]: The string to be written.
        TextCl [ShortInt]: Text color for S. Default is -1. If TextCl is
                           negative, then no change in text color.
        PosX [Word]: First parameter for GoToXY() (Crt unit). Default is 0.
        PosY [Word]: Second parameter for GoToXY() (Crt unit). Default is 0.
        BreakLine [Boolean]: Use Write() to write the string if this value is
                             false, use Writeln() otherwise. Default is False.
}
Procedure Put(S: String; TextCl: ShortInt = -1; PosX: Word = 0; PosY: Word = 0;
              BreakLine: Boolean = False);
Begin
    If TextCl > -1 then TextColor(TextCl);
    If (PosX <> 0) and (PosY <> 0) then GoToXY(PosX, PosY)
      else If (PosX <> 0) and (PosY = 0) then GoToXY(PosX, 1)
             else If (PosX = 0) and (PosY <> 0) then GoToXY(1, PosY);

    If BreakLine then Writeln(S) else Write(S);
End;

End.
