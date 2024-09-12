With Util,Timelib,Text_IO; Use Text_IO, Timelib;
Pragma RangeCheck(off); Pragma Debug(off); Pragma Arithcheck(Off);
Procedure Primes Is
--	From Byte Sept. 81 Benchmark evaluation

    SIZE : Constant := 8190;

    Flags : Array(0..SIZE) Of Boolean;
    Count,k,Prime : Integer;

    start,finish : Time;

Begin
	Put("10 Iterations"); New_line;
	start := Get_time;
Ten :   For Iter In 1..10 Loop
	    Count := 0;
Clear :	    For i In 0..SIZE Loop
		Flags(i) := TRUE;
	    End Loop Clear;
LPrime :    For i In 0 .. SIZE Loop
		If Flags(i) Then
		    Prime := i + i + 3;
		    k := i + Prime;
		    While k <= SIZE Loop
			Flags(k) := FALSE;
			k := k + Prime;
		    End Loop;
		    Count := Count + 1;
@		    Put("Prime "); Put(Prime); New_line;
		End If;
	    End Loop LPrime;
	End Loop Ten;
	finish := get_time;
	Put("Timing done on "); Put_Date(Current_Output,Get_date);
	    New_Line;
	Put("Start time - "); Put_Time(Current_Output,start); New_Line;
	Put("Finish time - "); Put_Time(Current_Output,finish); New_Line;
	Put("Elapsed time = "); Put_Time(Current_Output,elapsed_time
	    (Start,finish)); New_Line;
	Put(Count); Put("Primes"); New_line;
End Primes;
