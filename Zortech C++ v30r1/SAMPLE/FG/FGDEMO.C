/*_ fgdemo.c */
/* Copyright Prototronics */
/* 6490 Kaniksu Shores Circle */
/* Sandpoint, ID  83864-9445 */
/* Joe Huffman */
/* September 18, 1990 */
/* FAX:   208-263-8772 */
/* email: fg@proto.com */
/* Modified by Joe Huffman March 30, 1991*/

#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <time.h>
#include <assert.h>
#include <string.h>
#include <limits.h>
#include <fg.h>

struct fg_state *demostate_p = &fg;

/**********************************/
/* Useful macros. */

#define arraysize(array)  (sizeof(array) / sizeof(array[0]))
#define key_waiting() kbhit()
#define key_input() getch()

#define ESC 27

typedef struct {fg_coord_t x, y;} point_t;     /* an (x,y) pair        */
typedef struct {fg_coord_t g_x0, g_y0, g_z0, g_x, g_y, g_z;} three_d_t;
fg_box_t inner_box;

fg_color_t next_color (fg_color_t ex_color);
void beam_bounce (void);
void fancy_lines (void);
void lots_of_boxes (void);
void next_color_init (void), next_color_term (void);
void next_color_setcolormap (void);
fg_pbox_t rand_box (fg_pbox_t to_box, fg_pbox_t outer_box);
void press_any (void);

fg_coord_t star_delta (long int, fg_coord_t, fg_coord_t);
void explode_box (fg_const_pbox_t box);
void fixed_stars (int num, fg_box_t clipbox);
void clearscreen(void);
void stars (void);
void terminate (void);
void border (void);
void demo_text (char *);
void dissolve_demo(void);
void bounce_line (fg_box_t clipbox, int erase);
#define BOUNCE_INIT 0
#define BOUNCE_NORMAL 1
#define BOUNCE_ERASE -1

static char press_any_string [] = "Esc to exit, any other key to continue.";
void demo_functions (void);
void ellipse_demo (void);

typedef long int scale_t;
#define SCALE(a) ((scale_t)(a * 200.0))
#define UNSCALE(a) ((scale_t)((a)/200))
scale_t int_sin (int);
scale_t int_cos (int);
int int_arctan (scale_t slope);

void pyramid(int mode,point_t loc, scale_t scale_x, int phi);
void rotate_pyramids (void);
void blit_demo(void);
void mouse_demo(void);
void demo_fill_patterns(void);

main()
{
  if (fg_init_all () == FG_NULL)
  {
    fputs (
#if DOS386  /* 8514A not supported yet. */
"Unable to initialize graphics display device.\n\
This demo requires a CGA, EGA, VGA, TOSHIBA or Hercules graphics board.\n\
If this program was unable to properly sense the correct graphics board\n\
automatically type \"set FG_DISPLAY=XXXX\" at the DOS prompt where XXXX is one\n\
of the following:\n\
\tCGAHIRES\t\tCGAMEDRES\n\
\tEGAECD\t\t\tEGACOLOR\n\
\tEGALOWRES\t\tEVGAHIRES\n\
\tHERC\t\t\tORCHIDPROHIRES\n\
\tPARADISEHIRES\t\tTRIDENTHIRES\n\
\tVGA11\t\t\tVGA12\n\
\tVGA13\t\t\tVEGAVGAHIRES\n\
\tVESA{0|1|2|3|5|7}\tVESA6A\n\
\tTOSHIBA\n\
\tDFIHIRES\n\n\
Where:\tEGAECD means the EGA card with an enhanced color display.\n\
\tEGACOLOR means the EGA card with a color display.\n\
\tVEGAVGAHIRES means Video 7 Vega VGA card in 800 x 600 mode.\n\
\tVGA11 means the VGA card is to be run in mode 11 (hex).\n\
\tVGA12 means the VGA card is to be run in mode 12 (hex).\netc...", stderr);
#else /* DOS386 */
#if M_UNIX || M_XENIX
"Unable to initialize graphics display device.\n\
This demo requires a EGA or VGA graphics board.\n\
If this program was unable to properly sense the correct graphics board\n\
automatically type \"setenv FG_DISPLAY XXXX\" at the shell prompt where\n\
XXXX is one of the following:\n\
\tEGAECD\t\t\tEGACOLOR\n\
\tVGA12\t\t\tVGA13\n\
Where:\tEGAECD means the EGA card with an enhanced color display.\n\
\tEGACOLOR means the EGA card with a color display.\n\
\tVGA12 means the VGA card is to be run in mode 12 (hex).\netc...\n", stderr);
#else /* M_UNIX || M_XENIX */
"Unable to initialize graphics display device.\n\
This demo requires a CGA, EGA, VGA, 8514A, TOSHIBA or Hercules graphics board.\n\
If this program was unable to properly sense the correct graphics board\n\
automatically type \"set FG_DISPLAY=XXXX\" at the DOS prompt where XXXX is one\n\
of the following:\n\
\tCGAHIRES\t\tCGAMEDRES\n\
\tEGAECD\t\t\tEGACOLOR\n\
\tEGALOWRES\t\tEVGAHIRES\n\
\tHERC\t\t\tORCHIDPROHIRES\n\
\tPARADISEHIRES\t\tTRIDENTHIRES\n\
\tVGA11\t\t\tVGA12\n\
\tVGA13\t\t\tVEGAVGAHIRES\n\
\tVESA{0|1|2|3|5|7}\tVESA6A\n\
\tTOSHIBA\t\t\t8514A\n\
\tDFIHIRES\n\n\
Where:\tEGAECD means the EGA card with an enhanced color display.\n\
\tEGACOLOR means the EGA card with a color display.\n\
\tVEGAVGAHIRES means Video 7 Vega VGA card in 800 x 600 mode.\n\
\tVGA11 means the VGA card is to be run in mode 11 (hex).\n\
\tVGA12 means the VGA card is to be run in mode 12 (hex).\netc...", stderr);
#endif  /* M_UNIX || M_XENIX */
#endif  /* DOS386 */
    exit (1);
  }

  next_color_init ();
  demo_text (press_any_string);
  ellipse_demo ();
  blit_demo();
  clearscreen();
  demo_fill_patterns();
  mouse_demo();
  clearscreen();
  lots_of_boxes ();
  clearscreen();
  border ();
  fixed_stars (200, inner_box);
  stars ();
  dissolve_demo();
  clearscreen();
  rotate_pyramids ();

  demo_text ("Press any key to exit...");
  terminate ();
  return 0;
}

