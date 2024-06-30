/**
*
* This module defines the various console I/O functions.  They may
* be called directly, using the names included here, or the header
* file CONIO.H may be included so that more standard names may be
* used.  This source module is provided so that users may customize
* the console I/O functions, if desired.  Note that "cprintf" and
* "cscanf" (included in MC.LIB) call the functions "putch", "getch",
* and "ungetch".
*
**/
#define BDOS_IN   7	/* input function for "getch" */
#define BDOS_OUT  6	/* output function for "putch" */
#define BDOS_CKS  11	/* check keyboard status for "kbhit" */
#define BDOS_BKI  10	/* buffered keyboardd input for "cgets" */
#define BDOS_PRT  9	/* print string for "cputs" */

static char pushback;	/* character save for "ungetch" */ 

/**
* 
* name		getch -- get character from console
*
* synopsis	c = getch();
*		char c;		input character
*
* description	This function obtains the next character typed at
*		the console or, if one was pushed back via "ungetch",
*		returns the previously pushed back character.
*
**/
getch()
{
int c;

if (pushback != '\0')
   {			/* character was pushed back */
   c = pushback;
   pushback = '\0';
   return(c);
   }
return(bdos(BDOS_IN, 0xFF) & 127);
}
/**
*
* name		putch -- send character directly to console
*
* synopsis	putch(c);
*		char c;		character to be sent
*
* description	This function sends the specified character directly
*		to the user's console.
*
**/
putch(c)
char c;
{
bdos(BDOS_OUT, c&127);
return(c);
}
/**
*
* name		ungetch -- push character back to console
*
* synopsis	r = ungetch(c);
*		int r;		return code
*		char c;		character to be pushed back
*
* description	This function pushes the indicated character back
*		on the console.  Only a single level of pushback is
*		allowed.  The effect is to cause "getch" to return
*		the pushed-back character the next time it is called.
*
* returns	r = -1 if character already pushed back
*		= c otherwise
*
**/
ungetch(c)
char c;
{

if (pushback != '\0') return(-1);
pushback = c;
return(c);
}
/**
*
* name		cgets -- get string directly from console
*
* synopsis	p = cgets(s);
*		char *p;	pointer to result string
*		char *s;	string buffer (first byte = count)
*
* description	This function obtains a string directly from the
*		user's console.  This version uses the buffered
*		keyboard input function supported by the BDOS, so
*		that all of the line editing capabilities are available.
*		The first byte of "s" must be initialized to contain
*		the number of bytes, minus two, in "s".  The string
*		pointer returned is "s+2", which contains the first
*		byte of input data.  Note that "s[1]" will contain
*		the number of characters in the string.  The carriage
*		return (which the user at the console must type to
*		terminate the operation) is replaced by a null byte.
*
* returns	p = pointer to string received
*
**/
char *cgets(s)
char *s;
{
char *p;

if (*s == 0) *s = 250;		/* do not allow zero byte count */
bdos(BDOS_BKI, s);
p = s+2;
p[s[1]] = '\0';			/* set terminating byte */
return(p);
}
/**
*
* name		cputs -- send character string directly to console
*
* synopsis	cputs(s);
*		char *s;	character string to be sent
*
* description	This function sends the specified string directly to
*		the user's console.  The BDOS function for "print
*		string" is used.  The function locates the terminating
*		null byte, changes it to a '$' (the terminator 
*		required by the BDOS function), and then changes it
*		back to the null byte before returning.  Thus, the
*		string to be printed cannot itself contain a '$' and
*		it cannot reside in read-only memory (ROM).
*
*		Note that a carriage return or linefeed is NOT appended
*		by this function; they must be included in the string,
*		if desired.
*
**/
cputs(s)
char *s;
{
char *p;

for (p = s; *p != '\0'; p++) ;		/* find string terminator */
*p = '$';
bdos(BDOS_PRT, s);
*p = '\0';
return;
}