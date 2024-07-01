#include <stdio.h>
#include <ctype.h>

typedef	unsigned int size_t;

extern char *strchr(char *, int);
extern char *strcpy(char *, char *);
extern char *strdup(char *);
extern int atoi(char *);
extern int strcmp(char *, char *);
extern void *malloc(size_t);
extern void exit(int);
extern void free(void *);

int lineno;					/* The current line number being parsed	*/
int level;					/* The level of	quotes or comments being parsed	*/
int parens;					/* current parenthesis level */
int braces;					/* current curly brace level */
int totalfuncs;				/* total number	of functions seen */

#define	PARENS(c) ( ( c	== '(' ) - ( c == ')' )	)
#define	BRACES(c) ( ( c	== '{' ) - ( c == '}' )	)

#define	INITIA 0	/* Initial state of input stream machine */
#define	BEGCOM 1	/* Possible beginning of comment state */
#define	COMMEN 2	/* In comment state */
#define	AFTCOM 3	/* Possible end	of comment state */
#define	DOUBQT 4	/* In double quote state */
#define	DBQTBS 5	/* Backslash in	double quote state */
#define	SINGQT 6	/* In single quote state */
#define	SGQTBS 7	/* Backslash in	single quote state */
#define	POUND 8		/* Preprocessor	directive */
#define	TYPE 16			/* This	character might	preceed	a possible return type */
#define	NAME 32		/* This	character might	preceed	a possible function name */

#define	HASHSIZE ( 2 <<	10 )	/* Must	be a power of two */
#if 0
#define	MYBUFSIZ 15872			/* Size	of buffer used on input	stream */
#endif

/****************************************************************/
/**							       **/
/**   ARGUMENTS: a structure capable of	keeping	info on	the    **/
/**		 particular state of a file stream	       **/
/**							       **/
/**   RETURN: none					       **/
/**							       **/
/**   DESCRIPTION: SAVEPLACE saves the position	in the buffer, **/
/**   the line number, the current count of braces, and	parens **/
/**							       **/
/**   GLOBAL VARS REFERENCED: lineno, braces, parens.	       **/
/**							       **/
/**   GLOBAL VARS MODIFIED: none			       **/
/**							       **/
/****************************************************************/

#define	SAVEPLACE(x) (x).lineno	= lineno; (x).braces = braces; \
(x).parens = parens; (x).place = ftell(	fp )

/****************************************************************/
/**							       **/
/**   ARGUMENTS: a structure capable of	keeping	info on	the    **/
/**		 particular state of a file stream.	       **/
/**							       **/
/**   RETURN: none					       **/
/**							       **/
/**   DESCRIPTION: RECOVERPLACE	macro restores the position,   **/
/**   the line number, the current count of braces, and	parens **/
/**   of the last time a SAVEPLACE was done to the argument.   **/
/**							       **/
/**   GLOBAL VARS REFERENCED: lineno, braces, parens.	       **/
/**							       **/
/**   GLOBAL VARS MODIFIED: lineno, braces, parens, fp	       **/
/**							       **/
/****************************************************************/

#define	RECOVERPLACE(x)	lineno = (x).lineno; braces = \
(x).braces; parens = (x).parens; fseek(	fp, (x).place, 0 )

/***************************************************************************/
/**									  **/
/**  Global struct/union/enums						  **/
/**									  **/
/***************************************************************************/

enum relationchoice {
		CALLER,
		CALLEE
	};

struct placeptr	{
		long place;			/* position as reported/used by	ftell/fseek */
		int parens;			/* parenthesis level to	save/recover */
		int braces;			/* curly brace level to	save/recover */
		int lineno;			/* The current line number being parsed	*/
		};

struct func_ref_type {
		char *name;				/* name	of function referenced */
		char *type;				/* type	fo functions return */
		char *pnext_func_ref;	/* pointer to next function in hashtable */
		char *pcallerlist;		/* singly linked list of pointers to functions
									callee's */
		char *pcalleelist;		/* singly linked list of pointers to functions
									caller's */
		char *file_name;		/* name	of file	containing function reference */
		int lineno;				/* line	number of reference to function	*/
		int xref;				/* cross reference of last pruning */
		};

	/* hash	table */
struct func_ref_type *hashtbl[ HASHSIZE	] = { (struct func_ref_type *)NULL };

struct listtype	{
		struct func_ref_type *pelist;
		char *pnext_func_ref;	/* pointer to next element of list */
		char *file_name;		/* name	of file	where reference	occoured */
		int lineno;				/* line	number where reference occoured	*/
		};

struct listtype	ellipses = {	/* A null list element for pruning purposes */
							(struct	func_ref_type *)NULL,
							(char *)NULL,
							(char *)NULL,
							0
							};

struct placeptr	last_func_name;
struct placeptr	last_func_ret_type;


