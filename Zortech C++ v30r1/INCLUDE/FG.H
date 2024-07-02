/* Copyright Prototronics */
/* 6490 Kaniksu Shores Circle */
/* Sandpoint, ID  83864-9445 */
/* Joe Huffman */
/* September 18, 1990 */
/* FAX:   208-263-8772 */
/* email: fg@proto.com */
/* All Rights Reserved */

/* Modified by Joe Huffman December 10, 1990
*/

#ifndef __FG_H
#define __FG_H    1

#ifdef M_I386
#define _FAR
#else
#define _FAR _far
#endif

#if __cplusplus
extern "C" {
#endif

/* Definition of basic coordinate system                */

/************************************
 * Coordinate system (right-handed):
 *
 *           Y2 +
 *              |
 *              |
 *              |
 *           Y1 +-----------+
 *              X1          X2
 *
 * Where:
 *      X1 <= X2
 *      Y1 <= Y2
 */

typedef int fg_coord_t;    /* data type for all coordinates                */

/*****************************
 * Coordinate box.
 *      box[FG_X1] = x coordinate of left edge
 *      box[FG_Y1] = y coordinate of bottom edge
 *      box[FG_X2] = x coordinate of right edge
 *      box[FG_Y2] = y coordinate of top edge
 */

typedef fg_coord_t fg_box_t[4];
typedef fg_coord_t _FAR *fg_pbox_t;             /* pointer to a box         */
typedef fg_coord_t const _FAR *fg_const_pbox_t; /* pointer to a const box   */
typedef fg_coord_t fg_line_t[4];
typedef fg_coord_t _FAR *fg_pline_t;            /* pointer to a line        */
typedef fg_coord_t const _FAR *fg_const_pline_t;/* pointer to a const line  */
typedef unsigned short fg_pattern_t[16];        /* fill pattern data        */
typedef unsigned short _FAR *fg_ppattern_t;     /* Pointer to a pattern type*/

#define FG_X1 0
#define FG_Y1 1
#define FG_X2 2
#define FG_Y2 3

/* Midpoint of 2 coordinates    */
#define fg_coord_midpoint(x1,x2)   (((x1) + (x2)) / 2)

/* Determine # of pixels high a box is  */
#define fg_box_height(b)        ((b)[FG_Y2] - (b)[FG_Y1] + 1)

/* Determine # of pixels wide a box is  */
#define fg_box_width(b) ((b)[FG_X2] - (b)[FG_X1] + 1)

/* The number of bytes to allocate for a matrix with a bounding box 'b'. */
#define fg_matrix_size(b) (sizeof(char)*((b)[FG_X2]+1+7)/8*((b)[FG_Y2]+1))

/* The number of pixels in a box 'b'.  Helpful for calculating memory for
a fg_readbox. */
#define fg_box_area(b) (((long)fg_box_width(b))*((long)fg_box_height(b)))

/* Fill in the coordinates of a line. */
#define fg_make_line(l,x1,y1,x2,y2) ((l)[FG_X1]=(x1),(l)[FG_Y1]=(y1),\
(l)[FG_X2]=(x2),(l)[FG_Y2]=(y2))

/* Fill in the coordinates of a box. */
#define fg_make_box(b,x1,y1,x2,y2) ((b)[FG_X1]=(x1),(b)[FG_Y1]=(y1),\
(b)[FG_X2]=(x2),(b)[FG_Y2]=(y2))

/****** Return TRUE if line is horizontal ******/
#define fg_line_horiz(line) ((line)[FG_Y1] == (line)[FG_Y2])

/****** Return TRUE if line is vertical ******/
#define fg_line_vert(line)      ((line)[FG_X1] == (line)[FG_X2])

/* Determine if line is 0 length    */
#define fg_line_zerolength(ln)\
    ((ln)[FG_X1] == (ln)[FG_X2] && (ln)[FG_Y1] == (ln)[FG_Y2])