int _FAR dissolve_stop(void)
{
  if(key_waiting())
  {
    do
    {
      if (key_input () == ESC)
        terminate ();
    } while (key_waiting ());

    return 0;   /* Stop. */
  }
  return 1;     /* Keep going. */
}
/****************************************************************************
Helper function for dissolve_demo().  Returns non-zero if specified bit is 
set.
March 30, 1991
****************************************************************************/
int matrix_bit(char *m_p, fg_const_pbox_t box, fg_coord_t x, fg_coord_t y)
{
  int offset = y * ((fg_box_width(box) + 7)/CHAR_BIT) + x/CHAR_BIT;
  unsigned char mask = 1 << ((CHAR_BIT - 1) - (x % CHAR_BIT));

  return m_p[offset] & mask;
}
void dissolve_demo()
{
  static fg_box_t box_dissolve = {0,0,88,16};
#define BOX_WIDTH 89
#define BOX_HEIGHT 17
#define BOX_AREA (BOX_WIDTH * BOX_HEIGHT)
  static char matrix_dissolve [204] =
  {
    0xff,0x06,0x0f,0xc1,0xf8,0x3f,0x83,0x00,0xc0,0x18,0x7f,0x80,	/* XXXXXXXX     XX     XXXXXX     XXXXXX     XXXXXXX     XX        XX         XX    XXXXXXXX */
    0xff,0x86,0x1f,0xc3,0xf8,0x7f,0xc3,0x00,0xc0,0x18,0x7f,0x80,	/* XXXXXXXXX    XX    XXXXXXX    XXXXXXX    XXXXXXXXX    XX        XX         XX    XXXXXXXX */
    0xc1,0x86,0x18,0x03,0x00,0x60,0xc3,0x00,0xc0,0x18,0x60,0x00,	/* XX     XX    XX    XX         XX         XX     XX    XX        XX         XX    XX       */
    0xc1,0x86,0x18,0x03,0x00,0x60,0xc3,0x00,0x60,0x30,0x60,0x00,	/* XX     XX    XX    XX         XX         XX     XX    XX         XX       XX     XX       */
    0xc1,0x86,0x18,0x03,0x00,0x60,0xc3,0x00,0x60,0x30,0x60,0x00,	/* XX     XX    XX    XX         XX         XX     XX    XX         XX       XX     XX       */
    0xc1,0x86,0x18,0x03,0x00,0x60,0xc3,0x00,0x60,0x30,0x60,0x00,	/* XX     XX    XX    XX         XX         XX     XX    XX         XX       XX     XX       */
    0xc1,0x86,0x18,0x03,0x00,0x60,0xc3,0x00,0x30,0x60,0x60,0x00,	/* XX     XX    XX    XX         XX         XX     XX    XX          XX     XX      XX       */
    0xc1,0x86,0x18,0x03,0x00,0x60,0xc3,0x00,0x30,0x60,0x60,0x00,	/* XX     XX    XX    XX         XX         XX     XX    XX          XX     XX      XX       */
    0xc1,0x86,0x1f,0xc3,0xf8,0x60,0xc3,0x00,0x30,0x60,0x7c,0x00,	/* XX     XX    XX    XXXXXXX    XXXXXXX    XX     XX    XX          XX     XX      XXXXX    */
    0xc1,0x86,0x00,0xc0,0x18,0x60,0xc3,0x00,0x18,0xc0,0x60,0x00,	/* XX     XX    XX         XX         XX    XX     XX    XX           XX   XX       XX       */
    0xc1,0x86,0x00,0xc0,0x18,0x60,0xc3,0x00,0x18,0xc0,0x60,0x00,	/* XX     XX    XX         XX         XX    XX     XX    XX           XX   XX       XX       */
    0xc1,0x86,0x00,0xc0,0x18,0x60,0xc3,0x00,0x18,0xc0,0x60,0x00,	/* XX     XX    XX         XX         XX    XX     XX    XX           XX   XX       XX       */
    0xc1,0x86,0x00,0xc0,0x18,0x60,0xc3,0x00,0x0d,0x80,0x60,0x00,	/* XX     XX    XX         XX         XX    XX     XX    XX            XX XX        XX       */
    0xc1,0x86,0x00,0xc0,0x18,0x60,0xc3,0x00,0x0d,0x80,0x60,0x00,	/* XX     XX    XX         XX         XX    XX     XX    XX            XX XX        XX       */
    0xc1,0x86,0x00,0xc0,0x18,0x60,0xc3,0x00,0x0d,0x80,0x60,0x00,	/* XX     XX    XX         XX         XX    XX     XX    XX            XX XX        XX       */
    0xff,0x86,0x1f,0xc3,0xf8,0x7f,0xc3,0xfe,0x07,0x00,0x7f,0x80,	/* XXXXXXXXX    XX    XXXXXXX    XXXXXXX    XXXXXXXXX    XXXXXXXXX      XXX         XXXXXXXX */
    0xff,0x06,0x1f,0x83,0xf0,0x3f,0x83,0xfe,0x07,0x00,0x7f,0x80,	/* XXXXXXXX     XX    XXXXXX     XXXXXX      XXXXXXX     XXXXXXXXX      XXX         XXXXXXXX */
    };
  fg_coord_t x, y;
  fg_box_t box;
  fg_color_t text[BOX_AREA], back_color, fore_color;

  back_color = FG_LIGHT_BLUE == -1? FG_BLACK: FG_LIGHT_BLUE;
  fore_color = FG_LIGHT_WHITE;

  fg_fillboxdissolve(FG_WHITE,FG_MODE_SET,~0,fg.displaybox,1000,dissolve_stop);

  for(y = 0; y < BOX_HEIGHT; y++)
  {
    for(x = 0; x < BOX_WIDTH; x++)
    {
      fg_color_t *t_p = &text[y * BOX_WIDTH + x];

      if(matrix_bit(matrix_dissolve,box_dissolve,x,box_dissolve[FG_Y2] - y))
        *t_p = fore_color;
      else
        *t_p = back_color;
    }
  }

  fg_box_cpy(box,box_dissolve);
  x = (fg_box_width(fg.displaybox) - fg_box_width(box_dissolve))/2;
  box[FG_X1] += x;
  box[FG_X2] += x;
  box[FG_Y1] += y = fg_box_height(fg.displaybox)/2;
  box[FG_Y2] += y;

  fg_writeboxdissolve(box, text, 1, dissolve_stop);
  fg_fillboxdissolve(back_color,FG_MODE_SET,~0,fg.displaybox,1000,dissolve_stop);

#undef BOX_WIDTH
#undef BOX_HEIGHT
#undef BOX_AREA
}
void blit_demo(void)
{
  fg_line_t line;
  fg_box_t box;
  fg_coord_t delta_x, x, delta_y, y;
  fg_color_t color = 0;

  clearscreen();
  line[FG_X1] = fg_box_width(fg.displaybox)/2;
  line[FG_Y1] = fg_box_height(fg.displaybox)/2;

  for(y = 0; y <= fg.displaybox[FG_Y2]; y += 10)
  {
    line[FG_Y2] = y;
    line[FG_X2] = 0;
    fg_drawline (next_color (FG_BLACK), FG_MODE_SET, ~0, FG_LINE_SOLID, line);

    line[FG_X2] = fg.displaybox[FG_X2];
    fg_drawline (next_color (FG_BLACK), FG_MODE_SET, ~0, FG_LINE_SOLID, line);
  }

  for(x = 0; x <= fg.displaybox[FG_X2]; x += 10)
  {
    line[FG_X2] = x;
    line[FG_Y2] = 0;
    fg_drawline (next_color (FG_BLACK), FG_MODE_SET, ~0, FG_LINE_SOLID, line);

    line[FG_Y2] = fg.displaybox[FG_Y2];
    fg_drawline (next_color (FG_BLACK), FG_MODE_SET, ~0, FG_LINE_SOLID, line);
  }

  delta_x = fg_box_width(fg.displaybox)/8;
  delta_y = fg_box_height(fg.displaybox)/50;

  for(x = 0; !key_waiting() && x <= fg.displaybox[FG_X2]; x += delta_x)
  {
    fg_box_cpy(box,fg.displaybox);
    box[FG_X1] = x;
    box[FG_X2] = x + delta_x;
    if(box[FG_X2] > fg.displaybox[FG_X2])
      box[FG_X2] = fg.displaybox[FG_X2];
    box[FG_Y1] = box[FG_Y2] - delta_y;
    fg_fillbox(FG_BLACK, FG_MODE_SET, ~0, box);

    box[FG_Y1] = delta_y;

    do
    {
      fg_blit(box,box[FG_X1],0,0,0);
      box[FG_Y2] -= delta_y;
    } while (box[FG_Y2] >= box[FG_Y1] && !key_waiting());
  }
  while(key_waiting())
  {
    if (key_input () == ESC)
      terminate ();
  }
}
void center_string(fg_coord_t y, char _FAR *string)
{
  char _FAR *p = string;

  while(*p) /* Find the length of the string. */
    p++;

  fg_puts(FG_HIGHLIGHT,FG_MODE_SET, ~0, FG_ROT0,
    (fg.displaybox[FG_X2] - ((p - string) * fg_box_width(fg.charbox)))/2, y,
    string, fg.displaybox);
}


void rand_fill_pattern(void)
{
  fg_pattern_t p;
  int i = 15;
  do
  {
    p[i] = rand() & 1? ~rand(): rand();
  } while (i-- >= 0);

  fg_setfillpattern(FG_FILL_USER_DEFINED,p);
}
void polygon_translate(fg_coord_t *pdest,fg_coord_t *psrc,int vertices,
                       fg_coord_t x, fg_coord_t y)
{
  while(vertices-- >= 0)
  {
    *pdest++ = *psrc++ + x;
    *pdest++ = *psrc++ + y;
  }
}

void demo_fill_patterns()
{
  fg_coord_t p0[8], pout[8];
  int fill_type = FG_FILL_PATTERN_MAX;

  /* Initialize the user definable pattern. */
  rand_fill_pattern();

  /* create a origin based polygon (triangle with one corner at 0,0). */
  memset(p0,0,sizeof(p0));
  p0[2] = fg_box_width(fg_displaybox)/5;
  p0[4] = p0[2]/2;
  p0[5] = fg_box_height(fg_displaybox)/4;

  do
  {
    fg_color_t color, erase_color;
    fg_coord_t x, y;
    char *type_p;

    switch(fill_type)
    {
    default:              /* This will initialize things. */
      fill_type = FG_FILL_SOLID;
      type_p = "SOLID";
      x = 0;
      y = 0;
      break;

    case FG_FILL_SOLID:    fill_type = FG_FILL_BSLASH;  type_p = "BSLASH";
      break;

    case FG_FILL_BSLASH:   fill_type = FG_FILL_SLASH;   type_p = "SLASH";
      break;

    case FG_FILL_SLASH:    fill_type = FG_FILL_HATCH;   type_p = "HATCH";
      break;

    case FG_FILL_HATCH:    fill_type = FG_FILL_LINE;    type_p = "LINE";
      x = 0;
      y += fg_box_height(fg_displaybox)/3;
      break;

    case FG_FILL_LINE:     fill_type = FG_FILL_THICK_X; type_p = "THICK_X";
      break;

    case FG_FILL_THICK_X:  fill_type = FG_FILL_THIN_X;  type_p = "THIN_X";
      break;

    case FG_FILL_THIN_X:   fill_type = FG_FILL_SCALE;   type_p = "SCALE";
      break;

    case FG_FILL_SCALE:    fill_type = FG_FILL_WIDEDOT; type_p = "WIDEDOT";
      x = 0;
      y += fg_box_height(fg_displaybox)/3;
      break;

    case FG_FILL_WIDEDOT:  fill_type = FG_FILL_CLOSEDOT;type_p = "CLOSEDOT";
      break;

    case FG_FILL_CLOSEDOT: fill_type = FG_FILL_DIAMOND; type_p = "DIAMOND";
      break;

    case FG_FILL_DIAMOND:  fill_type = FG_FILL_USER_DEFINED; type_p = "USER";
      break;
    }

    fg_puts(FG_HIGHLIGHT,FG_MODE_SET,~0,FG_ROT0,x,y,type_p,fg.displaybox);
    polygon_translate(pout,p0,3,x,y + fg_box_height(fg.charbox) + 2);
    fg_fillpolygonpattern(FG_HIGHLIGHT,FG_MODE_SET,~0,3,pout,fg.displaybox,
      fill_type);

    color = erase_color = 0;
    while(fill_type == FG_FILL_USER_DEFINED && !key_waiting())
    {
      rand_fill_pattern();
      color = (color + 1) % fg.nsimulcolor;

      if(color == erase_color)
      {
        /* Test for a signed or signed number underflow. */
        if(--erase_color < 0 || erase_color > fg.nsimulcolor)
          erase_color = fg.nsimulcolor - 1;
      }
      fg_flush();
      sleep(2);
      fg_fillpolygon(erase_color,FG_MODE_SET,~0,3,pout,fg.displaybox);
      fg_fillpolygonpattern(color,FG_MODE_SET,~0,3,pout,fg.displaybox,
        fill_type);
    }
    x += fg_box_width(fg.displaybox)/4;
  } while(fill_type != FG_FILL_USER_DEFINED);

  do
  {
    if (key_input () == ESC)
      terminate ();
  } while (key_waiting ());

  return;
}
#ifdef __OS2__  /* No support for mouse under OS2. */

