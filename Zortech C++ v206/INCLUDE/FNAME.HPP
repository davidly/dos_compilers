#ifndef FILENAMEHPP
#define FILENAMEHPP
#include <string.h>
#include "errn.hpp"

enum {
    FN_OK,
    FN_BADDRIVE,
    FN_BADCOLON,
    FN_PTOOLONG,
    FN_DTOOLONG,
    FN_NTOOLONG,
    FN_XTOOLONG,
    FN_BADCHAR,
    FN_NULL,
    FN_NOMEM
};

class filename {
    char *fn;
    const char *forbid;
public:
    char drive;
    char name[9];
    char ext[4];
    char *path;
    filename() {
        memset(&drive,'\0',14);
        forbid = " *+=[]:;\",.?/";
        fn = path = NULL;
    }
    filename(char *, const char * = " *+=[]:;\",.?/");
    filename(filename&);
    ~filename() { delete path; delete fn; }
    int build(char, char *,char *,char *, int);
    int parse(char *);
    char *operator()(void);
    filename& operator=(filename&);
};
#endif