/***************************************************************************/
/**									  **/
/**  Function prototypes						  **/
/**									  **/
/***************************************************************************/

int mycompare( char **,	char **	);
int getsucc();
int hashfunc( char * );
int ismember( char *, char *[] );
int main( int, char *[]	);
int nsuccmemb( char * );
int succpos( int );

static void quicksort( char *, char * );
static void swap ( char	*, register char *, unsigned int );
struct func_ref_type *findname(	char * );
struct func_ref_type *makename(	char * );

void addlist( struct func_ref_type *, struct func_ref_type *, char *,
			int, enum relationchoice );
void dumptree( struct func_ref_type *, int, enum relationchoice	);
void findproc( void );
void initstatemachine();
void qsort( char *, unsigned int, unsigned int,	int (*)( char **, char ** ) );
void readtoken(	char *,	char * );
void sortdump( enum relationchoice );



/***************************************************************************/
/**									  **/
/**  Global declarations						  **/
/**									  **/
/***************************************************************************/

char *defaulttype = "int";		/* Pointer to the default return type for C */
char *endofsp = "Out of space";	/* Pointer to error message */
char *reswords[] = {			/* reserved words that could look like
																functions */
				        "if",
				        "while",
				        "for",
				        "return",
		        "sizeof",
		        "switch",
					NULL
					};

char alphanum[]	=				/* array of alpha numeric characters */
"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789";
								/* delimiters used by cflow */
char delimits[]	= " !@#$%^&*()-+=<>,.?/:;~`'|\n\\\t";
char filename[ 30 ];			/* Contains the	name of	the current file
															being scanned */
								/* array of state transitions for input
									state machine */
char gotonextstate[ 9 ][ 128 ] = { 0 };
#if 0
char mybuffer[ MYBUFSIZ	];		/* Buffer for the input	file */
#endif
char parentproc[ 50 ];			/* Name	of current parent procedure */
char procname[ 50 ];			/* Contains the	name of	the procedure
												reference being	scanned	*/
char spceq[] = " \t\n\r";		/* whitespace */
char typename[ 50 ];			/* Contains the	name of	the return type	of the
												reference being	scanned	*/

FILE *fp;						/* File	pointer	used for input */
int cutoff = 35;				/* Maximum depth of output ( default 35	) */
int verbose = 0;				/* Verbose flag	( 0 off, 1 on )	*/
enum relationchoice relationship = CALLEE;
								/* relationship	wanted on output
														( default CALLEE ) */
int xref = 0;					/* Starting xref number	*/

/****************************************************************/
/**							       **/
/**   ARGUMENTS: count of command line arguments	       **/
/**		 a pointer to the array	of command line	args.  **/
/**							       **/
/**   RETURN: 0	if no errors, -1 if out	of memory.	       **/
/**							       **/
/**   DESCRIPTION: This	program	scanns the flags, and sets     **/
/**   appropriate flags.  After	this all of the	remaining args **/
/**   that can be opened as files are opened and the contents  **/
/**   scanned for function references.	These are put in lists **/
/**   such that	each function has a linked list	of caller to   **/
/**   that function, and of callees of that function.  On      **/
/**   output either the	callee tree(s) is/are printed, or the  **/
/**   callers trees are	printed	under control of the -r	flag.  **/
/**   If there is more than one	tree to	be printed, then the   **/
/**   function names, which are	the roots of the trees,	are    **/
/**   sorted lexicographically before output.		       **/
/**							       **/
/**   GLOBAL VARS REFERENCED: verbose, cutoff, relationship    **/
/**			      parens, braces, lineno, level,   **/
/**			      totalfuncs		       **/
/**							       **/
/**   GLOBAL VARS MODIFIED: verbose, cutoff, relationship      **/
/**			    parens, braces, lineno, level,     **/
/**			    totalfuncs			       **/
/**							       **/
/****************************************************************/

int main( argc,	argv )

	int argc;
	char *argv[];