void mouse_demo(void)
{
}

#else

/****************************************************************************
A simple demo of the mouse capabilities.
April 10, 1990
****************************************************************************/

char bat_matrix[48] =
{
 /* This is drawn with the X's set to WHITE, blanks are unchanged. */

  0x00,0x0a,0x00,0x00,  /*             X X             */
  0x00,0x0e,0x00,0x00,  /*             XXX             */
  0x02,0x15,0x08,0x00,  /*       X    X X X    X       */
  0x07,0x9f,0x3c,0x00,  /*      XXXX  XXXXX  XXXX      */
  0x0f,0xff,0xfe,0x00,  /*     XXXXXXXXXXXXXXXXXXX     */
  0x1f,0xff,0xff,0x00,  /*    XXXXXXXXXXXXXXXXXXXXX    */
  0x3f,0xff,0xff,0x80,  /*   XXXXXXXXXXXXXXXXXXXXXXX   */
  0x7f,0xff,0xff,0xc0,  /*  XXXXXXXXXXXXXXXXXXXXXXXXX  */
  0xc7,0x3b,0x9c,0x60,  /* XX   XXX  XXX XXX  XXX   XX */
  0x82,0x11,0x08,0x20,  /* X     X    X   X    X     X */
  0x00,0x11,0x00,0x00,  /*            X   X            */
  0x00,0x2a,0x80,0x00   /*           X X X X           */
};

char arrow_matrix[15] =
{
  0x80,  /* X        */
  0xc0,  /* XX       */
  0xe0,  /* XXX      */
  0xf0,  /* XXXX     */
  0xf8,  /* XXXXX    */
  0xfc,  /* XXXXXX   */
  0xfe,  /* XXXXXXX  */
  0xff,  /* XXXXXXXX */
  0xfc,  /* XXXXXX   */
  0xf8,  /* XXXXX    */
  0xf8,  /* XXXXX    */
  0xcc,  /* XX  XX   */
  0x8c,  /* X   XX   */
  0x06,  /*      XX  */
  0x06,  /*      XX  */
};

fg_msm_cursor_t bat  = {bat_matrix, {0,0,26,11}, 13, 11};
fg_msm_cursor_t arrow = {arrow_matrix,{0,0,7,14}, 0, 14};

void mouse_demo(void)
{
  clearscreen();

  if(fg.msm)
  {
    unsigned int status, last_status = 0xffff;
    fg_box_t status_box;
    static char bat_string[] = "BAT";
    static char arrow_string[] = "ARROW";
    fg_box_t bat_select, arrow_select;
    fg_coord_t x, y, temp;
    int in_char, active_page = 0;
    char done = 0;

    /* Make a box for selecting the bat cursor. */
    bat_select[FG_X1] = 0;
    bat_select[FG_X2] = sizeof(bat_string) * fg_box_width(fg.charbox);

    bat_select[FG_Y2] = fg.displaybox[FG_Y2] - 2 * fg_box_height(fg.charbox);;
    bat_select[FG_Y1] = bat_select[FG_Y2] - fg_box_height(fg.charbox);

    /* Make a box for selecting the arrow cursor. */
    fg_box_cpy(arrow_select, bat_select);
    arrow_select[FG_X2] = sizeof(arrow_string) * fg_box_width(fg.charbox);

    /* Put the boxes at the correct locations. */
    temp = fg_box_width(fg.displaybox)/2;
    bat_select[FG_X1] += temp;
    bat_select[FG_X2] += temp;
    temp -= arrow_select[FG_X2] + fg_box_width(fg.charbox);

    arrow_select[FG_X1] += temp;
    arrow_select[FG_X2] += temp;

    /* Fill in the cursor select boxes on the screen. */
    fg_fillbox(FG_HIGHLIGHT, FG_MODE_SET, ~0, arrow_select);
    fg_fillbox(FG_HIGHLIGHT, FG_MODE_SET, ~0, bat_select);

    temp = fg_box_width(fg.charbox)/2;
    fg_puts(FG_HIGHLIGHT, FG_MODE_XOR, ~0, FG_ROT0, arrow_select[FG_X1] + temp,
      arrow_select[FG_Y1], arrow_string, fg.displaybox);
    fg_puts(FG_HIGHLIGHT, FG_MODE_XOR, ~0, FG_ROT0, bat_select[FG_X1] + temp,
      bat_select[FG_Y1], bat_string, fg.displaybox);

    center_string(fg.displaybox[FG_Y2]-fg_box_height(fg.charbox),
                  "Left button selects cursor.");
    center_string(3 * fg_box_height(fg.charbox), 
"Press F1, F2, F3 to query presses.");
    center_string(2 * fg_box_height(fg.charbox), 
"Press ^F1, ^F2, ^F3 to query releases.");
    center_string(fg_box_height(fg.charbox),
                  "Press mouse button(s) to change status.");

    fg_msm_setcurpos(fg_box_width(fg_displaybox)/2,
      fg_box_height(fg_displaybox)/2);
    fg_msm_showcursor();
    fg_flush();

    fg_box_cpy(status_box,fg.displaybox);
    status_box[FG_Y2] = fg.charbox[FG_Y2];

    do
    {
      static char press_format[] = "status %d, %u presses, last @%d,%d.";
      static char release_format[] = "status %d, %u releases, last @%d,%d.";
      char out_string[50];
      unsigned int count;
      static unsigned int ratio_x = 8, ratio_y = 16;

      do
      {
        status = fg_msm_getstatus(&x, &y);

        if(status != last_status)
        {
          static char motion = 1;   /* The default. */

          if(status & FG_MSM_RIGHT)
          {
            motion = ++motion % 2;
            fg_msm_motion(motion);
          }

          if(status & FG_MSM_LEFT)
          {
            if(fg_pt_inbox(bat_select,x,y))
            {
              fg_msm_setcursor(bat);
            }else
            if(fg_pt_inbox(arrow_select,x,y))
            {
              fg_msm_setcursor(arrow);
            }
          }

          sprintf(out_string, "status:%x, motion:%d, x:%d, y:%d", status,
            motion,x,y);
          fg_fillbox(FG_BLACK,FG_MODE_SET, ~0, status_box);
          center_string(0, out_string);
          fg_flush();
          last_status = status;
        }
      } while(!key_waiting());

      in_char = key_input();
      if (in_char == 0)             /* Extended key, function key, whatever. */
        in_char = key_input() << 8;

#define F1     (59 << 8)
#define F2     (60 << 8)
#define F3     (61 << 8)
#define F4     (62 << 8)
#define CTRLF1 (94 << 8)
#define CTRLF2 (95 << 8)
#define CTRLF3 (96 << 8)
#define CTRLF4 (97 << 8)
#define UP     (72 << 8)
#define DOWN   (80 << 8)

      out_string[0] = '\0';
      switch (in_char)
      {
      case ESC:
        terminate();
        break;
      case F1:
        count = FG_MSM_LEFT;
        status = fg_msm_getpress(&count, &x, &y);
        sprintf(out_string, press_format, status, count, x, y);
        break;
      case F2:
        count = FG_MSM_MIDDLE;
        status = fg_msm_getpress(&count, &x, &y);
        sprintf(out_string, press_format, status, count, x, y);
        break;
      case F3:
        count = FG_MSM_RIGHT;
        status = fg_msm_getpress(&count, &x, &y);
        sprintf(out_string, press_format, status, count, x, y);
        break;
      case F4:
        active_page = (active_page + 1) % fg.numpages;
        fg_setactivepage(active_page);
        fg_flush();
        break;
      case CTRLF4:
        fg_setdisplaypage(active_page);
        fg_flush();
        break;
      case CTRLF1:
        count = FG_MSM_LEFT;
        status = fg_msm_getrelease(&count, &x, &y);
        sprintf(out_string, release_format, status, count, x, y);
        break;
      case CTRLF2:
        count = FG_MSM_MIDDLE;
        status = fg_msm_getrelease(&count, &x, &y);
        sprintf(out_string, release_format, status, count, x, y);
        break;
      case CTRLF3:
        count = FG_MSM_RIGHT;
        status = fg_msm_getrelease(&count, &x, &y);
        sprintf(out_string, release_format, status, count, x, y);
        break;
      case UP:      /* Higher numbers mean slower mouse. */
        if(ratio_y < UINT_MAX/2)
        {
          ratio_x *= 2;
          ratio_y *= 2;
        }
        fg_msm_setratio(ratio_x, ratio_y);
        break;
      case DOWN:    /* Lower numbers mean faster mouse. */
        if(ratio_x > 1)
        {
          ratio_x /= 2;
          ratio_y /= 2;
        }
        fg_msm_setratio(ratio_x, ratio_y);
        break;
      default:
        done = 1;
        break;
      }
      if(out_string[0])
      {
        fg_fillbox(FG_BLACK,FG_MODE_SET, ~0, status_box);
        center_string(0, out_string);
        fg_flush();
      }
    } while(!done);

    fg_msm_hidecursor();

    while (key_waiting ())
    {
      if (key_input () == ESC)
        terminate ();
    }
  }
  else
  {
    static char no_mouse[] = "No mouse present.";
    fg_puts(FG_HIGHLIGHT, FG_MODE_SET, ~0, FG_ROT0, 
      (fg.displaybox[FG_X2] -
      (sizeof(no_mouse) - 1) * fg_box_width(fg.charbox))/2,
      fg_box_height(fg.charbox), no_mouse, fg.displaybox);

    if (key_input () == ESC)
      terminate ();
  }
}
#endif /* __OS2__ */

