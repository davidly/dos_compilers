/*
** wild.c
** wildcard expander
**
** handles '*' (none or more of any char), '?' (exactly one char), and
** '[string]' (chars which match string chars or between n1 and n2 if 'n1-n2'
** in string inclusive)
**
*/

#include <stdio.h>
#include <register.h>
#include <ctype.h>

/*
** these are the data structures
**
** [_psp]:81
**    Raw command line.
**
**	__argv
**     -------	   ------
**     |     |---->|    |---->"arg0"
**     -------	   ------
**		   |    |---->"arg1"
**		   ------
**		    ....
**		   ------
**		   |    |---->"argn"
**		   ------
**		   |NULL|
**		   ------
*/

#define SLASHCHAR	'\\'
#define FWDSLASHCHAR '/'
#define SLASH		"\\"
#define FWDSLASH    "/"


char *_hfind();

extern int __argc;
extern int __argl;
extern char **__argv;

static int _add(int, char ***, char far *, char far *, int );
static int _match(char far *, char ***, char far *, int );
static _sort (char **);

static _hmmcpy( a, b, n )
  char *a, far *b;
  int n;
{ REG1 int i;
  for ( i = 0; i < n; i++ )
	*( a + i ) = *( b + i );
}

char **
_cwild ( argv, pass, arg )

char **argv;
int pass;
char far *arg;

	{
	char savechar;
	char far *wchar;
	char far *arghead = arg;
    int  ptr, sptr, arglen;

	_setdta();
	while ( *arg && ( *arg != ' ' ) && ( *arg != '\t' ) 
		     && ( *arg != '\15' ))
		  arg++;
	savechar = *arg;		/* save this character, since it is in psp */
	*arg = '\0';
		  
	for ( wchar = arghead; wchar && ( *wchar != '*' ) && ( *wchar != '?' );
		wchar++ );
	_match( wchar, &argv, arghead, pass );
	*arg = savechar;		/* restore this character */
	return( argv );
	}




 static int
_match ( ptr, argv, arg, pass)
	char far *ptr;
	char ***argv;
	char far *arg;
	int pass;
	{
	char *new;
	int length;
	char **oldargv = *argv;
	int gotone = 0;
	if ( pass == 1 )
	     --__argc;

	while (ptr != arg && *ptr != SLASHCHAR && *ptr != FWDSLASHCHAR
           && *ptr != ':')
		/* find first slash or ':' before wildcard */
		ptr--;

	if (*ptr == ':' && ptr != arg+1) /* weird name, just add it as is */
		return( _add( 0, argv, arg, (char far *)NULL, pass ) );

	if (*ptr == SLASHCHAR || *ptr == FWDSLASHCHAR 
        || *ptr == ':') /* pathname */
		length = ptr - arg + 1; /* length of dir prefix */

	if (new = _hfind(arg)) {	/* get the first file name */

		do	{ /* got a file name */
			if (strcmp(new, ".") 
			   && strcmp(new, "..")) {
				if (*ptr != SLASHCHAR && *ptr != ':'
                    && *ptr != FWDSLASHCHAR ) {
					/* current directory; don't need path */
					if ( _add( 0, argv, (char far *)new,
						   (char far *)NULL, pass ) )
						return(-1);
					}
				else	/* add full pathname */
					if ( _add( length, argv, 
						 (char far *)new, arg, pass) )
						return(-1);
				gotone++;
				}

			} while (new = _hfind(NULL));  /* get following files */

		if (gotone) {
			if ( pass == 2 )
			   {
				new = **argv;
				**argv = NULL;
				_sort(oldargv);
				**argv = new;
			   }
			return(0);
			}
		}

	return( _add( 0, argv, arg, (char far *)NULL, pass) ); /* no match */
	}


static int
_add(length, argv, arg, prfxstr, pass )
	int length;
	char ***argv;
	char far *arg;
	char far *prfxstr;
	{
	int argln = 1, prfln = 0;
	char far *argcnt = arg, far *prfcnt = prfxstr;
	while ( *argcnt )
		{
		  argln++;
		  argcnt++;
		}
	while ( *prfcnt )
		{
		  prfln++;
		  prfcnt++;
		}
	if ( pass == 1 )
		  {
		    __argc++;
		    __argl += argln + length;
		  }
	   else		/* pass 2 actually build the arg */
		  {
			if ( length )
			   _hmmcpy( (char *)**argv, (char far *)prfxstr, prfln );
			_hmmcpy( (char *)**argv + length, arg, argln );
			(*argv)++;
			**argv = (char *)(*(*argv - 1) + argln + length);
		  }

	return(0);
	}


static
_sort (first)
	char **first;
	{
	char *temp, **last;
	if (!*first)
		return;
	while (*first) {
		last = first;
		 while (*++last)	{
			if (strcmp(*last, *first) < 0) {
				temp = *first;
				*first = *last;
				*last = temp;
				}
			}
		 ++first;
	}
}
