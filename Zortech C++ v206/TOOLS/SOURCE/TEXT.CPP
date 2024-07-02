#include <stream.hpp>
#include <disp.h>
#include <text.hpp>

typedef void (*PFC)(int);
void default_handler(int);
static PFC edit_handler = default_handler;

text::text(int r1, int c1, int r2, int c2, int att) // constructor
{
    lb = (pline) new char[sizeof(int)+80];  // allocate line buffer
    lb->length = 0;                         // initialise to empty line
    if (!lb) {
        (*edit_handler)(0);
        exit(1);
    }
    *lb->body = '\0';
    if (!linkline()) {                      // link an empty line into list
        (*edit_handler)(0);
        exit(1);
    }
    tl.setflush(1);                         // delete list objects as well
                                            // as nodes
    nomem = dirty = 0;
    row = col = tcol = vmove = 0;
    tlr = r1; tlc = c1; brr = r2, brc = c2; // set window limits etc
    attribute = att;
    wide = brc-tlc+1; high = brr-tlr+1;
    le.maxlength = wide-1;                     // set max width for string editor
    cl = maxl = 1;                          // have one (empty) line of text
    if (!disp_inited) disp_open();
    disp_scroll(0,tlr,tlc,brr,brc,attribute);   // clear window
    disp_move(tlr,tlc);                     // cursor to start position
}

int text::linkline()
{
    pline p;
    p = (pline) new char[sizeof(int)+strlen(lb->body)+1];
    if (!p)                     // allocate a line structure just big enough
        return(0);
    p->length = lb->length;     // copy line buffer
    strcpy(p->body,lb->body);
    if (tl.linkin(p))                // link it in after current line
        return(0);
    return(1);
}

int text::replace()
{
    if (dirty) {                // line buffer needs saving
        pline p;                // allocate a structure of correct size
        p = (pline) new char[sizeof(int)+lb->length+1];
        if (!p)
            return 0;
        p->length = lb->length; // copy line buffer
        strcpy(p->body,lb->body);
        tl.update(p);           // update list
        dirty = 0;
    }
    return 1;
}

void text::prevlin()
{
    if (!replace()) {           // update list if neccessary
        (*edit_handler)(1);
        nomem = 1;
        return;
    }
    tl -= 1;                    // back one on list
    --cl;
    lb->length = tl()->length;  // copy list item into line buffer
    strcpy(lb->body,tl()->body);
}

void text::nextlin()
{
    if (!replace()) {           // update list if neccessary
        (*edit_handler)(1);
        nomem = 1;
        return;
    }
    tl += 1;                    // forward one on list
    ++cl;
    lb->length = tl()->length;  // copy list item into line buffer
    strcpy(lb->body,tl()->body);
}

void text::up()                 // cursor up one line
{
    if (cl > 1) {               // anywhere to go?
        prevlin();              // go there
        col = tcol > lb->length? lb->length: tcol;  // can we stay in same col?
        if (!row) {             // at top of window
            disp_scroll(-1,tlr,tlc,brr,brc,attribute); // scroll down one
            disp_move(tlr,tlc);
            disp_printf("%s",lb->body); // and fill in the current line
        } else
            --row;              // otherwise just adjust row
        disp_move(tlr+row,tlc+col); // move to new position
        disp_flush();           // update cursor
        vmove = 1;              // last move was up/down,  latch column
    }
}

void text::down()               // cursor down one line
{                               // same as up()
    if (cl < maxl) {
        nextlin();
        col = tcol > lb->length? lb->length: tcol;
        if (row == high-1) {
            disp_scroll(1,tlr,tlc,brr,brc,attribute);
            disp_move(brr,tlc);
            disp_printf("%s",lb->body);
        } else
            ++row;
        disp_move(tlr+row,tlc+col);
        disp_flush();
        vmove = 1;
    }
}

