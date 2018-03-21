Unit timmy;

Interface
Uses Classes;
Type
    TTimmy = Object
                 Enabled: Boolean;
                 NotUnderstandReply: String;
                 Initialized: Boolean;
                 MetaData: Array of Array of String;
                 Function Init:Integer;
                 Function Add(QKeywords, Replies, Pararms: Array of String):Integer;
                 Function Remove(QKeywords: Array of String):Integer;
                 Function Answer(TQuestion: String):String;
             End;

Implementation
End.
