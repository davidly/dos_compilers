/*****
*  WORDCNT.C - Sample program for the debugging tutorial
*
*  Copyright (c) 1988 Borland International. All rights reserved.
*
*  NOTE: This program is for use with the debugging tutorial
*        in the debugging chapter of the User's Guide. It
*        intentionally contains bugs.
******/

#include <stdio.h>
#include <ctype.h>

#define MAXWORDLEN      16
#define NUL             ((char)0)
#define SPACE           ((char)0x20)

/*****
* Find the next word in the line buffer.
* IN:     wordptr points to the first character of a word or a preceding
*         space.
* RETURN: A pointer to the first character of the word. If there are no
*         more words, a pointer to the terminating NUL.
*****/
char *nextword(char *wordptr)
{
/* Advance to the first non-space. */
  while ( *wordptr==SPACE )
    wordptr++;
  return(wordptr);
}


/*****
* Find the length of a word. A word is defined as a sequence of characters
* terminated by a space or a NUL.
* IN:    wordptr points to a word.
* RETURN:The length of the word.
*****/
int wordlen(char *wordptr)
{
  char *wordlimit;
  wordlimit = wordptr;
  while ( *wordlimit & *wordlimit!=SPACE )
    wordlimit++;
  return( wordlimit-wordptr );
}


/*****
* The main function.
*****/
void main(void)
{
  FILE	*infile;        /* Input file. */
  char	linebfr[1024],  /* Input line buffer, very long for safety. */
        *wordptr;       /* Pointer to next word in linebfr. */
  int     i;            /* Scratch variable. */
  static int	wordlencnt[MAXWORDLEN],
                        /* Word lengths are counted in elements 1 to
                         MAXWORDLEN. Element 0 isn't used. The array is
                         static so that the elements need not be set to
                         zero at run time. */
	        overlencnt;     /* Overlength words are counted here. */

  printf("WARNING: This is an example program for the practice\n");
  printf("debugging session.  If you are not running this under the\n");
  printf("Integrated Development Environment press control-break now.\n");
  printf("See the debugging chapter of the User's Guide for details.\n\n");

  printf( "Enter the input file's name: " );
  gets(linebfr);
  if ( !strlen(linebfr) ) {
    printf( "You must specify an input file name!\n" );
    exit();
  }

  infile = fopen( linebfr, "r" );
  if ( !infile ) {
    printf( "Can't open input file!\n" );
    exit();
  }

/* Each loop processes one line. NOTE: if a line is longer than the
 input buffer the program may produce invalid results. The very large
 buffer makes this unlikely. */
  while (   fgets( linebfr, sizeof(linebfr), infile )   )   {
    printf("%s\n",linebfr);
    /* Check for buffer overflow & remove the trailing newline. */
    i = strlen(linebfr);
    if ( linebfr[i-1] != '\n' )
      printf( "Overlength line beginning\n\t%70s\n", linebfr );
    else
      linebfr[i-1] = NUL;

    /* lineptr points to the 1st word in linebfr (past leading spaces). */
    wordptr = nextword(linebfr);

    /* Each loop processes one word. The loop ends when [nextword]
       returns NULL, indicating there are no more words. */
    while (*wordptr) {
    /* Find the length of this word, increment the proper element of the
       length count array, & point to the space following the word. */
      i = wordlen(wordptr);
      if ( i > MAXWORDLEN )
        overlencnt++;
      else
      ;
      wordlencnt[i]++;
    wordptr += i;

      /* Find the next word (if any). */
      wordptr = nextword(wordptr);
    }
  }

/* Print the word length counts. Each loop prints one. */
  printf(  "  Length Count\n" );
  for ( i=1; i<MAXWORDLEN; i++ )
    printf( "  %5d %5d\n", i, wordlencnt[i] );
  printf( "Greater %5d\n", overlencnt );

/* Close the file & quit. */
  fclose(infile);
}
