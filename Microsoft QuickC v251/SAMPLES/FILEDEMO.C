/* FILEDEMO.C - Performs various file operations using DOS functions which
 * are invoked from QuickAssembler procedures. FILEDEMO demonstrates how
 * to interface C and QuickAssembler procedures, which in turn demonstrate
 * various assembly-language instructions, DOS calls, and BIOS interrupts.
 *
 * FILEDEMO.EXE is built from the following files:
 *    FILEDEMO.C - Main program
 *    FILE.ASM	 - QuickAssembler procedures for FILEDEMO
 *    COMMON.ASM - QuickAssembler procedures shared by other example programs
 *    DEMO.INC	 - Assembly include file with macros and structure declarations
 *    DEMO.H	 - C include file with prototypes and structure declarations
 *
 * Procedures:	ClearBox	     ChangeDrive	  GetDiskSize
 *		GetVidConfig	     GetVer		  GetCurDir
 *		GetCurDisk	     CopyFile		  DelFile
 *		MakeDir 	     RemoveDir		  ChangeDir
 *		GetAttribute	     SetAttribute	  RenameFile
 *		GetFileTime	     FindFirst		  FindNext
 *		UniqueFile	     OpenFile		  CloseFile
 *		ReadFile	     SetCurPos		  StrCompare
 *		StrFindChar	     ReadCharAttr
 */

#include "demo.h"
#include <string.h>
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>

/* Function prototypes */
char *get_spec( int n );
int list_dir( char *spec, int disp_attr );
void press( void );

/* Constants */
#define MAXSEARCH 80
#define MAXSPEC   64
#define BUFFSIZE  40 * 1024

/* Global variable */
struct file_info file;		  /* Structure for FindFirst info */

