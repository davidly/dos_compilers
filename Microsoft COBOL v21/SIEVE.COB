       IDENTIFICATION DIVISION.
       PROGRAM-ID. SIEVE.
      * Ten full 8190-flag sieve passes, not an extrapolated small run.
      * Two 4095-byte windows fit the DOS compiler's table limit.
      * Base primes are generated each pass; next multiples carry
      * between windows. No division is needed in the marking loop.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 BASE-TEXT PIC X(63).
       01 BASE-FLAGS REDEFINES BASE-TEXT.
          02 BASE-F PIC X OCCURS 63 TIMES INDEXED BY BASE-I BASE-K.
       01 PRIME-TABLE.
          02 PRIME-ENTRY OCCURS 31 TIMES
             INDEXED BY PRIME-I PRIME-COUNT.
             03 PRIME-VALUE PIC S9(4) COMP-0.
             03 NEXT-START PIC S9(4) COMP-0.
       01 FLAG-TEXT PIC X(4095).
       01 FLAG-DATA REDEFINES FLAG-TEXT.
          02 F PIC X OCCURS 4095 TIMES INDEXED BY MARK-C.
       01 WINDOW-INDEXES.
          02 WINDOW-BYTE PIC X OCCURS 2 TIMES INDEXED BY WINDOW-I.
       01 PRIME-N PIC S9(4) COMP-0.
       01 START-N PIC S9(4) COMP-0.
       01 TOTAL-PRIMES PIC 9(4).
       PROCEDURE DIVISION.
       MAIN.
           PERFORM SIEVE-PASS THRU PASS-DONE 10 TIMES.
           DISPLAY TOTAL-PRIMES ' primes'.
           STOP RUN.
       SIEVE-PASS.
           MOVE ALL '1' TO BASE-TEXT.
           MOVE 0 TO TOTAL-PRIMES.
           SET PRIME-COUNT TO 0.
           SET BASE-I TO 1.
           MOVE 3 TO PRIME-N.
       FIND-BASE.
           IF BASE-F(BASE-I) = '0' GO TO NEXT-BASE.
           SET PRIME-COUNT UP BY 1.
           MOVE PRIME-N TO PRIME-VALUE(PRIME-COUNT).
           MULTIPLY PRIME-N BY PRIME-N GIVING START-N.
           SUBTRACT 1 FROM START-N.
           DIVIDE START-N BY 2 GIVING START-N.
           MOVE START-N TO NEXT-START(PRIME-COUNT).
           SET BASE-K TO START-N.
       STRIKE-BASE.
           IF BASE-K > 63 GO TO NEXT-BASE.
           MOVE '0' TO BASE-F(BASE-K).
           SET BASE-K UP BY PRIME-N.
           GO TO STRIKE-BASE.
       NEXT-BASE.
           SET BASE-I UP BY 1.
           ADD 2 TO PRIME-N.
           IF BASE-I < 64 GO TO FIND-BASE.
           SET WINDOW-I TO 1.
       NEXT-WINDOW.
           MOVE ALL '1' TO FLAG-TEXT.
           SET PRIME-I TO 1.
       START-PRIME.
           MOVE PRIME-VALUE(PRIME-I) TO PRIME-N.
           SET MARK-C TO NEXT-START(PRIME-I).
       STRIKE-WINDOW.
           IF MARK-C > 4095 GO TO SAVE-NEXT.
           MOVE '0' TO F(MARK-C).
           SET MARK-C UP BY PRIME-N.
           GO TO STRIKE-WINDOW.
       SAVE-NEXT.
           SET MARK-C DOWN BY 4095.
           SET NEXT-START(PRIME-I) TO MARK-C.
           SET PRIME-I UP BY 1.
           IF PRIME-I NOT > PRIME-COUNT GO TO START-PRIME.
           INSPECT FLAG-TEXT TALLYING TOTAL-PRIMES FOR ALL '1'.
           SET WINDOW-I UP BY 1.
           IF WINDOW-I < 3 GO TO NEXT-WINDOW.
       PASS-DONE.
           EXIT.
