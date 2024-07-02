{$N-}
program Hilb;
{

  The program performs simultaneous solution by Gauss-Jordan
  elimination.

  --------------------------------------------------
  From: Pascal Programs for Scientists and Engineers

  Alan R. Miller, Sybex
  n x n inverse hilbert matrix
  solution is 1 1 1 1 1
  double precision version
  --------------------------------------------------

  INSTRUCTIONS
  1.  Compile and run the program using the $N- (Numeric Processing :
      Software) compiler directive.
  2.  if you have a math coprocessor in your computer, compile and run the
      program using the $N+ (Numeric Processing : Hardware) compiler
      directive.  Compare the speed and precision of the results to those
      of example 1.
}

const
  maxr = 10;
  maxc = 10;

type
{$IFOPT N+}                        { use extended type if using 80x87 }
  real  = extended;
{$ENDIF}
  ary   = array[1..maxr] of real;
  arys  = array[1..maxc] of real;
  ary2s = array[1..maxr, 1..maxc] of real;

var
  y          : arys;
  coef       : arys;
  a, b       : ary2s;
  n, m, i, j : integer;
  error      : boolean;

procedure gaussj
  (var b     : ary2s;  (* square matrix of coefficients *)
    y        : arys;  (* constant vector *)
    var coef : arys;  (* solution vector *)
    ncol     : integer;  (* order of matrix *)
    var error: boolean); (* true if matrix singular *)

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

var
  w    : array[1..maxc, 1..maxc] of real;
  index: array[1..maxc, 1..3] of integer;
  i, j, k, l, nv, irow, icol, n, l1   : integer;
  determ, pivot, hold, sum, t, ab, big: real;

procedure swap(var a, b: real);

var
  hold: real;

begin  (* swap *)
  hold := a;
  a := b;
  b := hold
end  (* procedure swap *);


begin     (* Gauss-Jordan main program *)
  error := false;
  nv := 1 (* single constant vector *);
  n := ncol;
  for i := 1 to n do
    begin
      w[i, 1] := y[i] (* copy constant vector *);
      index[i, 3] := 0
    end;
  determ := 1.0;
  for i := 1 to n do
    begin
      (* search for largest element *)
      big := 0.0;
      for j := 1 to n do
        begin
          if index[j, 3] <> 1 then
            begin
              for k := 1 to n do
                begin
                  if index[k, 3] > 1 then
                    begin
                      writeln(' ERROR: matrix singular');
                      error := true;
                      exit;         (* abort *)
                    end;
                  if index[k, 3] < 1 then
                    if abs(b[j, k]) > big then
                      begin
                        irow := j;
                        icol := k;
                        big := abs(b[j, k])
                      end
                end (* k loop *)
            end
        end (* j loop *);
      index[icol, 3] := index[icol, 3] + 1;
      index[i, 1] := irow;
      index[i, 2] := icol;

  (* interchange rows to put pivot on diagonal *)
  if irow <> icol then
    begin
      determ := - determ;
      for l := 1 to n do
        swap(b[irow, l], b[icol, l]);
      if nv > 0 then
        for l := 1 to nv do
          swap(w[irow, l], w[icol, l])
    end; (* if irow <> icol *)

      (* divide pivot row by pivot column *)
      pivot := b[icol, icol];
      determ := determ * pivot;
      b[icol, icol] := 1.0;
      for l := 1 to n do
        b[icol, l] := b[icol, l] / pivot;
      if nv > 0 then
        for l := 1 to nv do
          w[icol, l] := w[icol, l] / pivot;
      (*  reduce nonpivot rows *)
      for l1 := 1 to n do
        begin
          if l1 <> icol then
            begin
              t := b[l1, icol];
              b[l1, icol] := 0.0;
              for l := 1 to n do
                b[l1, l] := b[l1, l] - b[icol, l] * t;
              if nv > 0 then
                for l := 1 to nv do
                  w[l1, l] := w[l1, l] - w[icol, l] * t;
            end   (* if l1 <> icol *)
        end
    end (* i loop *);

  if error then exit;
  (* interchange columns *)
  for i := 1 to n do
    begin
      l := n - i + 1;
      if index[l, 1] <> index[l, 2] then
        begin
          irow := index[l, 1];
          icol := index[l, 2];
          for k := 1 to n do
            swap(b[k, irow], b[k, icol])
        end (* if index *)
    end  (* i loop *);
  for k := 1 to n do
    if index[k, 3] <> 1 then
      begin
        writeln(' ERROR: matrix singular');
        error := true;
        exit;   (* abort *)
      end;
  for i := 1 to n do
    coef[i] := w[i, 1];
end (* procedure gaussj *);


procedure get_data(var a : ary2s;
                   var y : arys;
                   var n, m : integer);

(* setup n-by-n hilbert matrix *)

var
  i, j : integer;

begin
  for i := 1 to n do
    begin
      a[n,i] := 1.0/(n + i - 1);
      a[i,n] := a[n,i]
    end;
  a[n,n] := 1.0/(2*n -1);
  for i := 1 to n do
    begin
      y[i] := 0.0;
      for j := 1 to n do
        y[i] := y[i] + a[i,j]
    end;
  writeln;
  if n < 7 then
    begin
      for i:= 1 to n  do
        begin
          for j:= 1 to m do
            write( a[i,j] :7:5, '  ');
          writeln( ' : ', y[i] :7:5)
        end;
      writeln
    end  (* if n<7 *)
end (* procedure get_data *);

procedure write_data;

(* print out the answers *)

var
  i : integer;

begin
  for i := 1 to m do
    write( coef[i] :13:9);
  writeln;
end (* write_data *);


begin  (* main program *)
  a[1,1] := 1.0;
  n := 2;
  m := n;
  repeat
    get_data (a, y, n, m);
    for i := 1 to n do
      for j := 1 to n do
        b[i,j] := a[i,j] (* setup work array *);
    gaussj (b, y, coef, n, error);
    if not error then write_data;
    n := n+1;
    m := n
  until n > maxr;
end.