{
	int c;
	if ( argc < 2 )
		{
		printf( "usage: cflow [-v][-r][-d] filelist" );
		}
	else
		{
		initstatemachine();
		while (	--argc > 0 )
			{					/* for all flags/files on the command line */
			++argv;
			if ( ( c = **argv ) == '-' || c	== '/' )
				{	/* we are processing a flag */
				while (	c = *(++(*argv)) )
					{
					switch(	c )
						{

					case 'v': /* be	verbose	on self	references */
					case 'V':
							verbose++;
							break;

					case 'r': /* reverse the caller:callee relationship */
					case 'R':
							relationship = CALLER;
							break;

					case 'd': /* set the flow graph	cutoff depth */
					case 'D':
							if ( isdigit(*(++(*argv))) )
								{
								cutoff = atoi( *argv );
								}
							break;
						}
					}	/* End of while	*/
				}
			else
				{	/* we are processing a file, and should	be done
						with flags */
				if ( ( fp = fopen( *argv, "rb" ) ) == NULL )
					{
					printf( "cflow: can't open %s\n", *argv );
					}
				else
					{
#if 0
					setvbuf( fp, mybuffer, _IOFBF, (unsigned int)sizeof( mybuffer )	);
#endif
					puts( *argv );
					strcpy(	filename, *argv	);
					totalfuncs = parens = braces = level = 0;
					lineno = 1;
					SAVEPLACE( last_func_name );
					SAVEPLACE( last_func_ret_type );
					while (	succpos( '(' ) )
						{			/* we have found a begin paren */
						findproc();
						}	/* End of while	*/
					fclose(	fp );
					}
				}
			}	/* End of while	*/
		}
	if ( relationship == CALLEE )
		{	/* "normal" caller:callee relationship */
		if ( findname( "main" )	)
			{	/* Found main */
			dumptree( findname( "main" ), 0, relationship );
			}
		else
			{	/* No main found */
			sortdump( relationship );
			}
		}
	else
		{	/* reverse caller:callee relationship */
		sortdump( relationship );
		}
	return(	0 );
}



/****************************************************************/
/**							       **/
/**   ARGUMENTS: none					       **/
/**							       **/
/**   RETURN: none					       **/
/**							       **/
/**   DESCRIPTION: findproc locates the	name of	the function   **/
/**   preceeding the parenthesis, and figures out whether we   **/
/**   are looking at a function	definition, or a function call **/
/**   also adds	to the caller, and callee list of the function **/
/**   as appropriate. (	see addlist() )			       **/
/**							       **/
/**   GLOBAL VARS REFERENCED: last_func_ret_type,	       **/
/**			      last_func_name, alphanum,	       **/
/**			      procname,	braces,	parentproc,    **/
/**			      lineno, parens, spceq,	       **/
/**			      defaulttype		       **/
/**							       **/
/**   GLOBAL VARS MODIFIED: none			       **/
/**							       **/
/**							       **/
/****************************************************************/

void findproc()

{
	char *thisplace;
	long sizetype;
	int oldlineno, oldbraces, oldparens;
	struct placeptr	place, typeplace, tplace;
	struct func_ref_type *alist, *blist;
	SAVEPLACE( place );
	typeplace = last_func_ret_type;
	place.place++;
	RECOVERPLACE( last_func_name );
	sizetype = last_func_name.place;
	readtoken( alphanum, procname );
	if ( ! braces )
		{
		strcpy(	parentproc, procname );
		}
	if ( *procname && strchr( alphanum, *procname )	&&
			( ismember( procname, reswords ) == -1 ) )
		{		/* This	is a function call, prototype, or definition */
		oldlineno = lineno;
		oldbraces = braces;
		oldparens = parens + 1;
		while (	succpos( ')' ) )
			{
			getsucc();
			if ( parens <= oldparens )
				{
				break;
				}
			}
		nsuccmemb( spceq );
		if ( getsucc() != ';' || oldbraces != 0	)
			{	/* This	is a call or a definition */
			alist =	makename( parentproc );
			blist =	makename( procname );

			if ( oldbraces )
				{	/* This	is scanning a call */
				addlist( alist,	blist, filename, oldlineno, CALLEE );
				addlist( blist,	alist, filename, oldlineno, CALLER );
				}
			else
				{	/* This	is scanning a definition */
				if ( alist->file_name )
					{
					free( alist->file_name );
					}
				alist->file_name = strdup( filename );
				alist->lineno =	oldlineno;
				}
			}
		else
			{	/* This	is scanning a prototype	*/
			RECOVERPLACE( typeplace	);
						/* remove starting whitespace */
			nsuccmemb( spceq );
			SAVEPLACE( typeplace );
			sizetype -= typeplace.place;
			for ( thisplace	= typename; --sizetype >= 0L; )
				{
				*thisplace++ = (char)getsucc();
				}	/* End of for */
			*thisplace = '\0';
			alist =	makename( procname );
			if ( alist->type != defaulttype	)
				{
				free( alist->type );
				}
			alist->type = strdup( typename );
			}
		}
	RECOVERPLACE( place );
}


/****************************************************************/
/**							       **/
/**   ARGUMENTS: a token name.				       **/
/**							       **/
/**   RETURN: a	pointer	to a struct func_ref_type	       **/
/**							       **/
/**   DESCRIPTION: makename sets up an function	reference      **/
/**   structure	for hash lookup	later.			       **/
/**							       **/
/**   GLOBAL VARS REFERENCED: hashtbl, hashval,	totalfuncs,    **/
/**			      endofsp			       **/
/**							       **/
/**							       **/
/**   GLOBAL VARS MODIFIED: hashtbl, hashval, totalfuncs       **/
/**							       **/
/****************************************************************/

