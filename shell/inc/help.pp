{
    The help command.
    If there's no argument, it prints the shell's overall guides.
    If an argument is specified, and it's the name of a command,
    then print the manual page of that command.

    Manual pages are found in /shell/man.
}
Procedure PrintHelp;
Var
    ManFileName, ManLine: String;
    ManF: Text;
Begin
    If Length(InputRec.Args) = 0
      then ManFileName := 'shell'
      else ManFileName := InputRec.Args[0];

    If not FileExists('man/' + ManFileName + '.txt')
      then Begin
             ShellLogger.Log(TLogger.ERROR, 'Could not find the manual entry for that');
             Exit;
           End
      else Begin
             Assign(ManF, 'man/' + ManFileName + '.txt');
             {$I-}
             Reset(ManF);
             {$I+}
             If IOResult <> 0
               then Begin
                      ShellLogger.Log(TLogger.ERROR, 'Failed to read manual entry');
                      Exit;
                    End;
             TextColor(7);
             While not EOF(ManF)
               do Begin
                    Readln(ManF, ManLine);
                    Writeln(ManLine);
                  End;
             Close(ManF);
           End;
End;
