{ BYTE magazine October 1982. Jerry Pournelle. }
{ various bugs not found because dimensions are square fixed by David Lee }
{ expected result: 4.65880E+05 }

{ array range checking off }
{$R- }
{ runtime exception checking off }
{$X- }

program matrix( output );

const
    l = 20; { rows in A and resulting matrix C }
    m = 20; { columns in A and rows in B (must be identical) }
    n = 20; { columns in B and resulting matrix C }

var
    A : array [ 1 .. l, 1 .. m ] of real; { [row,col] }
    B : array [ 1 .. m, 1 .. n ] of real;
    C : array [ 1 .. l, 1 .. n ] of real;

    Summ: real;

procedure filla;
var
    i, j : integer;
begin { filla }
    for i := 1 to l do
        for j := 1 to m do
            A[ i, j ] := i + j;
end; { filla }

procedure fillb;
var
    i, j : integer;
begin { fillb }
    for i := 1 to m do
        for j := 1 to n do
            B[ i, j ] := trunc( ( i + j ) / j );
end; { fillb }

procedure fillc;
var
    i, j : integer;
begin { fillc }
    for i := 1 to l do
        for j := 1 to n do
            C[ i, j ] := 0;
end; { fillc }

procedure matmult;
var
    i, j, k : integer;
begin { matmult }
    for i := 1 to l do
        for j := 1 to n do
            for k := 1 to m do
                C[ i, j ] := C[ i, j ] + A[ i, k ] * B[ k, j ];
end; { matmult }

procedure summit;
var
    i, j : integer;
begin { summit }
    for i := 1 to l do
        for j := 1 to n do
            Summ := Summ + C[ i, j ];
end; { summit }

begin { matrix }
    Summ := 0;

    filla;
    fillb;
    fillc;
    matmult;
    summit;

    Writeln( 'summ is :', Summ );
end. { matrix }

