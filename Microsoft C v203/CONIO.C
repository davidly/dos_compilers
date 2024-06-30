/**
*
* This module defines the various console I/O functions.  They may
* be called directly, using the names included here, or the header
* file CONIO.H may be included so that more standard names may be
* used.  This source module is provided so that users may customize
* the console I/O functions, if desired.  Note that "cprintf" and
* "cscanf" (included in LC.LIB) call the functions "putch", "getch",
* and "ungetch".
*
**/
#define BDOS_IN   8     /* input function for "getch" */
#define BDOS_INE  1     /* input function for "getche" */
#define BDOS_OUT  6     /* output function for "putch" */
#define BDOS_CKS  11    /* check keyboard status for "kbhit" */

static char pushback = 0;       /* character save for "ungetch" */ 
/**/
/**
* 
* name          getch -- get character from console 
*               getche - get character from console and echo it
*
* synopsis      c = getch();
*               char c;         input character
*
* description   These functions obtain the next character typed at
*               the console or, if one was pushed back via "ungetch",
*               returns the previously pushed back character.
*
**/
getch()
{
char c;

if(pushback)
   {
   c = pushback;
   pushback = 0;
   return(c);
   }
return(bdos(BDOS_IN));
}

getche()
{
char c;

if(pushback)
	{
	c = pushback;
	pushback = 0;
	return(c);
	}
return(bdos(BDOS_INE));
}
/**/
/**
*
* name          putch -- send character directly to console
*
* synopsis      putch(c);
*               char c;         character to be sent
*
* description   This function sends the specified character directly
*               to the user's console.
*
**/
putch(c)
char c;
{
bdos(BDOS_OUT, c&127);
return(c);
}
/**/
/**
*
* name          ungetch -- push character back to console
*
* synopsis      r = ungetch(c);
*               int r;          return code
*               char c;         character to be pushed back
*
* description   This function pushes the indicated character back
*               on the console.  Only a single level of pushback is
*               allowed.  The effect is to cause "getch" to return
*               the pushed-back character the next time it is called.
*
* returns       r = -1 if character already pushed back
*               = c otherwise
*
**/
ungetch(c)
char c;
{

if (pushback != '\0') return(-1);
pushback = c;
return(c);
}
/**/
/**
*
* name          kbhit -- check if character has been typed at console
*
* synopsis      status = kbhit();
*               int status;             1 if character typed, else 0
*
* description   This function checks to see if a character has been
*               typed at the user's console since the completion of
*               the last read operation.  The character typed can
*               be obtained by a "getch" call.
*
* returns       0 if no character has been typed
*               1 if a character is waiting to be read
*
**/
kbhit()
{
return(bdos(BDOS_CKS) != 0);
}