void clearscreen(void)
{
    fg_fillbox (FG_BLACK, FG_MODE_SET, ~0, fg.displaybox);
}

/**********************************
Ask the user to press a key to continue.
**********************************/
void press_any (void)
{
  fg_color_t color;
  fg_box_t string_box;

  fg_box_cpy (string_box, fg.charbox);

  string_box [FG_X1] = (fg_box_width (fg.displaybox) -
      sizeof (press_any_string) * fg_box_width (fg.charbox))/2;
  if (string_box[FG_X1] < fg.displaybox[FG_X1])
    string_box[FG_X1] = fg.displaybox[FG_X1];

  string_box [FG_X2] = (fg.displaybox [FG_X2] +
      sizeof (press_any_string) * fg_box_width (fg.charbox))/2;
  if (string_box[FG_X2] > fg.displaybox[FG_X2])
    string_box[FG_X2] = fg.displaybox[FG_X2];

  fg_fillbox (FG_BLACK, FG_MODE_SET, ~0, string_box);

  fg_puts (FG_HIGHLIGHT, FG_MODE_SET, ~0, FG_ROT0, string_box [FG_X1], 0,
         press_any_string, fg.displaybox);

  fg_flush ();
  do
  {
    if (key_input () == ESC)
      terminate ();
  } while (key_waiting ());
}
/**********************************
A demo of ellispes...
**********************************/
void ellipse_demo (void)
{
  fg_coord_t x, y, x_radius, y_radius;
  fg_box_t small_box;

  clearscreen();

  small_box [FG_X1] = fg_box_width (fg.displaybox)/4;
  small_box [FG_X2] = 3 * small_box [FG_X1];

  small_box [FG_Y1] = fg_box_height (fg.displaybox)/4;
  small_box [FG_Y2] = 3 * small_box [FG_Y1];
  fg_drawbox (FG_HIGHLIGHT,FG_MODE_SET, ~0,
     FG_LINE_DASH_DOTTED, small_box, fg.displaybox);

  x_radius = fg_box_width (small_box)/2;

  x = fg.displaybox [FG_X2]/2;
  y = fg.displaybox [FG_Y2]/2;

  do
  {
    long int temp;

    x_radius -= 5;
    y -= 2;

    temp = ((long int) (x_radius)) * fg.pixelx;
    y_radius = temp/((long int)fg.pixely);

    fg_drawellipse (next_color (FG_BLACK), FG_MODE_SET, ~0, x, y, x_radius,
       y_radius, 0, 3600, small_box);
    fg_flush();
  } while (x_radius > 0 && !key_waiting ());

  press_any ();

  clearscreen();
  x = fg_box_width (fg.displaybox)/2;
  y = fg_box_height (fg.displaybox)/5;
  x_radius = 0;

  do
  {
    fg_color_t color = next_color (FG_BLACK);
    long int temp = ((long int) (x_radius)) * fg.pixelx;
    y_radius = temp/((long int)fg.pixely);

    fg_drawellipse (color, FG_MODE_SET, ~0, x, y, x_radius,
       y_radius/2, 1800, 3600, fg.displaybox);

    fg_drawellipse (color, FG_MODE_SET, ~0, x, y, x_radius,
       y_radius * 2, 0, 1800, fg.displaybox);

    x_radius += 3;
    fg_flush();
  } while (x_radius < fg.displaybox [FG_X2]/2 &&
           y_radius < fg.displaybox [FG_Y2]/4 && !key_waiting ());

  beam_bounce ();   /* Continues until a key is input. */

  do
  {
    if (key_input () == ESC)
      terminate ();
  } while (key_waiting ());
}
/**********************************
"Radar" beam bouncing around.  Continues until a key is input.
**********************************/
void beam_bounce (void)
{
  scale_t slope;
  int start_angle, end_angle;
  fg_coord_t radius, x, y, diag_len;

  slope = SCALE (fg_box_height (fg.displaybox));
  slope /= fg_box_width (fg.displaybox);
  diag_len = SCALE(fg_box_width (fg.displaybox))/int_cos (int_arctan (slope));

  do
  {
    next_color_init ();

    start_angle = int_arctan (slope) * 10;
    end_angle = start_angle + 100;
    start_angle -= 100;

    x = fg.displaybox [FG_X1];
    y = fg.displaybox [FG_Y1];

    radius = 0;
    do
    {
      fg_drawarc (next_color (FG_BLACK), FG_MODE_XOR, ~0, x, y, radius,
        start_angle, end_angle, fg.displaybox);
      fg_flush();
      radius += 10;
    } while (radius <= diag_len && radius < 720);

    x = fg.displaybox [FG_X2];
    y = fg.displaybox [FG_Y2];

    radius = 0;
    do
    {
      fg_drawarc (next_color (FG_BLACK), FG_MODE_XOR, ~0, x, y, radius,
        2600, 2700, fg.displaybox);

      fg_flush();
      radius += 10;
    } while (radius <= fg.displaybox [FG_Y2]);


    x = fg.displaybox [FG_X2];
    y = fg.displaybox [FG_Y1];

    start_angle = int_arctan (-slope) * 10;
    end_angle = start_angle + 100;
    start_angle -= 100;

    radius = 0;
    do
    {
      fg_drawarc (next_color (FG_BLACK), FG_MODE_XOR, ~0, x, y, radius,
        start_angle, end_angle, fg.displaybox);

      fg_flush();
      radius += 10;
    } while (radius <= diag_len && radius < 720);

    x = fg.displaybox [FG_X1];
    y = fg.displaybox [FG_Y2];

    radius = 0;

    do
    {
      fg_drawarc (next_color (FG_BLACK), FG_MODE_XOR, ~0, x, y, radius,
        2700, 2800, fg.displaybox);

      fg_flush();
      radius += 10;
    } while (radius <= fg.displaybox [FG_Y2]);

    fg_flush ();
  } while (!key_waiting ());
}
/**********************************
Lots of boxes, very fast.
**********************************/
void lots_of_boxes (void)
{
  fg_box_t box;
  const int n_col = fg.nsimulcolor;

  do
  {
    fg_fillbox (rand() % n_col, FG_MODE_SET, ~0, rand_box(box, fg.displaybox));
    fg_flush ();
  } while (!key_waiting ());

  do
  {
    if (key_input () == ESC)
      terminate ();
  } while (key_waiting ());
}
/**********************************
Create a new box that fits inside of outer_box but of random size.
**********************************/
fg_pbox_t rand_box (to_box, outer_box)
fg_pbox_t to_box, outer_box;
{
  to_box [FG_X2] = (rand () % (fg_box_width (outer_box) - 1)) + 1;
  to_box [FG_Y2] = (rand () % (fg_box_height (outer_box) - 1)) + 1;

  to_box [FG_X1] = rand () % to_box [FG_X2];
  to_box [FG_Y1] = rand () % to_box [FG_Y2];

  to_box [FG_X1] += outer_box [FG_X1];
  to_box [FG_X2] += outer_box [FG_X1];
  to_box [FG_Y1] += outer_box [FG_Y1];
  to_box [FG_Y2] += outer_box [FG_Y1];

  return to_box;
}
/**********************************
Some fancy looking lines.
**********************************/
void fancy_lines (void)
{
  fg_line_t line;

  border ();

  line [FG_X1] = line [FG_X2] = inner_box [FG_X1];
  line [FG_Y1] = inner_box [FG_Y1];
  line [FG_Y2] = inner_box [FG_Y2];

  do
  {
    fg_drawline (next_color (FG_BLACK), FG_MODE_SET, ~0, FG_LINE_SOLID, line);
    line [FG_X2] += 10;
    line [FG_Y1] += 10;
  } while (line [FG_X2] < inner_box [FG_X2] &&
           line [FG_Y1] < inner_box [FG_Y2]);

  line [FG_X1] = line [FG_X2] = inner_box [FG_X2];
  line [FG_Y1] = inner_box [FG_Y1];
  line [FG_Y2] = inner_box [FG_Y2];

  do
  {
    fg_drawline (next_color (FG_BLACK), FG_MODE_SET, ~0, FG_LINE_SOLID, line);
    line [FG_X1] -= 10;
    line [FG_Y2] -= 10;
  } while (line [FG_X1] > inner_box [FG_X1] &&
           line [FG_Y2] > inner_box [FG_Y1]);
}
/**********************************
The title of the program.
**********************************/
void demo_text (press_any_string)
char *press_any_string;
{
  static fg_box_t flash_box = {0,0,65,12};
  static char flash_matrix[117] =
{
0x7f,0xe2,0x00,0x00,0x40,0x0f,0xf0,0x80,0x40,	/*  XXXXXXXXXX   X                  X          XXXXXXXX    X        X */
0x80,0x02,0x00,0x00,0x40,0x10,0x08,0x80,0x40,	/* X             X                  X         X        X   X        X */
0x80,0x02,0x00,0x00,0xa0,0x10,0x08,0x80,0x40,	/* X             X                 X X        X        X   X        X */
0x80,0x02,0x00,0x00,0xa0,0x10,0x00,0x80,0x40,	/* X             X                 X X        X            X        X */
0x80,0x02,0x00,0x01,0x10,0x10,0x00,0x80,0x40,	/* X             X                X   X       X            X        X */
0x80,0x02,0x00,0x01,0x10,0x10,0x00,0x80,0x40,	/* X             X                X   X       X            X        X */
0xff,0x02,0x00,0x02,0x08,0x0f,0xf0,0xff,0xc0,	/* XXXXXXXX      X               X     X       XXXXXXXX    XXXXXXXXXX */
0x80,0x02,0x00,0x03,0xf8,0x00,0x08,0x80,0x40,	/* X             X               XXXXXXX               X   X        X */
0x80,0x02,0x00,0x04,0x04,0x00,0x08,0x80,0x40,	/* X             X              X       X              X   X        X */
0x80,0x02,0x00,0x04,0x04,0x00,0x08,0x80,0x40,	/* X             X              X       X              X   X        X */
0x80,0x02,0x00,0x08,0x02,0x10,0x08,0x80,0x40,	/* X             X             X         X    X        X   X        X */
0x80,0x02,0x00,0x08,0x02,0x10,0x08,0x80,0x40,	/* X             X             X         X    X        X   X        X */
0x80,0x01,0xff,0x10,0x01,0x0f,0xf0,0x80,0x40,	/* X              XXXXXXXXX   X           X    XXXXXXXX    X        X */
};

static fg_box_t graphics_box = {0,0,92,12};
static char graphics_matrix[156] =
{
0x7f,0xc1,0xfc,0x00,0x80,0x3f,0x84,0x04,0x7c,0x3f,0x07,0xf0,	/*  XXXXXXXXX     XXXXXXX          X         XXXXXXX    X       X   XXXXX    XXXXXX     XXXXXXX  */
0x80,0x22,0x02,0x01,0x40,0x20,0x44,0x04,0x10,0x40,0x88,0x08,	/* X         X   X       X        X X        X      X   X       X     X     X      X   X       X */
0x80,0x22,0x02,0x01,0x40,0x20,0x44,0x04,0x10,0x40,0x08,0x00,	/* X         X   X       X        X X        X      X   X       X     X     X          X         */
0x80,0x02,0x02,0x02,0x20,0x20,0x44,0x04,0x10,0x40,0x08,0x00,	/* X             X       X       X   X       X      X   X       X     X     X          X         */
0x80,0x02,0x02,0x02,0x20,0x20,0x44,0x04,0x10,0x40,0x08,0x00,	/* X             X       X       X   X       X      X   X       X     X     X          X         */
0x80,0x02,0x02,0x04,0x10,0x20,0x44,0x04,0x10,0x40,0x08,0x00,	/* X             X       X      X     X      X      X   X       X     X     X          X         */
0x80,0x03,0xfc,0x04,0x10,0x3f,0x87,0xfc,0x10,0x40,0x07,0xf0,	/* X             XXXXXXXX       X     X      XXXXXXX    XXXXXXXXX     X     X           XXXXXXX  */
0x83,0xc2,0x02,0x0f,0xf8,0x20,0x04,0x04,0x10,0x40,0x00,0x08,	/* X     XXXX    X       X     XXXXXXXXX     X          X       X     X     X                  X */
0x80,0x22,0x02,0x08,0x08,0x20,0x04,0x04,0x10,0x40,0x00,0x08,	/* X         X   X       X     X       X     X          X       X     X     X                  X */
0x80,0x22,0x02,0x10,0x04,0x20,0x04,0x04,0x10,0x40,0x00,0x08,	/* X         X   X       X    X         X    X          X       X     X     X                  X */
0x80,0x22,0x02,0x10,0x04,0x20,0x04,0x04,0x10,0x40,0x00,0x08,	/* X         X   X       X    X         X    X          X       X     X     X                  X */
0x80,0x22,0x02,0x20,0x02,0x20,0x04,0x04,0x10,0x40,0x80,0x08,	/* X         X   X       X   X           X   X          X       X     X     X      X           X */
0x7f,0xc2,0x02,0x20,0x02,0x20,0x04,0x04,0x7c,0x3f,0x07,0xf0,	/*  XXXXXXXXX    X       X   X           X   X          X       X   XXXXX    XXXXXX     XXXXXXX  */
};

#if M_UNIX || M_XENIX
  static char support_string [] = "Supports EGA and VGA.";
#else
#if !__OS2__
  static char support_string [] = "Supports [C|E|V]GA, TIGA, and Hercules.";
#else
  static char support_string [] = "Supports CGA, EGA, VGA, and Hercules.";
#endif
#endif
  static char demo_string [] = "Demo program for:";
  fg_coord_t x, y;
  char *cptr, out_str [81];

  clearscreen();
  fancy_lines ();

  x = (fg.displaybox [FG_X2] -
      arraysize (demo_string) * fg_box_width(fg.charbox))/2;
  y = fg_box_height (fg.displaybox)/4;
  y *= 3;

  fg_puts (FG_HIGHLIGHT, FG_MODE_SET, ~0, FG_ROT0, x, y, demo_string, 
    fg.displaybox);

  x = (fg_box_width (fg.displaybox) - fg_box_width (flash_box))/2;
  y -= fg_box_height (flash_box) + fg_box_height (fg.charbox)/2;
  fg_drawmatrix (next_color (FG_BLACK), FG_MODE_SET, ~0, FG_ROT0, x, y,
      flash_matrix, flash_box, fg.displaybox);

  x = (fg_box_width (fg.displaybox) - fg_box_width (graphics_box))/2;
  y -= fg_box_height (graphics_box) + fg_box_height (fg.charbox)/2;
  fg_drawmatrix (next_color (FG_BLACK), FG_MODE_SET, ~0, FG_ROT0, x, y,
      graphics_matrix, graphics_box, fg.displaybox);

  x = (fg_box_width (fg.displaybox) -
      sizeof (support_string) * fg_box_width (fg.charbox))/2;
  y = fg_box_height (fg.displaybox)/2;

  fg_puts (FG_HIGHLIGHT, FG_MODE_SET, ~0, FG_ROT0, x, y, support_string,
    fg.displaybox);

  switch (fg.display)
  {
#if !(M_UNIX || M_XENIX || __OS2__)
  case FG_ATI61:  /* ATI Wonder: 640 x 400 x 256 colors (mode 0x61). */
    cptr = "ATI Wonder+ mode 0x61 (640 x 400 x 256 colors)";
    break;
  case FG_ATI62:  /* ATI Wonderboard: 640 x 480 x 256 colors (mode 0x62). */
    cptr = "ATI Wonder+ mode 0x62 (640 x 480 x 256 colors)";
    break;
  case FG_ATI63:  /* ATI Wonderboard: 800 x 600 x 256 colors (mode 0x63). */
    cptr = "ATI Wonder+ mode 0x63 (800 x 600 x 256 colors)";
    break;
  case FG_CGAMEDRES:  /* IBM CGA in 320*200 color (mode 0x04)         */
    cptr = "CGA in med res mode";
    break;
  case FG_EGALOWRES:  /* IBM EGA in 320*200 color (mode 0x0D)         */
    cptr = "EGA in low res mode";
    break;
  case FG_VGA13:      /* IBM VGA in 320*200, 256 colors               */
    cptr = "VGA mode 13";
    break;
  case FG_HERCHALF:   /* Hercules monochrome, 1 display page          */
    cptr = "Hercules in Half (one page) mode";
    break;
  case FG_HERCFULL:   /* Hercules monochrome, 2 display pages         */
    cptr = "Hercules in Full (two page) mode";
    break;
  case FG_TOSHIBA:    /* Toshiba J-3100                       */
    cptr = "Toshiba";
    break;
  case FG_8514A:
    cptr = "IBM 8514A";
    break;
  case FG_EVGAHIRES:
    cptr = "Everex EVGA board 800 x 600 mode";
    break;
  case FG_VEGAVGAHIRES:
    cptr = "Video 7 Vega VGA 800 x 600 mode";
    break;
  case FG_PARADISEHIRES:
    cptr = "Paradise VGA 800 x 600 mode";
    break;
  case FG_TRIDENTHIRES:
    cptr = "Trident VGA 800 x 600 mode";
    break;
  case FG_TIGA:
    cptr = "TIGA";
    break;
  case FG_ORCHIDPROHIRES:
    cptr = "Orchid Pro Designer VGA 800 x 600 mode";
    break;
  case FG_DFIHIRES:
    cptr = "Diamond Flower Instruments VGA 800 x 600 mode";
    break;
  case FG_VESA0:      /* VESA super VGA in 640*400, 256 colors         */
    cptr = "VESA VGA mode 100, 640 x 400 x 256 colors";
    break;
  case FG_VESA1:      /* VESA super VGA in 640*480, 256 colors         */
    cptr = "VESA VGA mode 101, 640 x 480 x 256 colors";
    break;
  case FG_VESA2:      /* VESA super VGA in 800*600, 16 colors         */
    cptr = "VESA VGA mode 102, 800 x 600 x 16 colors";
    break;
  case FG_VESA3:      /* VESA super VGA in 800*600, 256 colors         */
    cptr = "VESA VGA mode 103, 800 x 600 x 256 colors";
    break;
  case FG_VESA5:      /* VESA super VGA in 1024*768, 256 colors         */
    cptr = "VESA VGA mode 105, 1024 x 768 x 256 colors";
    break;
  case FG_VESA7:      /* VESA super VGA in 1280*1024, 256 colors         */
    cptr = "VESA VGA mode 107, 1280 x 1024 x 256 colors";
    break;
  case FG_VESA6A:      /* VESA super VGA in 800*600, 16 colors         */
    cptr = "VESA VGA mode 6A, 800 x 600 x 16 colors";
    break;
#endif /* UNIX || XENIX || __OS2__ */

  case FG_CGAHIRES:   /* IBM CGA in 640*200 (mode 0x06)               */
    cptr = "CGA high resolution mode";
    break;
  case FG_EGACOLOR:   /* IBM EGA with regular color display (mode 0x0E)  */
    cptr = "EGA with a IBM Color Display";
    break;
  case FG_EGAMONO:    /* IBM EGA with IBM monochrome monitor (mode 0x0F) */
    cptr = "EGA with a Monochrome Display";
    break;
  case FG_EGAECD:     /* IBM EGA with enhanced color display (mode 0x10) */
    cptr = "EGA with an Enhanced Color Display";
    break;
  case FG_VGA11:      /* IBM VGA in 640*480, 1 color                  */
    cptr = "VGA mode 11, 2 color";
    break;
  case FG_VGA12:      /* IBM VGA in 640*480, 16 colors                */
    cptr = "VGA mode 12, 16 colors";
    break;
  default:
    assert (0);
  }

  sprintf (out_str, "Graphics device: %s.", cptr);
  y -= 2 * fg_box_height (fg.charbox);
  center_string(y, out_str);

  y -= 2 * fg_box_height (fg.charbox);
  center_string(y, "FG library version:");

  y -= 2 * fg_box_height (fg.charbox);
  center_string(y, fg.version);

  y -= 2 * fg_box_height (fg.charbox);
  center_string(y, press_any_string);

#if M_UNIX || M_XENIX
  y -= 2 * fg_box_height (fg.charbox);
  center_string(y, "Use 'Ctrl-Alt Fn' to change multiscreen.");
#endif

  fg_flush ();

  bounce_line (fg.displaybox, BOUNCE_INIT);
  while (!key_waiting ())
    bounce_line (fg.displaybox, BOUNCE_NORMAL);

  do
  {
    if (key_input () == ESC)
      terminate ();
  } while (key_waiting ());
}
/**********************************
And now, an attempt to be clever.
**********************************/
void rotate_pyramids (void)
{
  scale_t size;
  int page;
  int phi;
  point_t loc1, loc2;

  page = 0;
  loc1.x = 0;
  loc2.x = fg.displaybox [FG_X2];
  loc1.y = fg.displaybox [FG_Y2]/2;
  loc2.y = fg.displaybox [FG_Y2]/2;
  phi = 0;

  size = 1;
  while (!key_waiting () && loc2.x > 0)
  {
    if (fg.numpages > 1)    /* If more than one page swap back and forth.*/
    {
      page ^= 1;
      fg_setactivepage (page);  /* Swap output pages. */
    }

    clearscreen();
    pyramid (FG_MODE_SET, loc1, size, phi);
    pyramid (FG_MODE_SET, loc2, size, -phi);
#if 0
    pyramid (FG_MODE_SET, loc1, size/4, -2 * phi);
    pyramid (FG_MODE_SET, loc2, size/4, 2 * phi);
#endif

    if (fg.numpages > 1)    /* If more than one page swap back and forth. */
      fg_setdisplaypage (page);
    loc1.x += 2;
    loc2.x -= 2;
    phi += 5;
    if (phi > 360)
      phi -= 360;

    if (loc2.x > fg.displaybox [FG_X2]/2)
      size++;
    else
      size--;
  }

  while (key_waiting ())
  {
    if (key_input () == ESC)
      terminate ();
  }
}

