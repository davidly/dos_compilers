/*  extension definitions
 *
 *  Modifications:
 *
 *	16-Jan-1987 mz	Add pascal typing
 *			Exportable switch lists
 *	10-Feb-1987 mz	Add fExecute
 *	22-Oct-1987 mz	Correct definitions as headers
 *	23-Oct-1987 bw	long LINE
 *	15-Dec-1987 bw	Add ReadCmd and ReadChar
 *			Add KbHook and KbUnHook
 *			Add toPIF() macro
 */

#define EXTERNAL    far

#define BUFLEN	250

/* Use this in a swiDesc table to eliminate C 5.X compiler warnings.
 * For example: { "Switchname", toPIF(switchvar), SWI_BOOLEAN },
*/
#define toPIF(x)  (PIF)(long)(void far *)&x

typedef char buffer[BUFLEN];

typedef char flagType;

typedef long LINE;
typedef int  COL;

struct cmdDesc {
    char far *name;
    flagType (pascal EXTERNAL *func)();
    unsigned arg;
    unsigned argType;
    };

typedef struct cmdDesc far *PCMD;

typedef flagType (pascal EXTERNAL *PIF)(char far *);

union swiAct {
    flagType (pascal EXTERNAL *pFunc)(char far *);
    int far *ival;
    flagType far *fval;
    };

struct swiDesc {
    char far *name;
    union swiAct act;
    int type;
    };

typedef struct swiDesc far *PSWI;

#define SWI_BOOLEAN 0
#define SWI_NUMERIC 1
#define SWI_SCREEN  4
#define SWI_SPECIAL 5

/*  The following need to be added to SWI_NUMERIC to control interpretation
 *  and display of the values
 */
#define RADIX10 (0x0A << 8)
#define RADIX16 (0x10 << 8)

typedef unsigned PFILE;

flagType    pascal Replace	    (char, COL, LINE, PFILE, flagType);
void	    pascal MoveCur	    (COL, LINE);
void	    pascal DelLine	    (PFILE, LINE, LINE);
void	    pascal DelBox	    (PFILE, COL, LINE, COL, LINE);
void	    pascal DelStream	    (PFILE, COL, LINE, COL, LINE);
PFILE	    pascal AddFile	    (char far *);
void	    pascal DelFile	    (PFILE);
flagType    pascal RemoveFile	    (PFILE);
void	    pascal CopyBox	    (PFILE, PFILE, COL, LINE, COL, LINE, COL, LINE);
void	    pascal CopyLine	    (PFILE, PFILE, LINE, LINE, LINE);
void	    pascal CopyStream	    (PFILE, PFILE, COL, LINE, COL, LINE, COL, LINE);
void	    pascal pFileToTop	    (PFILE);
void	    pascal Display	    (void);
void	    pascal GetCursor	    (COL far *, LINE far *);
LINE	    pascal FileLength	    (PFILE);
int	    pascal GetLine	    (LINE, char far *, PFILE);
PFILE	    pascal FileNameToHandle (char far *, char far *);
flagType    pascal FileRead	    (char far *, PFILE);
flagType    pascal FileWrite	    (char far *, PFILE);
flagType    pascal SetKey	    (char far *, char far *);
int	    pascal DoMessage	    (char far *);
void	    pascal PutLine	    (LINE, char far *, PFILE);
flagType    pascal BadArg	    (void);
flagType    pascal fExecute	    (char far *);
PSWI	    pascal ReadCmd	    (void);
long	    pascal ReadChar	    (void);
void	    pascal KbHook	    (void);
void	    pascal KbUnHook	    (void);

