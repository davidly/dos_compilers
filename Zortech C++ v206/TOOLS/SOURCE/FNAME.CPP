#include <ctype.h>
#include <fname.hpp>

typedef void (* PFC)(int,char *);
extern void default_error(int,char *);
PFC fn_handler = default_error;

filename::filename(char * fname, const char *disallow)
{
    memset(&drive,'\0',14);
    forbid = (const char *) disallow;
    fn = path = NULL;
    parse(fname);
}

filename::filename(filename& a)
{
    unsigned i;
    if (a.fn) {
        i = strlen(a.fn)+1;
        fn = new char [i];
        if (!fn) goto allerr;
        memmove(fn,a.fn,i);
    } else fn = 0;
    if (a.path) {
        i = strlen(a.path)+1;
        path = new char [i];
        if (!path) goto allerr;
        memmove(path,a.path,i);
    } else path = 0;
    forbid = a.forbid;
    drive = a.drive;
    strcpy(name,a.name);
    strcpy(ext,a.ext);
    return;
allerr:
    fn_handler(ENOMEM,"filename - not enough memory");
}

filename& filename::operator=(filename& a)
{
    if (this == &a)
        return;

    delete fn;
    delete path;
    fn = path = NULL;
    unsigned i;
    if (a.fn) {
        i = strlen(a.fn)+1;
        fn = new char [i];
        if (!fn)
            goto allerr1;
        else 
            memmove(fn,a.fn,i);
    } else fn = 0;
    if (a.path) {
        i = strlen(a.path)+1;
        path = new char[i];
        if (!path) {
allerr1:
            fn_handler(ENOMEM,"filename - not enough memory");
            return *this;
        } else 
            memmove(path,a.path,i);
    } else path = 0;
    forbid = a.forbid;
    drive = a.drive;
    strcpy(name,a.name);
    strcpy(ext,a.ext);
    return *this;
}

char *filename::operator()()
{
    int length = strlen(name)+strlen(ext)+1;
    if (path)
        length += strlen(path)+1;
    if (drive)
        length += 2;
    if (fn)
        delete fn;
    fn = new char[length+1];
    if (!fn) {
        fn_handler(ENOMEM,"filename - not enough memory");
        return NULL;
    }
    if (drive) {
        *fn = drive;
        *(fn+1) = ':';
        *(fn+2) = '\0';
    } else
        *fn='\0';
    if (path) {
        strcat(fn,path);
        strcat(fn,"\\");
    }
    strcat(fn,name);
    if (*ext) {
        strcat(fn,".");
        strcat(fn,ext);
    }
    return fn;
}

int filename::build(char d, char *p, char *n, char *e, int modify)
{
    if (d) {
        d = toupper(d);
        if (d < 'A' || d > 'P')
            return FN_BADDRIVE;
        drive = d;
    } else if (!modify)
        drive = '\0';
    if (n && *n) {
        if (strlen(n) > 8)
            return FN_NTOOLONG;
        if (strpbrk(n,forbid))
            return FN_BADCHAR;
        strupr(n);
        strcpy(name,n);
    } else if (!modify)
        memset(name,'\0',9);
    if (e && *e) {
        if (strlen(e) > 3)
            return FN_XTOOLONG;
        if (strpbrk(e,forbid))
            return FN_BADCHAR;
        strupr(e);
        strcpy(ext,e);
    } else if (!modify)
        memset(ext,'\0',4);
    if (p) {
        int len = strlen(p);
        char *r, *q;
        delete path;
        path = NULL;
        q = strpbrk(p,forbid);
        if (q && *q != '.')
            return FN_BADCHAR;
        for (r = q = p;;) {
            q = strchr(q,'\\');
            if (!q) {
                if (strlen(r) > 12)
                    return FN_DTOOLONG;
                break;
            }
            if (*(q+1) == '\0') {
                --len;              // trailing backslash
                break;
            } else
                r = ++q;
            if (*r == '\\')
                return FN_BADCHAR;
        }
        if (len > 64)
            return FN_PTOOLONG;
        path = new char[len+1];
        if (!path) {
            fn_handler(ENOMEM,"filename - not enough memory");
            return FN_NOMEM;
        }
        strcpy(path,p);
        strupr(path);
    } else if (!modify) {
        delete path;
        path = NULL;
    }
    return(0);
}

int filename::parse(char *s)
{
    char local[80], *t, *p, *q, *e, *n, d = '\0';

    if (!s)
        return FN_NULL;
    strcpy(local,s);
    n = strrchr(local,'\\');
    if (n) {
        if (n > local && *(n-1) == '\\')
            return FN_BADCHAR;
        p = local;
        *n++ = '\0';
    } else {
        p = NULL;
        n = local;
    }
    e = strrchr(n,'.');
    if (e)
        *e++ = '\0';
    if (p)
        q = local;
    else
        q = n;
    t = strchr(q,':');
    if (t) {
        if (t > q+1)
            return FN_BADCOLON;
        d = *q;
        if (p)
            p += 2;
        else
            n += 2;
    }
    if (*n == '\0')
        return FN_NULL;
    return build(d,p,n,e,0);
}

PFC set_fn_handler(PFC handler)
{
    PFC local = fn_handler;
    fn_handler = handler;
    return local;
}

