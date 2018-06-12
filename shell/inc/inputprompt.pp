{
    inputprompt.pp - Input prompt method for Timmy Interactive Shell

    Copyright (C) 2018 42tm Team <fourtytwotm@gmail.com>

    This file is part of Timmy Interactive Shell.

    Timmy Interactive Shell is free software: you can redistribute it
    and/or modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation, either version 3
    of the License, or (at your option) any later version.
}

{
    User command prompt for Timmy Shell.
    This prompt highlights the command with a blue color.
    Also let the user go to previous/next command.
}
Function InputPrompt: String;
Var
    Flag,                 // String on display
    FlagCurrent: String;  // Current user input string
    InputKey: Char;       // Character to assign ReadKey to
    CursorX,              // Current X position of the cursor
    HistoryPos,           // Position in Env.InputHis, used when user press up/down
    FlagIter:             // Iteration for the string Flag (local)
              LongWord;
Begin
    Flag := ''; FlagCurrent := '';
    CursorX := 4;
    HistoryPos := Length(Env.InputHis);
    While True
      do Begin
           If (HistoryPos = Length(Env.InputHis)) then Flag := FlagCurrent;
           Delline; Insline;
           GoToXY(1, WhereY);
           TextColor(15);
           Write('>> ');  // Prompt string

           // Print command with blue color
             TextColor(11);
             Flag := Flag + ' ';
             For FlagIter := 1 to Pos(' ', Flag) - 1 do Write(Flag[FlagIter]);
           // Print rest of the current user's command string (with white color)
             TextColor(15);
             For FlagIter := Pos(' ', Flag) to Length(Flag) - 1
               do Write(Flag[FlagIter]);

           Delete(Flag, Length(Flag), 1);
           GoToXY(CursorX, WhereY);
           InputKey := Readkey;
           Case Ord(InputKey) of
             0: Begin
                  InputKey := Readkey;
                  Case InputKey of
                    #75: If CursorX > 4 then Dec(CursorX);
                    #77: If CursorX < Length(Flag) + 4 then Inc(CursorX);
                    #72: // Go back to previous command only if
                         // the input history is not empty
                           If Length(Env.InputHis) > 0
                             then Begin
                                    If HistoryPos = Length(Env.InputHis)
                                      then FlagCurrent := Flag;  // Save the current input
                                    If HistoryPos > 0
                                      then Begin
                                             Dec(HistoryPos);
                                             Flag := Env.InputHis[HistoryPos];
                                             CursorX := 4 + Length(Flag);
                                           End;
                                  End;
                    #80: // Go to next command
                           If HistoryPos < Length(Env.InputHis)
                             then Begin
                                    Inc(HistoryPos);
                                    If HistoryPos = Length(Env.InputHis)
                                      then CursorX := 4 + Length(FlagCurrent)
                                      else Begin
                                             Flag := Env.InputHis[HistoryPos];
                                             CursorX := 4 + Length(Flag);
                                           End;
                                  End;
                  End;
                End;
             13: Exit(Flag);  // Enter key
             32..126: Begin  // A text character
                        Flag := Copy(Flag, 1, CursorX - 4)
                                     + InputKey
                                     + Copy(Flag, CursorX - 3,
                                            Length(Flag) - CursorX + 4);
                        If HistoryPos = Length(Env.InputHis)
                          then FlagCurrent := Flag;
                        Inc(CursorX);
                      End;
             8: Begin  // Backspace key
                  If CursorX = 4 then Continue;
                  Delete(Flag, CursorX - 4, 1);
                  If HistoryPos = Length(Env.InputHis) then FlagCurrent := Flag;
                  Dec(CursorX);
                End;
           End;
         End;
End;