/*  Each function has a definition of how arguments are to be processed.
 *  This definition is comprised of a bitmap describing which arguments are
 *  legal and, if so, how they are to be interpreted.  The definitions are:
 *
 *  KEEPMETA	The function being executed does not take the <meta>
 *		prefix.  The state of the <meta> flag is preserved
 *		across this editor function.
 *
 *  CURSORFUNC	The function being executed is a cursor movement
 *		function.  It is allowed within the context of
 *		an <arg> to select a file range on the screen; it
 *		cannot take an <arg>.  It does not remove highlighting
 *		that is present on the screen.
 *
 *  WINDOWFUNC	The function being executed is a window movement
 *		function.  It does not remove highlighting that is
 *		present on the screen.
 *
 *  NOARG	The function accepts the absence of an <arg> function.
 *		When called the function receives a pointer to a
 *		structure containing the location where the function
 *		is expected to be applied.
 *
 *  TEXTARG	The function accepts a textual argument that may
 *		be typed in or selected on the screen.	The function is
 *		called with a far pointer to the asciz text of the
 *		argument.  See NULLEOL, NULLEOW, BOXSTR.
 *
 *  NULLARG	The function accepts an <arg> with no discernable
 *		cursor movement (cursor is on <arg> position).	The
 *		function is called with a pointer to a structure
 *		containing the location of the arg within the file.
 *
 *  NULLEOL	The function accepts an <arg> with no discernable
 *		cursor movement (cursor is on <arg> position).	The
 *		function is called with a pointer to a structure
 *		indicating TEXTARG and containing a pointer to the
 *		asciz text of the line from the cursor to end-of-line.
 *
 *  NULLEOW	The function accepts an <arg> with no discernable
 *		cursor movement (cursor is on <arg> position).	The
 *		function is called with a pointer to a structure
 *		indicating TEXTARG and containing a pointer to the
 *		asciz text of the line from the cursor to the next
 *		whitespace.
 *
 *  LINEARG	The function accepts an <arg> that is in the same
 *		column as the cursor.  The function is expected to be
 *		applied to all lines beginning in the range <arg> to
 *		cursor inclusive.  The function is called with a
 *		pointer to a structure containing the beginning
 *		line of the range and the ending line of the range
 *
 *  STREAMARG	The function accepts an <arg> that is considered to
 *		apply beginning at a specific file location and
 *		proceeding through all intervening lines and line-
 *		breaks up until just to the left of the ending file
 *		position.  The function is called with a pointer to
 *		a structure containing the beginning point of the range
 *		and the first point just beyond the end of the range.
 *
 *  BOXARG	The function accepts an <arg> that is considered to
 *		apply to a rectangle on the screen.  The function is
 *		called with a pointer to a structure containing the
 *		left and right column boundaries (inclusive) and the
 *		top and bottom line numbers (inclusive) that describe
 *		the region.
 *
 *  BOXSTR	If a BOXARG is presented to the function and the box
 *		contains only a single line, the function is called
 *		with a pointer to a structure marked TEXTARG and
 *		containing a far pointer to the selection as an asciz
 *		string.
 *
 *  NUMARG	If text was specified and is numeric, it is considered
 *		to represent a number of lines offset from the cursor
 *		and represents the other end of an arg.  The
 *		above tests are then applied, excluding TEXTARG.
 *
 *  MARKARG	If text was specified and interpreted as a mark, it is
 *		considered to be the other end of an arg.  The above
 *		tests are then applied, excluding TEXTARG.
 */

#define NOARG	    0x0001		/* no argument specified	      */
#define TEXTARG     0x0002		/* text specified		      */
#define NULLARG     0x0004		/* arg + no cursor movement	      */
#define NULLEOL     0x0008		/* null arg => text from arg->eol     */
#define NULLEOW     0x0010		/* null arg => text from arg->end word*/
#define LINEARG     0x0020		/* range of entire lines	      */
#define STREAMARG   0x0040		/* from low-to-high, viewed 1-D       */
#define BOXARG	    0x0080		/* box delimited by arg, cursor       */

#define NUMARG	    0x0100		/* text => delta to y position	      */
#define MARKARG     0x0200		/* text => mark at end of argument    */

#define BOXSTR	    0x0400		/* single-line box => text	      */

#define KEEPMETA    0x2000		/* do not eat meta flag 	      */
#define WINDOWFUNC  0x4000		/* moves window 		      */
#define CURSORFUNC  0x8000		/* moves cursor 		      */


/*  no argument specified						      */
struct	noargType {
    LINE    y;
    COL     x;
    };

/*  text argument specified						      */
struct textargType {
    int     cArg;
    LINE    y;
    COL     x;
    char far *pText;
    };

/*  null argument specified						      */
struct	nullargType {
    int     cArg;
    LINE    y;
    COL     x;
    };

/*  line   argument specified						      */
struct lineargType {
    int     cArg;
    LINE yStart;
    LINE yEnd;
    };

/*  stream argument specified						      */
struct streamargType {
    int     cArg;
    LINE yStart;
    COL  xStart;
    LINE yEnd;
    COL  xEnd;
    };

/*  box argument specified						      */
struct boxargType {
    int     cArg;
    LINE yTop;
    LINE yBottom;
    COL  xLeft;
    COL  xRight;
    };

struct	argType {
    int     argType;
    union   {
	struct	noargType	noarg;
	struct	textargType	textarg;
	struct	nullargType	nullarg;
	struct	lineargType	linearg;
	struct	streamargType	streamarg;
	struct	boxargType	boxarg;
	} arg;
    };

typedef struct argType ARG;