/* Copy boxes. */
#define fg_box_cpy(to,from) ((fg_pbox_t)fg_line_cpy((to),(from)))

/* Change the definition of a FG_COLOR. */
/* As in 'fg_setcolornum(FG_WHITE, 7);' */
#define fg_setcolornum(old_color,new_num) ((old_color) = (new_num))

/* Change the motion algorithm.  */
/* 0 is linear, 1 is non-linear.  All other values reserved. */
#define fg_msm_motion(a)  (fg.msm_motion = a)

/* Change the mouse output function. */
#define fg_msm_setoutput(a)  (fg.msm_output_p = a)

/*************************
 * Rotation values:
 */

#define FG_ROT0   0
#define FG_ROT90  1
#define FG_ROT180 2
#define FG_ROT270 3

/*************************
 * Mouse button defines.
 * Status of mouse has these bits set if that button is depressed.
 * 1 if down 0 if up.
 */

#define FG_MSM_LEFT   1
#define FG_MSM_RIGHT  2
#define FG_MSM_MIDDLE 4

typedef struct fg_msm_cursor
{
  char _FAR *matrix;
  fg_box_t box;
  fg_coord_t hot_x, hot_y;
} fg_msm_cursor_t;

typedef struct fg_font
{
  char _far * fontptr;  /* First 128 characters.  */
  char _far * fontptr2; /* Second 128 characters. */
  fg_box_t charbox;
  fg_coord_t baseline;  /* Distance from bottom of char to baseline. */
} fg_font_t;

typedef unsigned char fg_color_t;

typedef struct FG_HANDLE _FAR *fg_handle_t;

/* Defines for the type of display encountered  */
#define FG_NULL     0    /* all graphics are routed to bit bucket        */

/* The following correspond to BIOS video modes:                             */
#ifndef __OS2__
#define FG_CGAMEDRES    4    /* IBM CGA in 320*200 color (mode 0x04)         */
#endif

#define FG_CGAHIRES     6    /* IBM CGA in 640*200 (mode 0x06)               */
#define FG_EGALOWRES    0x0D /* EGA in 320 x 200 x 16 colors (mode 0x0D)     */
#define FG_EGACOLOR     0x0E /* EGA with regular color display (mode 0x0E)   */
#define FG_EGAMONO      0x0F /* EGA with IBM monochrome monitor (mode 0x0F)  */
#define FG_EGAECD       0x10 /* EGA with enhanced color display (mode 0x10)  */
#define FG_VGA11        0x11 /* IBM VGA in 640*480, 1 color                  */
#define FG_VGA12        0x12 /* IBM VGA in 640*480, 16 colors                */

#if !(M_UNIX || __OS2__)
#define FG_ORCHIDPROHIRES 0x29 /* ORCHID PRO DESIGNER VGA 800*600, 16 colors */
#define FG_PARADISEHIRES  0x58 /* PARADISE VGA 800*600, 16 colors            */
#define FG_TRIDENTHIRES   0x5B /* TRIDENT VGA 800*600, 16 colors             */
#define FG_ATI61          0xA61/* ATI 640 x 400, 256 colors.                 */
#define FG_ATI62          0xA62/* ATI 640 x 480, 256 colors.                 */
#define FG_ATI63          0xA63/* ATI 800 x 600, 256 colors.                 */
#define FG_VEGAVGAHIRES   0x62 /* VIDEO 7 VEGA VGA in 800 x 600, 16 colors   */
#define FG_DFIHIRES       0x64 /* Diamond Flower Instruments 800 x 600 x 16  */
#define FG_VESA6A         0x6A /* VESA mode 0x6A, 800 x 600, 16 colors.      */
#define FG_EVGAHIRES      0x70 /* Everex EVGA in 800 x 600, 16 colors        */
#define FG_TOSHIBA        0x74 /* Toshiba J-3100                             */

