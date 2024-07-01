/* Turbo C - (C) Copyright 1987 by Borland International */

#include <dos.h>
#include <stdio.h>
#include <string.h>
#include <mem.h>
#include "mcalc.h"

struct screenelement
{
 char character;
 char color;
};

void scroll(int direction, int lines, int x1, int y1, int x2, int y2,
            int attrib)
/* Scrolls an area of the screen */
{
 union REGS reg;

#if VIDEOWRITE
 int row, size;
 char far *source;
 char far *dest;

 if (direction <= RIGHT)
 {
  size = (x2 - x1 + 1) << 1;
  source = displayptr + (y1 * 160) + (x1 << 1);
  if (direction == RIGHT)
   dest = source + (lines << 1);
  else
   dest = source - (lines << 1);
  for (row = y1; row <= y2; row++)
  {
   movescreenmem(source, dest, size, snow);
   source += 160;
   dest += 160;
  }
  return;
 }
#endif
 reg.x.ax = ((direction + 4) << 8) + lines;
 reg.h.bh = colortable[attrib];
 reg.x.cx = (y1 << 8) + x1;
 reg.x.dx = (y2 << 8) + x2;
 int86(0X10, &reg, &reg);
} /* scroll */

int egainstalled(void)
/* Tests for the presence of an EGA */
{
 union REGS reg;

 reg.x.ax = 0X1200;
 reg.x.bx = 0X0010;
 reg.x.cx = 0XFFFF;
 int86(0X10, &reg, &reg);
 return((reg.x.cx == 0XFFFF) ? 0 : 1);
} /* egainstalled */

void setcursor(int startline, int endline)
/* Sets the shape of the cursor */
{
 union REGS reg;

 reg.h.ah = 1;
 reg.x.cx = (startline << 8) + endline;
 int86(0X10, &reg, &reg);
} /* setcursor */

void clrscr(void)
/* Clears the screen */
{
 scroll(UP, 0, 0, 0, 79, 24, WHITE);
} /* clrscr */

void gotoxy(int col, int row)
/* Moves the cursor to a specific column and row */
{
 union REGS reg;

 reg.h.ah = 2;
 reg.h.bh = 0;
 reg.x.dx = (row << 8) + col;
 int86(0X10, &reg, &reg);
} /* gotoxy */

#if VIDEOWRITE

void writef(int col, int row, int color, int width, va_list arg_list, ...)
/* Prints a string in video memory at a selected location in a color */
{
 va_list arg_ptr;
 char *format;
 char output[81];
 struct screenelement buffer[80];
 int counter, len;
 unsigned size;

 va_start(arg_ptr, arg_list);
 format = arg_list;
 vsprintf(output, format, arg_ptr);
 color = (color > 127) ? colortable[color - 128] + 128 : colortable[color];
 if ((len = strlen(output)) < width)
  setmem(&output[len], width - len, ' ');
 size = width << 1;
 setmem(buffer, size, color);
 for (counter = 0; counter < width; counter++)
  buffer[counter].character = output[counter];
 movescreenmem((char far *)(buffer),
               displayptr + (row * 160) + (col << 1), size, snow);
} /* writef */

#else

void writef(int col, int row, int color, int width, va_list arg_list, ...)
/* Prints a string in video memory at a selected location in a color */
{
 va_list arg_ptr;
 char *format;
 char output[81];
 int counter, len, oldcol, oldrow;
 register pcol = col;
 union REGS inreg, outreg;

 va_start(arg_ptr, arg_list);
 format = arg_list;
 vsprintf(output, format, arg_ptr);
 color = (color > 127) ? colortable[color - 128] + 128 : colortable[color];
 if ((len = strlen(output)) < width)
  setmem(&output[len], width - len, ' ');
 inreg.h.ah = 3;
 inreg.h.bh = 0;
 int86(0X10, &inreg, &outreg);
 oldrow = outreg.h.dh;
 oldcol = outreg.h.dl;
 inreg.h.ah = 9;
 inreg.x.bx = color;
 inreg.x.cx = 1;
 for (counter = 0; counter < width; counter++)
 {
  gotoxy(pcol++, row);
  inreg.h.al = output[counter];
  int86(0X10, &inreg, &outreg);
 }
 gotoxy(oldcol, oldrow);
} /* writef */

#endif

void initcolortable(int blackwhite)
/* Sets up the color table */
{
 int color, fg, bg, tempfg, tempbg;

 if (!blackwhite)
 {
  for (color = 0; color < 128; color++)
   colortable[color] = color;
 }
 else
 {
  for (fg = BLACK; fg <= WHITE; fg++)
  {
   for (bg = BLACK; bg <= LIGHTGRAY; bg++)
   {
    tempfg = ((fg >= DARKGRAY) ? WHITE : ((fg >= BLUE) ? LIGHTGRAY : fg));
    if (bg != BLACK)
    {
     tempbg = LIGHTGRAY;
     tempfg = ((tempfg <= DARKGRAY) && (tempfg != BLACK) ? DARKGRAY :
               BLACK);
    }
    else
     tempbg = BLACK;
    colortable[fg + (bg << 4)] = tempfg + (tempbg << 4);
   };
  };
 };
} /* initcolortable */

