#ifndef WINDOWHPP
#define WINDOWHPP
#include <stdarg.h>
#include <disp.h>
#include "dlist.hpp"
#include "sedit.hpp"

class window {
    friend class window_set;
    window_set *ws;
    string_editor se;
    int suspended;
    int tlr,tlc,brr,brc;
    int attribute, frameatt;
    int border;
    int wide, high, cr, cc;
    string_editor e;
    unsigned *buffer;
    void redisplay();
    void swap();
    void outc(char);
public:
    window(window_set *, int, int, int, int, int, int, int = -1);
    void clear();
    void chat(int, int);
    int title(char *);
    void modify(int att, int frame, int fa = -1) {
        frameatt = fa == -1? att: fa;
        attribute = att; border = frame;
        redisplay();
    }
    void suspend();
    void select();
    void locate(int, int);
    void putch(char c)  // putc clashes with a macro in stdio.h
       { select(); disp_setattr(attribute); outc(c); disp_flush(); }
    void puts(char *s)
       { select(); disp_setattr(attribute); while (*s) outc(*s++); disp_flush(); }
    int printf(char *,...);
    int gets(char *s)
        { select(); disp_setattr(attribute);
            return se.edit(tlr+cr+1,tlc+cc+1,s,1); }
    int close();
    ~window() { close(); }
};

typedef window* pwindow;
declare(gdlist,pwindow);

class window_set {
    friend class window;
    int overlapped;
    gdlist(pwindow) wl;
    int add(pwindow);
    void purge();
public:
    window_set(int tiled) {
        overlapped = tiled;
        if (!disp_inited) disp_open();
    }
    ~window_set() { purge(); }
};
#endif
