/**
*
* This header file defines an equivalence between several of the
* standard level 2 I/O functions and their console I/O counterparts.
* Use this header file for programs which perform all of these functions
* to the console only, and need an unbuffered, direct interface to the
* user's console.  See Section 3.2.3 of the manual for more information.
*
**/
#define getchar getch
#define putchar putch
#define gets cgets
#define puts cputs
#define printf cprintf
#define scanf cscanf