#define FG_VESA0        0x100/* VESA mode 0x100, 640 x 400, 256 colors.      */
#define FG_VESA1        0x101/* VESA mode 0x101, 640 x 480, 256 colors.      */
#define FG_VESA2        0x102/* VESA mode 0x102, 800 x 600, 16 colors.       */
#define FG_VESA3        0x103/* VESA mode 0x103, 800 x 600, 256 colors.      */
#define FG_VESA5        0x105/* VESA mode 0x105, 1024 x 768, 256 colors.     */
#define FG_VESA7        0x107/* VESA mode 0x107, 1280 x 1024, 256 colors.    */

/* VESA modes not implemented. */
#define FG_VESA4        0x104/* VESA mode 0x104, 1024 x 768, 16 colors.      */
#define FG_VESA6        0x106/* VESA mode 0x106, 1280 x 1024, 16 colors.     */

#define FG_HERCHALF        2 /* Hercules monochrome, 1 display page  */
#define FG_HERCFULL        3 /* Hercules monochrome, 2 display pages */
#define FG_8514A         -10 /* IBM 8514A                            */
#define FG_TIGA         0x340/* Texas Instruments TMS340 Family - TIGA 2.0 */
#endif

#ifndef __OS2__
/* Other values for fg_display: */
#define FG_VGA13          0x13 /* IBM VGA in 320*200, 256 colors             */
#endif /* __OS2__ */

/* Used for filling outlines of pixels, see fg_outlinefill().           */
#define FG_FILL_ON_RIGHT 1  /* Don't change these without careful       */
#define FG_FILL_ON_LEFT  0  /* consideration of the source code. See    */
                            /* the static function delete_excess.       */

/* Collect global variables into a single structure. */
struct fg_state
{
char _FAR *version;
int  (_cdecl _FAR *init_p)(void);
void (_cdecl _FAR *term_p)(void);
void (_cdecl _FAR *msm_flush_p)(void);
void (_cdecl _FAR *msm_hidecursor_p)(void);
void (_cdecl _FAR *msm_init_p)(void);
void (_cdecl _FAR *msm_output_p)(fg_coord_t x, fg_coord_t y);
void (_cdecl _FAR *msm_showcursor_p)(void);
void (_cdecl _FAR *msm_term_p)(void);

#define FG_LINE_MAX     12
  unsigned short int linetype[FG_LINE_MAX];

#define FG_COLOR_MAX    21
  int color[FG_COLOR_MAX];

  short int saddr;
  char _far *fontptr, _far *fontptr2;
  int activepage;
  int displaypage;
  fg_box_t charbox;
  int display;      /* FGxxxxx      */
  fg_box_t displaybox;
  long ncolormap;
  int nsimulcolor;
  int numpages;
  int pixelx, pixely;
/* Function pointers (initialized by fg_init_xxxx())    */
void (_cdecl _FAR *blit_p)(fg_const_pbox_t, fg_coord_t, fg_coord_t,int,int); 
void (_cdecl _FAR *drawarc_p) (fg_color_t,int,int,fg_coord_t,fg_coord_t, 
                  fg_coord_t,int,int,fg_const_pbox_t); 
void (_cdecl _FAR *drawdot_p) (fg_color_t,int,int,fg_coord_t,fg_coord_t); 
void (_cdecl _FAR *drawline_p)(fg_color_t,int,int,int,fg_const_pline_t); 
void (_cdecl _FAR *drawlinep_p)(fg_color_t,int,int,int,fg_const_pline_t); 
void (_cdecl _FAR *drawmatrix_p)  (fg_color_t,int,int,int,fg_coord_t,
                  fg_coord_t,char _FAR *, fg_const_pbox_t,fg_const_pbox_t); 
void (_cdecl _FAR *fillbox_p) (fg_color_t, int, int, fg_const_pbox_t);
void (_cdecl _FAR *flush_p)(void);
void (_cdecl _FAR *putc_p)(fg_color_t,int,int,int,fg_coord_t,
                  fg_coord_t,char,fg_const_pbox_t);
void (_cdecl _FAR *readbox_p) (fg_const_pbox_t, fg_color_t _FAR *);
fg_color_t (_cdecl _FAR *readdot_p)(fg_coord_t,fg_coord_t);
void (_cdecl _FAR *setdisplaypage_p)(unsigned int);
void (_cdecl _FAR *setactivepage_p)(unsigned int);
void (_cdecl _FAR *setlinepattern_p)(int, int);
void (_cdecl _FAR *writebox_p)(fg_const_pbox_t, const fg_color_t _FAR *);
void (_cdecl _FAR *setpalette_p)(fg_color_t color_num, fg_color_t red,
                      fg_color_t green, fg_color_t blue);

