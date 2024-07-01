{ Bubble Sort Demonstration Program }
{       Microsoft Pascal 3.1        }

{ The main routine reads from the terminal an array  }
{ of ten real numbers and calls the procedure BUBBLE }
{ to sort them.                                      }

program BubbleSort(input,output);

  const
    TABLEN = 10;                    { Length of reals table }

  type
    TABLE = array[1 .. TABLEN] of real4;
                                    { Table of reals type }
  var
    R:          TABLE;              { The table itself }
    i:          integer;            { Table index }

  procedure Bubble(var t: TABLE);   { The sorting routine }
    var
      i:        integer;            { Index variable }
      j:        integer;            { Index variable }
      temp:     real4;              { Exchange variable }
    begin
      for i := 1 to 9 do            { Outer loop }
        begin
          for j := i + 1 to 10 do   { Inner loop }
            begin
              if (t[i] > t[j]) then { Sort in ascending order }
                begin
                  temp := t[i];     { Perform the }
                  t[i] := t[j];     { exchange of }
                  t[j] := temp;     { table elememts }
                end;
            end;
        end;
    end;

  begin
    writeln(' Bubble Sort Demonstration Program.');
    for i := 1 to 10 do             { Loop to read in reals }
      begin
        writeln(' Please input real number no. ',i:2);
                                    { Prompt user }
        readln(R[i]);               { Read response }
      end;
    Bubble(R);                      { Sort the array }
    writeln;                        { Skip a line }
    writeln(' The sorted ordering from lowest to highest is:');
                                    { Print a header }
    for i := 1 to 10 do             { Loop to print array }
      begin
        write(R[i]);                { Write a number }
        if (i mod 5 = 0) then writeln;
                                    { Five numbers per line }
      end;
  end.

