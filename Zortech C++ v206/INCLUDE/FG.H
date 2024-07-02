/*_ fg.h   Fri Mar 24 1989   Modified by: Walter Bright */
/* Copyright (C) 1987-1989 by Northwest Software        */
/* All Rights Reserved                                  */
/* Originally written by Joe Huffman                    */

#ifndef FG_H
#define FG_H    1

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
typedef fg_coord_t far *fg_pbox_t;            /* pointer to a box        */
typedef fg_coord_t const far *fg_const_pbox_t;/* pointer to a const box  */
typedef fg_coord_t fg_line_t[4];
typedef fg_coord_t far *fg_pline_t;           /* pointer to a line       */
typedef fg_coord_t const far *fg_const_pline_t;/* pointer to a const line */

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
a fg_boxread. */
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

/* Copy boxes   */
#define fg_box_cpy(to,from) ((fg_pbox_t)fg_line_cpy((to),(from)))

/* Change the definition of a FG_COLOR. */
/* As in 'fg_setcolornum(FG_WHITE, 7);' */
#define fg_setcolornum(old,new) ((old) = (new))


/*************************
 * Rotation values:
 */

#define FG_ROT0   0
#define FG_ROT90  1
#define FG_ROT180 2
#define FG_ROT270 3

typedef unsigned char fg_color_t;

typedef struct FG_HANDLE far *fg_handle_t;

/* Defines for the type of display encountered  */
#define FG_NULL     0    /* all graphics are routed to bit bucket        */

/* The following correspond to BIOS video modes:                             */
#define FG_CGAMEDRES    4    /* IBM CGA in 320*200 color (mode 0x04)         */
#define FG_CGAHIRES     6    /* IBM CGA in 640*200 (mode 0x06)               */
#define FG_EGACOLOR     0x0E /* EGA with regular color display (mode 0x0E)   */
#define FG_EGAMONO      0x0F /* EGA with IBM monochrome monitor (mode 0x0F)  */
#define FG_EGAECD       0x10 /* EGA with enhanced color display (mode 0x10)  */
#define FG_VGA11        0x11 /* IBM VGA in 640*480, 1 color                  */
#define FG_VGA12        0x12 /* IBM VGA in 640*480, 16 colors                */
#define FG_VGA13        0x13 /* IBM VGA in 320*200, 256 colors               */
#define FG_PARADISEHIRES 0x58/* PARADISE VGA 800*600, 16 colors              */

/* Other values for fg_display: */
#define FG_VEGAVGAHIRES 0x62 /* VIDEO 7 VEGA VGA in 800 x 600, 16 colors     */
#define FG_EVGAHIRES    0x70 /* Everex EVGA in 800 x 600, 16 colors          */
#define FG_HERCHALF        2 /* Hercules monochrome, 1 display page  */
#define FG_HERCFULL        3 /* Hercules monochrome, 2 display pages */
#define FG_TOSHIBA        -6 /* Toshiba J-3100                       */
#define FG_8514A         -10 /* IBM 8514A                            */

/* Used for filling outlines of pixels, see fg_outlinefill().           */
#define FG_FILL_ON_RIGHT 1  /* Don't change these without careful	*/
#define FG_FILL_ON_LEFT  0  /* consideration of the source code. See */
                            /* the static function delete_excess.   */

/* Collect global variables into a single structure. */
struct fg_state
{
int  (* cdecl far init_p)(void);

#define FG_LINE_MAX     10
  int linetype[FG_LINE_MAX];

#define FG_COLOR_MAX    20
  int color[FG_COLOR_MAX];

  int saddr;
  char far *fontptr, far *fontptr2;
  int activepage;
  int displaypage;
  fg_box_t charbox;
  int display;      /* FGxxxxx      */
  fg_box_t displaybox;
  long ncolormap;
  int nsimulcolor;
  unsigned numpages;
  int pixelx, pixely;
/* Function pointers (initialized by fg_init_xxxx())    */
void (* cdecl far blit_p)(fg_const_pbox_t, fg_coord_t, fg_coord_t,int,int); 
void (* cdecl far drawarc_p) (fg_color_t,int,int,fg_coord_t,fg_coord_t, 
                  fg_coord_t,int,int,fg_const_pbox_t); 
void (* cdecl far drawdot_p) (fg_color_t,int,int,fg_coord_t,fg_coord_t); 
void (* cdecl far drawline_p)(fg_color_t,int,int,int,fg_const_pline_t); 
void (* cdecl far drawlinep_p)(fg_color_t,int,int,int,fg_const_pline_t); 
void (* cdecl far drawmatrix_p)  (fg_color_t,int,int,int,fg_coord_t,
                  fg_coord_t,char far *, fg_const_pbox_t,fg_const_pbox_t); 
void (* cdecl far fillbox_p) (fg_color_t, int, int, fg_const_pbox_t);
void (* cdecl far flush_p)(void);
void (* cdecl far getcolormap_p)(fg_color_t far *, int);
void (* cdecl far putc_p)(fg_color_t,int,int,int,fg_coord_t,
                  fg_coord_t,char,fg_const_pbox_t); 
void (* cdecl far readbox_p) (fg_const_pbox_t, fg_color_t far *);
fg_color_t (* cdecl far readdot_p)(fg_coord_t,fg_coord_t);
void (* cdecl far setcolormap_p) (const fg_color_t far *, int);
void (* cdecl far setdisplaypage_p)(unsigned int);
void (* cdecl far setactivepage_p)(unsigned int);
void (* cdecl far setlinepattern_p)(int, int);
void (* cdecl far term_p)(void);
void (* cdecl far writebox_p)(fg_const_pbox_t, const fg_color_t far *); 