main()
{
    static char source[64];	  /* Buffer for source file/path	*/
    static char text[MAXSEARCH];  /* Pointer to buffer for search text	*/
    static char date_time[19];	  /* Receive file date and time 	*/
    int err, mode, handle, len;   /* Codes, file handle, bytes read	*/
    int row, col, ch;		  /* Cursor coordinates, kb character	*/
    int i, j, attr;		  /* Index variables, file attribute	*/
    int disp_attr;		  /* Display attribute			*/
    char *spec, *ptr, *buffer;	  /* File spec, char match, read buffer */
    long dsize, disk_use;	  /* Disk size and usage		*/
    struct disk_stat disk;	  /* Structure for disk size params	*/

    static char copy_msg[] =
    {
	"Files can be copied or moved in 2 different modes:\n" \
	"      0  -  overwrite target file if it exists\n" \
	"      1  -  abort if target file exists\n\n" \
	"Mode 1 is supported only with DOS versions 3.0 or higher.\n"
    };
    static char move_msg[] =
    {
	"Quick Move uses DOS function 56h (Rename File) to effectively " \
	"move a file from\none directory to another directory on the " \
	"same drive.  It copies the entry\nfrom the source directory to " \
	"the target directory, but does not physically\ncopy the file.\n\n" \
	"Source and target specifications must be given in full, " \
	"including filenames,\neven if the names are the same."
    };
    static char grep_msg[] =
    {
	"The Find Text option uses the StrFindChar and StrCompare procedures " \
	"to locate\na text string within specified files, like Unix's " \
	"\"grep\" command.  Find Text\nis limited to case-sensitive searches " \
	"within the current directory.\n\nEnter the desired search string " \
	"without quotation marks.  When specifying the\nfilename, use " \
	"wildcard characters to expand the search to a group of files --\n" \
	"for example, \"*.*\" searches all files within the current " \
	"directory, \"*.bat\"\nlimits the search to batch files, and so forth."
    };
    static char attr_msg[] =
    {
	"\t\t\t1    normal      \n" \
	"\t\t\t2    read-only   \n" \
	"\t\t\t3    hidden      \n" \
	"\t\t\t4    system      \n" \
	"\t\t\t     volume      \n" \
	"\t\t\t     subdirectory\n" \
	"\t\t\t5    archive     \n"
    };

    GetVidConfig();
    ReadCharAttr( &disp_attr );
    clear_scrn( disp_attr, 0, 24 );
    SetCurPos( 8, 0 );
    puts( "Welcome to QuickAssembler's FILEDEMO program.\n\n\nThis program " \
	  "is meant to encourage experimentation while demonstrating how " \
	  "to\naccess DOS from QuickAssembler procedures.  As a safety " \
	  "precaution, however,\nwe suggest you DO NOT experiment with " \
	  "files that cannot easily be replaced." );
    press();

    do
    {
	/* Display current drive and directory */
	clear_scrn( disp_attr, 0, 24 );
	SetCurPos( 0, 0 );
	printf( "Current Directory:  %c:\\", (char) (GetCurDisk() + 'A') );
	GetCurDir( source );
	puts( source );

	/* Display DOS version */
	SetCurPos( 1, 0 );
	printf( "DOS Version:        %2.1f", ( (float) GetVer() ) / 100 );

	/* Display disk statistics for current drive */
	SetCurPos( 0, 58 );
	GetDiskSize( 0, &disk );
	dsize = (long)disk.bytes * disk.sects * disk.total;
	disk_use = (long)(disk.total - disk.avail) * disk.bytes * disk.sects;
	printf( "Disk Size: %6lu K", dsize / 1024 );
	SetCurPos( 1, 58 );
	printf( "Disk Use:  %6lu K", disk_use / 1024 );

	/* Display menu and poll for key press */
	clear_scrn( disp_attr, 2, 23 );
	SetCurPos( 5, 0 );
	puts( " \t    ***      QuickAssembler File " \
	      "Demonstration Program      ***" );
	SetCurPos( 7, 0 );
	puts( " \tA  List Directory       \t\tH  Get/Set File Attribute" );
	puts( " \tB  Copy File            \t\tI  Get File Date and Time" );
	puts( " \tC  Move File            \t\tJ  Rename File" );
	puts( " \tD  Make Subdirectory    \t\tK  Delete File" );
	puts( " \tE  Remove Subdirectory  \t\tL  Create Unique File" );
	puts( " \tF  Change Default Drive \t\tM  Quick Move" );
	puts( " \tG  Change Directory     \t\tN  Find Text" );
	printf( "\n\n\tSelect an option, or press ESC to quit: " );
	ch = getch();
	switch( (ch = toupper( ch )) )
	{
	    /* List first 60 files in specified directory */
	    case 'A':
		err  = list_dir( get_spec( 1 ), disp_attr );
		if( !err )
		    press();
		break;

	    /* Copy or Move File according to requested mode:
	     *		0 = overwrite target
	     *		1 = abort if target exists
	     * If Move requested, delete source file after copy.
	     */
	    case 'B':
	    case 'C':
		clear_scrn( disp_attr, 2, 17 );
		SetCurPos( 9, 0 );
		puts( copy_msg );
		mode = -1;
		while( (mode < 0)  ||  (mode > 1) )
		{
		    SetCurPos( 16, 0 );
		    printf( "Enter copy mode:  " );
		    mode = (int) (getche() - '0');
		}
		spec = get_spec( 2 );			/* Get source	  */
		strcpy( source, spec ); 		/* Save in buffer */
		spec = get_spec( 3 );			/* Get target	  */
		err  = CopyFile( mode, source, spec );
		if( (ch == 'C')  &&  !err )
		    err = DelFile( source );
		break;

	    /* Make Directory */
	    case 'D':
		err = MakeDir( get_spec( 1 ) );
		break;

	    /* Remove Directory */
	    case 'E':
		err = RemoveDir( get_spec( 1 ) );
		break;

	    /* Change Default Drive */
	    case 'F':
		SetCurPos( 18, 0 );
		printf( "Enter new drive letter:  " );
		ch = getch();
		ch = toupper( ch );
		ChangeDrive( ch );
		err = 0;
		break;

	    /* Change Directory */
	    case 'G':
		err = ChangeDir( get_spec( 1 ) );
		break;

	    /* Get and Set File Attributes */
	    case 'H':
		strcpy( source, get_spec( 3 ) );
		if( (err = GetAttribute( source )) != -1 )
		{
		    attr = err;
		    if( !attr )
			attr_msg[6] = '*';
		    else
			attr_msg[6] = ' ';
		    for( j = 1, i = 27; j <= 32; j <<= 1, i+= 21 )
		    {
			attr_msg[i] = ' ';
			if( attr & j )
			    attr_msg[i] = '*';
		    }
		    err = 0;
		    clear_scrn( disp_attr, 2, 17 );
		    SetCurPos( 7, 0 );
		    puts( attr_msg );
		    printf( "\n\nToggle attribute bits by selecting 1-5, " \
			    "or any other key to exit:  " );
		    mode = (int)( getch() - '0' );
		    if( (mode > 0)  &&	(mode < 6) )
		    {
			switch( --mode )
			{
			    case 0:
				attr = 0;
				break;

			    case 1:
			    case 2:
			    case 3:
				attr = attr ^ (1 << (--mode) );
				break;

			    case 4:
				attr = attr ^ 32;
			}
			err = SetAttribute( attr, source );
		    }
		}
		break;

	    /* Get File Date and Time */
	    case 'I':
		if( (handle = OpenFile( 0, get_spec( 3 ) )) == -1 )
		    err = 1;
		else
		    err = 0;
		if( !err )
		{
		    if( !(err = GetFileTime( handle, date_time )) )
		    {
			clear_scrn( disp_attr, 2, 17 );
			SetCurPos( 12, 10 );
			printf( "File's date and time stamp:  %s", date_time );
			CloseFile( handle );
			press();
		    }
		}
		break;

	    /* Rename File */
	    case 'J':
		strcpy( source, get_spec( 2 ) );
		err = RenameFile( source, get_spec( 3 ) );
		break;

	    /* Delete File */
	    case 'K':
		err = DelFile( get_spec( 3 ) );
		break;

	    /* Create File with Unique Name */
	    case 'L':
		strcpy( source, get_spec( 1 ) );
		handle = UniqueFile( 0, source );   /* Normal file attr = 0 */
		if( handle >= 0 )
		{
		    printf( "\n\nDOS creates file %s", source );
		    press();
		    err = 0;
		}
		else err = 1;
		break;

	    /* Quick Move from one directory to another */
	    case 'M':
		clear_scrn( disp_attr, 2, 17 );
		SetCurPos( 8, 0 );
		puts( move_msg );
		strcpy( source, get_spec( 2 ) );
		err = RenameFile( source, get_spec( 3 ) );
		break;

	    /* Search files for specified text */
	    case 'N':
		clear_scrn( disp_attr, 2, 17 );
		buffer = (char *) malloc( BUFFSIZE + 1 );
		if( buffer == NULL )
		{
		    SetCurPos( 12, 26 );
		    puts( "Insufficient memory for option" );
		    err = 1;
		    break;
		}
		SetCurPos( 7, 0 );
		puts( grep_msg );
		SetCurPos( 18, 0 );
		printf( "Enter search text:  " );
		GetStr( text, MAXSEARCH );

		/* Find first data file. */
		if( err = FindFirst( 0, get_spec( 3 ), &file ) )
		{
		    clear_scrn( disp_attr, 2, 17 );
		    SetCurPos( 12, 24 );
		    puts( "No files found matching specification" );
		}

		/* If file found, initialize screen coordinates and
		 * open file for reading.
		 */
		else
		{
		    clear_scrn( disp_attr, 2, 17 );
		    row = 6;
		    col = 0;
		    do
		    {
			if( (handle = OpenFile( 0, file.name )) != -1 )
			{

			    /* If file opened successfully, read a block
			     * of BUFFSIZE bytes. If end-of-file encountered
			     * (number of bytes read not equal to BUFFSIZE)
			     * or read error, set error flag to break loop.
			     * Terminate block with a NULL to make it an
			     * ASCIIZ string.
			     */
			    err = 0;
			    while( !err )
			    {
				len = ReadFile( handle, BUFFSIZE, buffer );
				if( (len == 0)  ||  (len != BUFFSIZE) )
				    ++err;
				ptr = buffer;
				*( ptr + len ) = 0;

				/* Search block for first character in text */
				while( spec = StrFindChar( text[0], ptr, 0 ) )
				{

				    /* If initial character found, compare
				     * remaining characters in search text.
				     * If all characters match, display file
				     * name and break out of loop.
				     */
				    ptr = StrCompare( ++spec, &text[1],
					  (strlen( text ) - 1) );
				    if( !ptr )
				    {
					SetCurPos( row++, col );
					puts( file.name );
					if( row == 16)
					{
					    row  = 6;
					    col += 20;
					}
					err  = 1;
					break;
				    }
				}
			    }
			    CloseFile( handle );
			}
			else
			{
			    err = 1;
			    break;
			}
		    } while( !FindNext( &file ) );

		    if( (row == 6)  &&  (col == 0) )
		    {
			SetCurPos( 12, 22 );
			puts( "Text not found in specified file(s)" );
		    }
		    press();
		    err = 0;
		}
		free( buffer ); 	    /* Free allocated block */
		break;

	    default:
		continue;
	}

	if( err )
	{
	    clear_scrn( disp_attr, 24, 24 );
	    SetCurPos( 24, 0 );
	    printf( "***  Error  ***\a" );
	    press();
	}

    } while( ch != ESCAPE );		/* Exit if ESC key pressed    */

    clear_scrn( disp_attr, 0, 24 );	/* Clear screen before exit   */
    SetCurPos( 23, 0 ); 		/*   and set cursor to bottom */
    return( 0 );
}


