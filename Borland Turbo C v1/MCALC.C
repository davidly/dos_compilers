/* Turbo C - (C) Copyright 1987 by Borland International */

#define MAIN

#include <string.h>
#include <alloc.h>
#include <stdarg.h>
#include "mcalc.h"

CELLPTR cell[MAXCOLS][MAXROWS], curcell;
unsigned char format[MAXCOLS][MAXROWS];
unsigned char colwidth[MAXCOLS];
unsigned char colstart[SCREENCOLS];
int leftcol, rightcol, toprow, bottomrow, curcol, currow, lastcol, lastrow;
char changed = FALSE;
char formdisplay = FALSE;
char autocalc = TRUE;
char stop = FALSE;
char colortable[128];
char colorcard;
char snow;
char far *displayptr;
long memleft;

void run()
/* The main program loop */
{
 int input;

 do
 {
  displaycell(curcol, currow, HIGHLIGHT, NOUPDATE);
  curcell = cell[curcol][currow];
  showcelltype();
  input = getkey();
  switch(input)
  {
   case '/' :
    mainmenu();
    break;
   case '!' :
    recalc();
    break;
   case F2 :
    editcell(curcell);
    break;
   case DELKEY :
    deletecell(curcol, currow, UPDATE);
    printfreemem();
    if (autocalc)
     recalc();
    break;
   case PGUPKEY :
    toprow -= 20;
    currow -= 20;
    if (currow < 0)
     currow = toprow = 0;
    else if (toprow < 0)
    {
     currow -= toprow;
     toprow = 0;
    }
    setbottomrow();
    displayscreen(NOUPDATE);
    break;
   case PGDNKEY :
    toprow += 20;
    currow += 20;
    if ((currow >= MAXROWS) && (toprow >= MAXROWS))
    {
     currow = MAXROWS - 1;
     toprow = MAXROWS - 20;
    }
    else if (toprow > (MAXROWS - 20))
    {
     currow -= (toprow + 20 - MAXROWS);
     toprow = MAXROWS - 20;
    }
    setbottomrow();
    displayscreen(NOUPDATE);
    break;
   case CTRLLEFTKEY :
    displaycell(curcol, currow, NOHIGHLIGHT, NOUPDATE);
    if (leftcol == 0)
     curcol = 0;
    else
    {
     curcol = rightcol = leftcol - 1;
     setleftcol();
     setrightcol();
     displayscreen(NOUPDATE);
    }
    break;
   case CTRLRIGHTKEY :
    displaycell(curcol, currow, NOHIGHLIGHT, NOUPDATE);
    if (rightcol == MAXCOLS - 1)
     curcol = rightcol;
    else
    {
     curcol = leftcol = rightcol + 1;
     setrightcol();
     setleftcol();
     displayscreen(NOUPDATE);
    }
    break;
   case HOMEKEY :
    currow = curcol = leftcol = toprow = 0;
    setrightcol();
    setbottomrow();
    displayscreen(NOUPDATE);
    break;
   case ENDKEY :
    rightcol = curcol = lastcol;
    currow = bottomrow = lastrow;
    settoprow();
    setleftcol();
    setrightcol();
    displayscreen(NOUPDATE);
    break;
   case UPKEY :
    moverowup();
    break;
   case DOWNKEY :
    moverowdown();
    break;
   case LEFTKEY :
    movecolleft();
    break;
   case RIGHTKEY :
    movecolright();
    break;
   default :
    if ((input >= ' ') && (input <= '~'))
     getinput(input);
    break;
  } /* switch */
 }
 while (!stop);
} /* run */

main(int argc, char *argv[])
{
 initdisplay();
 clrscr();
 writef((80 - strlen(MSGHEADER)) >> 1, 10, MSGHEADERCOLOR, strlen(MSGHEADER),
        MSGHEADER);
 writef((80 - strlen(MSGKEYPRESS)) >> 1, 12, PROMPTCOLOR,
        strlen(MSGKEYPRESS), MSGKEYPRESS);
 gotoxy(79, 24);
 getkey();
 clrscr();
 initvars();
 memleft = memsize;
 redrawscreen();
 if (argc > 1)
  loadsheet(argv[1]);
 clearinput();
 run();
 clrscr();
 gotoxy(0, 0);
}
