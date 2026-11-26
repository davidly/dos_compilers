(* BYTE magazine October 1982. Jerry Pournelle. Matrix multiply.
   integer version: this Oberon-M has no REAL type. Each element of C fits
   in 16 bits; the sum is kept in base 10000. Oberon has no FOR loop, so
   the loops are WHILE loops. The output is written from the module body:
   LIO.WriteInt called from a procedure hangs in this program.
   expected result: 465880 *)

MODULE MM;
  IMPORT LIO;

  CONST
    N = 20;

  VAR
    res, summHi, summLo: INTEGER;
    a, b, c: ARRAY N, N OF INTEGER;
    r: LIO.Rider;

  PROCEDURE FillA;
    VAR i, j: INTEGER;
  BEGIN
    i := 0;
    WHILE i < N DO
      j := 0;
      WHILE j < N DO
        a[i, j] := i + j + 2;
        INC(j)
      END;
      INC(i)
    END
  END FillA;

  PROCEDURE FillB;
    VAR i, j: INTEGER;
  BEGIN
    i := 0;
    WHILE i < N DO
      j := 0;
      WHILE j < N DO
        b[i, j] := (i + j + 2) DIV (j + 1);
        INC(j)
      END;
      INC(i)
    END
  END FillB;

  PROCEDURE FillC;
    VAR i, j: INTEGER;
  BEGIN
    i := 0;
    WHILE i < N DO
      j := 0;
      WHILE j < N DO
        c[i, j] := 0;
        INC(j)
      END;
      INC(i)
    END
  END FillC;

  PROCEDURE MatMult;
    VAR i, j, k: INTEGER;
  BEGIN
    i := 0;
    WHILE i < N DO
      j := 0;
      WHILE j < N DO
        k := 0;
        WHILE k < N DO
          c[i, j] := c[i, j] + a[i, k] * b[k, j];
          INC(k)
        END;
        INC(j)
      END;
      INC(i)
    END
  END MatMult;

  PROCEDURE Summit;
    VAR i, j: INTEGER;
  BEGIN
    i := 0;
    WHILE i < N DO
      j := 0;
      WHILE j < N DO
        summLo := summLo + c[i, j];
        WHILE summLo >= 10000 DO
          summLo := summLo - 10000;
          INC(summHi)
        END;
        INC(j)
      END;
      INC(i)
    END
  END Summit;

BEGIN
  LIO.OpenWrite("CON", r, res);

  IF res = 0 THEN (* Success *)
    summHi := 0;
    summLo := 0;
    FillA;
    FillB;
    FillC;
    MatMult;
    Summit;
    LIO.Write(r, "summ is : ");
    LIO.WriteInt(r, summHi);
    IF summLo < 1000 THEN LIO.WriteInt(r, 0) END;
    IF summLo < 100 THEN LIO.WriteInt(r, 0) END;
    IF summLo < 10 THEN LIO.WriteInt(r, 0) END;
    LIO.WriteInt(r, summLo);
    LIO.WriteLn(r);
    LIO.Close(r)
  END
END MM.
