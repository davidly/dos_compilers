/**
*
* This module defines the standard C main function _main.
*
* This version processes the command-line specifiers which modify
* the stack size or specify assignments for "stdin" and "stdout".
*
**/
#include "stdio.h"
#include "ctype.h"

#define MAXNAM 16              /* maximum filename size */
#define MAXARG 32              /* maximum command line arguments */

/**
*
* The following location defines the default stack size (bytes).  It is
* used by "sbrk" to call XCMEM to initialize the memory pool.
*
**/
extern int _stack;

/**
*
* name         _main - process command line, open files, and call "main"
*
* synopsis     _main(line);
*              char *line;     ptr to command line that caused execution
*
* description  This function performs the standard pre-processing for
*              the main module of a C program.  It accepts a command
*              line of the form
*
*              pgmname [=stack] [<infile] [>outfile] parms
*
*              and processes the three optional leading fields, builds
*              a list of pointers to the other parameters, and calls
*              the main function "main".  The first optional field
*              specifies an override of the default stack size; "stack"
*              should be a decimal number of bytes.  The second specifies
*              a file name for assignment to "stdin"; "infile" is the
*              file name.  The third specifies, similarly, a file name
*              "outfile" for assignment to "stdout".  Note that the
*              optional fields need not be specified in the order listed
*              above.
*
**/
_main(line)
char *line;
{
int i;
FILE *fp0, *fp1, *fp2;
static int argc = 1;
static char *outmode = "w";
static char inam[MAXNAM+1], onam[MAXNAM+1], tnam[1];
static char *argv[MAXARG];

while (isspace(*line)) line++;         /* find program name */
for(argc = 0; argc < MAXARG; )
{
switch(*line)
{
case '=':                              /* stack size specifier */
   line++;
   _stack = 0;
   while (isdigit(*line))
       _stack = 10*_stack + (*line++ & 15);
   break;

case '<':                              /* input file specifier */
   line++;
   for(i = 0; (*line != '\0') && (isspace(*line) == 0); line++)
       if (i<MAXNAM) inam[i++] = *line;
   inam[i] = '\0';
   break;

case '>':                              /* output file specifier */
   line++;
   if (*line == '>')
       {                       /* output file to be appended to */
       outmode = "a";
       line++;
       }
   for (i = 0; (*line != '\0') && (isspace(*line) == 0); line++)
       if (i<MAXNAM) onam[i++] = *line;
   onam[i] = '\0';
   break;

default:                               /* command line argument */
   argv[argc++] = line;
   while (*line != '\0' && isspace(*line) == 0) line++;
}
i = *line;             /* save terminating character */
*line++ = '\0';
if (i == '\0') break;                  /* end of line */
while (isspace(*line)) line++;         /* scan to next */
if (*line == '\0') break;
}

fp0 = fopen(inam, "r");        /* open stdin */
fp1 = fopen(onam, outmode);    /* open stdout */
fp2 = fopen(tnam, "a");        /* open stderr */
if (fp2 == NULL) _exit(1);
if (fp0 == NULL)
   {
   fputs("Can't open stdin file\n", fp2);
   exit(1);
   }
if (fp1 == NULL)
   {
   fputs("Can't create stdout file\n", fp2);
   exit(1);
   }

if (inam[0] == '\0')
   fp0->_flag |= _IONBF;
if (onam[0] == '\0') 
   fp1->_flag |= _IONBF;
fp2->_flag |= _IONBF;

main(argc, argv);              /* call main function */
exit(0);
}
0') 
   fp1->_flag |= _IONBF;
fp2->_flag |= _IONBF;