/**********************************
Draw a three dimensional pyramid.  It is upright when phi is PI/2;
**********************************/
void pyramid (int mode,point_t loc, scale_t scale_x, int phi)
{
#define PYR_POINT 0
#define PYR_BASE1 1
#define PYR_BASE2 2
#define PYR_BASE3 3
#define PYR_BASE4 4
#define PYRAMID_PTS 5

  three_d_t c [PYRAMID_PTS];
  scale_t c_phi, s_phi;
  scale_t scale_y;
  int i, line_style;
  fg_line_t line;
  fg_coord_t d, h, w;

  i = PYRAMID_PTS - 1;
  do
  {
    c[i].g_x0 = c[i].g_y0 = c[i].g_z0 = 0;
  } while (--i >= 0);

  w = fg.displaybox [FG_X2];
  d = fg.displaybox [FG_X2];
  h = fg.displaybox [FG_Y2];

  c [PYR_POINT].g_z0 = h;      /* Point is the height in the z direction. */
  c [PYR_BASE1].g_y0 = d/2;    /* Front corner of the base. */
  c [PYR_BASE3].g_y0 = -d/2;   /* Back corner of the base. */
  c [PYR_BASE4].g_x0 = w/2;    /* Right corner of the base. */
  c [PYR_BASE2].g_x0 = -w/2;   /* Left corner of the base. */

  c_phi = int_cos (phi);
  s_phi = int_sin (phi);

  scale_y = fg.pixelx * scale_x;
  scale_y /= fg.pixely;

  /* Do the coordinate transformation. */
  i = PYRAMID_PTS - 1;
  do
  {
    c[i].g_y = loc.y +
               UNSCALE (scale_y * (UNSCALE (c[i].g_y0 * c_phi) +
               UNSCALE (c[i].g_z0 * s_phi)));
    c[i].g_x = loc.x + UNSCALE (scale_x * c[i].g_x0);
    c[i].g_z = UNSCALE (c[i].g_y0 * s_phi - c[i].g_z0 * c_phi);
  } while (--i >= 0);

  next_color_init ();

  fg_drawellipse (FG_HIGHLIGHT, mode, ~0,
    c[PYR_POINT].g_x, c[PYR_POINT].g_y, (int) (UNSCALE (scale_x * h/16)),
    (int) (UNSCALE (scale_y * h/16)), 0, 3600, fg.displaybox);

#if 0   /* Too slow. */
  fg_fillpattern(c[PYR_POINT].g_x,c[PYR_POINT].g_y,next_color(FG_BLACK),
    FG_HIGHLIGHT,FG_FILL_WIDEDOT);
#endif

  fg_make_line (line, c[PYR_BASE1].g_x, c[PYR_BASE1].g_y, c[PYR_BASE2].g_x,
    c[PYR_BASE2].g_y);
  fg_drawlineclip (next_color (FG_BLACK), mode, ~0, FG_LINE_SOLID, line,
    fg.displaybox);

  fg_make_line (line, c[PYR_BASE1].g_x, c[PYR_BASE1].g_y, c[PYR_BASE4].g_x,
    c[PYR_BASE4].g_y);
  fg_drawlineclip (next_color (FG_BLACK), mode, ~0, FG_LINE_SOLID, line,
    fg.displaybox);

  fg_make_line (line, c[PYR_BASE2].g_x, c[PYR_BASE2].g_y, c[PYR_BASE3].g_x,
    c[PYR_BASE3].g_y);
  fg_drawlineclip (next_color (FG_BLACK), mode, ~0, FG_LINE_SOLID, line,
    fg.displaybox);

  fg_make_line (line, c[PYR_BASE3].g_x, c[PYR_BASE3].g_y, c[PYR_BASE4].g_x,
    c[PYR_BASE4].g_y);
  fg_drawlineclip (next_color (FG_BLACK), mode, ~0, FG_LINE_SOLID, line,
    fg.displaybox);

  if (c[PYR_POINT].g_z <= 0 && c[PYR_BASE1].g_z <= 0)
    line_style = FG_LINE_SPARSE_DOTTED;
  else
    line_style = FG_LINE_SOLID;

  fg_make_line (line, c[PYR_POINT].g_x, c[PYR_POINT].g_y, c[PYR_BASE1].g_x,
    c[PYR_BASE1].g_y);
  fg_drawlineclip (next_color (FG_BLACK), mode, ~0, line_style, line,
    fg.displaybox);

  if (c[PYR_POINT].g_z <= 0 && c[PYR_BASE2].g_z <= 0)
    line_style = FG_LINE_SPARSE_DOTTED;
  else
    line_style = FG_LINE_SOLID;

  fg_make_line (line, c[PYR_POINT].g_x, c[PYR_POINT].g_y, c[PYR_BASE2].g_x,
    c[PYR_BASE2].g_y);
  fg_drawlineclip (next_color (FG_BLACK), mode, ~0, line_style, line,
    fg.displaybox);

  if (c[PYR_POINT].g_z <= 0 && c[PYR_BASE3].g_z <= 0)
    line_style = FG_LINE_SPARSE_DOTTED;
  else
    line_style = FG_LINE_SOLID;

  fg_make_line (line, c[PYR_POINT].g_x, c[PYR_POINT].g_y, c[PYR_BASE3].g_x,
    c[PYR_BASE3].g_y);
  fg_drawlineclip (next_color (FG_BLACK), mode, ~0, line_style, line,
    fg.displaybox);

  if (c[PYR_POINT].g_z <= 0 && c[PYR_BASE4].g_z <= 0)
    line_style = FG_LINE_SPARSE_DOTTED;
  else
    line_style = FG_LINE_SOLID;

  fg_make_line (line, c[PYR_POINT].g_x, c[PYR_POINT].g_y, c[PYR_BASE4].g_x,
    c[PYR_BASE4].g_y);
  fg_drawlineclip (next_color (FG_BLACK), mode, ~0, line_style, line,
    fg.displaybox);

  fg_flush ();
}