struct func_ref_type *makename(	nameptr	)

	char *nameptr;

{
	struct func_ref_type *pelist;
	int hashval;
	int newel = 1;
	pelist = hashtbl[ hashval = hashfunc( nameptr )	];
	if ( pelist )
		{
		while (	( newel	= strcmp( nameptr, pelist->name	) ) &&
				pelist->pnext_func_ref )
			{
			pelist = (struct func_ref_type *)pelist->pnext_func_ref;
			}	/* End of while	*/
		if ( newel )
			{
			if ( ( pelist->pnext_func_ref =
					malloc(	sizeof(	struct func_ref_type ) ) ) == NULL )
				{
				fprintf( stderr, endofsp );
				exit( -1 );
				}
			pelist = (struct func_ref_type *)(pelist->pnext_func_ref);
			totalfuncs++;
			}
		}
	else
		{
		if ( ( pelist =	( hashtbl[ hashval ]
			= (struct func_ref_type	*)malloc(
			sizeof(	struct func_ref_type ) ) ) ) ==	NULL )
			{
			fprintf( stderr, endofsp );
			exit( -1 );
			}
		totalfuncs++;
		}
	if ( newel )
		{	/* Initialize function name node to undefined state. */
		pelist->pcallerlist = NULL;
		pelist->pnext_func_ref = NULL;
		pelist->type = defaulttype;
		pelist->pcalleelist = NULL;
		pelist->file_name = NULL;
		pelist->name = strdup( nameptr );
		}
	if ( pelist == NULL )
			{
			fprintf( stderr, endofsp );
			exit( -1 );
			}
	return(	pelist );
}


/****************************************************************/
/**							       **/
/**   ARGUMENTS: a token name.				       **/
/**							       **/
/**   RETURN: a	pointer	to a struct func_ref_type	       **/
/**							       **/
/**   DESCRIPTION: findname returns a function reference to    **/
/**   the structure whose name field matches the token name,   **/
/**   or NULL in the case of no	match.			       **/
/**							       **/
/**   GLOBAL VARS REFERENCED: hashval, hashfunc		       **/
/**							       **/
/**   GLOBAL VARS MODIFIED: none			       **/
/**							       **/
/****************************************************************/

struct func_ref_type *findname(	nameptr	)

	char *nameptr;

{
	struct func_ref_type *pelist;
	int hashval;
	pelist = hashtbl[ hashval = hashfunc( nameptr )	];
	if ( pelist )
		{
		while (	strcmp(	nameptr, pelist->name )	&&
				pelist->pnext_func_ref )
			{
			pelist = (struct func_ref_type *)pelist->pnext_func_ref;
			}	/* End of while	*/
		}
	return(	pelist );
}



/****************************************************************/
/**							       **/
/**   ARGUMENTS: token to get hashed			       **/
/**							       **/
/**   RETURN: hash value.				       **/
/**							       **/
/**   DESCRIPTION: hashfunc hashes tokens based	on the sum     **/
/**   of all the characters in the token.		       **/
/**							       **/
/**   GLOBAL VARS REFERENCED: hashval, hashfunc		       **/
/**							       **/
/**   GLOBAL VARS MODIFIED: none			       **/
/**							       **/
/****************************************************************/

int hashfunc( token )

	char *token;

{
	int retval = 0;
	for ( ;	*token ; retval	+= *token++ )
		;
	return(	retval & ( HASHSIZE - 1	) );
}


/****************************************************************/
/**							       **/
/**   ARGUMENTS: Two function reference	pointers, the	       **/
/**		 filename where	the reference took place.      **/
/**		 The line number where the reference occoured. **/
/**		 And the relation between the first two	       **/
/**		 references.				       **/
/**							       **/
/**   RETURN: void					       **/
/**							       **/
/**   DESCRIPTION: addlist adds	one function to	the others     **/
/**   CALLEE/CALLER list the list being	chosen by the relation **/
/**   being passed in.					       **/
/**							       **/
/**   GLOBAL VARS REFERENCED: endofsp			       **/
/**							       **/
/**   GLOBAL VARS MODIFIED: none			       **/
/**							       **/
/****************************************************************/

void addlist( pafunc, pbfunc, filename,	lineno,	relation )

	struct func_ref_type *pafunc;
	struct func_ref_type *pbfunc;
	char *filename;
	int lineno;
	enum relationchoice relation;

