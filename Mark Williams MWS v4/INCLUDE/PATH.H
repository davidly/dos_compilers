/*
 *	Let's C Version 4.0.C.
 *	Copyright (c) 1982-1987 by Mark Williams Company, Chicago.
 *	All rights reserved. May not be copied or disclosed without permission.
 */

/*
 * path.h
 * For COHERENT, GEMDOS, MSDOS.
 */

#include <access.h>

#if	COHERENT
#define PATHSEP		'/'		/* Path name component separator */
#define	PATHSEPSTRING	"/"		/* PATHSEP as a string */
#define LISTSEP		':'		/* Search list component separator */
#define DEFPATH		":/bin:/usr/bin"
#define DEFLIBPATH	"/lib:/usr/lib"
#define DEFSHELL	"sh"
#endif

#if	GEMDOS
#define PATHSEP		'\\'
#define	PATHSEPSTRING	"\\"
#define LISTSEP		','
#define DEFPATH		",\\bin,\\usr\\bin"
#define DEFLIBPATH	"\\lib,,\\usr\\lib"
#define DEFSHELL	"msh.prg"
#endif

#if	MSDOS
#define PATHSEP		'\\'
#define	PATHSEPSTRING	"\\"
#define LISTSEP		';'
#define DEFPATH		";\\bin;\\usr\\bin"
#define DEFLIBPATH	"\\lib;\\usr\\lib"
#define	DEFSHELL	"command.com"
#endif

#define MAXPATH	128			/* Size of static pathname buffer */
extern char *path();			/* (char *path, *file; int mode;) */
