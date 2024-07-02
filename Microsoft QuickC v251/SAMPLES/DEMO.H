/* Constants */
#define CR 13				/* ASCII code for Return  */
#define ESCAPE 27			/* ASCII code for Esc key */
#define MDA 0				/* Adapter constants	  */
#define CGA 1
#define MCGA 2
#define EGA 3
#define VGA 4
#define MONO 0				/* Display constants	  */
#define COLOR 1
#define clear_scrn( attr, row1, row2 ) ClearBox( attr, row1, 0, row2, 79 )

/* Structure members at 1-byte boundaries */
#pragma pack( 1 )

/* Video configuration structure */
struct vid_config
{
    unsigned char vmode;	/* Current mode 		  */
    unsigned char dpage;	/* Current display page 	  */
    unsigned char rows; 	/* Number of display rows - 1	  */
    unsigned char display;	/* Either MONO or COLOR 	  */
    unsigned char adapter;	/* Adapter code 		  */
    unsigned char CGAvalue;	/* Enable value for CGA 	  */
    unsigned sgmnt;		/* Video segment with page offset */
};
struct vid_config vconfig;	/* Structure for video configuration */

/* Disk statistics returned from GetDiskSize procedure */
struct disk_stat
{
    unsigned total;		/* total clusters      */
    unsigned avail;		/* available clusters  */
    unsigned sects;		/* sectors per cluster */
    unsigned bytes;		/* bytes per sector    */
};

/* File information returned from FindFirst procedure  */
struct file_info
{
    char pad[21];		/* pad to 43 bytes     */
    char attrib;		/* file attribute      */
    int time;			/* file time	       */
    int date;			/* file date	       */
    long size;			/* file size	       */
    char name[13];		/* file name	       */
};

/* Procedure prototypes from COMMON.ASM */
void  GetVidConfig( void );
void  StrWrite( int row, int col, char *str );
void  ClearBox( int attr, int row1, int col1, int row2, int col2 );
int   GetVer( void );
int   SetCurPos( int row, int col );

/* Procedure prototypes from MATH.ASM */
long  AddLong(	long long1, long long2 );
long  SubLong(	long long1, long long2 );
long  ImulLong( long long1, long long2 );
long *MulLong(  long long1, long long2 );
int   DivLong(	long long1, short short2, short *remn );
int   IdivLong( long long1, short short2, short *remn );
int   Quadratic( float a, float b, float c, float *r1, float *r2 );

/* Procedure prototypes from FILE.ASM */
void  ChangeDrive( int drive );
void  GetDiskSize( int drive, struct disk_stat *disk );
void  GetVidConfig( void );
int   ReadCharAttr( int *attr );
int   GetCurDir( char *spec );
int   GetCurDisk( void );
int   CopyFile( int imode, char *fspec1, char *fspec2 );
int   DelFile( char *fspec );
int   MakeDir( char *pspec );
int   RemoveDir( char *pspec );
int   ChangeDir( char *pspec );
int   GetAttribute( char *fspec );
int   SetAttribute( int attr, char *fspec );
int   RenameFile( char *fspec1, char *fspec2 );
int   GetFileTime( int handle, char *str );
int   FindFirst( int attr, char *fspec, struct file_info *finfo );
int   FindNext( struct file_info *finfo );
int   UniqueFile( int attr, char *fspec );
int   OpenFile( int access, char *fspec );
int   CloseFile( int handle );
int   ReadFile( int handle, int len, char *pbuff );
int   SetCurPos( int row, int col );
int   GetStr( char *bufstr, int maxlen );
char *StrCompare( char *str1, char *str2, int len );
char *StrFindChar( char ichar, char *str, int direct );
