Program PrecisionDemo;
{
            BCD DEMONSTRATION PROGRAM  Version 1.00A

   This program demonstrates the increase in precision gained
   by using TURBOBCD.  Monetary calculations done in floating
   point lose precision because there is no precise binary
   representation for any power of 1/10 (.1, .01, etc).  Binary
   coded decimals perform all calculations in decimal and thus
   are more precise for financial applications.

   INSTRUCTIONS
   1. Compile and run this program using TURBOBCD.COM.  Note that
      the results are all zero.
   2. Compile and run this program using TURBO.COM and compare
      the results with (1) above.
}

Begin
  ClrScr;
  WriteLn('Each of the following calculations should result in zero provided');
  WriteLn('you compiled this program using TURBOBCD.COM:');
  Writeln;
  WriteLn('(((1234.99 - 1235.0) * 10000.0) + 100.0) * 100000.0 = ',
           ((1234.99-1235.0)*10000.0+100.0)*100000.0:1:20);
  WriteLn('((1/5) * 5) - 1                                     = ',
           1/5*5-1:1:20);
  WriteLn('1.34 + 1.66 - 3.0                                   = ',
           1.34+1.66-3.0:1:20);
End.

