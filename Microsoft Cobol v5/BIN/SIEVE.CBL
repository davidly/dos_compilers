       IDENTIFICATION DIVISION.
       PROGRAM-ID. SIEVE.
      * Native unsigned COMP-5 fields avoid numeric conversions.
      * Ten complete 8190-flag passes with byte flags.
      * Mark from P squared; only primes through 127 need striking.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 FLAG-TEXT PIC X(8190).
       01 FLAG-DATA REDEFINES FLAG-TEXT.
          02 F PIC X OCCURS 8190 TIMES.
       01 PRIME-N PIC 9(4) COMP-5.
       01 START-N PIC 9(4) COMP-5.
       01 TOTAL-PRIMES PIC 9(4).
       01 BASE-I PIC 9(4) COMP-5.
       01 MARK-C PIC 9(4) COMP-5.
       PROCEDURE DIVISION.
       MAIN.
           PERFORM SIEVE-PASS THRU PASS-DONE 10 TIMES.
           DISPLAY TOTAL-PRIMES ' primes'.
           STOP RUN.
       SIEVE-PASS.
           MOVE ALL '1' TO FLAG-TEXT.
           MOVE 3 TO PRIME-N.
           MOVE 1 TO BASE-I.
       NEXT-BASE.
           IF F(BASE-I) = '0' GO TO ADVANCE-BASE.
           MOVE PRIME-N TO START-N.
           MULTIPLY PRIME-N BY START-N.
           SUBTRACT 1 FROM START-N.
           DIVIDE 2 INTO START-N.
           MOVE START-N TO MARK-C.
       STRIKE-FLAG.
           IF MARK-C > 8190 GO TO ADVANCE-BASE.
           MOVE '0' TO F(MARK-C).
           ADD PRIME-N TO MARK-C.
           GO TO STRIKE-FLAG.
       ADVANCE-BASE.
           ADD 1 TO BASE-I.
           ADD 2 TO PRIME-N.
           IF PRIME-N < 128 GO TO NEXT-BASE.
           MOVE 0 TO TOTAL-PRIMES.
           INSPECT FLAG-TEXT TALLYING TOTAL-PRIMES FOR ALL '1'.
       PASS-DONE.
           EXIT.
