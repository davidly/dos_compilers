#if 0
                            FG APPLICATION NOTE

                How to make your own FG video board driver.

Five functions must be written for a minimal FG_ driver.  If you do the 
minimum you will get something that will work but may be unacceptably slow.  
To speed it up replace the fg_c_XXX functions with custom versions 
optimized for speed.  The ones that will get you the biggest overall 
improvement are fg_drawline() (especially horizontal lines which are used by 
many other functions), and fg_drawmatrix() (used by fg_putc(), fg_puts(), and 
the mouse functions).  If you want to do the minimum to speed it up, implement
fg_drawline() for solid, horizontal lines, passing other lines to 
fg_c_drawline().  See example below. 

Test your driver for functionality and send it to me if you wish us 
to incorporate it into the standard product (no strings attached, 
please!).  Either via the Zortech BBS at 206-822-6907, or email it to 
uunet!proto!fg.  ASCII, uuencoded, compressed, pkzip, lharc or 
combinations thereof are all acceptable.  I will probably be able to 
speed up the driver and incorporate it into the regular library. 

---------------------------------------
Function 1.
Create a function (called "your_init_func") that does the following:

call fg_misc_init BEFORE going into graphics mode.  This function 
initializes fg.text_mode, fg.text_rows, and fg.attribute, using int 10h 
queries to the video adapter BIOS. 

set fg.display = 94 (Or whatever number you fancy except 0 or one that has
    already been used for something else, see fg.h).

set fg.init_p to "your_init_func()".
set fg.term_p to "your_term_func()".
set fg.drawdot_p to "your_drawdot_func()".
set fg.readdot_p to "your_readdot_func()".
set fg.flush_p to "your_flush_func()".
set most all other function pointers in the structure 
    "fg" (see fg.h) to "fg_c_XXX()" where XXX is the name like 
    "drawline()", "drawmatrix()", etc. Or if fg_c_XXX isn't available (look 
    in listing produced by "zorlib" on fg.lib) create your own function (a 
    dummy function if nothing else).

    Exceptions:
    fg_c_putc doesn't exist, use fg_a_putc.
    fg_c_setpalette doesn't exist.  Make your own, use a dummy, or use 
    fg_ega_setpalette() or fg_vga_setpalette(), if your board is ega or vga 
    bios compatible for this new mode. 
    Don't touch ANY of the fg.msm_XXX function pointers. They are all 
    initialized automagically if you follow this procedure.

set fg.fontptr to a font table for chars 0->127 (use fg_font if nothing else).
set fg.fontptr2 to a font table for chars 128->255 (use fg_font2...).
    Set fg.fontptr2 to 0 if nothing is available.