void fixed_stars (num, clipbox)
int num;
fg_box_t clipbox;
{
  fg_coord_t temp1, temp2;
  int star;

  temp1 = clipbox [FG_X2] - clipbox [FG_X1];
  temp2 = clipbox [FG_Y2] - clipbox [FG_Y1];
  for (star = num; star; star--)
  {
    fg_coord_t x, y;

    x = (rand () % temp1) + clipbox [FG_X1];
    y = (rand () % temp2) + clipbox [FG_Y1];
    fg_drawdot (next_color (FG_BLACK), FG_MODE_SET, ~0, x, y);
  }
}
#define NUM_STARS 700
#define STAR_TIME 5

typedef struct star
 {
   fg_coord_t x, y, speed; fg_color_t color; struct star *next_star;
 } star_t;

void stars (void)
{
  clock_t t0, t1;
  star_t *list_p, *s_p;
  fg_coord_t mid_x, mid_y, temp1, temp2;
  int num_stars;

  mid_x = (fg.displaybox [FG_X2] + 1)/2;
  mid_y = (fg.displaybox [FG_Y2] + 1)/2;

  num_stars = NUM_STARS;
  s_p = list_p = calloc (sizeof (star_t), 1);

  while (1)
  {
    s_p->color = next_color (FG_BLACK);  /* Pick a color, excluding black. */
    s_p->x = mid_x;
    s_p->y = mid_y;
    s_p->speed = rand () % 8 + 1;
    if (--num_stars)
    {
      s_p->next_star = calloc (sizeof (star_t), 1);
      s_p = s_p->next_star;
    }
    else
    {
      s_p->next_star = (star_t *) NULL;
      break;
    }
  }

  t0 = clock ();
  do
  {
    t1 = clock () - t0;

    for (s_p = list_p; s_p != NULL; s_p = s_p->next_star)
    {
      fg_coord_t delta_x, delta_y;

      /* Erase the star. */
      fg_drawdot (s_p->color, FG_MODE_XOR, ~0, s_p->x, s_p->y);

      /* Move the star. */
      delta_x = star_delta (t1 * s_p->speed, s_p->x, mid_x);
      delta_y = star_delta (t1 * s_p->speed, s_p->y, mid_y);

      if (delta_x == 0 && delta_y == 0)
      {    /* -4, -3, -2, -1, 0, 1, 2, 3, 4 */
        delta_x = (4 - rand () % 9) * s_p->speed;
        delta_y = (4 - rand () % 9) * s_p->speed;
      }

      s_p->x += delta_x;
      s_p->y += delta_y;

      /* Is it time to kill it? */
      if (s_p->x < inner_box [FG_X1] || s_p->x > inner_box [FG_X2] ||
          s_p->y < inner_box [FG_Y1] || s_p->y > inner_box [FG_Y2])
      {
        /* Kill the star (actually just move it to the center). */
        s_p->x = mid_x;
        s_p->y = mid_y;
      }
      else  /* Draw the star again. */
        fg_drawdot (s_p->color, FG_MODE_XOR, ~0, s_p->x, s_p->y);
    }
   /* Do this for a few seconds. */
  } while (!key_waiting () && t1 >= 0 && t1 < STAR_TIME * CLK_TCK);

  /* Free up the memory and give a "star burst". */
  do
  {
    fg_line_t line;

    s_p = list_p;
    list_p = s_p->next_star;

    line [FG_X1] = s_p->x;
    line [FG_Y1] = s_p->y;
    line [FG_X2] = s_p->x + star_delta (10 * t1, s_p->x, mid_x);
    line [FG_Y2] = s_p->y + star_delta (10 * t1, s_p->y, mid_y);

    fg_drawlineclip (s_p->color, FG_MODE_SET, ~0, FG_LINE_SOLID, line,
      inner_box);

    free (s_p);
  } while (list_p != NULL);

  while (key_waiting ())
  {
    if (key_input () == ESC)
      terminate ();
  }
}
/*******************************
Calculate the delta change in position for this coordinate.
*/
fg_coord_t star_delta (speed, p, mid)
long int speed;
fg_coord_t p, mid;
{
  return (speed * (p - mid))/2000;
}