{
	struct listtype	*listptr;
	char *parentptr;
	if ( ( ( relation == CALLEE ) ?
			pafunc->pcalleelist : pafunc->pcallerlist ) == NULL )
		{
		if ( ( listptr = (struct listtype *)malloc(
				sizeof(	struct listtype	) ) ) == NULL )
			{
			fprintf( stderr, endofsp );
			exit( -1 );
			}
		if ( relation == CALLEE	)
			{
			pafunc->pcalleelist = (char *)listptr;
			}
		else
			{
			pafunc->pcallerlist = (char *)listptr;
			}
		}
	else
		{
		listptr	= (struct listtype *)( relation	== CALLEE ?
							pafunc->pcalleelist : pafunc->pcallerlist );
		while (	listptr->pnext_func_ref	)
			{	/* walk	the list, and insert at	the end	*/
			listptr	= (struct listtype *)listptr->pnext_func_ref;
			}	/* End of while	*/
		if ( ( listptr->pnext_func_ref = (char *)malloc(
				sizeof(	struct listtype	) ) ) == NULL )
			{
			fprintf( stderr, endofsp );
			exit( -1 );
			}
		listptr	= (struct listtype *)listptr->pnext_func_ref;
		}

	listptr->pelist	= pbfunc;
	listptr->pnext_func_ref	= NULL;
	listptr->file_name = strdup( filename );
	listptr->lineno	= lineno;
}


/****************************************************************/
/**							       **/
/**   ARGUMENTS: pointer to a function reference.	       **/
/**		 level of nesting so far.		       **/
/**		 relation to use.			       **/
/**							       **/
/**   RETURN: none					       **/
/**							       **/
/**   DESCRIPTION: dumptree prints out the current nesting     **/
/**   level of relation	and calls itself recursively for lower **/
/**   nesting levels.					       **/
/**							       **/
/**   GLOBAL VARS REFERENCED: cutoff, verbose, ellipses	       **/
/**							       **/
/**   GLOBAL VARS MODIFIED: none			       **/
/**							       **/
/****************************************************************/

void dumptree( pafunc, level, relation )

	struct func_ref_type *pafunc;
	int level;
	enum relationchoice relation;

{
	struct listtype	*roverptr;
	struct listtype	*beginlist;
	struct func_ref_type *old_pafunc;
	char *old_nextptr;
	int i;
	if ( pafunc && level < cutoff )
		{			/* There is a branch below this	level */
		if ( !level )
			{
			printf( "%4d", level );
			for ( i	= 0; i <= level; i++ )
				{
				putchar( '\t' );
				}	/* End of for */

			if ( pafunc->file_name )
				{	/* a definition	has been found */
				printf( "%s:%s() <%s,%d>\n", pafunc->name, pafunc->type,
					pafunc->file_name, pafunc->lineno );
				}
			else
				{
				printf( "%s:%s() <,>\n", pafunc->name, pafunc->type );
				}
			level++;
			}
		if ( relation == CALLEE	)
			{
			beginlist = roverptr = (struct listtype	*)pafunc->pcalleelist;
			}
		else
			{
			beginlist = roverptr = (struct listtype	*)pafunc->pcallerlist;
			}

		while (	roverptr )
			{		/* Walk	the list of CALLER/CALLEE's */
			if ( !verbose && beginlist != &ellipses	&& beginlist ==	roverptr )
				{
				printf( "(%3d)", xref );
				}
			else
				{
				printf( "     ", xref );
				}
			printf( "%4d", level );

			for ( i	= 0; i <= level; i++ )
				{
				putchar( '\t' );
				}	/* End of for */

			if ( roverptr->pelist != (struct func_ref_type *)NULL )
				{
				printf( "%s:%s() <%s,%d>", roverptr->pelist->name,
					roverptr->pelist->type,	roverptr->file_name,
					roverptr->lineno );
				}
			else
				{
				printf( "...relations shown at (%1d)", pafunc->xref );
				}
			old_pafunc = roverptr->pelist;
			old_nextptr = roverptr->pnext_func_ref;
			if ( !verbose && beginlist != &ellipses	&& beginlist ==	roverptr )
				{
				free( beginlist->file_name );
				free( beginlist	);
				pafunc->xref = xref++;
				if ( relation == CALLEE	)
					{
					pafunc->pcalleelist = (char *)&ellipses;
					}
				else
					{
					pafunc->pcallerlist = (char *)&ellipses;
					}
				}
			putchar( '\n' );
			dumptree( old_pafunc, level + 1, relation );
			roverptr = (struct listtype *)old_nextptr;
			}	/* End of while	*/
		}
}

/****************************************************************/
/**							       **/
/**   ARGUMENTS: none					       **/
/**							       **/
/**   RETURN: none					       **/
/**							       **/
/**   DESCRIPTION: initstatemachine sets up which state	to go  **/
/**   to given which state is currently	active and which       **/
/**   character	has been read in.			       **/
/**							       **/
/**   GLOBAL VARS REFERENCED: gotonextstate		       **/
/**							       **/
/**   GLOBAL VARS MODIFIED: gotonextstate		       **/
/**							       **/
/****************************************************************/

void initstatemachine()

