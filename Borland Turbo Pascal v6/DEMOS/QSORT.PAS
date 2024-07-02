
{ Turbo Sort }
{ Copyright (c) 1985,90 by Borland International, Inc. }

program qsort;
{$R-,S-}
uses Crt;

{ This program demonstrates the quicksort algorithm, which      }
{ provides an extremely efficient method of sorting arrays in   }
{ memory. The program generates a list of 1000 random numbers   }
{ between 0 and 29999, and then sorts them using the QUICKSORT  }
{ procedure. Finally, the sorted list is output on the screen.  }
{ Note that stack and range checks are turned off (through the  }
{ compiler directive above) to optimize execution speed.        }

const
  max = 1000;

type
  list = array[1..max] of integer;

var
  data: list;
  i: integer;

{ QUICKSORT sorts elements in the array A with indices between  }
{ LO and HI (both inclusive). Note that the QUICKSORT proce-    }
{ dure provides only an "interface" to the program. The actual  }
{ processing takes place in the SORT procedure, which executes  }
{ itself recursively.                                           }

procedure quicksort(var a: list; Lo,Hi: integer);

procedure sort(l,r: integer);
var
  i,j,x,y: integer;
begin
  i:=l; j:=r; x:=a[(l+r) DIV 2];
  repeat
    while a[i]<x do i:=i+1;
    while x<a[j] do j:=j-1;
    if i<=j then
    begin
      y:=a[i]; a[i]:=a[j]; a[j]:=y;
      i:=i+1; j:=j-1;
    end;
  until i>j;
  if l<j then sort(l,j);
  if i<r then sort(i,r);
end;

begin {quicksort};
  sort(Lo,Hi);
end;

begin {qsort}
  Write('Now generating 1000 random numbers...');
  Randomize;
  for i:=1 to max do data[i]:=Random(30000);
  Writeln;
  Write('Now sorting random numbers...');
  quicksort(data,1,max);
  Writeln;
  for i:=1 to 1000 do Write(data[i]:8);
end.
