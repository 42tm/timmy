Uses Logger, Timmy in '../../timmy.pas';
Var TestLogger: TLogger;

BEGIN
    TestLogger.Init(20, 10, 'log.dat');
    TestLogger.Log(TLogger.WARNING, 'This is a warning');
END.
