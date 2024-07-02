/*
   UM.C unmangle C++ names in a file.

   This program may be freely distributed provided it is included with the
   file unmangle.c. This program is provided 'as is' with no warrantees as
   to its suitability for any usage, whether implied or otherwise.
   
   This file can be compiled as is with Zortech C++ v2 or later and will
   produce an executable which can be run on a text file to demonstrate the
   use of the name unmangling functions.
   
   compile with:

    ztc -mti um

   and the usage is:

	um file
	um <file

   The input can come from either a text file or from standard input.   	
   The name unmangled output is sent to stdout and can be redirected to
   a file.
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

char *unmangle_ident(char *);

int _cdecl main(int argc, char *argv[])
{
	FILE *fp;
	char *line, *s, *s0, *s1;
	int x;

	if (argc > 1)
	{
	    if ((fp = fopen(argv[1],"r")) == NULL)
	    {
		fputs("Can't open ",stdout);
		puts(argv[1]);
		exit(EXIT_FAILURE);
	    }
	}
	else
	    fp = stdin;		/* get input from standard in	*/
	
	line = malloc(255);
	
	while (fgets(line,255,fp))
	{	char *p = line;

		/* mangled identifiers always start with a '_'	*/
		while ((s0 = strchr(p,'_')) != NULL)
		{	char c;

			/* Point s1 at end of identifier	*/
			s1 = s0;
			while (isascii(*s1) &&
				(*s1 == '_' || isalpha(*s1) || isdigit(*s1)))
				s1++;

			c = *s1;
			*s1 = 0;		/* terminate identifer	*/
			s = unmangle_ident(s0);
			*s1 = c;		/* restore string	*/
			if (s)
			{
				*s0 = 0;
				fputs(p,stdout);
				fputs(s,stdout);
				free(s);
			}
			else
			{	*s1 = 0;
				fputs(p,stdout);
				*s1 = c;
			}
			p = s1;			/* remainder of line	*/
		}
		fputs(p,stdout);
	}
	free(line);
	if (fp != stdin)
	    fclose(fp);
	return EXIT_SUCCESS;
}