set fg.charbox to proper values.  They are 0,0,8,13 for fg_font.
set fg.displaybox to proper values.  They are 0,0,639,399 for 640 x 400 mode.
set fg.ncolormap to number of colors possible (64L * 64L * 64L for VGA13).
set fg.nsimulcolor to number of colors possible simultaneously (256 in VGA13).
set fg.pixelx and fg.pixely to some reasonable numbers.
set fg.numpages to 1 (or more if you have working "your_setdisplaypage()" and 
    "your_setactivepage()" functions.
set fg.activepage and fg.displaypage to 0
call fg_zero_colors().  This sets all color variables (FG_WHITE, FG_BLACK, 
etc) to -1.  Then set each of the valid colors individually to the "proper"
number via fg_setcolornum().

The "proper" number is determined by the graphics board, mode, and the 
implementation of "your_draw_dot" and "your_read_dot" functions.

put the display into graphics mode.

call (*fg.msm_init_p)().  It has been initialized for you, just call it.

return fg.display

---------------------------------------
Function 2.

This is optional.  fg_misc_term() may work instead of having to 
create your own.

fg_misc_term() does an int 10h with register AH equal to 0, and AL equal to 
fg.text_mode.  fg.text_mode was initialized when you called fg_misc_init().  
fg_misc_term also clears the screen using the attribute found in fg.attribute 
via int 10h with AX equal to 0600h.  If fg.text_rows does not equal 25 it sets 
ega boards into 43 line mode, and vga boards into 50 line mode.  It then sets 
the cursor to the upper left hand corner via int 10h with AH equal to 2. 

If you do not call fg_misc_term() you must call (*fg.msm_term_p)(), call 
fg_set_dummy(), and set fg.display = FG_NULL. 

---------------------------------------
Function 3.
Create a "your_drawdot_func()" that calls fg_msm_hidecursor(), draws a 
single dot on the screen, then calls fg_msm_showcursor(). 

---------------------------------------
Function 4.
Create a "your_readdot_func()" that calls fg_msm_hidecursor(), reads a 
single dot from the screen, then calls fg_msm_showcursor().  Returning the
value of the dot.

---------------------------------------
Function 5.
This is optional.  If your board and implementation has some output 
buffer that must be flushed before the screen is fully up to date, flush 
this buffer after calling (*fg.msm_flush_p(). 

If there is no buffer to flush, then fg.flush_p may be assigned to 
fg.msm_flush_p in "your_init_func".

---------------------------------------

Compile them all in the L model and link them with your application (must 
be L model) and fg.lib.

If you wish to use the driver with other models (C, M, or S) applications, run 
"patchobj in.obj out.obj -l" on each module.  You may then link the "out.obj"s 
with other model applications, or add the modules to fg.lib.  This requires 
however, that you do NOT call any standard library functions.  Functions such 
as memset(), memcpy() are very tempting but must be avoided if you plan to 
link with anything other than the L model standard library.  FG library 
functions are, however, okay to call.

Joe Huffman May 28, 1990
FAX:   208-263-8772
uucp: uunet!proto!joe


----------------------
Example:
#endif

/* Copyright Prototronics */
/* 6490 Kaniksu Shores Circle */
/* Sandpoint, ID  83864-9445 */
/* Joe Huffman */
/* September 18, 1990 */
/* FAX:   208-263-8772 */
/* email: joe@proto.com */

/* FG graphics routines specific to VGA mode 13.

Compile with one of the following:

ztc fg_drvr -o -DTEST -ml -DDEBUG fgdebug.lib     (Largest and slowest)
ztc fg_drvr -o -DTEST -mli -DDEBUG fgdebug.lib
ztc fg_drvr -o -DTEST -ml fg.lib
ztc fg_drvr -o -DTEST -mli fg.lib                 (Small and fastest)
ztc fg_drvr -o+space -DTEST -mli fg.lib           (Smallest and fast)

Run fg_drvr.exe (requires VGA compatible graphics adapter).
*/

#include    <dos.h>
#include    "fg.h"

#ifdef DEBUG
#define assert(e)	((void)((e) || fg_assert(#e,__FILE__,__LINE__)))
#else
#define assert(e) ((void)(e))
#endif

extern void
  fg_misc_init(void),
  fg_c_setlinepattern(int,int),
  fg_c_drawline(fg_color_t,int,int,int,fg_const_pline_t),
  fg_c_drawlinep(fg_color_t,int,int,int,fg_const_pline_t),
  fg_c_drawellipse (fg_color_t color, int mode, int mask,
    fg_coord_t x_center, fg_coord_t y_center, fg_coord_t x_radius, 
    fg_coord_t y_radius, int start_ang, int end_ang, fg_const_pbox_t clipbox),
  fg_c_readbox(fg_const_pbox_t,fg_color_t *),
  fg_c_writebox(fg_const_pbox_t,const fg_color_t *),
  fg_c_fillbox(fg_color_t,int,int,fg_const_pbox_t),
  fg_c_drawmatrix(fg_color_t,int,int,int,fg_coord_t,fg_coord_t,char *,
    fg_const_pbox_t,fg_const_pbox_t),
  fg_c_blit(fg_const_pbox_t,fg_coord_t,fg_coord_t,int,int),
  fg_c_drawarc(fg_color_t,int,int,fg_coord_t,fg_coord_t,fg_coord_t,int,int,
    fg_const_pbox_t),
  fg_vga_getpalette(fg_color_t color_num, fg_color_t _FAR *red,
                     fg_color_t _FAR *green, fg_color_t _FAR *blue),
  fg_vga_setpalette(fg_color_t, fg_color_t, fg_color_t, fg_color_t),
  fg_misc_term(void),
  fg_zero_colors(void),
  fg_set_dummy(void),
  fg_c_put_handle(fg_handle_t handle),
  fg_c_free_handle(fg_handle_t handle),
  fg_a_putc(fg_color_t,int,int,int,fg_coord_t,fg_coord_t,char,fg_const_pbox_t);

fg_handle_t fg_c_save(fg_const_pbox_t box);

extern char _far fg_font[], _far fg_font2[];

/***********************************
For all values except 0x1130, only the first argument is used.
For 0x1130, the second argument is placed in BH.  This results in
returning a far pointer to a font table.  For VGA compatible boards:

BH == 2 -> A contiguous 8x14 256 entry font table.
BH == 5 -> A contiguous 9x14 256 entry font table.
BH == 6 -> A contiguous 8x16 256 entry font table.
BH == 3 -> A 128 entry 8x8 font table (characters 0 -> 127).
BH == 4 -> A 128 entry 8x8 font table (characters 128 -> 255).

 */
char _far *fg_video_io(int func,...);

#define MY_XMAX 319
#define MY_YMAX 199

/* Convert from x,y to offset into display buffer   */
#if DOS386
extern unsigned short _x386_zero_base_selector;
#define OFFSET(x,y) ((MY_YMAX - (y)) * (MY_XMAX + 1) + (x) + 0xA0000L)
#define BUFFER      _x386_zero_base_selector
#else
#define OFFSET(x,y) ((MY_YMAX - (y)) * (MY_XMAX + 1) + (x))
#define BUFFER      0xA000  /* segment of start of display buffer   */
#endif

/***********************************
 */

static fg_color_t fg_vga13_readdot(x,y)
fg_coord_t x,y;
{ char _far *p;
  fg_msm_hidecursor();

  assert(x >= 0);
  assert(x <= MY_XMAX);
  assert(y >= 0);
  assert(y <= MY_YMAX);

  p = MK_FP(BUFFER,OFFSET(x,y));
  fg_msm_showcursor();
  return *p;
}

/***********************************
 */

static void fg_vga13_drawdot(fg_color_t color, int mode, int mask, 
     fg_coord_t x, fg_coord_t y)
{
  char _far *p;
  fg_msm_hidecursor();

  assert(x >= 0);
  assert(x <= MY_XMAX);
  assert(y >= 0);
  assert(y <= MY_YMAX);

  p = MK_FP(BUFFER,OFFSET(x,y));
  if(mode == FG_MODE_SET)
    *p = (*p & ~mask) | (color & mask);
  else /* FG_MODE_XOR */
    *p ^= color & mask;
  fg_msm_showcursor();
}

/***********************************
 */

static void fg_vga13_drawline(fg_color_t color,int mode,int mask,int line_type,
            fg_const_pline_t line)
{
  fg_coord_t x1, x2, y;
  char _far *p, _far *pend;

  if(line_type != FG_LINE_SOLID || !fg_line_horiz(line))
  {
    fg_c_drawline(color, mode, mask, line_type, line);
    return;
  }

  x1 = line[FG_X1];
  x2 = line[FG_X2];
  if(x1 > x2)
  {
    fg_coord_t temp = x1;

    x1 = x2;
    x2 = temp;
  }

  y = line[FG_Y1];

  assert(x1 >= 0);
  assert(x1 <= MY_XMAX);
  assert(x2 >= 0);
  assert(x2 <= MY_XMAX);
  assert(y >= 0);
  assert(y <= MY_YMAX);

  p = MK_FP(BUFFER,OFFSET(x1,y));
  pend = MK_FP(BUFFER,OFFSET(x2,y));

  fg_msm_hidecursor();

  color &= mask;

  if(mode == FG_MODE_SET)
  {
    if((mask & 0xff) == 0xff)  /* Special, frequent case. */
    {
      do
      {
        *p = color;
      }while(++p <= pend);
    }
    else  /* General case. */
    {
      do
      {
        *p = (*p & ~mask) | color;
      }while(++p <= pend);
    }
  }
  else  /* mode == FG_MODE_XOR */
  {
    do
    {
      *p ^= color;
    }while(++p <= pend);
  }

  fg_msm_showcursor();
}

/***********************************
 * Dummy function for unimplemented routines.
 */

/***********************************
 * Initialization for VGA mode 0x13.
 */

int fg_init_my_vga13()
{
  fg_font_t font;

  fg_set_dummy();       /* Set all function pointers to a dummy function. */
  fg_misc_init();
  fg.display = 0x94;    /* FG_MY_VGA13 */

  /* Set function pointers to point to my routines    */
  fg.init_p = fg_init_my_vga13;  /* subsequent inits go here  */
  fg.readdot_p = fg_vga13_readdot;
  fg.drawdot_p = fg_vga13_drawdot;

  /* No need for flushing a buffer or special termination code. */
  fg.flush_p = fg.msm_flush_p;
  fg.term_p = fg_misc_term;

  fg.fillbox_p = fg_c_fillbox;
  fg.drawmatrix_p = fg_c_drawmatrix;
  fg.readbox_p = fg_c_readbox;
  fg.writebox_p = fg_c_writebox;
  fg.drawline_p = fg_vga13_drawline;    /* My implementation. */
  fg.drawlinep_p = fg_c_drawlinep;
  fg.drawarc_p = fg_c_drawarc;
  fg.drawellipse_p = fg_c_drawellipse;
  fg.putc_p = fg_a_putc;
  fg.blit_p = fg_c_blit;
  fg.setlinepattern_p = fg_c_setlinepattern;
  fg.setpalette_p = fg_vga_setpalette;
  fg.getpalette_p = fg_vga_getpalette;
  fg.save_p = fg_c_save;
  fg.put_handle_p = fg_c_put_handle;
  fg.free_handle_p = fg_c_free_handle;

  /* Do an int 10h with AX equal to 0x1130, BH == 3. */
  font.fontptr = fg_video_io(0x1130,3);   /* 8 x 8 char font. */
  /* Do an int 10h with AX equal to 0x1130, BH == 4. */
  font.fontptr2 = fg_video_io(0x1130,4);
  font.charbox[FG_X1] = 0;
  font.charbox[FG_Y1] = 0;
  font.charbox[FG_X2] = 7;
  font.charbox[FG_Y2] = 7;
  font.baseline = 1;
  fg_set_font(&font);

  fg.displaybox[FG_X1] = 0;
  fg.displaybox[FG_Y1] = 0;
  fg.displaybox[FG_X2] = MY_XMAX;
  fg.displaybox[FG_Y2] = MY_YMAX;   /* screen size      */

  fg.ncolormap = 64L * 64L * 64L;   /* 6 bits for each of red, green, blue. */
  fg.nsimulcolor = 256;

  fg.pixelx = 730;
  fg.pixely = 875;

  fg.numpages = 1;
  fg.activepage = 0;
  fg.displaypage = 0;

  fg_zero_colors(); /* Set all defined colors to -1. */

/* See your graphics adapter programmer's reference for information on this. */
  fg_setcolornum(FG_BLACK, 0);
  fg_setcolornum(FG_BLUE, 1);
  fg_setcolornum(FG_GREEN, 2);
  fg_setcolornum(FG_CYAN, 3);
  fg_setcolornum(FG_RED, 4);
  fg_setcolornum(FG_PURPLE, 5);
  fg_setcolornum(FG_BROWN, 6);
  fg_setcolornum(FG_WHITE, 7);
  fg_setcolornum(FG_GRAY, 8);
  fg_setcolornum(FG_LIGHT_BLUE, 9);
  fg_setcolornum(FG_LIGHT_GREEN, 10);
  fg_setcolornum(FG_LIGHT_CYAN, 11);
  fg_setcolornum(FG_LIGHT_RED, 12);
  fg_setcolornum(FG_LIGHT_MAGENTA, 13);
  fg_setcolornum(FG_YELLOW, 14);
  fg_setcolornum(FG_LIGHT_WHITE, 15);

  /* Go into graphics mode.  int 10h with ax == 0x0013. */
  fg_video_io(0x0013);

  (*fg.msm_init_p)();   /* MUST be after setting of fg.displaybox. */

  return fg.display;
}


#ifdef TEST
/****************************************************************************
A minimumal test suite.  If other low level routines are implemented they
should be tested as well.
****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <conio.h>

#define ESC 27

#define key_waiting() kbhit()
#define key_input() getch()

void terminate(void), clearscreen(void), show_colors(void),
     dot_test(void), color_tile(void), rand_dots();

int main(int argc, char *argv[])
{
  assert (fg_init() == 0x94);

  dot_test();
  rand_dots();
  show_colors();
  color_tile();
  key_input();
  terminate();
}

/********************************
* By supplying this function, no other drivers will be pulled in during the 
* link.  This makes it the smallest possible size.
*/
int fg_init_all(void)
{
  return fg_init_my_vga13();
}

/********************************
 * Terminate, and print results.
 */

void terminate(void)
{ int display = fg.display;

  fg_term();

  printf("fg.display = 0x%X\n",display);
  printf("screen width = %d, height = %d\n",
    fg_box_width(fg.displaybox), fg_box_height(fg.displaybox));
  printf("ncolormap = %ld, nsimulcolor = %d\n", fg.ncolormap, fg.nsimulcolor);
  printf("numpages = %u\n", fg.numpages);
  printf("pixelx = %d, pixely = %d\n", fg.pixelx, fg.pixely);
  printf("char width = %d, height = %d\n",
    fg_box_width(fg.charbox), fg_box_height(fg.charbox));
  printf("FG library version: '%s'\n", fg.version);

  exit(0);
}

/********************************
 * Clear the screen to FG_BLACK
 */
void clearscreen(void)
{
  fg_fillbox(FG_BLACK, FG_MODE_SET, ~0, fg.displaybox);
}

/********************************
 * Helper function for show_colors()
 */
void put_color(fg_color_t c, char *s, fg_coord_t *y, fg_pbox_t b,fg_coord_t h)
{
  fg_puts(c, FG_MODE_SET, ~0, FG_ROT0, 20, *y, s, fg.displaybox);
  fg_fillbox(c, FG_MODE_SET, ~0, b);
  *y += h;
  b [FG_Y1] += h;
  b [FG_Y2] += h;
}

void show_colors(void)
{
  fg_box_t box;
  fg_coord_t y, h = fg_box_height(fg.charbox) * 3;

  h /= 2;

  clearscreen();

  fg_box_cpy(box, fg.charbox);
  box [FG_X2] = 18;
  y = 0;

  if(FG_BLACK != -1)
    put_color(FG_BLACK, "BLACK", &y, box, h);
  if(FG_RED != -1)
    put_color(FG_RED, "RED", &y, box, h);
  if(FG_MAGENTA != -1)
    put_color(FG_MAGENTA, "MAGENTA", &y, box, h);
  if(FG_BLUE != -1)
    put_color(FG_BLUE, "BLUE", &y, box, h);
  if(FG_CYAN != -1)
    put_color(FG_CYAN, "CYAN", &y, box, h);
  if(FG_GREEN != -1)
    put_color(FG_GREEN, "GREEN", &y, box, h);
  if(FG_BROWN != -1)
    put_color(FG_BROWN, "BROWN", &y, box, h);
  if(FG_GRAY != -1)
    put_color(FG_GRAY, "GRAY", &y, box, h);
  if(FG_LIGHT_RED != -1)
    put_color(FG_LIGHT_RED, "LIGHT RED", &y, box, h);
  if(FG_LIGHT_MAGENTA != -1)
    put_color(FG_LIGHT_MAGENTA, "LIGHT MAGENTA", &y, box, h);
  if(FG_LIGHT_BLUE != -1)
    put_color(FG_LIGHT_BLUE, "LIGHT BLUE", &y, box, h);
  if(FG_LIGHT_CYAN != -1)
    put_color(FG_LIGHT_CYAN, "LIGHT CYAN", &y, box, h);
  if(FG_LIGHT_GREEN != -1)
    put_color(FG_LIGHT_GREEN, "LIGHT GREEN", &y, box, h);
  if(FG_YELLOW != -1)
    put_color(FG_YELLOW, "YELLOW", &y, box, h);
  if(FG_WHITE != -1)
    put_color(FG_WHITE, "WHITE", &y, box, h);
  if(FG_LIGHT_WHITE != -1)
    put_color(FG_LIGHT_WHITE, "LIGHT WHITE", &y, box, h);
  if(FG_BLINK != -1)
    put_color(FG_BLINK, "BLINK", &y, box, h);

  if(key_input() == ESC)
    terminate();

  clearscreen();
}

/***********************************
 * Used to guarantee register AX has been trashed, before doing a readdot.
 */

int trash_ret_reg(void)
{
  return rand();
}

/***********************************
 */

void dot_test(void)
{
  fg_coord_t x, y;
  int color, i, mode, j, cc;
  fg_line_t l1;
  fg_box_t b1;
  char outstring[80];
  static char format_str[] = "Dot test, %s mode pass %d.";

#define min(a,b) ((a) < (b) ? (a) : (b))

  b1[FG_X1] = 0;
  b1[FG_X2] = fg.displaybox[FG_X2] / 10;
  b1[FG_Y1] = 0;
  b1[FG_Y2] = min(fg.nsimulcolor*2,fg.displaybox[FG_Y2]-10-fg.charbox[FG_Y2]);

  fg_fillbox(FG_LIGHT_WHITE, FG_MODE_SET, ~0, b1);

  b1[FG_X1] = b1[FG_X2];
  b1[FG_X2] = fg.displaybox[FG_X2];
  b1[FG_Y2] = fg.displaybox[FG_Y2];
  b1[FG_Y1] = b1[FG_Y2] - fg.charbox[FG_Y2];

  mode = FG_MODE_XOR;

  while(1)
  {
    for(j = 1; j <= 2; j++)
    {
      int xx, yy;

      for(color = 0; color < fg.nsimulcolor; color++)
      {
        y = color;
        if(y > fg.displaybox[FG_Y2])
          break;
        for(x = 0; x <= 100 && x <= fg.displaybox[FG_X2]; x++)
        {
          fg_drawdot(color, mode, ~0, x, y);
          if(mode == FG_MODE_SET)
          {
            trash_ret_reg();
            assert(fg_readdot(x, y) == color);
          }
        }
      }
      if(mode == FG_MODE_SET)
        sprintf(outstring, format_str, "SET", j);
      else
        sprintf(outstring, format_str, "XOR", j);

      fg_fillbox(FG_BLACK, FG_MODE_SET, ~0, b1);
      fg_puts(FG_LIGHT_WHITE, FG_MODE_SET, ~0, FG_ROT0, b1[FG_X1], b1[FG_Y1], 
        outstring, fg.displaybox);

      fg_flush();
      switch(key_input())
      {   case ESC:   terminate();
          case '\r':  return;
      }
    }

    if(mode == FG_MODE_SET)
      break;
    else
      mode = FG_MODE_SET;
  }
}

/**********************************
 * Draw color tiles.
 */

void color_tile(void)
{ int color;
  fg_box_t b;
  fg_coord_t x,y,stepx,stepy;

  stepy = fg_box_height(fg.displaybox) / 16;
  stepx = stepy;
  color = 0;
  for(x = fg.displaybox[FG_X1]; x + stepx - 1 <= fg.displaybox[FG_X2]; 
      x += stepx)
  {
    for(y = fg.displaybox[FG_Y1]; y + stepy - 1 <= fg.displaybox[FG_Y2]; 
        y += stepy)
    {   b[FG_X1] = x;
        b[FG_Y1] = y;
        b[FG_X2] = x + stepx - 1;
        b[FG_Y2] = y + stepy - 1;
        fg_fillbox(color,FG_MODE_SET,~0,b);
        color++;
        if(color >= fg.nsimulcolor)
          return;
    }
  }
}
/**********************************
 * Another dot test.
 */
void rand_dots(void)
{
  while(!key_waiting())
  { fg_coord_t x,y;
    int draw_color, last_color;

    x = rand() % fg_box_width(fg.displaybox);
    y = rand() % fg_box_height(fg.displaybox);

    trash_ret_reg();
    last_color = fg_readdot(x,y);
    draw_color = rand() % fg.nsimulcolor;
    fg_drawdot(draw_color, FG_MODE_XOR, ~0, x, y);

    /* Verify that we can read back what we wrote */
    trash_ret_reg();
    assert(fg_readdot(x,y) == (last_color ^ draw_color));

    fg_drawdot(draw_color, FG_MODE_SET, ~0, x, y);
    assert(fg_readdot(x,y) == draw_color);
  }

  if(key_input() == ESC)
    terminate();
}

#endif