void text::newline(int splitcol)    // enter key pressed split line at
{                                   // splitcol
    char temp[80], *p;          // buffer to split off tail
    p = lb->body+splitcol;      // point to tail
    strcpy(temp,p);             // put in buffer
    *p = '\0';                  // and cut it off
    lb->length = strlen(lb->body);  // fill in length field
    dirty = 1;                  // mark line buffer for update
    if (!replace()) {           // then do it
        (*edit_handler)(1);
        nomem = 1;
        return;
    }
    strcpy(lb->body,temp);          // now get new line in line buffer
    lb->length = strlen(lb->body);
    if (!linkline()) {          // and link it in
        (*edit_handler)(2);
        nomem = 1;
        return;
    }
    dirty = 0;                  // line buffer == list
    ++cl; ++maxl;               // line count and current line both increment
    disp_move(tlr+row,tlc+splitcol);        // cursor to start of tail
    disp_printf("%*c",wide-splitcol,' ');   // write spaces over it
    if (row == high-1)          // split line was at bottom of window
        disp_scroll(1,tlr,tlc,tlr+row,brc,attribute); // scroll up one
    else {
        ++row;                  // adjust row
        int d = (row == high-1)? 0: -1;
        disp_scroll(d,tlr+row,tlc,brr,brc,attribute);
    }                           // then scroll the rest down one
    disp_move(tlr+row,tlc);     // position at start of new line
    disp_printf("%s",lb->body); // display it
    disp_move(tlr+row,tlc);
    disp_flush();               // update cursor
    col = 0;                    // and set column no
}

void text::deleolf()    // cursor at end of line, forward delete joins up
{                       // current line to next
    if (cl == maxl) {           // nothing there to join
        bdos(6,7,0);
        return;
    }
    tl += 1;                    // advance list pointer to next line
    if (tl()->length+lb->length >= wide) {
        bdos(6,7,0);            // combined line would be loo long
        tl -= 1;
        return;
    }
    strcat(lb->body,tl()->body);    // graft next line on to current
    lb->length = strlen(lb->body);
    pline p = *tl;              // link out next line
    delete p;                   // and get rid of garbage    
    --maxl;                     // have one less line
    if (cl < maxl)              // if the last line was deleted the currency
        tl -= 1;                // will have reverted to the current line
    dirty = 1;                  // mark the line buffer for update
    repaint(row);               // update rest of window
}

void text::deleolb()    // backspace at start of line joins it to previous
{
    if (cl == 1) {              // nothing there to join
        bdos(6,7,0);
        return;
    }
    char temp[81];
    strcpy(temp,lb->body);
    tl -= 1;                    // list pointer to previous line
    if (tl()->length+lb->length >= wide) {
        bdos(6,7,0);            // combined line would be loo long
        tl += 1;                // back to original line
        return;
    }
    tl += 1;
    pline p = *tl;              // link out old line
    delete p;
    --maxl;                     // have one less line
    if (cl < maxl)              // if the last line was deleted the currency
        tl -= 1;                // will have backed up
    --cl;                       // one nearer to start of file
    strcpy(lb->body,tl()->body);
    lb->length = tl()->length;
    col = lb->length;           // adjust col
    if (row) --row;             // and row unless at top of window
    strcat(lb->body,temp);      // graft old line on to this
    lb->length = strlen(lb->body);
    dirty = 1;                  // mark the line buffer for update
    repaint(row);               // update rest of window
}

int text::saveline()
{
    if (!replace()) {
        (*edit_handler)(3);         // no memory to save it
        return 0;
    }
    pline p = *tl;                  // link line out of dlist
    if (ss.push(p)) {
        (*edit_handler)(3);         // no memory to save it
        return 0;
    }
    return 1;
}

int text::copyline()
{
    if (!replace()) {
        (*edit_handler)(4);
        return 0;
    }
    pline p = (pline) new char[sizeof(int)+lb->length+1];
    if (!p) {
        (*edit_handler)(4);
        return 0;
    }
    p->length = lb->length;
    strcpy(p->body,lb->body);
    if (ss.push(p)) {
        delete p;
        (*edit_handler)(4);
        return 0;
    }
    return 1;
}

void text::restore()
{
    if (!replace()) {
        (*edit_handler)(1);
        nomem = 1;
        return;
    }
    pline p = ss.pop();
    if (!p)
        return;                 // nothing on stack
    if (cl > 1) {
        tl -= 1;
        if (tl.linkin(p)) {
            (*edit_handler)(2);
            nomem = 1;
            return;
        }
        ++maxl;
        col = 0;
        repaint(0);
    } else {
        newline(0);
        up();
        lb->length = p->length;
        strcpy(lb->body,p->body);
        dirty = 1;
        delete p;
        disp_printf("%s",lb->body);
        disp_move(tlr,tlc);
        disp_flush();
    }
}

