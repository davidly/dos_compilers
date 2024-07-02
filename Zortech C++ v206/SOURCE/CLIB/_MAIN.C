/*_ _main.c   Sun Jun  4 1989   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Walter Bright		*/
/* All rights reserved.				*/

#include <stdio.h>
#include <dos.h>
#include <string.h>
#include <stdlib.h>

/*********************************
 * This is a replacement for the usual _main routine. It takes
 * argc and argv, and does wild card expansion on any arguments
 * containing a '*' or '?', and then calls main() with a new
 * argc and argv. Any errors result in calling main() with the original
 * arguments intact. Arguments containing wild cards that expand to
 * 0 filenames are deleted. Arguments without wild cards are passed
 * straight through.
 *
 * Arguments which are preceded by a " or ', are passed straight
 * through. (cck)
 */

extern int _argc;
extern char **_argv;

/* Using a name starting with "_STI" causes this function to be put	*/
/* into the static constructor table. (!)				*/

void _STI_wildcard()
{
	struct FIND  *p;
	int i,nargc, path_size, nargvmax;
	char **nargv, path[2+64+1], *cp, *end_path;
	nargc = 0;
	nargvmax = _argc;
	nargv = (char **) malloc(sizeof(char *) * _argc);
	if (!nargv)
		goto noexpand;
	for(i=0; i<_argc; ++i){
		cp = _argv[i];				/* cck */
		if( !(cp[-1]=='"' || cp[-1]=='\'') &&	/* cck */
		     (strchr(_argv[i], '*') || strchr(_argv[i], '?'))
				){	/* if have expandable names */
			end_path = _argv[i] + strlen(_argv[i]);
			while (	end_path >= _argv[i] &&
				*end_path != '\\' &&
				*end_path != '/' &&
				*end_path != ':')
				end_path--;
			path_size = 0;
			if(end_path >= _argv[i]){	/* if got a path */
				path_size = end_path - _argv[i] + 1;
				memcpy(path, _argv[i], path_size);
			}
			path[path_size] = 0;
			p = findfirst(_argv[i], 0);
			while (p)
			{
				cp = malloc(path_size + strlen(p->name) + 1);
				if (!cp)
					goto noexpand;
				strcpy(cp, path);
				strcat(cp, p->name);
				if (nargc >= nargvmax)
				{	nargvmax += 10;
					nargv = (char **) realloc(nargv,nargvmax * sizeof(char *));
					if (!nargv)
						goto noexpand;
				}
				nargv[nargc++]  = cp;
				p = findnext();
			}
		}
		else
		{	if (nargc >= nargvmax)
			{	nargvmax += 10;
				nargv = (char **) realloc(nargv,nargvmax * sizeof(char *));
				if (!nargv)
					goto noexpand;
			}
			nargv[nargc++] = _argv[i];
		}
	}
	_argc = nargc;
	_argv = nargv;

noexpand:
	;	/* give up	*/
}
