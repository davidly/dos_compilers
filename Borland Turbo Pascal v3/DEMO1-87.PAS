program HilbDemo87;
{
          TURBO-87 DEMONSTRATION PROGRAM  Version 1.00A

      This program demonstrates the increased speed and precision
      of the TURBO-87 compiler:

      --------------------------------------------------
      From: Pascal Programs for Scientists and Engineers

      Alan R. Miller, Sybex
      n x n inverse hilbert matrix
      solution is 1 1 1 1 1
      double precision version
      --------------------------------------------------

      The program performs simultaneous solution by Gauss-Jordan
      elimination.

      INSTRUCTIONS
      1.  Compile the program using the TURBO-87.COM compiler.
      2.  Type Ctrl-C to interrupt the program.
}

CONST
  maxr = 10;
  maxc = 10;

TYPE
  ary   = ARRAY[1..maxr] OF real;
  arys  = ARRAY[1..maxc] OF real;
  ary2s = ARRAY[1..maxr, 1..maxc] OF real;

VAR
  y          : arys;
  coef       : arys;
  a, b       : ary2s;
  n, m, i, j : integer;
  error      : boolean;

PROCEDURE gaussj
  (VAR b     : ary2s;  (* square matrix of coefficients *)
    y        : arys;  (* constant vector *)
    VAR coef : arys;  (* solution vector *)
    ncol     : integer;  (* order of matrix *)
    VAR error: boolean); (* true if matrix singular *)

(*  Gauss Jordan matrix inversion and solution *)
(*  Adapted from McCormick  *)
(*  Feb  8, 81 *)
(*   B(N,N) coefficient matrix, becomes inverse *)
(*   Y(N)   original constant vector *)
(*   W(N,M) constant vector(s) become solution vector *)
(*   DETERM is the determinant *)
(*   ERROR = 1 if singular *)
(*   INDEX(N,3) *)
(*   NV is number of constant vectors *)

LABEL 
  99,98;

VAR
  w    : ARRAY[1..maxc, 1..maxc] OF real;
  index: ARRAY[1..maxc, 1..3] OF integer;
  i, j, k, l, nv, irow, icol, n, l1   : integer;
  determ, pivot, hold, sum, t, ab, big: real;

PROCEDURE swap(VAR a, b: real);

VAR
  hold: real;

BEGIN  (* swap *)
  hold := a;
  a := b;
  b := hold
END  (* procedure swap *);


BEGIN     (* Gauss-Jordan main program *)
  error := false;
  nv := 1 (* single constant vector *);
  n := ncol;
  FOR i := 1 TO n DO
    BEGIN
      w[i, 1] := y[i] (* copy constant vector *);
      index[i, 3] := 0
    END;
  determ := 1.0;
  FOR i := 1 TO n DO
    BEGIN
      (* search for largest element *)
      big := 0.0;
      FOR j := 1 TO n DO
        BEGIN
          IF index[j, 3] <> 1 THEN
            BEGIN
              FOR k := 1 TO n DO
                BEGIN
                  IF index[k, 3] > 1 THEN
                    BEGIN
                      writeln(' ERROR: matrix singular');
                      error := true;
                      GOTO 98        (* abort *)
                    END;
                  IF index[k, 3] < 1 THEN
                    IF abs(b[j, k]) > big THEN
                      BEGIN
                        irow := j;
                        icol := k;
                        big := abs(b[j, k])
                      END
                END (* k loop *)
            END
        END (* j loop *);
      index[icol, 3] := index[icol, 3] + 1;
      index[i, 1] := irow;
      index[i, 2] := icol;

  (* interchange rows to put pivot on diagonal *)
  IF irow <> icol THEN
    BEGIN
      determ := - determ;
      FOR l := 1 TO n DO
        swap(b[irow, l], b[icol, l]);
      IF nv > 0 THEN
        FOR l := 1 TO nv DO
          swap(w[irow, l], w[icol, l])
    END; (* if irow <> icol *)

      (* divide pivot row by pivot column *)
      pivot := b[icol, icol];
      determ := determ * pivot;
      b[icol, icol] := 1.0;
      FOR l := 1 TO n DO
        b[icol, l] := b[icol, l] / pivot;
      IF nv > 0 THEN
        FOR l := 1 TO nv DO
          w[icol, l] := w[icol, l] / pivot;
      (*  reduce nonpivot rows *)
      FOR l1 := 1 TO n DO
        BEGIN
          IF l1 <> icol THEN
            BEGIN
              t := b[l1, icol];
              b[l1, icol] := 0.0;
              FOR l := 1 TO n DO
                b[l1, l] := b[l1, l] - b[icol, l] * t;
              IF nv > 0 THEN
                FOR l := 1 TO nv DO
                  w[l1, l] := w[l1, l] - w[icol, l] * t;
            END   (* IF l1 <> icol *)
        END
    END (* i loop *);
  98:

  IF error THEN GOTO 99;
  (* interchange columns *)
  FOR i := 1 TO n DO
    BEGIN
      l := n - i + 1;
      IF index[l, 1] <> index[l, 2] THEN
        BEGIN
          irow := index[l, 1];
          icol := index[l, 2];
          FOR k := 1 TO n DO
            swap(b[k, irow], b[k, icol])
        END (* if index *)
    END  (* i loop *);
  FOR k := 1 TO n DO
    IF index[k, 3] <> 1 THEN
      BEGIN
        writeln(' ERROR: matrix singular');
        error := true;
        GOTO 99   (* abort *)
      END;
  FOR i := 1 TO n DO
    coef[i] := w[i, 1];
  99:
END (* procedure gaussj *);


PROCEDURE get_data(VAR a : ary2s;
                   VAR y : arys;
                   VAR n, m : integer);

(* setup n-by-n hilbert matrix *)

VAR
  i, j : integer;

BEGIN
  FOR i := 1 TO n DO
    BEGIN
      a[n,i] := 1.0/(n + i - 1);
      a[i,n] := a[n,i]
    END;
  a[n,n] := 1.0/(2*n -1);
  FOR i := 1 TO n DO
    BEGIN
      y[i] := 0.0;
      FOR j := 1 TO n DO
        y[i] := y[i] + a[i,j]
    END;
  writeln;
  IF n < 7 THEN
    BEGIN
      FOR i:= 1 TO n  DO
        BEGIN
          FOR j:= 1 TO m DO
            write( a[i,j] :7:5, '  ');
          writeln( ' : ', y[i] :7:5)
        END;
      writeln
    END  (* if n<7 *)
END (* procedure get_data *);

PROCEDURE write_data;

(* print out the answers *)

VAR
  i : integer;

BEGIN
  FOR i := 1 TO m DO
    write( coef[i] :13:9);
  writeln;
END (* write_data *);


BEGIN  (* main program *)
  a[1,1] := 1.0;
  n := 2;
  m := n;
  REPEAT
    get_data (a, y, n, m);
    FOR i := 1 TO n DO
      FOR j := 1 TO n DO
        b[i,j] := a[i,j] (* setup work array *);
    gaussj (b, y, coef, n, error);
    IF not error THEN write_data;
    n := n+1;
    m := n
  UNTIL n > maxr;
END.