{
	int character;
	for ( character	= 0; character < 128; character++ )
		{	/* set up the majority of state	jumps */
		if ( !isalnum( character ) && character	!= '_' && character != '(' )
			{
			gotonextstate[ INITIA ][ character ] = NAME;
			}
		else
			{
			gotonextstate[ INITIA ][ character ] = INITIA;
			}
		gotonextstate[ BEGCOM ][ character ] = INITIA;
		gotonextstate[ COMMEN ][ character ] = COMMEN;
		gotonextstate[ AFTCOM ][ character ] = COMMEN;
		gotonextstate[ DOUBQT ][ character ] = DOUBQT;
		gotonextstate[ DBQTBS ][ character ] = DOUBQT;
		gotonextstate[ SINGQT ][ character ] = SINGQT;
		gotonextstate[ SGQTBS ][ character ] = SINGQT;
		gotonextstate[ POUND ][	character ] = POUND;
		}	/* End of for */
	/* Now set all of the exceptions */

	gotonextstate[ INITIA ][ ';' ] = TYPE;	/* preceeding beginning	of a type */
	gotonextstate[ INITIA ][ ',' ] = TYPE;
	gotonextstate[ INITIA ][ '{' ] = TYPE;
	gotonextstate[ INITIA ][ '}' ] = TYPE;

	gotonextstate[ INITIA ][ '#' ] = POUND;		/* beginning of	preprcssr */
	gotonextstate[ INITIA ][ '/' ] = BEGCOM;	/* beginning of	comment*/
	gotonextstate[ INITIA ][ '"' ] = DOUBQT;	/* double quoted stuff */
	gotonextstate[ DOUBQT ][ '"' ] = INITIA;	/* end of double quoted stuff */
	gotonextstate[ INITIA ][ '\'' ] = SINGQT;	/* single quoted stuff */
	gotonextstate[ SINGQT ][ '\'' ] = INITIA;	/* end of single quoted stuff */
	gotonextstate[ BEGCOM ][ '*' ] = COMMEN;	/* end comment is confirmed */
	gotonextstate[ DOUBQT ][ '\\' ]	= DBQTBS;	/* protect the next character */
	gotonextstate[ SINGQT ][ '\\' ]	= SGQTBS;	/* protect the next character */
	gotonextstate[ COMMEN ][ '*' ] = AFTCOM;	/* possible end	of comment */
	gotonextstate[ AFTCOM ][ '*' ] = AFTCOM;	/* possible end	of comment */
	gotonextstate[ AFTCOM ][ '/' ] = INITIA;	/* possible end	of comment */
	gotonextstate[ POUND ][ '\n' ] = INITIA;	/* end of preprocessor */
}


/****************************************************************/
/**							       **/
/**   ARGUMENTS: relationship to use for outputting trees.     **/
/**							       **/
/**   RETURN: none					       **/
/**							       **/
/**   DESCRIPTION: sortdump looks at all of the	function names **/
/**   and sorts	them using qsort.  Then	the functions are      **/
/**   dumped out using dumptree	with the relation wanted being **/
/**   passed on	to dumptree.				       **/
/**							       **/
/**   GLOBAL VARS REFERENCED: totalfuncs, endofsp, hashtbl     **/
/**							       **/
/**   GLOBAL VARS MODIFIED: none			       **/
/**							       **/
/****************************************************************/

void sortdump( relationship )

	enum relationchoice relationship;

{
	int hashlook;
	struct func_ref_type **ppelist;
	struct func_ref_type *pcollisionwalker;
	struct func_ref_type **ppsorttable;
	if ( ( ppsorttable = (struct func_ref_type **)malloc(
			sizeof(struct func_ref_type *) * ( totalfuncs +	1 ) ) )	== NULL	)
		{
		fprintf( stderr, endofsp );
		exit( -1 );
		}
	ppelist	= ppsorttable;
	for ( hashlook = 0; hashlook < HASHSIZE; hashlook++ )
		{				/* for each element in the hash	table */
		if ( hashtbl[ hashlook ] )
			{
			pcollisionwalker = *ppelist = hashtbl[ hashlook	];
			ppelist++;
			while (	pcollisionwalker->pnext_func_ref )
				{		/* for each collision element */
				pcollisionwalker =
					(struct	func_ref_type *)pcollisionwalker->pnext_func_ref;
				*ppelist = pcollisionwalker;
				ppelist++;
				}	/* End of while	*/
			}
		}	/* End of for */
	qsort( (char *)ppsorttable, totalfuncs,	sizeof(struct func_ref_type *),
			mycompare );
	ppelist	= ppsorttable;
	while (	ppelist	< (ppsorttable + totalfuncs) )
		{
		putchar( '\n' );
		dumptree( *ppelist, 0, relationship );
		ppelist++;
		}	/* End of while	*/
}

