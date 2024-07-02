/* CRLF.C - Translates files for use in the QuickC editor.
 *
 * Copyright (c) 1988-1989, Microsoft Corporation
 *
 * A program list is not required to create CRLF from inside QC. No
 * special options are required.
 *
 * The QuickC editor has the following restrictions on the files it
 * can edit:
 *
 *   - All lines must be terminated by a carriage return (CR) followed
 *     by a line feed (LF)--ASCII codes 0x0D/0x0A.
 *
 *   - Character 0 is not allowed.  All other characters in the
 *     range 1 to 255 are allowed.
 *
 * The editor specifically handles CR (0x0D), LF (0x0A), and HT (0x09).
 * Since other control characters may be undesirable, CRLF allows the
 * user to optionally change control characters to a specified character
 * or to simply remove them. The syntax is
 *
 *      CRLF <infile> <outfile> [/c<ascii>]
 *
 * where <infile> is the file to be translated, <outfile> is the new
 * translated file, and <ascii> is the ASCII code for the character
 * to which control characters (except CR, LF, and HT) will be translated.
 * The ASCII code may be entered in decimal (ddd), octal (0ddd), or
 * hexadecimal (0xddd).
 *
 * For example, /c32 will translate all control characters to spaces.
 * If <ascii> is given as 0, control characters will be removed rather
 * than translated. If /c is not given, the program will prompt for
 * translation characters.
 */

#include <stdio.h>
#include <io.h>
#include <conio.h>
#include <stdlib.h>
#include <memory.h>
#include <ctype.h>

/* Constants */
#define NUM_CHARS   32  /* Total number of control characters */

#define HT      0x09    /* Horizontal tab character           */
#define LF      0x0A    /* Linefeed character                 */
#define CR      0x0D    /* Carriage-return character          */

#define SKIP    0       /* Filter out control characters      */
#define PROMPT  -1      /* Get translation from prompts       */

/* Global variables. Note that the compiler initializes global arrays
 * to 0. The code in translate_char() depends on the following global
 * array being initialized to 0.
 */
int mapping[NUM_CHARS];

int global_trans = PROMPT;

/* Function prototypes */
void translate_file( FILE *fdIn, FILE *fdOut );
int  translate_char( int line, int c );

/* main - opens input and output files and translates them.
 *
 * Params: argc - count of arguments
 *         argv - array of argument strings
 *
 * Return: None
 */
void main( int argc, char *argv[] )
{
    FILE *fdInput;
    FILE *fdOutput;
    int  c;

    /* Check command line arguments for validity and print syntax
     * prompt if invalid.
     */
    if( (argc != 3) && (argc != 4) )
	{
        fprintf( stderr, "SYNTAX: crlf <infile> <outfile> [/c<ascii>]\n" );
        exit( 1 );
	}

    /* Check for the /c (or -c) option. If present, read in the
     * global translation value.
     */
    if( argc == 4 )
	{
        if( ((argv[3][0] == '/') || (argv[3][0] == '-')) &&
            (toupper( argv[3][1] ) == 'C') )
        {
            sscanf( &argv[3][2], "%i", &global_trans );
            if( global_trans > 255 )
            {
                fprintf( stderr, "crlf: unknown translation character\n" );
                global_trans = PROMPT;
            }
        }
		else
		{
            fprintf( stderr, "crlf: fatal error: unknown option '%s'\n",
                     argv[3] );
            exit( 1 );
		}
	}

    /* Try to open the input and output files in binary mode. */
    if( (fdInput = fopen( argv[1], "rb" )) == NULL )
	{
        fprintf( stderr, "crlf: fatal error: can't open '%s'\n", argv[1] );
        exit( 1 );
    }

    if( !access( argv[2], 0 ) )
    {
        printf( "File exists. Overwrite? " );
        c = getch();
        if( c != 'y' && c != 'Y' )
            exit( 1 );
        printf( "\n" );
    }
    if( (fdOutput = fopen( argv[2], "wb" )) == NULL )
	{
        fclose( fdInput );
        fprintf( stderr, "crlf: fatal error: can't open '%s'\n", argv[2] );
        exit( 1 );
	}

    /* Translate the input file to the output file. */
    translate_file( fdInput, fdOutput );

    /* Close the files and exit. */
    fclose( fdInput );
    fclose( fdOutput );
    exit( 0 );
}


