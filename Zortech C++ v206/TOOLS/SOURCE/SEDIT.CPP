#include <stdio.h>
#include <disp.h>
#include <sedit.hpp>

typedef void (* PFC)(int,char *);
extern void default_error(int,char *);
PFC sedit_handler = default_error;

enum  { BS = 0x0e08, ESC = 0x011b, DEL = 0x5300, INS = 0x5200, LCUR = 0x4b00,
        RCUR = 0x4d00, WLEFT = 0x7300, WRIGHT = 0x7400, HOME = 0x4700,
        END = 0x4f00, RET = 0x1c0d, UCUR = 0x4800, DCUR = 0x5000,
        CTRLEND = 0x7500, CTRLHOME = 0x7700 };

string_editor::string_editor(int ml, int insmode)
{
    maxlength = ml; insert = insmode;
    howlong = where = -1;
    local = new char[ml+1];
    if (!local)
        sedit_handler(ENOMEM,"line editor - not enough memory");
}

int string_editor::edit(int arow, int acol, char *s, int fillin, int sc, int dc)
{
    char c, *p, *q, *r;
    int fv, i, kc, cc = acol+sc;

    if (fillin) {           // string not visible
        disp_move(arow,acol);
        if (*s)
            disp_printf("%s",s);
        else                // or not relevant
            disp_printf("%*c",maxlength,' ');
    }
    p = s+sc;
    howlong = strlen(s);
    strcpy(local,s);        // in case edit abandoned
    q = s+howlong;          // q points beyond end of string
    disp_move(arow,acol+sc);
    disp_flush();
    for (;;) {
        kc = dc? dc: command_source();
        c = kc = convertor(kc,s,p-s);
        if (!insert && kc == DEL)   // it not insert mode
            c = kc = 0x3920;        // treat DEL as space
        if (kc == BS) {
            if (p > s) {
                --p;
                disp_putc('\b');    // backspace
                if (insert) {
                    howlong--;      // adjust length
                    q--;            // and tail pointer
                    r = p;
                    while ((*r = *(r+1)) != '\0') {
                        disp_putc(*r);
                        r++;        // move tail down one
                    }
                } else
                    *p = ' ';       // otherwise just blank the position
                cc--;
                disp_putc(' ');     // blank position or old last char
                disp_move(arow,cc);
                disp_flush();
            }
        } else if (kc == DEL) {
            if (p == q)             // at end - nothing to delete
                continue;
            r = p;
            while ((*r = *(r+1)) != '\0') {
                disp_putc(*r);      // move tail down one
                r++;
            }
            disp_putc(' ');         // blank last char
            disp_move(arow,cc);
            disp_flush();
            *--q = '\0';
            howlong--;
        } else if (kc == CTRLHOME) {
            strcpy(s,p);
            i = strlen(s);
            disp_move(arow,acol);
            disp_printf("%s%*c",s,howlong-i,' ');
            disp_move(arow,acol);
            disp_flush();
            p = s;
            q = s+i;
            howlong = i;
            cc = acol;
        } else if (kc == CTRLEND) {
            q = p;
            *p = '\0';
            i = strlen(s);
            disp_printf("%*c",howlong-i,' ');
            disp_move(arow,cc);
            disp_flush();
            howlong = i;
        } else if (kc == INS) {
            insert = !insert;       // toggle insert mode
        } else if (kc == LCUR && p > s) {
            p--;
            cc--;
            disp_move(arow,cc);     // left one char
            disp_flush();
        } else if (kc == RCUR && p < q) {
            p++;
            cc++;
            disp_move(arow,cc);     // right one char
            disp_flush();
        } else if (kc == WLEFT && p > s) {
            do {
                p--;
                cc--;
            } while (p > s && !(*(p-1) == ' ' && *p != ' '));
            disp_move(arow,cc);     // word left
            disp_flush();
        } else if (kc == WRIGHT && p < q) {
            do {
                p++;
                cc++;
            } while (p < q && !(*(p-1) == ' ' && *p != ' '));
            disp_move(arow,cc);     // word right
            disp_flush();
        } else if (kc == HOME) {
            p = s;
            cc = acol;
            disp_move(arow,cc);     // left hand end
            disp_flush();
        } else if (kc == END) {
            p = q;
            cc = acol+howlong;
            disp_move(arow,cc);     // right hand end
            disp_flush();
        } else if (kc == RET || kc == UCUR || kc == DCUR) {
            for (--q; *q == ' '; --q) ; // strip trailing blanks
            *++q = '\0';                // terminate
            where = p-s;
            return(kc ==RET? 1:(kc == UCUR? 2: 3));
        } else if (kc == ESC) {
            strcpy(s,local);        // restore original
            where = p-s;
            return(0);
        } else if ((fv = filter(c,s,p-s)) != 0) {
                        // is the character acceptable?
            if (insert) {
                if (howlong < maxlength) {
                    r = q+1;
                    while (r > p) {
                        *r = *(r-1);
                        r--;        // move tail along
                    }
                    disp_printf(" %s",r+1);
                    *r = c;
                    howlong++;
                    q++;
                    p++;    
                    goto update;
                } else putchar(7); // already at max length - beep
            } else if (p == q) {
                if (howlong < maxlength) {
                    howlong++;
                    *++q = '\0';
                    *p++ = c;
                    goto update;
                } else putchar(7);
            } else {
                *p++ = c;           // overwrite existing character
    update:
                disp_move(arow,cc);
                disp_flush();
                disp_putc(c);       // display the character
                disp_flush();
                cc++;
            }
        } else if (fv == 0)         // bad char beep it
            putchar(7);
        // else just ignore it
        if (dc) {
            where = p-s;
            return 4;               // single command mode
        }
    }
}

PFC set_sedit_handler(PFC handler)
{
    PFC local = sedit_handler;
    sedit_handler = handler;
    return local;
}