/****************************************************************/
/**							       **/
/**   ARGUMENTS: pointers to two function reference nodes      **/
/**							       **/
/**   RETURN: 1, 0, or -1				       **/
/**							       **/
/**   DESCRIPTION: compare compares the	two function names in  **/
/**   the structures pointed to	by ppa,	and ppb.  The return   **/
/**   value is the result of the strcmp	of these two names.    **/
/**							       **/
/**   GLOBAL VARS REFERENCED: none			       **/
/**							       **/
/**   GLOBAL VARS MODIFIED: none			       **/
/**							       **/
/****************************************************************/

int mycompare( ppa, ppb	)

	char **ppa;
	char **ppb;

{
	return(	strcmp(	((struct func_ref_type *)(*ppa))->name,
			((struct func_ref_type *)(*ppb))->name ) );
}


/****************************************************************/
/**							       **/
/**   ARGUMENTS: none					       **/
/**							       **/
/**   RETURN: an integer				       **/
/**							       **/
/**   DESCRIPTION: This	state machine reads in characters and  **/
/**   keeps reading in characters until	an initial state is    **/
/**   reached, this means the character	being read is not in a **/
/**   comment, or quoted.  Also	tags are marked	to show	the    **/
/**   possible start of	function names,	and type returns.  In  **/
/**   addition a count of parens and braces is made for	use    **/
/**   elsewhere.					       **/
/**							       **/
/**   GLOBAL VARS REFERENCED: lineno, parens, gotonextstate,   **/
/**			      braces, last_func_ret_type,      **/
/**			      last_func_name		       **/
/**							       **/
/**   GLOBAL VARS MODIFIED:   lineno, parens, braces,	       **/
/**			      last_func_ret_type,	       **/
/**			      last_func_name		       **/
/**							       **/
/****************************************************************/

int getsucc()


{
	static int near	c;
	static int near	state;
	static int near	previousstate;
	state =	INITIA;	/* start things	out in the initial state */
	do
		{
		if ( ( c = getc( fp ) )	== '\n'	)
			{
			lineno++;
			}
		if ( c == EOF )
			{
			return(	EOF );
			}
		previousstate =	state &	15;
		state =	gotonextstate[ state ][	c ];
		} while	( ( state & 15 ) != INITIA
				|| (  previousstate != INITIA && previousstate != BEGCOM ) );
		/* Keep	eating characters until	we are out of comments and quotes */

	if ( previousstate == BEGCOM )
		{	/* This	is the only context sensitive area, if a '/' is	seen
			followed by anything but a '*' then we must back up */
		ungetc(	c, fp );
		return( '/' );
		}
	if ( state == TYPE )
		{		/* Save	the location of	the last function return value */
		SAVEPLACE( last_func_ret_type );
		braces += BRACES( c );
		}
	else
		{
		parens += PARENS( c );
		if ( state == NAME )
			{
			SAVEPLACE( last_func_name );
			}
		}
	return(	c );
}




/****************************************************************/
/**							       **/
/**   ARGUMENTS: character				       **/
/**							       **/
/**   RETURN: character					       **/
/**							       **/
/**   DESCRIPTION: succpos finds the next succesive position   **/
/**   in a file	that matches the character passed into it.     **/
/**							       **/
/**   GLOBAL VARS REFERENCED: none			       **/
/**							       **/
/**   GLOBAL VARS MODIFIED: none			       **/
/**							       **/
/****************************************************************/

int succpos( c )   /* Sets pointer to next position of character [c] */
	int c;
{
	static int near	tmpc;
	while (	( c != ( tmpc =	getsucc() ) ) && ( tmpc	!= EOF	) )
		;
	if( tmpc != EOF	)
		{
		ungetc(	c, fp );
		return(	1 );
		}
	return(	0 );
}



/****************************************************************/
/**							       **/
/**   ARGUMENTS: character pointer			       **/
/**							       **/
/**   RETURN: character					       **/
/**							       **/
/**   DESCRIPTION: nsuccmemb finds the next succesive character**/
/**   using getsucc that is not	a member of the	characters     **/
/**   pointed to by the	variable passed	in.		       **/
/**							       **/
/**   GLOBAL VARS REFERENCED: none			       **/
/**							       **/
/**   GLOBAL VARS MODIFIED: none			       **/
/**							       **/
/****************************************************************/

int nsuccmemb( lstr )

	char *lstr;
{
	int c;
	if( ( c	= getsucc() ) != EOF )
		{
		while (	( strchr( lstr,	c ) != NULL ) && ( c !=	EOF ) )
			{
			c = getsucc();
			}    /*	End of while */
		ungetc(	c, fp );
		}
	return(	c != EOF );
}



