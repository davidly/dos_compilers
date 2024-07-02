/* Copyright (C) 1983, 1984 by Manx Software Systems */

#define EXEMAGIC	0x5a4d

struct exehead {		/* MS-dos .exe file header */
	int e_magic;
	int e_used;			/* number of bytes used in final sector of file */
	int e_pages;		/* size of file in 512-byte pages */
	int e_nreloc;		/* number relocation table items */
	int e_hsize;		/* size of header in 16-byte paragraphs */
	int e_min;			/* minimum # of para required above program */
	int e_max;			/* maximum # of para    "       "      " */
	unsigned e_ss;		/* offset of stack segment in load module */
	unsigned e_sp;		/* initial SP value */
	unsigned e_csum;	/* negative sum of all words in the file */
	unsigned e_ip;		/* starting IP for program */
	unsigned e_cs;		/*    "     CS    " */
	int e_freloc;		/* offset of first relocation item */
	int e_ovly;			/* overlay number */
};

execv(path, argv)
char *path, **argv;
{
	register char *cp, *xp;
	int i, fd;
	char buffer[130];
	char fcb1[16], fcb2[16];
	struct exehead header;

	if ((fd = _open(path,0)) == -1)
		return -1;
	if (_read(fd, &header, sizeof header) != sizeof header)
		header.e_magic = 0;

	cp = buffer+1;
	i = 1;
	if (*argv) {
		++argv;			/* skip arg0, used for unix (tm) compatibility */
		while (xp = *argv++) {
			if (i == 1)
				fcbinit(xp, fcb1);
			else if (i == 2)
				fcbinit(xp, fcb2);
			*cp++ = ' ';
			while (*xp) {
				if (cp >= buffer+128)
					goto done;
				*cp++ = *xp++;
			}
			++i;
		}
	}
done:
	buffer[0] = cp - (buffer+1);
	return exec(fd, buffer, fcb1, fcb2, &header);
}