static int next_color_index = 0;
int next_colormap[32] =
   {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1};

/*******************************
Initialize the next color function.
*/
void next_color_init (void)
{
  if (next_color_index == 0)
    next_color_setcolormap ();
  else
    next_color_index = 0;
}
/****************************
Initialize the list of availiable colors.
****************************/
void next_color_setcolormap (void)
{ int i;

  i = 0;
  next_colormap[i++] = FG_BLACK;
  next_colormap[i++] = FG_BLUE;
  next_colormap[i++] = FG_GREEN;
  next_colormap[i++] = FG_CYAN;
/* FG_BLUE_GREEN is the same as CYAN. */
/*  next_colormap[i++] = FG_BLUE_GREEN; */
  next_colormap[i++] = FG_RED;
  next_colormap[i++] = FG_LIGHT_WHITE;
  next_colormap[i++] = FG_MAGENTA;
/* Purple is the same as magenta. */
/*  next_colormap[i++] = FG_PURPLE; */
  next_colormap[i++] = FG_YELLOW;
  next_colormap[i++] = FG_WHITE;

  next_colormap[i++] = FG_GRAY;
  next_colormap[i++] = FG_LIGHT_BLUE;
  next_colormap[i++] = FG_LIGHT_RED;
  next_colormap[i++] = FG_LIGHT_GREEN;
  next_colormap[i++] = FG_LIGHT_CYAN;
/* Light BLUE_GREEN is the same as LIGHT_CYAN. */
/*  next_colormap[i++] = FG_LIGHT_BLUE_GREEN; */
  next_colormap[i++] = FG_LIGHT_MAGENTA;
  next_colormap[i++] = FG_BROWN;

/* normally an intense white  */
/* Same as LIGHT_WHITE */
/*  next_colormap[i++] = FG_HIGHLIGHT; */

/* blinking white   */
  next_colormap[i++] = FG_BLINK;
}
/*******************************
Terminiate the next color package.
*/
void next_color_term (void)
{
  return;
}

/*******************************
 * Pick a color excluding this one color.
 */

fg_color_t next_color (fg_color_t ex_color)
{
  do
  {
    next_color_index++;
    next_color_index %= sizeof(next_colormap)/sizeof(next_colormap[0]);
  } while (next_colormap[next_color_index] == -1 ||
    next_colormap [next_color_index] == ex_color);

  return next_colormap [next_color_index];
}

