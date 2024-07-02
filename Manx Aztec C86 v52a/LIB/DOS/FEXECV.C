/* Copyright (C) 1983, 1984 by Manx Software Systems */

fexecv(path, argv)
char *path, **argv;
{
	register char *cp, *xp;
	int i;
	char buffer[130];
	char fcb1[16], fcb2[16];

	cp = buffer+1;
	i = 1;
	fcbinit(".", fcb1);		/* initialize fcb's, in case no args */
	fcbinit(".", fcb2);
	if (*argv) {
		++argv;			/* skip arg0, used for unix (tm) compatibility */
		while (xp = *argv++) {
			if (i == 1)
				fcbinit(xp, fcb1);
			else if (i == 2)
				fcbinit(xp, fcb2);
			*cp++ = ' ';
			while (*xp) {
				if (cp >= buffer+127)
					goto done;
				*cp++ = *xp++;
			}
			++i;
		}
	}
done:
	buffer[0] = cp - (buffer+1);
	*cp = '\r';		/* add CR to make some dos commands happy */
	return fexec(path, 0, buffer, fcb1, fcb2);
}