/* translate_file - translates file for use in QuickC editor. Checks
 * each character to see if it is a control character, and if so,
 * handles appropriately.
 *
 * Params: fdIn - input file handle, as obtained from fopen()
 *         fdOut - output file handle, as obtained from fopen()
 *
 * Return: None
 *
 * Uses:   trans_mode - character to translate to
 */
void translate_file( FILE *fdIn, FILE *fdOut )
{
	int	c;
	int	i;
	int	line = 1;

    /* Loop until the end of the file, reading each character from
     * the input file and writing it to the output file. Handle
     * control characters; pass other characters through unchanged.
     * Note * that a return value of EOF does NOT necessarily indicate
     * the end of the file--feof() must be called to verify that
     * the end of file has actually been reached.
     */
    while( ((c = getc( fdIn )) != EOF) || (!feof( fdIn )) )
	{

        /* If CR, check and handle the next character. */
        if( c == CR )
        {
            /* Get the next key. */
            c = getc( fdIn );

            /* If we've reached the end of file, write character and
             * break loop to terminate function.
             */
            if( (c == EOF) && (feof( fdIn )) )
			{
                putc( CR, fdOut );
				break;
            }

            /* If it's a LF, write the CR/LF, increment the line count,
             * and use the continue statement to return to the top of
             * the loop for the next character.
             */
            else if( c == LF )
			{
                putc( CR, fdOut );
                putc( LF, fdOut );
				++line;
				continue;
            }

            /* If it's a CR with no following LF, skip or translate it. */
			else
            {
				if( global_trans != SKIP )
				{
					putc( translate_char( line, CR ), fdOut );
				}
			}
		}

        /* If it's LF with no preceeding CR (common in files uploaded
         * from Unix or Macintosh), write a CR/LF and increment the
         * line count.
         */
        else if( c == LF )
		{
            putc( CR, fdOut );
            putc( LF, fdOut );
			++line;
		}

        /* If it's a control character that we haven't already handled,
         * skip or translate it (depending on value of global_trans).
         */
        else if( (c != HT) && (c < NUM_CHARS) )
		{
            if( global_trans != SKIP )
                putc( translate_char( line, c ), fdOut );
		}

        /* Otherwise, just write the character to the output file. */
		else
			putc(c, fdOut);
	}
}


/* translate_char - translates a control character. If a translate
 * character was provided on the command line, it is used. Otherwise
 * the user is prompted for a translation character. This character
 * is put in the appropriate element of the mapping[] array for future
 * reference.
 *
 * For example, if we find character 3, and the user wants to map
 * this to character 42, we set mapping[3] = 42. Next time we encounter
 * character 3, we look at mapping[3] and substitute character 42
 * without asking.
 *
 * Params: line - line number in which the character was found
 *         c - character to be translated
 *
 * Return: Translated value of character (may be same as original
 *         character if user didn't want to translate it)
 *
 * Uses:   trans_mode - character to translate to
 *         mapping - array of translatable characters
 */
int translate_char( int line, int c )
{
    int  new_val;

    /* If command-line translation code was given, return it. */
    if( global_trans != PROMPT )
        return( global_trans );

    /* Otherwise, check to see if we've already got a translated value
     * for this character. If so, return that value.
     */
    if( mapping[c] != 0 )
        return( mapping[c] );

    /* Prompt for a translation value. We can't accept 0 or numbers
     * larger than 255, so loop until we get a valid translation
     * character. The for loop without any parameters will loop until
     * a break statement is encountered. The scanf %i specifier is given
     * so that the user can enter the ASCII code in decimal (ddd),
     * octal (0ddd), or hexadecimal (0xddd).
     *
     * A different input mechanism could be implemented here.
     * For example, you could use getche() to allow the user to
     * type in the replacement character directly rather than
     * entering an ASCII code.
     */
    printf( "Control character %u in line %u:  ", c, line );
    for( ;; )
    {
        printf( "Enter ASCII translation code: " );
        scanf( "%i", &new_val );
        if( (new_val == 0) || (new_val > 255) )
        {
            printf( "Invalid translation value\n" );
            fflush( stdin );
        }
        else
            break;
    }

    /* Remember the translated value in mapping[c]. */
    mapping[c] = new_val;
    return( new_val );
}