/****************************************************************/
/**							       **/
/**   ARGUMENTS: character pointers			       **/
/**							       **/
/**   RETURN: none					       **/
/**							       **/
/**   DESCRIPTION: readtoken reads in characters using getsucc **/
/**   as long as the characters	are members of characters      **/
/**   pointed to by plegalstr, these characters	are put	into   **/
/**   the place	pointed	to by ptokenstr, and null terminated.  **/
/**							       **/
/**   GLOBAL VARS REFERENCED: none			       **/
/**							       **/
/**   GLOBAL VARS MODIFIED: none			       **/
/**							       **/
/****************************************************************/

void readtoken(	plegalstr, ptokenstr )	/* Reads token composed	of
					   *plegalstr into *ptokenstr */
	char *plegalstr;
	char *ptokenstr;

{
	int c;
	struct placeptr	place;
	SAVEPLACE( place );
	RECOVERPLACE( place );
	while (	( c = getsucc()	) && strchr( plegalstr,	c ) && c != EOF	)
		{
		*ptokenstr++ = (char )c;
		}	/* End of while	*/
	*ptokenstr = 0;
}


/****************************************************************/
/**							       **/
/**   ARGUMENTS: character pointer, and	an array of character  **/
/**		 pointers.				       **/
/**							       **/
/**   RETURN: integer					       **/
/**							       **/
/**   DESCRIPTION: ismember returns -1 if ptoken is not	a      **/
/**   member of	any of the characters pointed to in the	array  **/
/**   plistwords,  if the ptoken is a member, the position in  **/
/**   that array is returned.				       **/
/**							       **/
/**   GLOBAL VARS REFERENCED: none			       **/
/**							       **/
/**   GLOBAL VARS MODIFIED: none			       **/
/**							       **/
/****************************************************************/

int ismember( ptoken, plistwords )
	char *ptoken, *plistwords[];
{
	int i =	0;
	while (	*plistwords && strcmp( ptoken, *plistwords ) )
		{
		*++plistwords;
		++i;
		}    /*	End of while */
	return(	strcmp(	ptoken,	*plistwords ) ?	-1 : i );
}



static unsigned	int width;
static int (*compare)( char **,	char **	);



/****************************************************************/
/**							       **/
/**   ARGUMENTS:	base = (char *)	pointer	to base	of array   **/
/**		num  = (unsigned) number of elements in	the array  **/
/**	wid  = (unsigned) width	in bytes of each array element **/
/**		comp = (int (*)	()) pointer to function	returning      **/
/**		analog of strncmp for strings, but supplied for	       **/
/**		comparing the array elements.  It accepts 2 pointers   **/
/**		to elements and	returns	neg if 1<2, 0 if 1=2,	       **/
/**		pos if 1>2.					       **/
/**							       **/
/**   RETURN: none					       **/
/**							       **/
/**   DESCRIPTION: qsort quick sorts an	array of elements in   **/
/**   place.						       **/
/**							       **/
/**   GLOBAL VARS REFERENCED: array starting at	base	       **/
/**							       **/
/**   GLOBAL VARS MODIFIED: array starting at base	       **/
/**							       **/
/****************************************************************/

void qsort( base, num, wid, comp )

	char *base;
	unsigned int num;
	unsigned int wid;
	int (*comp)( char **, char ** );

{
	register char *q = base;
	register char *p = base	+ wid;
	int i =	num - 1;
	int sort = 0;	/* set to non-zero if sort must	be done	*/
			/* (some element is out	of order) */

	if ( num )
		{
		while (	i-- )
			{
			if ( (*comp)( (char **)q, (char	**)p ) > 0 )
				{
				sort++;
				break;
				}

			q = p;
			p += wid;
			}
		}

	if (sort)
		{
		width =	wid;
		compare	= comp;
		quicksort( base, base +	(num - 1) * width );
		}
}


static void quicksort( lo, hi )

	char *lo;
	char *hi;

{
	register char *higuy = hi + width;
	register char *loguy = lo;

	while (	lo < hi	)
		{
		for ( ;	; )
			{
			do	{
				loguy += width;
				} while	(loguy < hi && (*compare)( (char **)loguy, (char **)lo ) <= 0);

			do	{
				higuy -= width;
				} while	(higuy > lo && (*compare)( (char **)higuy, (char **)lo ) >= 0);

			if (higuy <= loguy)
				break;

			swap( loguy, higuy, width );
			}	/* End of for */

		swap( lo, higuy, width );
		if ( higuy - lo	>= hi -	higuy )
			{
			quicksort( higuy + width, hi );
			hi = higuy - width;
			loguy =	lo;
			}
		else
			{
			quicksort( lo, higuy - width );
			loguy =	lo = higuy + width;
			higuy =	hi + width;
			}
		}	/* End of while	*/
}



static void swap ( one,	two, w )

	char *one;
	register char *two;
	unsigned int w;

{
	char temp;

	while (	w-- )
		{
		temp = *one;
		*one++ = *two;
		*two++ = temp;
		}
}