  char text_rows, attribute, text_mode;
  unsigned char msm;           /* Mouse present flag.                 */
  unsigned char msm_motion;    /* Mouse motion translation algorithm. */
  unsigned char palette[17];   /* Only valid for some modes.          */
  unsigned char captured;     /* UNIX only.  Non-zero if screen is active. */
  unsigned char adapter_class;/* UNIX only.  EGA/VGA flag. */
#define FG_FILL_SOLID         0
#define FG_FILL_BSLASH        1
#define FG_FILL_SLASH         2
#define FG_FILL_HATCH         3
#define FG_FILL_LINE          4
#define FG_FILL_THICK_X       5
#define FG_FILL_THIN_X        6
#define FG_FILL_SCALE         7
#define FG_FILL_WIDEDOT       8
#define FG_FILL_CLOSEDOT      9
#define FG_FILL_DIAMOND       10
#define FG_FILL_USER_DEFINED  11
#define FG_FILL_PATTERN_MAX   12
  fg_pattern_t filltype[FG_FILL_PATTERN_MAX];
  fg_handle_t saved_screen;   /* UNIX only.  Image is stored here while */
                              /* screen is not active. */
  fg_coord_t font_baseline;
fg_handle_t (_cdecl _FAR *save_p)(fg_const_pbox_t);
void (_cdecl _FAR *put_handle_p)(fg_handle_t);
void (_cdecl _FAR *getpalette_p)(fg_color_t color_num, fg_color_t _FAR *red,
                    fg_color_t _FAR *green, fg_color_t _FAR *blue);
void (_cdecl _FAR *drawellipse_p)(fg_color_t,int,int,fg_coord_t,fg_coord_t,
                    fg_coord_t, fg_coord_t,int,int,fg_const_pbox_t);
void (_cdecl _FAR *fill_p)(fg_coord_t,fg_coord_t,fg_color_t,fg_color_t);
void (_cdecl _FAR *fillpattern_p)(fg_coord_t,fg_coord_t,fg_color_t,fg_color_t,
      int);
void (_cdecl _FAR *free_handle_p)(fg_handle_t);
unsigned int mallocs_outstanding;
unsigned short int window_io_address;     /* FG private. */
unsigned short int window_num;            /* FG private. */
void (_cdecl _FAR *window_set_p)(void);   /* FG private. */
unsigned int window_size;                 /* FG private. */
};

extern struct fg_state _cdecl fg;

/* For backward compatibility. */
#define fg_activepage  fg.activepage
#define fg_charbox     fg.charbox
#define fg_color       fg.color
#define fg_display     fg.display
#define fg_displaybox  fg.displaybox
#define fg_displaypage fg.displaypage
#define fg_linetype    fg.linetype
#define fg_ncolormap   fg.ncolormap
#define fg_nsimulcolor fg.nsimulcolor
#define fg_numpages    fg.numpages
#define fg_pixelx      fg.pixelx
#define fg_pixely      fg.pixely

void _cdecl _FAR fg_assert(const char _FAR *,const char _FAR *,unsigned);
int _cdecl _FAR fg_get_type(void);
int _cdecl _FAR fg_init_all(void);
int _cdecl _FAR fg_init_cga(void);
int _cdecl _FAR fg_init_egaecd(void);
int _cdecl _FAR fg_init_egamono(void);
int _cdecl _FAR fg_init_egacolor(void);
int _cdecl _FAR fg_init_vga11(void);
int _cdecl _FAR fg_init_vga12(void);

