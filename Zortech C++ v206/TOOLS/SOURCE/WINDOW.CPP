#include <window.hpp>

typedef void (* PFC)(int,char *);
extern void default_error(int,char *);
PFC window_handler = default_error;

int window_set::add(pwindow nw)
{
    wl.end();
    if (wl.linkin(nw) == -1)
        return 0;
    return 1;
}

void window_set::purge()
{
    pwindow p;
    wl.start();
    while (wl.size()) {
        p = *wl;
        p->close();
    }
}


window::window(window_set *wset, int r1, int c1, int r2, int c2,
                            int att, int frame, int fa)
{
    tlr = r1; tlc = c1; brr = r2; brc = c2; attribute = att; border = frame;
    wide = brc-tlc-1; high = brr-tlr-1; // excluding border
    se.maxlength = wide;
    frameatt = fa == -1? att:  fa;
    int bufsize = (r2-r1+1) * (c2-c1+1);
    buffer = new unsigned[bufsize];
    if (!buffer) {
        window_handler(ENOMEM,"windows - not enough memory");
        return;
    }
    disp_peekbox(buffer,r1,c1,r2,c2);
    disp_scroll(0,r1,c1,r2,c2,att);
    disp_box(frame,frameatt,r1,c1,r2,c2);
    ws = wset;
    ws->add(this);
    suspended = 0;
    locate(0,0);
    cr = cc = 0;
}

void window::chat(int ln, int newatt)
{
    unsigned t[80];        // temp area to change attribute
    char *p;
    int i;
    disp_peekbox(t,ln+tlr,tlc+1,ln+tlr,brc-1);
    for (p = (char *) t+1, i = wide; i--; *p = newatt, p += 2) ;
    disp_pokebox(t,ln+tlr,tlc+1,ln+tlr,brc-1);
}

int window::title(char *s)
{
    int x = strlen(s);
    if (x > wide-3)
        return(0);
    x += 2;
    x = (wide-x)/2;
    disp_move(tlr,tlc+x+1);
    disp_setattr(frameatt);
    disp_printf("[%s]",s);
}
    

void window::redisplay()
{
    int i;

    for (i = 0; i <= high; ++i)
        chat(i,attribute);
    disp_box(border,frameatt,tlr,tlc,brr,brc);
}

void window::swap()
{
    unsigned t[80];        // swap buffer
    unsigned *p;
    int i, w = (wide+2);

    for (i = tlr, p = buffer; i <= brr; ++i, p += w) {
        disp_peekbox(t,i,tlc,i,brc);
        disp_pokebox(p,i,tlc,i,brc);
        memmove(p,t,w*2);
    }
}

void window::suspend()
{
    if (ws->overlapped) {
        for ((ws->wl).end(); (long) (ws->wl)() != (long) this; (ws->wl) -= 1)
            if (!(ws->wl)()->suspended) {
                (ws->wl)()->swap();
                (ws->wl)()->suspended = 1;
            }
    }
    swap();
    suspended = 1;
}

void window::select()
{
    if (ws->overlapped) {
        for ((ws->wl).end(); (long) (ws->wl)() != (long) this; (ws->wl) -= 1)
            if (!(ws->wl)()->suspended) {
                (ws->wl)()->swap();
                (ws->wl)()->suspended = 1;
            }
        }
    if (suspended) swap();
    suspended = 0;
    locate(cr,cc);
}

void window::clear()
{
    select();
    if (suspended)
        return;
    disp_scroll(0,tlr+1,tlc+1,brr-1,brc-1,attribute);
    locate(0,0);
}

int window::close()
{
    if (!buffer)
        return 1;   // closed already
    if (ws->overlapped) {
        for ((ws->wl).end(); (long) (ws->wl)() != (long) this; (ws->wl) -= 1)
            if (!(ws->wl)()->suspended)
                return 0;       // embedded can't close it
    }
    if (!suspended)
        disp_pokebox(buffer,tlr,tlc,brr,brc);
    delete buffer;
    buffer = 0;     // close is also called by the destructor
    *(ws->wl);      // link it out
    return 1;
}

void window::locate(int r, int c)
{
    if (r < 0 || r > high-1)
        return;
    if (c < 0 || c > wide-1)
        return;
    disp_move(tlr+r+1,tlc+c+1);
    disp_flush();
    cr = r; cc = c;
}

void window::outc(char c)
{
    if (c >= ' ') {
        disp_putc(c);
        if (cc == wide-1) {
            cc = 0;
            goto newline;
        } else
            ++cc;
        disp_move(tlr+cr+1,tlc+cc+1);
    } else {
        switch (c) {
        case '\n':
            cc = 0;
newline:
            if (cr == high-1)
                disp_scroll(1,tlr+1,tlc+1,brr-1,brc-1,attribute);
            else
                ++cr;
            break;
        case '\b':
            if (cc)
                --cc;
            break;
        case '\t':
            cc |= 7;
            ++cc;
            if (cc >= wide-1) {
                cc -= wide;
                goto newline;
            }
            break;
        }
    }
    disp_move(tlr+cr+1,tlc+cc+1);
}

int window::printf(char *format,...)
{
    char buf[256];
    select();
    disp_setattr(attribute);
    va_list arg_ptr;
    va_start(arg_ptr,format);
    vsprintf(buf,format,arg_ptr);
    puts(buf);
    disp_flush();
}

PFC set_window_handler(PFC handler)
{
    PFC local = window_handler;
    window_handler = handler;
    return local;
}
