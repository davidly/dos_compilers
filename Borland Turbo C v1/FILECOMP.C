/* FILECOMP.C

   file compare program, similar to unix diff 

   Copyright (c) Borland International 1987
   All Rights Reserved.
*/

/**********************************************************************

The FILECOMP program implements Paul Heckel's algorithm from the
Communications of the Association for Computing Machinery,
April 1978 for detecting the differences between two files.	 This
algorithm has the advantage over more commonly used compare
algorithms that it is fast and can detect differences of an
arbitrary number of lines.  It has the defect that it reads both
files twice if there are differences.

It uses getopt to parse command line options.

Compile with Turbo C,

  tcc -O -Z filecomp getopt

You may also use the -p (pascal) option.

The command format is: FILECOMP [options] filespec1 filespec2

Options:
	/f		show full lines.
	/t		expand tabs before comparing.
	/b		ignore trailing blanks.
	/w		ignore spaces and tabs.
	/y		case insensitive compare.

Defaults are:
	Brief	show first 34 characters of lines.
	No tabs	don't expand tabs.
	No trim	don't ignore trailing blanks.
	White	compare spaces and tabs.
	Case		case sensitive compare.

Arbitrary path qualification is allowed in the filespecs. In addition,
the output can be redirected to the printer or a file with normal DOS
redirection conventions (e. g. >PRN).

By default (Brief), output is displayed with the two files side-by-side.
This is felt to make it easier to spot the location of differences, even
though only 34 characters of each record can be shown. The Full option
causes the whole record to be shown. Along with each record displayed is
its line number in the file it came from.

If either file contains tabs, they will not be expanded before
comparison unless the Tabs option is used. If Tabs is not used, any tabs
in displayed records will probably make the output appear strange, since
they will be expanded by DOS.

A design limitation of the program is that only the first 256
characters of each record are compared.

**********************************************************************/


#include <stdio.h>
#include <ctype.h>		/* for toupper */
#include <string.h>		/* for strcpy, strupr */

#define MAXLINES 5000
#define FULL	0x80
#define TABS	0x40
#define TRIM	0x20
#define WHITE	0x10
#define CASE	0x08
#define BLANK	0x04

#define TRUE	1
#define FALSE	0

long hash1[MAXLINES], hash2[MAXLINES];
unsigned char occ1[8192], occ2[8192];
int n1, n2;
FILE *file1, *file2;
char name[80], *s;
int different = 0;

unsigned char flag1 = WHITE;

void givehelp(void)
{
	printf("Usage is: FILECOMP [options] filespec1 filespec2\n");
	printf("Options:\n");
	printf("  /f\tshow full lines.\n");
	printf("  /t\texpand tabs before comparing.\n");
	printf("  /b\tignore trailing blanks.\n");
	printf("  /w\tignore spaces and tabs.\n");
	printf("  /y\tcase insensitive compare.\n");
	printf("filespec2 can be a drive or directory name.\n");
}

/* expand tabs */
void tabex(unsigned char *s1, unsigned char *s2)
{
	int i;
	unsigned char j;
	for (i=j=0; s1[i]; i++) {
		if (s1[i] != '\t') {
			s2[j++] = s1[i];
			continue;
		}
		do s2[j++] = ' '; while(j%8 != 0);
	}
	s2[j] = 0;
}

/* zap white space */
void zapwhite(unsigned char *s1, unsigned char *s2)
{
	int i, j;
	for (i=j=0; s1[i]; i++) {
		if (s1[i] != ' ' && s1[i] != '\t')
			s2[j++] = s1[i];
	}
	s2[j] = 0;
}

/* extract bits from the occurrence vector */
unsigned char getbits(unsigned char *array, unsigned long indx)
{
	unsigned i, j;
	indx &= 32767;
	i = indx>>2;
	j = indx - (i<<2);
	return ((array[i]>>((3-j)<<1)) & 0x03);
}

/* store bits in the occurrence array */
void setbits(unsigned char *array, unsigned long indx, unsigned char x)
{
	unsigned i, j, shift;

	indx &= 32767;
	i = indx>>2;
	j = indx - (i<<2);
	shift = (3-j)<<1;
	array[i] &= ~(0x03<<shift);
	array[i] |= x<<shift;
}

