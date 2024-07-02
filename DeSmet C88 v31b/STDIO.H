/*	STDIO.H		Include file for C88 input/output.	*/

/*	a 'FILE' is simply an integer is this implimentation	*/

#define FILE	int

/*	Standard input, standard output and standard error.	*/

#define stdin	(FILE *)0
#define stdout	(FILE *)1
#define	stderr	(FILE *)2
#define	stdaux	(FILE *)3
#define stdprn	(FILE *)4

#ifdef LARGE_CASE

/*	With LARGE case (-B option), */
/*	Use lower case stdin, stdout etc with fopen(), fread(), getc() etc. */
/*	Use upper case STDIN, STDOUT etc with open(), read() etc.	*/

#define STDIN	0
#define STDOUT	1
#define	STDERR	2
#define	STDAUX	3
#define STDPRN	4

#endif

#define	NULL	(void *)0
#define TRUE	1
#define FALSE	0
#define EOF		(-1)
#define ERR		(-1)

#define	SEEK_SET 0
#define	SEEK_CUR 1
#define	SEEK_END 2

#define	F_ERR	1
#define	F_EOF	2

extern char _flag[];

#define feof(f) (_flag[(int)f] & F_EOF)
#define ferror(f) (_flag[(int)f] & F_ERR)
#define clrerror(f) (_flag[(int)f] & ~(F_ERR | F_EOF))

int closeall(void);
int fclose(FILE *);
int fflush(FILE *);
int fgetc(FILE *);
int fgetchar(void);
char *fgets(char *, int, FILE *);
long filelength(int);
int fileno(FILE *);
FILE *fopen(char *, char *);
int fprintf(FILE *, char *, ... );
int fputc(int, FILE *);
int fputchar(int);
int fputs(char *, FILE *);
int fread(char *, int, int, FILE *);
FILE *freopen(char *, char *, FILE *);
int fscanf(FILE *, char *, ... );
long fseek(FILE *, long, int);
long ftell(FILE *);
int fwrite(char *, int, int, FILE *);
int getc(FILE *);
int getchar(void);
char *gets(char *);
int getw(FILE *);
int printf(char *, ... );
int puts(char *);
int putw(int, FILE *);
int rewind(FILE *);
int scanf(char *, ... );
int sprintf(char *, char *, ... );
int sscanf(char *, char *, ... );
int ungetc(int, FILE *);