#if !(M_UNIX || __OS2__)
int _cdecl _FAR fg_init_ati61();
int _cdecl _FAR fg_init_ati62();
int _cdecl _FAR fg_init_ati63();
#endif

#ifndef __OS2__
int _cdecl _FAR fg_init_egalowres(void);
int _cdecl _FAR fg_init_cgamedres(void);
int _cdecl _FAR fg_init_vga13(void);
int _cdecl _FAR fg_init_herc(void);
int _cdecl _FAR fg_init_herchalf(void);
int _cdecl _FAR fg_init_hercfull(void);
int _cdecl _FAR fg_init_paradisehires(void);
int _cdecl _FAR fg_init_tridenthires(void);
int _cdecl _FAR fg_init_orchidprohires(void);
int _cdecl _FAR fg_init_dfihires(void);
int _cdecl _FAR fg_init_evgahires(void);
int _cdecl _FAR fg_init_vegavgahires(void);
int _cdecl _FAR fg_init_tiga(void);
int _cdecl _FAR fg_init_toshiba(void);
int _cdecl _FAR fg_init_8514a(void);
int _cdecl _FAR fg_init_vesa0(void);
int _cdecl _FAR fg_init_vesa1(void);
int _cdecl _FAR fg_init_vesa2(void);
int _cdecl _FAR fg_init_vesa3(void);
int _cdecl _FAR fg_init_vesa5(void);
int _cdecl _FAR fg_init_vesa7(void);
int _cdecl _FAR fg_init_vesa6A(void);

#if 0 /* Not implemented */
int _cdecl _FAR fg_init_vesa4(void);
int _cdecl _FAR fg_init_vesa6(void);
#endif

unsigned _cdecl _FAR fg_msm_getpress(unsigned _FAR *,fg_coord_t _FAR *,
               fg_coord_t _FAR *);
unsigned _cdecl _FAR fg_msm_getrelease(unsigned _FAR *,fg_coord_t _FAR *,
               fg_coord_t _FAR *);
unsigned _cdecl _FAR fg_msm_getstatus(fg_coord_t _FAR *,fg_coord_t _FAR *);
void _cdecl _FAR fg_msm_setarea(fg_const_pbox_t);
void _cdecl _FAR fg_msm_setcurpos(fg_coord_t,fg_coord_t);
void _cdecl _FAR fg_msm_setcursor(fg_msm_cursor_t cursor);
void _cdecl _FAR fg_msm_setratio(unsigned,unsigned);

#endif /* __OS2__ */
int _cdecl _FAR fg_box_enclose(fg_const_pbox_t b1, fg_const_pbox_t b2);
int _cdecl _FAR fg_pt_inbox(fg_const_pbox_t clip,fg_coord_t x,fg_coord_t y);
int _cdecl _FAR fg_getfillside(const fg_coord_t _FAR *p,unsigned int vertices);
unsigned _cdecl _FAR fg_linepixels (fg_const_pline_t line);
fg_pline_t _cdecl _FAR fg_line_cpy(fg_pline_t to, fg_const_pline_t from);
int _cdecl _FAR fg_lineclip(fg_const_pbox_t clip, fg_const_pline_t fline,
            fg_pline_t lin);
void _cdecl _FAR fg_setenv_variable (const char _FAR *new_string);
void _cdecl _FAR fg_fillboxdissolve(fg_color_t color, int mode, int mask,
                    fg_const_pbox_t box, unsigned int count,
                    int (_cdecl _FAR *func_p)(void));
void _cdecl _FAR fg_writeboxdissolve(fg_const_pbox_t box,
                    const fg_color_t _FAR *p, unsigned int count,
                    int (_cdecl _FAR *func_p)(void));
