#include <string.h>

_splitpath(name, drive, dir, fname, ext)
char *name, *drive, *dir, *fname, *ext;
{

	char *cp, *cp2, c;
	char path[144];

	strcpy(path, name);
	if (path[1]==':'){
		drive[0] = *path;
		drive[1] = ':';
		drive[2] = 0;
		cp = path+2;
	} else{
		*drive = 0;
		cp = path;
	}
	if ((cp2=strrchr(path, '/')) || (cp2=strrchr(path, '\\'))){
		c = cp2[1];
		cp2[1] = 0;
		strcpy(dir, cp);
		cp2[1] = c;
		cp = cp2+1;
	} else {
		*dir = 0;
	}
	if (cp2=strchr(cp,'.')){
		*cp2 = 0;
		strcpy(fname, cp);
		strcpy(ext, cp2+1);
	} else {
		strcpy(fname, cp);
		*ext=0;
	}
}
