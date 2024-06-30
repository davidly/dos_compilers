/**
*
* The following structure is a UNIX file block that retains information about
* a file being accessed via the level 1 I/O functions.
*/
struct UFB
{
char ufbflg;		/* flags */
char ufbtyp;		/* device type */
#if MSDOS
#if MSDOS2
int ufbfh;		/* file handle */
#else
struct FCB ufbfcb;	/* file control block */
#endif
#else
struct FAB
	{
	struct FCB fcb;		/* file control block */
	char wf;		/* buffer write flag */
	long fpos;		/* file position */
	long eof;		/* end of file */
	long peof;		/* previous end of file */
	int bn;			/* block number */
	char b[128];		/* block buffer */
	}
    ufbfcb;
#endif
};
#define NUFBS 20	/* number of UFBs defined */

/*
*
* UFB.ufbflg definitions
*
*/
#define UFB_OP 0x80	/* file is open */
#define UFB_RA 0x40	/* reading is allowed */
#define UFB_WA 0x20	/* writing is allowed */
#define UFB_NT 0x10	/* access file with no translation */
#define UFB_AP 8	/* append mode flag */	
/*
*
* UFB.ufbtyp definitions
*
*/
#define D_DISK 0
#define D_CON 1
#define D_PRN 2
#define D_AUX 3
#define D_NULL 4

