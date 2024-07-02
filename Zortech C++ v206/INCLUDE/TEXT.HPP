#ifndef EDITHPP
#define EDITHPP
#include <stdlib.h>
#include "sedit.hpp"
#include "dlist.hpp"
#include "slist.hpp"

struct line {
    int length;
    char body[1];
};

typedef line *pline;
declare(gdlist,pline);
declare(gstack,pline);

class text {
    unsigned cl, maxl;          // current and last line numbers
    pline lb;                   // pointer to current line buffer
    int nomem;                  // no room for any more
    int dirty;                  // current line buffer modified
    int row, col, tcol, vmove;  // housekeeping data
    int tlr,tlc,brr,brc;        // window data
    int wide, high;
    int attribute;
    gdlist(pline) tl;           // linked list of text lines
    gstack(pline) ss;           // stack of saved lines
    string_editor le;           // use the existing line editor
    int replace(void);          // update linked list line from line buffer
    int linkline(void);         // put a new line in the list
    void prevlin(void);
    void nextlin(void);
    void up(void);
    void down(void);
    void newline(int);
    void deleolf(void);         // delete end of line forwards
    void deleolb(void);         // delete end of line backwards
    void delline(void);
    int saveline();             // save deleted line
    int copyline();             // save a copy of the current line
    void restore();             // pop a line off the stored list
    void goline(unsigned);      // move to line no
    void blockup(void);         // up window height-1 lines
    void blockdown(void);       // down ditto
    void endof(void);           // to last line
public:
    text(int, int, int, int, int);
    void repaint(int);          // redisplay current text from line n
    void topof(void);           // to first line and redisplay
    pline extract() {
        if (!tl.size()) return NULL;
        tl.start(); return *tl; // link out and get first line
    }
    int addline(char *);        // fill line buffer and link in
    char *getline(unsigned);    // get pointer to line text
    void moveit(int,int);       // relocate the window
    int textedit(void);         // go
    ~text() { pline p; while (cl--) { p = extract(); delete p;} delete lb; }
};
#endif