void _cdecl _FAR fg_fillboxpattern(fg_color_t color, int mode, int mask,
                       fg_const_pbox_t b,int pattern);
void _cdecl _FAR fg_drawdotpattern(fg_color_t color,int mode,int mask,
                  fg_coord_t x, fg_coord_t y, int pattern);
int _cdecl _FAR fg_fillpolygonpattern (fg_color_t color, int mode, int mask,
                  unsigned int vertices, const fg_coord_t _FAR *polygon,
                  fg_const_pbox_t clipbox,int pattern);
int _cdecl _FAR fg_fillpolygon (fg_color_t color, int mode, int mask,
                  unsigned int vertices, const fg_coord_t _FAR *polygon,
                  fg_const_pbox_t clipbox);
void _cdecl _FAR fg_restore (fg_handle_t);
void _cdecl _FAR fg_free_handle (fg_handle_t);
void _cdecl _FAR fg_setfillpattern(int, fg_ppattern_t);
void _cdecl _FAR fg_drawlinepattern(fg_color_t,int,int,int,fg_const_pline_t);
void _cdecl _FAR fg_drawlineclip (fg_color_t color, int mode, int mask, 
                  int fg_line_type, fg_const_pline_t line, 
                  fg_const_pbox_t clip);
void _cdecl _FAR fg_drawlinepatternclip (fg_color_t color, int mode, int mask, 
                  int pattern, fg_const_pline_t line, fg_const_pbox_t clip);
void _cdecl _FAR fg_drawlinepclip (fg_color_t color, int mode, int mask, 
                  int fg_line_type, fg_const_pline_t line, 
                  fg_const_pbox_t clip);
void _cdecl _FAR fg_drawbox (fg_color_t, int, int, int, fg_const_pbox_t, 
                  fg_const_pbox_t);
void _cdecl _FAR fg_drawpolygon (fg_color_t color, int mode, int mask, int 
                  line_type, unsigned int vertices, const fg_coord_t _FAR 
                  *polygon, fg_const_pbox_t clipbox);
void _cdecl _FAR fg_filloutline (fg_color_t color, int mode, int mask, 
                  const fg_coord_t _FAR *out_line, fg_coord_t _FAR *buffer,
                  unsigned int pixels, int fill_side, fg_const_pbox_t clipbox);
void _cdecl _FAR fg_filloutlinepattern(fg_color_t color, int mode, int mask, 
                  const fg_coord_t _FAR *out_line, fg_coord_t _FAR *buffer,
                  unsigned int pixels, int fill_side, fg_const_pbox_t clipbox,
                  int pattern);
void _cdecl _FAR fg_puts (fg_color_t,int,int,int,fg_coord_t,fg_coord_t,
                  char _FAR *, fg_const_pbox_t);
void _cdecl _FAR fg_adjustxy (int, int, fg_coord_t _FAR *, fg_coord_t _FAR *,
                  fg_const_pbox_t);
void _cdecl _FAR fg_traverseline (int line_type, fg_const_pline_t ln_ptr, 
                  fg_coord_t _FAR *pt_pairs);
void _cdecl _FAR fg_drawthickline (fg_color_t,int,int,int,fg_const_pline_t,
                  fg_const_pbox_t,int);
void _cdecl _FAR fg_set_font(const fg_font_t _FAR *newfont_p);
void _cdecl _FAR fg_get_font(fg_font_t _FAR *dest_p);
int _cdecl _FAR fg_boxclip(fg_const_pbox_t clip, fg_const_pbox_t box_in,
                 fg_pline_t box_out);
void _cdecl _FAR * _FAR fg_malloc(unsigned bytes);
void _cdecl _FAR fg_free(void _FAR *p);

