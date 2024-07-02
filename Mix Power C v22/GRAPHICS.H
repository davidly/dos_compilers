/*$no list*//*$no trace <<< graphics.h >>> */
/*   Copyright (c) Mix Software 1988       */

            /* video modes */
#define CGA_320      4    /* cga 320 x 200 four color */
#define CGA_BW       5    /* cga 320 x 200 black & white */
#define CGA_HR       6    /* cga 640 x 200 two color */
#define MONOCHROME   7    /* monochrome 80 x 25 text */
#define EGA_320     13    /* ega 320 x 200, 16 color */
#define EGA_640     14    /* ega 640 x 200, 16 color */
#define EGA_BW      15    /* ega 640 x 350, monochrome */
#define EGA_HR      16    /* ega 640 x 350, 4 or 16 color */
#define VGA_2       17    /* vga, mcga 640 x 480, two color */
#define VGA_16      18    /* vga, 640 x 480, 16 color */
#define VGA_256     19    /* vga, mcga 320 x 200, 256 color */
#define HERCMODE    99    /* Hercules monochrome graphics, 720 x 348 */
#define DEFAULTMODE -1    /* default video mode */

        /* special colors for lines and patterns */
#define PENCOLOR    0xff
#define TRANSPARENT 0xfe
#define BACKGROUND  0x00

        /* operators to control putimage */
#define COPY_PUT  0
#define XOR_PUT   1
#define OR_PUT    2
#define AND_PUT   3
#define NOT_PUT   4

extern int _vxcurs;      /* current x position of graphics cursor */
extern int _vycurs;      /* current y position of graphics cursor */

                            /* screen description */
#if !Defined(struct vconfig)
struct vconfig {
    int xpixels;         /* number of pixels in x direction */
    int ypixels;         /* number of pixels in y direction */
    int textcols;        /* number of text columns */
    int textrows;        /* number of text rows */
    int colors;          /* number of colors */
    int bitsperpixel;    /* number of bits for each pixel */
    int pages;           /* number of video pages */
    int colormask;       /* value to & with color for bitsperpixel */
    int aspect_v;        /* aspect ratio of screen is: */
    int aspect_h;        /*    aspect_v/aspect_h       */
                         /*    ie. y = aspect_v/aspect_h * y0 for 1:1 */
};
#endif

/* desciption of a fill pattern (used in pie charts) */
#if !Defined(struct fill_pattern)
struct fill_pattern {
    int width;
    int height;
    char *pattern;
};
#endif

void            box(int width, int height, int fillflag);
void            circle(int radius, int color);
void            clrscrn2(int color);
void            ellipse(int xradius, int yradius, int color);
void            fill(int bordercolor);
void            fill_style(char *colors, int width, int height);
void            flood(int width, int height);
void            getimage(int left, int top, int right, int bottom,
                void far *buffer);
int             getpixel(int x, int y);
int             getvmode(void);
struct vconfig *getvconfig(struct vconfig *screen);
long            imagesize(int left, int top, int right, int bottom);
void            line_by(int xoffset, int yoffset);
void            line_style(char *colors, int size);
void            line_to(int x, int y);
void            move_by(int xoffset, int yoffset);
void            move_to(int x, int y);
int             pen_color(int color);
void            pie(int radius, double *data, int pieces,
                    struct fill_pattern *fillpat);
void            plotch(int ch);
void            plots(char *string);
void            putimage(int left, int top, void far *buffer, int operation);
int             readdot(int row, int col);
int             setapage(int pageno);
void            setcolor(int background, int palette);
int             setvpage(int pageno);
void            setpixel(int x, int y);
int             setvmode(int mode);
void            writedot(int row, int col, int pixel);

/*$list*//*$trace       <<< graphics.h >>> */
