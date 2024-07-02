void *malloc();

char *
strdup(cp)
char *cp;
{
	char *np;

	np = malloc(strlen(cp)+1);
	strcpy(np, cp);
	return np;
}