/* Use function pointers for lowest level routines      */
#define fg_blit           (*fg.blit_p)
#define fg_drawarc        (*fg.drawarc_p)
#define fg_drawellipse    (*fg.drawellipse_p)
#define fg_drawdot        (*fg.drawdot_p)
#define fg_drawline       (*fg.drawline_p)
#define fg_drawlinep      (*fg.drawlinep_p)
#define fg_drawmatrix     (*fg.drawmatrix_p)
#define fg_fillbox        (*fg.fillbox_p)
#define fg_fill           (*fg.fill_p)
#define fg_fillpattern    (*fg.fillpattern_p)
#define fg_flush          (*fg.flush_p)
#define fg_init           (*fg.init_p)
#define fg_msm_flush      (*fg.msm_flush_p)
#define fg_msm_hidecursor (*fg.msm_hidecursor_p)
#define fg_msm_init       (*fg.msm_init_p)
#define fg_msm_showcursor (*fg.msm_showcursor_p)
#define fg_msm_term       (*fg.msm_term_p)
#define fg_put_handle     (*fg.put_handle_p)
#define fg_putc           (*fg.putc_p)
#define fg_readbox        (*fg.readbox_p)
#define fg_readdot        (*fg.readdot_p)
#define fg_save           (*fg.save_p)
#define fg_free_handle    (*fg.free_handle_p)
#define fg_setdisplaypage (*fg.setdisplaypage_p)
#define fg_setactivepage  (*fg.setactivepage_p)
#define fg_setlinepattern (*fg.setlinepattern_p)
#define fg_setpalette     (*fg.setpalette_p)
#define fg_getpalette     (*fg.getpalette_p)
#define fg_term           (*fg.term_p)
#define fg_writebox       (*fg.writebox_p)

/* Writing modes        */
#define FG_MODE_XOR   3
#define FG_MODE_SET   0

/* Line types   */
#define    FG_LINE_SOLID         0
#define    FG_LINE_LONG_DASH     1
#define    FG_LINE_MEDIUM_DOTTED 2
#define    FG_LINE_DASH_DOTTED   3
#define    FG_LINE_MEDIUM_DASHED 4
#define    FG_LINE_DASH_W_2_DOTS 5
#define    FG_LINE_SHORT_DASH    6
#define    FG_LINE_DENSE_DOTTED  7
#define    FG_LINE_SPARSE_DOTTED 8
#define    FG_LINE_USER_DEFINED  9
#define    FG_LINE_FG_RESERVED1  10
#define    FG_LINE_FG_RESERVED2  11

/* Values for color     */
#define FG_BLACK        fg.color[0]
#define FG_BLUE         fg.color[1]
#define FG_GREEN        fg.color[2]
#define FG_CYAN         fg.color[3]
/* Cyan is the same as BLUE_GREEN. */
#define FG_BLUE_GREEN   fg.color[3]
#define FG_RED          fg.color[4]
#define FG_MAGENTA      fg.color[5]
/* Purple is the same as magenta. */
#define FG_PURPLE       fg.color[5]
#define FG_YELLOW       fg.color[6]
#define FG_WHITE        fg.color[7]
#define FG_GRAY         fg.color[8]
#define FG_LIGHT_BLUE   fg.color[9]
#define FG_LIGHT_GREEN  fg.color[10]
#define FG_LIGHT_CYAN   fg.color[11]
/* Light blue-green is the same as light_cyan. */
#define FG_LIGHT_BLUE_GREEN     fg.color[11]
#define FG_LIGHT_RED    fg.color[12]
#define FG_LIGHT_MAGENTA fg.color[13]
#define FG_BROWN        fg.color[14]
/* normally an intense white  */
#define FG_LIGHT_WHITE  fg.color[15]
/* Same as LIGHT_WHITE */
#define FG_HIGHLIGHT    fg.color[15]
/* blinking white   */
#define FG_BLINK        fg.color[16]

/* Used to guarantee the header file matches the libraries. */
#ifndef FG_SYNCHRONIZED
static void _near _cdecl fg_version_sync(void)
{
  extern char fg_version_sync_May_22_1991;
  fg_version_sync_May_22_1991 = 0;
}
#endif

#if __cplusplus
}
#endif

#endif  /* ifndef __FG_H */

