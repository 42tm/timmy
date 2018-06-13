{
    jam.pp - The Jam procedure for Shell frontend

    Copyright (C) 2018 42tm Team <fourtytwotm@gmail.com>

    This file is part of Timmy Interactive Shell.

    Timmy Interactive Shell is free software: you can redistribute it
    and/or modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation, either version 3
    of the License, or (at your option) any later version.
}

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
