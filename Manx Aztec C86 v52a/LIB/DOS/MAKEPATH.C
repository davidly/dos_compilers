_makepath(name, drive, dir, fname, ext)
char *name, *drive, *dir, *fname, *ext;
{
	int len;

	*name = 0;
	if (drive && drive[0]){
		strcat(name, drive);
		if (name[1] != ':')
			strcat(name, ":");
	}
	if (dir && dir[0]){
		strcat(name, dir);
		len = strlen(name);
		if (name[len-1] != '/' && name[len-1] != '\\')
			strcat(name, "\\");
	}
	strcat(name, fname);
	if (ext && ext[0]){
		if (ext[0] != '.')
			strcat(name, ".");
		strcat(name, ext);
	}
}