/* read in file, build hash & occurrence tables */
int input(FILE *file, long hashvect[], unsigned char occ[])
{
	int i, j;
	long h;
	unsigned char bits, buffer[256], temp[256];
	long hash();

	for (i=0; i<MAXLINES; i++) {
		if (flag1&WHITE) {
			if (fgets(temp,256,file)==0) return i;
			zapwhite(temp,buffer);
		} else if ((flag1&TABS)==0) {
			if (fgets(buffer,256,file)==0) return i;
		} else {
			if (fgets(temp,256,file)==0) return i;
			tabex(temp,buffer);
		}
		if (flag1&CASE) strupr(buffer);
		if (flag1&TRIM) {
			for (j=0; j<256 && j>=0 && buffer[j] && buffer[j]!='\n'; j++);
			for (j=j-1; j>=0 && buffer[j]==' ' ; j--);
			buffer[j+1] = 0;
		}
		h = hash(buffer);
		if (h<0) 
			hashvect[i] = h; 
		else 
			hashvect[i] = -h;
		bits = getbits(occ,-hashvect[i]);
		if (bits==0) 
			setbits(occ,-hashvect[i],1);
		else if (bits==1) 
			setbits(occ,-hashvect[i],2);
	}
	printf("File truncated at %d lines.\n",MAXLINES);
	return i-1;
}

/* hash a character string */
long hash(unsigned char *s)
{
	long h=0, h1;
	while (*s) {
		h1 = h;
		h = h<<1;
		if (h1<0) h |= 1;
		h ^= *s++;
	}
	if (h==0) h = 1;
	return h;
}

/* display the results of comparison */
void output(int l1,int l2)
{
	static int cl1 = 0, cl2 = 0;
	char line[81];
	unsigned int bi1=0, bi2=0;
	unsigned char end1=1, end2=1;
	int i;
	char buffer1[256], buffer2[256], temp[256];

	different = 1;

	for (i=0; i<80; i++) line[i] = ' ';
	line[80] = 0;
	if (l1>=0) {
		for (i=cl1; i<=l1; i++)
			if((flag1&TABS)==0) fgets(buffer1,256,file1);
			else {
				fgets(temp,256,file1);
				tabex(temp,buffer1);
			}
		cl1 = l1 + 1;
		sprintf(line,"%4d ",l1+1);
		line[5] = ' ';
		for (i=0; buffer1[i+bi1] && buffer1[i+bi1]!='\n' && i<34; i++)
			line[i+5] = buffer1[i+bi1];
		if (i==34) {
			bi1 += 34;
			end1 = 0;
		}
	}
	if (l2>=0) {
		for (i=cl2; i<=l2; i++)
			if((flag1&TABS)==0) fgets(buffer2,256,file2);
			else {
				fgets(temp,256,file2);
				tabex(temp,buffer2);
			}
		cl2 = l2 + 1;
		sprintf(line+40,"%4d ",l2+1);
		line[45] = ' ';
		for (i=0; buffer2[i+bi2] && buffer2[i+bi2]!='\n' && i<34; i++)
			line[i+45] = buffer2[i+bi2];
		if (i==34) {
			bi2 += 34;
			end2 = 0;
		}
	}
	line[45+i] = '\n';
	line[46+i] = 0;
	fwrite(line,1,46+i,stdout);
	if (flag1 & FULL) while (!end1 || !end2) {
		for (i=0; i<80; i++) line[i] = ' ';
		if (!end1) {
			for (i=0; buffer1[i+bi1] && buffer1[i+bi1]!='\n' && i<34; i++)
				line[i+5] = buffer1[i+bi1];
			if (i==34) bi1 += 34; else end1 = 1;
		}
		if (!end2) {
			for (i=0; buffer2[i+bi2] && buffer2[i+bi2]!='\n' && i<34; i++)
				line[i+45] = buffer2[i+bi2];
			if (i==34) bi2 += 34; else end2 = 1;
		}
		line[45+i] = '\n';
		line[46+i] = 0;
		fwrite(line,1,46+i,stdout);
	}
}

/* match strings with specified minimum */
int match(unsigned char *s1, unsigned char *s2, unsigned char min)
{
	unsigned int i;
	for (i=0; *s1 && *s2; i++) 
		if (toupper(*s1++) != *s2++) return 0;
	if (*s1==0) return i>=min;
	return 0;
}

