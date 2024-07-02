/* Copyright (C) 1983, 1984 by Manx Software Systems */

execvp(name, argv)
char *name, **argv;
{
	register char *cp, *xp;
	char *getenv(), path[64];

	tryexec("", name, argv);
	if ((cp = getenv("PATH")) != 0) {
		while (*cp) {
			xp = path;
			while (*cp) {
				if (*cp == ';') {
					++cp;
					break;
				}
				*xp++ = *cp++;
			}
			*xp = 0;
			if (path[0] != 0)
				tryexec(path, name, argv);
		}
	}
	return -1;
}

static
tryexec(dir, name, argv)
char *dir, *name, **argv;
{
	char newname[64];
	register char *cp;
	char *strchr(), *strrchr();
	int len = strlen(dir);

	strcpy(newname, dir);
#if 1 /* 10/4/92 jd: to decide whether to append '/', check last char */
	if (len) {	/* if null dir, don't append '/' */
		switch(newname[len-1]){
		case ':': /* dir is just drive name */
		case '/': /* dir ends in / or \ */
		case '\\':
			break;
		default:	/* dir ends in . or letters */
			strcat(newname, "/");
			break;
		}
	}
#else
	if (((cp = strchr(newname, '/')) || (cp = strchr(newname, '\\')))
				&& *(cp+1) != 0)
		strcat(newname, "/");
#endif
	strcat(newname, name);
	if (strchr(name, '.') == 0) {
		strcat(newname, ".com");
		execv(newname, argv);
		strcpy(strrchr(newname,'.'), ".exe");
	}
	execv(newname, argv);
}
