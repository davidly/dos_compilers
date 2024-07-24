       01 SQLCA.
           05  SQLCAID         PIC X(8).
           05  SQLCABC         PIC S9(9) COMP-5.
           05  SQLCODE         PIC S9(9) COMP-5.
           05  SQLERRM.
               49  SQLERRML    PIC S9(4) COMP-5.
               49  SQLERRMC    PIC X(70).
           05  SQLERRP         PIC X(8).
           05  SQLERRD         PIC S9(9) COMP-5 OCCURS 6.
           05  SQLWARN.
               10  SQLWARN0    PIC X.
               10  SQLWARN1    PIC X.
               10  SQLWARN2    PIC X.
               10  SQLWARN3    PIC X.
               10  SQLWARN4    PIC X.
               10  SQLWARN5    PIC X.
               10  SQLWARN6    PIC X.
               10  SQLWARN7    PIC X.
           05  SQLEXT          PIC X(8).