/**************************************
Bounce a line off the edges of the screen.
**************************************/
void bounce_line (clipbox, erase)
fg_box_t clipbox;
int erase;
{
  static fg_line_t old_line, new_line;
  static fg_color_t old_color, new_color;
  static fg_coord_t vel_x1 = 10, vel_x2 = 15, vel_y1 = 10, vel_y2 = 16;

  if (erase == BOUNCE_INIT)
  {
    new_line[FG_X1] = new_line[FG_Y1] = new_line[FG_X2] = new_line[FG_Y2] = 0;
    new_color = FG_BLACK;
  }

  /* Save the last line. */
  fg_line_cpy (old_line, new_line);
  old_color = new_color;

  /* Create the new line. */
  new_color = next_color (FG_BLACK);
  new_line[FG_X1] += vel_x1; new_line[FG_X2] += vel_x2;
  new_line[FG_Y1] += vel_y1; new_line[FG_Y2] += vel_y2;

  if ((unsigned)new_line[FG_X1] > clipbox[FG_X2])
  {
    fg_coord_t temp;

    new_line[FG_X1] = new_line[FG_X1] > 0? clipbox[FG_X2]: 0;

    vel_x1 = (vel_x1 > 0? -1: 1) * (rand () % 32);

    temp = 32 + (vel_x1 > 0? -vel_x1: vel_x1);
    vel_y1 = vel_y1 > 0? temp: -temp;
  }

  if ((unsigned)new_line[FG_Y1] > clipbox[FG_Y2])
  {
    fg_coord_t temp;

    new_line[FG_Y1] = new_line[FG_Y1] > 0? clipbox[FG_Y2]: 0;

    vel_y1 = (vel_y1 > 0? -1: 1) * (rand () % 32);

    temp = 32 + (vel_y1 > 0? -vel_y1: vel_y1);
    vel_x1 = vel_x1 > 0? temp: -temp;
  }

  if ((unsigned)new_line[FG_X2] > clipbox[FG_X2])
  {
    fg_coord_t temp;

    new_line[FG_X2] = new_line[FG_X2] > 0? clipbox[FG_X2]: 0;

    vel_x2 = (vel_x2 > 0? -1: 1) * (rand () % 32);

    temp = 32 + (vel_x2 > 0? -vel_x2: vel_x2);
    vel_y2 = vel_y2 > 0? temp: -temp;
  }

  if ((unsigned) new_line[FG_Y2] > clipbox [FG_Y2])
  {
    fg_coord_t temp;

    new_line[FG_Y2] = new_line[FG_Y2] > 0? clipbox[FG_Y2]: 0;

    vel_y2 = (vel_y2 > 0? -1: 1) * (rand () % 32);

    temp = 32 + (vel_y2 > 0? -vel_y2: vel_y2);
    vel_x2 = vel_x2 > 0? temp: -temp;
  }

  /* Erase the old line. */
  if (erase != BOUNCE_INIT &&
    (old_line[FG_X1] != old_line[FG_X2] || old_line[FG_Y1] != old_line[FG_Y2]))
  {
    fg_drawline (old_color, FG_MODE_XOR, ~0, FG_LINE_SOLID, old_line);
  }

  /* Draw the new line. */
  if (erase != BOUNCE_ERASE &&
     (new_line[FG_X1] != new_line[FG_X2] || new_line[FG_Y1] != new_line[FG_Y2]))
  {
    fg_drawline (new_color, FG_MODE_XOR, ~0, FG_LINE_SOLID, new_line);
  }
  fg_flush ();
}

/****************************
Terminate gracefully.
****************************/
void terminate (void)
{
  fg_term ();
  exit (0);
}
/****************************
Draw a fancy border around the screen to make the screen look like a view port 
from a "space ship".
****************************/
void border (void)
{
  unsigned int radius;
  int x, y;

  fg_drawbox (FG_HIGHLIGHT, FG_MODE_SET, ~0, FG_LINE_SOLID, fg.displaybox,
    fg.displaybox);

  radius = (fg.displaybox[FG_X2] + 1)/128;

  fg_box_cpy (inner_box, fg.displaybox);
  inner_box [FG_X1] += radius;
  inner_box [FG_X2] -= radius;
  inner_box [FG_Y1] += radius;
  inner_box [FG_Y2] -= radius;

  y = fg.displaybox [FG_Y2];

  for (x = fg.displaybox [FG_X2]; x >= 0; x -= 2 * radius)
  {
    fg_drawarc (next_color (FG_BLACK), FG_MODE_SET, ~0, x, 0, radius, 0, 1800,
       fg.displaybox);
    fg_drawarc(next_color(FG_BLACK), FG_MODE_SET, ~0, x, y, radius, 1800, 3600,
       fg.displaybox);
  }

  x = fg.displaybox [FG_X2];

  for (y = fg.displaybox [FG_Y2]; y >= 0; y -= 2 * radius)
  {
    fg_drawarc (next_color(FG_BLACK), FG_MODE_SET, ~0, 0, y, radius, 2700, 900,
      fg.displaybox);
    fg_drawarc (next_color(FG_BLACK), FG_MODE_SET, ~0, x, y, radius, 900, 2700,
      fg.displaybox);
  }
  fg_drawbox (FG_HIGHLIGHT, FG_MODE_SET, ~0, FG_LINE_SOLID, inner_box,
     fg.displaybox);
}
/*********************************
A black box that smoothly explodes.
*********************************/
void explode_box (fg_const_pbox_t box)
{
  int step, x_mod, y_mod;
  fg_box_t b1;

  assert (fg_box_width (box));
  assert (fg_box_height (box));

  b1 [FG_X2] = b1 [FG_X1] = fg_coord_midpoint(box [FG_X1], box [FG_X2]);
  b1 [FG_Y2] = b1 [FG_Y1] = fg_coord_midpoint(box [FG_Y1], box [FG_Y2]);

  /* Increment both x and y such that both complete at about the same time. */
  x_mod = (3 * fg_box_height (box))/fg_box_width (box);
  if (x_mod == 0)
    x_mod = 1;

  y_mod = (3 * fg_box_width (box))/fg_box_height (box);
  if (y_mod == 0)
    y_mod = 1;

  step = 0;

  do
  {
    fg_drawbox (FG_BLACK, FG_MODE_SET, ~0, FG_LINE_SOLID, b1, fg.displaybox);

    if (++step % y_mod == 0)
    {
      if (b1 [FG_Y1] > box [FG_Y1])
        b1 [FG_Y1]--;
      if (b1 [FG_Y2] < box [FG_Y2])
        b1 [FG_Y2]++;
    }

    if (step % x_mod == 0)
    {
      if (b1 [FG_X1] > box [FG_X1])
        b1 [FG_X1]--;

      if (b1 [FG_X2] < box [FG_X2])
        b1 [FG_X2]++;
    }
  } while (b1 [FG_Y1] != box [FG_Y1] || b1 [FG_Y2] != box [FG_Y2] ||
       b1 [FG_X1] != box [FG_X1] || b1 [FG_X2] != box [FG_X2]);

  fg_drawbox (FG_BLACK, FG_MODE_SET, ~0, FG_LINE_SOLID, b1, fg.displaybox);
}

/*********************************
A look-up table for cosine and sine.
*********************************/
scale_t cos_table [19] = 
  { SCALE (1),      /* 0 degrees. */
    SCALE (.99619), /* 5 degrees. */
    SCALE (.98481), /* 10 degrees. */
    SCALE (.96592), /* 15 degrees. */
    SCALE (.93969), /* 20 degrees. */
    SCALE (.90631), /* 25 degrees. */
    SCALE (.86603), /* 30 degrees. */
    SCALE (.81915), /* 35 degrees. */
    SCALE (.76604), /* 40 degrees. */
    SCALE (.70711), /* 45 degrees. */
    SCALE (.64278), /* 50 degrees. */
    SCALE (.57358), /* 55 degrees. */
    SCALE (.50000), /* 60 degrees. */
    SCALE (.42262), /* 65 degrees. */
    SCALE (.34202), /* 70 degrees. */
    SCALE (.25882), /* 75 degrees. */
    SCALE (.17365), /* 80 degrees. */
    SCALE (.08716), /* 85 degrees. */
    SCALE (0)       /* 90 degrees. */
  };
/*********************************
A look-up table version of cosine.
*********************************/
scale_t int_cos (angle)
int angle;
{
  int quadrant, remainder;
  scale_t answer;

  if (angle < 0)
    angle = - angle;

  angle += 2;   /* Round to the nearest 5 degrees. */
  remainder = (angle % 90)/5;
  quadrant = (angle % 360);

  if (quadrant < 90)
  {
    answer = cos_table [remainder];
  } else
  if (quadrant < 180)
  {
    answer = -cos_table [18 - remainder];
  } else
  if (quadrant < 270)
  {
    answer = -cos_table [remainder];
  } else
  if (quadrant < 360)
    answer = cos_table [18 - remainder];
  else
    assert (0);

  return answer;
}
/*********************************
A look-up table version of sine.
*********************************/
scale_t int_sin (angle)
int angle;
{
  return int_cos (angle - 90);
}
/*********************************
Find the arc tangent.
*********************************/
int int_arctan (slope)
scale_t slope;
{
  int angle;

  angle = 0;
  do
  {
    scale_t cos_answer, test_slope;

    cos_answer = int_cos (angle);

    if (cos_answer == 0)
      continue;

    test_slope = SCALE (int_sin (angle));
    test_slope /= cos_answer;

    if (test_slope > slope &&
       (test_slope >= 0 && slope >= 0 || test_slope < 0 && slope < 0))
    {
      break;
    }

  } while ((angle += 5) < 180);

  return angle;
}
void _FAR _cdecl fg_assert (const char _FAR *e, const char _FAR *f, unsigned int line)
{
  fg_term ();
  printf ("FG ASSERT: '%s', %s line %u", (char *)e, (char *)f, line);
  exit (1);
}