void text::delline()                // delete the whole line
{
    if (maxl == 1) {                // first and only line
        if (!copyline()) {          // save a copy
            nomem = 1;              // no more memory
            return;
        }
        lb->length = 0;
        *lb->body = '\0';           // zero it
        dirty = 1;
        row = col = 0;              // adjust position
    } else {
        if (!saveline()) {          // keep a copy
            nomem = 1;
            return;
        }
        lb->length = tl()->length;  // update buffer to new current line
        strcpy(lb->body,tl()->body);
        dirty = 0;                  // line buffer == list
        if (cl == maxl) {           // deleted last line
            if (row)
                row--;
            col = lb->length;       // go to end of previous line
            --cl;                   // current line becomes one less
        } else 
            col = tcol > lb->length? lb->length: tcol;  // same column if possible
        --maxl;
    }
    repaint(row);                   // update rest of window
}

void text::goline(unsigned ln)  // adjust currency to line no ln
{
    if (ln > maxl || ln < 1)    // ignore if out of range
        return;
    if (!replace()) {           // update list from current line if required
        (*edit_handler)(1);
        nomem = 1;
        return;
    }
    if (maxl-ln < ln-1) {       // take shortest route
        tl.end();
        cl = maxl;
        while (cl != ln) {
            --cl;
            tl -= 1;            // step till on right line
        }
    } else {
        tl.start();
        cl = 1;
        while (cl != ln) {
            ++cl;
            tl += 1;
        }
    }
    lb->length = tl()->length;  // update line buffer
    strcpy(lb->body,tl()->body);
    dirty = 0;                  // line buffer == list
}

void text::repaint(int r)       // update screen after a goline, line deletion
{                               // etc, starting at row r
    unsigned savcl = cl;        // remember where we were
    goline(cl-(row-r));         // go to line corresponding to row r
    disp_move(tlr+r,tlc);       // put display position in row r
    for (;;) {
        disp_printf("%s%*c",tl()->body,wide-tl()->length,' ');
        if (r == high-1)        // all window updated
            break;
        ++r;                    // next row
        disp_move(tlr+r,tlc);
        if (cl == maxl) {       // there is no more
            disp_scroll(0,tlr+r,tlc,brr,brc,attribute);
            break;              // blank rest of window and quit
        }
        tl += 1;                // next line on list
        ++cl;                   // keep track
    }
    goline(savcl);              // restore cl and currency
    disp_move(tlr+row,tlc+col);
    disp_flush();               // update cursor
}

void text::blockdown()          // down high-1 lines
{
    unsigned dest = cl+high-1;
    if (dest < maxl) {
        goline(dest);
        col = 0;
        repaint(0);
    } else                      // unless end is near
        endof();
}

void text::blockup()            // up high-1 lines
{
    if (high-1 < cl) {
        unsigned dest = cl-(high-1);
        if (dest-1 < row)
            row = dest-1;
        goline(dest);
        col = 0;
        repaint(0);
    } else
        topof();
}

void text::topof()              // display first high lines
{
    if (!replace()) {
        (*edit_handler)(1);
        nomem = 1;
        return;
    }
    tl.start();                 // we can go directly to start
    lb->length = tl()->length;  // update line buffer
    strcpy(lb->body,tl()->body);
    dirty = 0;
    cl = 1;
    row = col = 0;
    repaint(0);
}

void text::endof()              // display last high/2 lines
{
    if (!replace()) {
        (*edit_handler)(1);
        nomem = 1;
        return;
    }
    tl.end();
    lb->length = tl()->length;
    strcpy(lb->body,tl()->body);
    dirty = 0;
    col = lb->length;           // position at end
    row = (maxl > (high-1)/2)? (high-1)/2: maxl-1;
    cl = maxl;                  // no more than half way down window
    repaint(0);
}

// This is written for the PC environment - elsewhere the command source
// would have to emulate the PC by producing the following values

