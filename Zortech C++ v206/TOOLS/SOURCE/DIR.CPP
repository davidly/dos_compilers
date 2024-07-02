#include <dos.h>
#include <stream.hpp>
#include <dir.hpp>

typedef void (* PFC)(int, char*);
extern void default_error(int,char*);
static PFC dir_handler = default_error;

directory::directory(char *spec, int attr)
{
    struct FIND *p;
    pfinf q,r;
    int t,s;

    q = new file_info;
    if (!q) {
allerr:
        dir_handler(ENOMEM,"dir - not enough memory");
        return;
    }
    *q->name = '\0';
    if (d.linkin(q))       // create a dummy entry
        goto allerr;
    count = 0;
    p = findfirst(spec,attr);
    while (p) {
        q = new file_info;
        if (!q)
            goto allerr;
        q->attribute = p->attribute;
        memmove(&q->time,&p->time,2*sizeof(unsigned)+sizeof(unsigned long)+13);
        d.end();
        for (;;) {      // insertion sort - not highly efficient
                        // but we can do it as we go along
            if (strcmp(d()->name,p->name) <= 0) {
                if (d.linkin(q)) goto allerr;
                break;
            } else
                d--;
        }
        ++count;
        p = findnext();
    }
    d.start();
    q = *d;
    delete q;
}

PFC set_dir_handler(PFC handler)
{
    PFC loc = dir_handler;
    dir_handler = handler;
    return loc;
}