void printcol(void)
/* Prints the column headings */
{
 int col;
 char colstr[MAXCOLWIDTH + 1];

 scroll(UP, 0, 0, 1, 79, 1, HEADERCOLOR);
 for (col = leftcol; col <= rightcol; col++)
 {
  centercolstring(col, colstr);
  writef(colstart[col - leftcol], 1, HEADERCOLOR, colwidth[col], colstr);
 }
} /* printcol */

void clearlastcol()
/* Clears any data left in the last column */
{
 int col;

 if ((col = colstart[rightcol - leftcol] + colwidth[rightcol]) < 80)
  scroll(UP, 0, col, 2, 79, SCREENROWS + 1, WHITE);
} /* clearlastcol */

void printrow(void)
/* Prints the row headings */
{
 int row;

 for (row = 0; row < SCREENROWS; row++)
  writef(0, row + 2, HEADERCOLOR, LEFTMARGIN, "%-d", row + toprow + 1);
} /* printrow */

void displaycell(int col, int row, int highlighting, int updating)
/* Displays the contents of a cell */
{
 int color;
 char *s;

 if ((updating) &&
     ((cell[col][row] == NULL) || (cell[col][row]->attrib != FORMULA)))
  return;
 s = cellstring(col, row, &color, FORMAT);
 if (highlighting)
 {
  if (color == ERRORCOLOR)
   color = HIGHLIGHTERRORCOLOR;
  else
   color = HIGHLIGHTCOLOR;
 }
 writef(colstart[col - leftcol], row - toprow + 2, color, colwidth[col],
        "%s", s);
} /* displaycell */

void displaycol(int col, int updating)
/* Displays a column on the screen */
{
 int row;

 for (row = toprow; row <= bottomrow; row++)
  displaycell(col, row, NOHIGHLIGHT, updating);
} /* displaycol */

void displayrow(int row, int updating)
/* Displays a row on the screen */
{
 int col;

 for (col = leftcol; col <= rightcol; col++)
  displaycell(col, row, NOHIGHLIGHT, updating);
} /* displayrow */

void displayscreen(int updating)
/* Displays the current screen of the spreadsheet */
{
 int row;

 for (row = toprow; row <= bottomrow; row++)
  displayrow(row, updating);
 clearlastcol();
} /* displayscreen */

void clearinput(void)
/* Clears the input line */
{
 scroll(UP, 0, 0, 24, 79, 24, WHITE);
 gotoxy(0, 24);
} /* clearinput */

void changecursor(insmode)
/* Changes the cursor shape based on the current insert mode */
{
 if (insmode)
 {
  if (colorcard)
   setcursor(5, 7);
  else
   setcursor(9, 12);
 }
 else
 {
  if (colorcard)
   setcursor(6, 7);
  else
   setcursor(10, 12);
 }
} /* changecursor */

void showcelltype(void)
/* Prints the type of cell and what is in it */
{
 char colstr[3], *s;
 int color;

 formdisplay = !formdisplay;
 s = cellstring(curcol, currow, &color, NOFORMAT);
 colstring(curcol, colstr);
 if (curcell == NULL)
  writef(0, 22, CELLTYPECOLOR, 80, "%s%d %s", colstr, currow + 1, MSGEMPTY);
 else switch(curcell->attrib)
 {
  case TEXT :
   writef(0, 22, CELLTYPECOLOR, 80, "%s%d %s", colstr, currow + 1,
          MSGTEXT);
   break;
  case VALUE :
   writef(0, 22, CELLTYPECOLOR, 80, "%s%d %s", colstr, currow + 1,
          MSGVALUE);
   break;
  case FORMULA :
   writef(0, 22, CELLTYPECOLOR, 80, "%s%d %s", colstr, currow + 1,
          MSGFORMULA);
   break;
 } /* switch */
 writef(0, 23, CELLCONTENTSCOLOR, 80, "%s", s);
 formdisplay = !formdisplay;
} /* showcelltype */

void redrawscreen(void)
/* Displays the entire screen */
{
 setrightcol();
 setbottomrow();
 writef(0, 0, MSGMEMORYCOLOR, strlen(MSGMEMORY), MSGMEMORY);
 writef(28, 0, PROMPTCOLOR, strlen(MSGCOMMAND), MSGCOMMAND);
 changeautocalc(autocalc);
 changeformdisplay(formdisplay);
 printfreemem();
 displayscreen(NOUPDATE);
} /* redrawscreen */

void initdisplay(void)
/* Initializes various global variables - must be called before using the
   above procedures and functions.
*/
{
 union REGS reg;

 reg.h.ah = 15;
 int86(0X10, &reg, &reg);
 colorcard = (reg.h.al != 7);
 snow = (!egainstalled() && colorcard);
 initcolortable(!colorcard || (reg.h.al == 0) || (reg.h.al == 2));
 displayptr = (char far *)(colorcard ? 0XB8000000L : 0XB0000000L);
} /* initdisplay */
