/*  skel.c - skeleton for loadable Z extension
 *
 *  Extensions have three components, defined in this order:
 *
 *	Editor functions.  These are commands that can be attached to
 *	    keys and are invoked when those keys are struck.  These functions
 *	    have 5 arguments:
 *
 *	    arg - the keystroke that was used to invoke the function.
 *	    cArg - the number of <arg> commands that have been issued before
 *		this function.
 *	    argType - the class of argument that has been read.  This is one
 *		of the following:
 *		NOARG - no arg was given
 *		LINEARG - the cursor is in the same column as the original arg
 *		    but on a different line
 *		STREAMARG - the cursor is in the same line as the original arg
 *		    but in a different column.
 *		NULLARG - the cursor is in the same place as the original arg
 *		BOXARG - the cursor is on a different line and in a different
 *		    column
 *		TEXTARG - the user has handed in some text.
 *	    pText - a far pointer to a NUL-terminated string that indicates
 *		the special text involved.  This has meaning ONLY for
 *		NULLARG, STREAMARG, and TEXTARG.
 *	    fMeta - the value of the flag controlled by the <meta> command.
 *
 *	    Editor functions are expected to return a boolean value indicating
 *	    success or failure.  Typically, TRUE is returned in the normal case.
 *	    These values can be tested inside of macros.
 *
 *	Command description table.  This is a vector of command descriptions
 *	    that contain the textual name of the function (for user assignment),
 *	    the function to be called, and some data describing the type of
 *	    arguments that the function can take.
 *
 *	WhenLoaded function.  This function is called whenever the extension
 *	    is loaded into memory.
 *
 *  Modifications
 *
 *	16-Jan-1987 mz	Add pascal typing
 *			Export switch set
 *	21-May-1987 bw	Add return from WhenLoaded for OS/2
 *	22-Oct-1987 mz	Correct definitions as headers
 *
 */

#include "ext.h"

#define TRUE	-1
#define FALSE	0
#define NULL	((char *) 0)

flagType pascal EXTERNAL Skel (argData, pArg, fMeta)
unsigned int argData;
ARG far * pArg;
flagType fMeta;
{
    return TRUE;
}

struct swiDesc	swiTable[] =
{
    {	NULL, NULL, NULL    }
};

struct cmdDesc	cmdTable[] =
{
    {"skel",Skel,0,    NOARG						    },
    {NULL,  NULL,NULL, NULL						    }
};

WhenLoaded ()
{
    return TRUE;
}