  char text_rows, attribute, text_mode;
};

extern struct fg_state cdecl fg;

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

void cdecl far fg_assert(const char far *,const char far *,unsigned);
int cdecl far fg_get_type(void);
fg_handle_t cdecl far fg_save(fg_const_pbox_t);
int cdecl far fg_init_all(void);
int cdecl far fg_init_cga(void);
int cdecl far fg_init_cgamedres(void);
int cdecl far fg_init_egaecd(void);
int cdecl far fg_init_egamono(void);
int cdecl far fg_init_egacolor(void);
int cdecl far fg_init_herc(void);
int cdecl far fg_init_herchalf(void);
int cdecl far fg_init_hercfull(void);
int cdecl far fg_init_paradisehires(void);
int cdecl far fg_init_vga11(void);
int cdecl far fg_init_vga12(void);
int cdecl far fg_init_vga13(void);
int cdecl far fg_init_evgahires(void);
int cdecl far fg_init_vegavgahires(void);
int cdecl far fg_init_toshiba(void);
int cdecl far fg_init_8514a(void);
int cdecl far fg_box_enclose(fg_const_pbox_t b1, fg_const_pbox_t b2);
int cdecl far fg_pt_inbox(fg_const_pbox_t clip,fg_coord_t x,fg_coord_t y);
int cdecl far fg_getfillside (const fg_coord_t far *p, unsigned int vertices);
unsigned cdecl far fg_linepixels (fg_const_pline_t line);
fg_pline_t cdecl far fg_line_cpy(fg_pline_t to, fg_const_pline_t from);
int cdecl far fg_lineclip(fg_const_pbox_t clip, fg_const_pline_t fline,
            fg_pline_t lin);
void cdecl far fg_setenv_variable (const char far *new_string);
void cdecl far fg_setpalette (fg_color_t color_num, fg_color_t red, 
                    fg_color_t green,
                    fg_color_t blue);

int cdecl far cdecl fg_fillpolygon (fg_color_t color, int mode, int mask,
                  unsigned int vertices, const fg_coord_t far *polygon,
                  fg_const_pbox_t clipbox);
void cdecl far fg_restore (fg_handle_t);
void cdecl far fg_drawellipse(fg_color_t,int,int,fg_coord_t,fg_coord_t,
                  fg_coord_t, fg_coord_t,int,int,fg_const_pbox_t);
void cdecl far fg_drawlineclip (fg_color_t color, int mode, int mask, 
                  int fg_line_type, fg_const_pline_t line, 
                  fg_const_pbox_t clip);
void cdecl far fg_drawlinepclip (fg_color_t color, int mode, int mask, 
                  int fg_line_type, fg_const_pline_t line, 
                  fg_const_pbox_t clip);
void cdecl far fg_drawbox (fg_color_t, int, int, int, fg_const_pbox_t, 
                  fg_const_pbox_t);
void cdecl far fg_drawpolygon (fg_color_t color, int mode, int mask, int 
                  line_type, unsigned int vertices, const fg_coord_t far 
                  *polygon, fg_const_pbox_t clipbox);
void cdecl far fg_filloutline (fg_color_t color, int mode, int mask, 
                  const fg_coord_t far *out_line, fg_coord_t far *buffer,
                  unsigned int pixels, int fill_side, fg_const_pbox_t clipbox);
void cdecl far fg_puts (fg_color_t,int,int,int,fg_coord_t,fg_coord_t,
                  char far *, fg_const_pbox_t);
void cdecl far fg_adjustxy (int, int, fg_coord_t far *, fg_coord_t far *,
                  fg_const_pbox_t);
void cdecl far fg_fill(fg_coord_t,fg_coord_t,fg_color_t,fg_color_t);
void cdecl far fg_traverseline (int line_type, fg_const_pline_t ln_ptr, 
                  fg_coord_t far *pt_pairs);
void cdecl far fg_drawthickline (fg_color_t,int,int,int,fg_const_pline_t,
                  fg_const_pbox_t,int);

/* Use function pointers for lowest level routines      */
#define fg_blit           (*fg.blit_p)
#define fg_drawarc        (*fg.drawarc_p)
#define fg_drawdot        (*fg.drawdot_p)
#define fg_drawline       (*fg.drawline_p)
#define fg_drawlinep      (*fg.drawlinep_p)
#define fg_drawmatrix     (*fg.drawmatrix_p)
#define fg_fillbox        (*fg.fillbox_p)
#define fg_flush          (*fg.flush_p)
#define fg_getcolormap    (*fg.getcolormap_p)
#define fg_init           (*fg.init_p)
#define fg_putc           (*fg.putc_p)
#define fg_readbox        (*fg.readbox_p)
#define fg_readdot        (*fg.readdot_p)
#define fg_setcolormap    (*fg.setcolormap_p)
#define fg_setdisplaypage (*fg.setdisplaypage_p)
#define fg_setactivepage  (*fg.setactivepage_p)
#define fg_setlinepattern (*fg.setlinepattern_p)
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

#if __cplusplus
}
#endif

#endif  /* ifndef FG_H */