/* main program */
int cdecl main(int argc, char *argv[])
{
	int i,j,k,opt,ifile;
	unsigned char linked;

	extern int getopt(int argc, char *argv[], char *optionS);
	extern int opterr, optind;

	if (argc<3) {
		givehelp();
		return 0;
	}

	/* get options */

	opterr = FALSE;		/* handle errors ourself */
	while ((opt = getopt(argc, argv, "ftbwy")) != EOF) {
		switch (opt) {
			case '?':
				printf("Invalid command line option\n");
				givehelp();
				return(1);
			case 'f':
				flag1 |= FULL; break;
			case 't':
				flag1 |= TABS; break;
			case 'b':
				flag1 |= TRIM; break;
			case 'w':
				flag1 &= ~WHITE; break;
			case 'y':
				flag1 |= CASE; break;
		}
	}

	ifile = optind;		/* index of first file parm */

	/* step 1: read first file and hash it */
	file1 = fopen(argv[ifile],"r");
	if (file1==0) {
		printf("Unable to open file '%s'\n",argv[ifile]);
		return 2;
	}

	printf("Reading file '%s'.\n",argv[ifile]);
	n1 = input(file1,hash1,occ1);
	fseek(file1,0L,0);

	/* get the file name, with dir name stripped off */
	for (i=j=0; (k=argv[ifile][i]) != 0; ++i)
		if (k == ':' || k == '\\' || k == '/') j = i + 1;
	s = argv[1] + j;

	/* if argv[ifile+1] ends in : or \, tack on 1st file name */
	for (i=j=0; (k=argv[ifile+1][i]) != 0; ++i)
		if (k == ':' || k == '\\' || k == '/') j = i + 1;
	strcpy(name,argv[ifile+1]);
	if (j == i) strcpy(name+j,s);

	/* step 2: read second file and hash it */
	file2 = fopen(name,"r");
	if (file2==0) {
		/* maybe argv[ifile] was a directory, so try again */
		if (j != i) {
			name[i] = '\\';
			strcpy(name+i+1,s);
			file2 = fopen(name,"r");
		}
	}

	if (file2==0) {
		printf("Unable to open file '%s'.\n",name);
		return 2;
	}

	printf("Reading file '%s'.\n",name);
	n2 = input(file2,hash2,occ2);
	fseek(file2,0L,0);

	/* step 3: identify lines that are unique in both files */
	for (i=0; i<8192; i++) occ1[i] &= occ2[i];

	/* step 4: link together matching unique lines */
	for (i=0; i<n1; i++) {
		if (getbits(occ1,-hash1[i])!=1) continue;
		for (j=0; i+j<n2 || i-j>=0; j++) {
			if (i+j<n2) if (hash2[i+j]==hash1[i]) {
				hash1[i] = i+j;
				hash2[i+j] = i;
				break;
			}
			if (i-j>=0) if (hash2[i-j]==hash1[i]) {
				hash1[i] = i-j;
				hash2[i-j] = i;
				break;
			}
		}
	}

	/* step 5: link the first and last lines, if possible */
	if (hash1[0]<0 && hash1[0]==hash2[0]) hash1[0] = hash2[0] = 0;
	if (hash1[n1-1]<0 && hash1[n1-1]==hash2[n2-1]) {
		hash1[n1-1] = n2-1;
		hash2[n2-1] = n1-1;
	}

	/* step 6: starting from linked lines, link following lines that match */
	linked = 0;
	for (i=0; i<n1; i++) {
		if (hash1[i]>=0) linked = 1;
		else if (linked==1) {
			if (hash1[i]==hash2[hash1[i-1]+1]) {
				hash1[i] = hash1[i-1]+1;
				hash2[hash1[i]] = i;
			}
			else linked = 0;
		}
	}

	/* step 7: link matching lines that precede linked lines */
	linked = 0;
	for (i=n1-1; i>=0; i--) {
		if (hash1[i]>=0) linked = 1;
		else if (linked==1) {
			if (hash1[i]==hash2[hash1[i+1]-1]) {
				hash1[i] = hash1[i+1] - 1;
				hash2[hash1[i]] = i;
			} else linked = 0;
		}
	}

	/* step 8: display the results */
	for (i=j=0; i<n1 && j<n2;) {
		if (hash1[i]<j && hash2[j]<i) {
			output(i++,j++);
			continue;
		}
		if (hash1[i]<j) {
			output(i++,-1);
			continue;
		}
		if (hash2[j]<i) {
			output(-1,j++);
			continue;
		}
		if (hash1[i]==j) {
			for (k=1; i+k<=n1 && j+k<=n2 && hash1[i+k]==j+k; k++);
			printf("\n*** %d line(s) match. ***\n\n",k);
			i += k;
			j += k;
			continue;
		}
		if (hash1[i]-j <= hash2[j]-i) {
			for (k=j; k<hash1[i]; k++) output(-1,k);
			j = hash1[i];
			continue;
		} else {
			for (k=i; k<hash2[j]; k++) output(k,-1);
			i = hash2[j];
			continue;
		}
	}
	if (i<n1) for (k=i; k<n1; k++) output(k,-1);
	if (j<n2) for (k=j; k<n2; k++) output(-1,k);
	fclose(file1);
	fclose(file2);
	return different;
}
/* end of program */