enum  { BS = 0x0e08, ESC = 0x011b, DEL = 0x5300, INS = 0x5200, LCUR = 0x4b00,
        RCUR = 0x4d00, WLEFT = 0x7300, WRIGHT = 0x7400, HOME = 0x4700,
        END = 0x4f00, RET = 0x1c0d, UCUR = 0x4800, DCUR = 0x5000,
        CTRLBS = 0x0e7f, ALTX = 0x2d00, PGUP = 0x4900, PGDN = 0x5100,
        CTRLPGUP = 0x8400, CTRLPGDN = 0x7600, CTRLHOME = 0x7700,
        CTRLEND = 0x7500, ALTR = 0x1300, ALTS = 0x1f00};

int text::textedit()
{
    char c;
    int  kc;
    disp_move(tlr+row,tlc+col);
    disp_flush();
    for (;;) {
        if (vmove)
            vmove = 0;
        else
            tcol = col;
        c = kc = bioskey(0);
        switch (kc) {
        case LCUR:
        case RCUR:  // pass all these commands to string editor
        case HOME:  // in single command mode, line buffer not affected
        case END:
        case WRIGHT:
        case WLEFT: 
            le.edit(tlr+row,tlc,lb->body,0,col,kc);
            col = le.where;
            break;
        case UCUR:
            up();
            break;
        case DCUR:
            down();
            break;
        case BS:
            if (!col)   // backspace at start of line
                deleolb();
            else {      // otherwise give it to string editor
                le.edit(tlr+row,tlc,lb->body,0,col,kc);
                --col;
                --lb->length;
                dirty = 1;  // mark line buffer for update
            }
            break;
        case DEL:
            if (col == lb->length)
                deleolf();  // delete at end of line
            else {      // otherwise give it to string editor
                le.edit(tlr+row,tlc,lb->body,0,col,kc);
                --lb->length;
                dirty = 1;  // mark line buffer for update
            }
            break;
        case RET:       
            newline(col);
            break;
        case CTRLBS:
            delline();
            break;
        case PGUP:
            blockup();
            break;
        case PGDN:
            blockdown();
            break;
        case CTRLPGUP:
            topof();
            break;
        case CTRLPGDN:
            endof();
            break;
        case CTRLEND:
        case CTRLHOME:
            le.edit(tlr+row,tlc,lb->body,0,col,kc);
            dirty = 1;  // mark line buffer for update
            lb->length = strlen(lb->body);
            col = le.where;
            break;
        case ALTS:
            copyline();
            if (!nomem && cl < maxl)
                down();
            break;
        case ALTR:
            restore();
            break;
        case ALTX:
            return maxl;    // quit and return number of lines stored
        default:
            if (!c)         // unrecognised function key etc
                bdos(6,7,0);
            else            // use line editor to insert it
                le.edit(tlr+row,tlc,lb->body,0,col,kc);
                lb->length = le.howlong;
                col = le.where;
                dirty = 1;  // mark line buffer for update
            break;
        }
        if (nomem)          // memory exhausted drop out and return
            return maxl;    // number of lines
    }
}

int text::addline(char *s)  // so a list can be built from a file etc
{
    char *p;
    if (strlen(s) > wide) {
        p = s+wide;
        *p = '\0';          // truncate if too long
    }
    strcpy(lb->body,s);     // get in line buffer
    lb->length = strlen(s);
    dirty = 1;
    if (!replace()) {       // update list
        (*edit_handler)(1);
        return 0;
    }
    lb->length = 0;         // re-initialise line buffer
    *lb->body = '\0';
    if (!linkline()) {      // create another list entry
        (*edit_handler)(2);
        return 0;
    }
    dirty = 0;              // line buffer == list
    ++cl; ++maxl;           // keep track and count it
    return 1;
}

char *text::getline(unsigned n)
{
    goline(n);
    char *p = tl()->body;
    row = col = 0;
    return p;
}

void text::moveit(int r, int c) // move window - top left corner coordinates
{
    tlr = r; tlc = c; brr = r+high-1, brc = c+wide-1;
}   // do a repaint afterwards to put the text there

char *edit_ermess[] = {
    "no memory to create editor",
    "replace failed, no memory",
    "line not linked, no memory",
    "line not saved, no memory",
    "line not copied, no memory"
};

void default_handler(int n)
{
    disp_move(24,0);            // arbitrary choice - configure as required
    disp_printf("edit - %s",edit_ermess[n]);
    bdos(6,7,0);                // beep so user notices
}

PFC set_edit_handler(PFC nh)
{
    PFC t = edit_handler;
    edit_handler = nh;
    return t;
}