/* get_spec - Prompts for file or path specifications.
 *
 * Params:  n - Prompt number
 *
 * Return:  Pointer to specification
 */

char *get_spec( int n )
{
    static char spec[MAXSPEC];

    switch( n )
    {
	case 1:
	    SetCurPos( 18, 0 );
	    printf( "Enter path:  " );
	    break;
	case 2:
	    SetCurPos( 18, 0 );
	    printf( "Enter source file:  " );
	    break;
	case 3:
	    SetCurPos( 20, 0 );
	    printf( "Enter target file:  " );
	    break;
    }
    GetStr( spec, MAXSPEC );
    return spec;
}


/* list_dir - Lists specified directory by invoking DOS function 4Eh (Find
 * First Matching Entry), then DOS function 4Fh (Find Next Matching Entry).
 *
 * Params:  spec - Pointer to path specification
 * 
 * Return:  err  - Error code returned from FindFirst procedure:
 *		   0 = successful	  1 = error
 */

int list_dir( char *spec, int disp_attr )
{
    int row, col;
    int err, end;

    clear_scrn( disp_attr, 2, 23 );
    strcat( spec, "\\*.*" );
    err = FindFirst( 16, spec, &file ); /* Find directories, normal files */
    if( !err )
    {
	for( end = 0, col = 0; (col < 80)  &&  (end == 0); col += 22 )
	{
	    for( row = 5; (row < 20)  &&  (end == 0); row++ )
	    {
		SetCurPos( row, col );
		puts( file.name );
		end = FindNext( &file );
	    }
	}
    }
    return err;
}


/* press - Prompt for keyboard signal to continue.
 *
 * Params:  None
 */

void press( void )
{
    SetCurPos( 24, 49 );
    printf( ". . . press a key to continue" );
    SetCurPos( 24, 47 );
    getch();
}
