// mulmix.c
// Mixed-language program example for demonstrating
// Windows support in Microsoft FORTRAN 5.1

#include <stdio.h>
#ifdef NULL
#undef NULL
#endif

#include <windows.h>

void _fortran PRINTRESULTS( long *, long *, long * );

void _fortran PRINTRESULTS( long *Num1, long *Num2, long *Result )
  {
    char szBuffer[128];

    wsprintf( szBuffer, "%ld * %ld = %ld",
              *Num1, *Num2, *Result );
    MessageBox ( NULL, szBuffer, "Result", MB_OK );

    return;
  }
