/* Graphics functions */
/*   Copyright (c) Mix Software 1988    */

#define NULL 0
#define HERCMODE 99
#define CGAHIGH   6
#define CGALOW    4
#define CGALOWBW  5
#define PENCOLOR 0xff
#define TRANSPARENT 0xfe

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
                        /*    ie y = aspect_v/aspect_h * y0 for 1:1 */
   };

struct fillpattern {
   int width;
   int height;
   char *pattern;
   };

/* ------------------------------------------------------------ */
/* Pie chart */
/* Create a pie chart from a set of values.  Each value in the array */
/* determines the relative area of the pie.  The pie is drawn as a   */
/* circle in the current pen color.  Each segment is bounded by a    */
/* solid line in the current pen color.  Each segment is filled using*/
/* an array of pattern pointers to determine the fill values.        */
/* The center of the pie is at the current graphics cursor.          */
/* Note: pie changes both the line style and the fill style.         */

int pie(radius,data,datasize,patterns)
   int radius;       /* radius of the circle */
   double *data;     /* values to determine the size of each section */
   int datasize;     /* number of sections in the pie */
   struct fillpattern *patterns;
{
   extern int _v_color;          /* pen color */
   extern int _vxcurs, _vycurs;
   extern struct vconfig _vconfig;
   extern double sin(), cos();

   double total;
   double *dataptr;
   double angle, section_width;
   double aspect;
   long s, c;
   static double twopi = 6.283185307179586;
   static double pi4 = 0.7853981633974483096;
   int center_x, center_y;
   int i, r, x, y, color;
   getvconfig(&_vconfig);
   color = _v_color & _vconfig.colormask;
   center_x = _vxcurs;
   center_y = _vycurs;
   if (datasize <= 0 || datasize > radius) return -1;
   if (patterns == NULL) return -1;
   circle(radius,_v_color);
   aspect = (double) _vconfig.aspect_v / (double) _vconfig.aspect_h;
   move_to(center_x,center_y);         /* first boundary */
   line_style(&_v_color,1);            /* solid lines in pen color */
   line_to(center_x+radius,center_y);
   for (i = 0, dataptr = data, total = 0.0; i < datasize; ++i)
      total += *dataptr++;
   for (i = 0, dataptr = data, angle = 0.0; i < datasize; ++dataptr, ++i) {
      section_width = (*dataptr * twopi)/total;
      angle += section_width;
      move_to(center_x,center_y);
      line_to(center_x + (int)(radius*cos(angle)+0.5),
              center_y + (int)(radius*sin(angle)*aspect+0.5) );
      fill_style(patterns->pattern,patterns->width,patterns->height);
      patterns++;
      r = radius;
      /* locate an interior point to start filling */
      section_width /= 2.0;
      c = 32768. * cos(angle-section_width);
      s = 32768. * sin(angle-section_width) * aspect;
      if ((section_width > pi4) || (2.0 * radius * sin(section_width) >= 3.0)) {
         while (--r > 1) {  /* find interior point to fill */
            x = center_x + ((r * c + 16384) >> 15);
            y = center_y + ((r * s + 16384) >> 15);
            if (readdot(y,x) != color) {
               move_to(x,y);
               fill(_v_color);
               r = -1;
               }
            }
         }
      }
   return 0;
   }

/* ------------------------------------------------------------ */
/*  Set the current pen color.  The color is used for set_pixel.   */
/*  In line drawing, if any part of the pattern is set to PENCOLOR */
/*  the current pen color is used.  */

int pen_color(newcolor)
   int newcolor;
{
   extern int _v_color;
   int oldcolor;
   oldcolor = _v_color;
   _v_color = newcolor;
   return oldcolor;
   }

/* ------------------------------------------------------------ */
/* Draw a rectangle of the specified size starting with the     */
/* current graphics cursor as the upper left corner.  The       */
/* graphics cursor is unchanged.                                */

int box(x_size, y_size, fillflag)
   int x_size; /* size of the box in the horizontal direction */
   int y_size; /* size of the box in the vertical direction */
   int fillflag;  /* non-zero if box is to be filled */
{
   if (x_size < 0) { move_by(x_size+1,0); x_size = -x_size; }
   if (y_size < 0) { move_by(0,y_size+1); y_size = -y_size; }
   line_by(0,y_size-1);
   line_by(x_size-1,0);
   line_by(0,-y_size+1);
   line_by(-x_size+1,0);
   if (fillflag) {
      if (x_size > 2 && y_size > 2) {
         move_by(1,1);
         flood(x_size-2,y_size-2);
         }
      }
   }

/* ------------------------------------------------------------ */
/* Draw a line from the current cursor for a specified distance. */

int line_by(x_offset, y_offset)
   int x_offset;  /* distance in x (horizonal) direction */
   int y_offset;  /* distance in y (vertical) direction */
{
   extern int _vxcurs, _vycurs;
   return line_to(_vxcurs+x_offset,_vycurs+y_offset);
   }

/* ------------------------------------------------------------ */
/* Draw a line from the current cursor to the specified end   */
/* point.  The line style is in the external variable _vl_pat.*/
/* The pattern is repeated as necessary                       */

int line_to(x_end, y_end)
   int x_end, y_end;   /* end of line coordinate */
{
   extern int _vl_psiz;
   extern char *_vl_pat;
   extern int _vxcurs, _vycurs;
   extern int _v_color;
   int t;
   int x, y;
   int x_start, y_start;
   int d, incr1, incr2, dx, dy, delta;
   int *xp = &x, *yp = &y;  /* pointers to coordinates */
   char *pat, *patlimit;

   x_start = _vxcurs;  _vxcurs = x_end;
   y_start = _vycurs;  _vycurs = y_end;
   dy = (y_end > y_start) ? (y_end-y_start) : (y_start-y_end);
   dx = (x_end > x_start) ? (x_end-x_start) : (x_start-x_end);
   if (dy > dx) {                             /* slope greater than 1 */
      t = y_end; y_end = x_end; x_end = t;    /* swap */
      t = y_start; y_start = x_start; x_start = t;
      xp = &y; yp = &x;
      }

   if (x_start > x_end) {  /* start with smaller coordinate */
      t = x_end; x_end = x_start; x_start = t;
      t = y_end; y_end = y_start; y_start = t;
      }

   dx = x_end-x_start;
   delta = 1;
   if (y_end > y_start) dy = y_end - y_start;
   else {
      dy = y_start-y_end;
      delta = -1;
      }
   d = dy+dy - dx;
   incr1 = dy+dy;
   incr2 = incr1-dx-dx;
   x = x_start; y = y_start;
   pat = _vl_pat;
   patlimit = _vl_pat + _vl_psiz;

   do {
      writedot(*yp,*xp,*pat);
      ++x;
      if (d < 0) d += incr1;
      else { y += delta; d += incr2; }
      if (++pat >= patlimit) pat = _vl_pat;
      } while (x <= x_end);
   }

/* ------------------------------------------------------------ */
/* move graphics cursor to a specified coordinate */

int move_to(x,y)
   int x;         /* move graphics cursor */
   int y;
{
   extern int _vxcurs, _vycurs;
   _vxcurs = x;
   _vycurs = y;
   }

/* ------------------------------------------------------------ */
/* move graphics cursor by a specified offset */

int move_by(x,y)
   int x;         /* move graphics cursor by a specified offset */
   int y;
{
   extern int _vxcurs, _vycurs;
   _vxcurs += x;
   _vycurs += y;
   }

/* ------------------------------------------------------------ */
/*  Set the style of lines.  */

int line_style(colors, size)
   char *colors;   /* List of colors for each unit of line */
   int size;       /* Size of a unit (colors for each repetition) */
{
   extern char *_vl_pat;
   extern int  _vl_psiz;
   _vl_pat = colors;
   _vl_psiz = size;
   }

/* ------------------------------------------------------------ */
/*  Draw a circle with center at (x,y) and given radius */

circle(radius,color)
   int radius;
   int color;
{
   int x, y, d;
   extern struct vconfig _vconfig;
   getvconfig(&_vconfig);
   x = 0;
   y = radius;
   d = 3 - radius+radius;
   while (x < y) {
      _cpoint(x,y,color);
      if (d < 0) d = d + 4*x + 6;
      else {
         d = d + 4*(x - y) + 10;
         y -= 1;
         }
      ++x;
      }
   if (x == y) _cpoint(x,y,color);
   }

/* ------------------------------------------------------------ */
/*  Draw the 8 symetric points on a circle.  The y coordinate */
/*  is scaled according to the aspect ratio of the screen.    */

_cpoint(x,y,color)
   int x,y;    /* coordinate of point in 45 to 90 degree region */
{
   extern int _vxcurs,_vycurs; /* coordinate of center of circle */
   extern struct vconfig _vconfig;
   int x3, y3;
   int round;
   round = _vconfig.aspect_h >> 1;
   y3 = (y * _vconfig.aspect_v + round) / _vconfig.aspect_h;
   x3 = (x * _vconfig.aspect_v + round) / _vconfig.aspect_h;
   writedot(_vycurs+y3, _vxcurs+x, color);
   writedot(_vycurs+x3, _vxcurs+y, color);
   writedot(_vycurs-x3, _vxcurs+y, color);
   writedot(_vycurs-y3, _vxcurs+x, color);
   writedot(_vycurs-y3, _vxcurs-x, color);
   writedot(_vycurs-x3, _vxcurs-y, color);
   writedot(_vycurs+x3, _vxcurs-y, color);
   writedot(_vycurs+y3, _vxcurs-x, color);
   }

/* ------------------------------------------------------------ */
/*  Draw an ellipse with center at (x,y).  The ellipse is       */
/*  drawn in display coordinates.  There is no compensation     */
/*  for the aspect ratio of the screen.                         */

ellipse(x_radius,y_radius,color)
   int x_radius;  /* axis size in x direction */
   int y_radius;  /* axis size in y direction */
   int color;
{
   extern int _vxcurs,_vycurs; /* coordinate of center */
   int x = _vxcurs;
   int y = _vycurs;
   int x0, y0, d, t;
   int reverse = 0;
   if (x_radius < y_radius) {
      t = x; x = y; y = t;
      t = x_radius; x_radius = y_radius; y_radius = t;
      reverse = 1;
      }
   x0 = 0;
   y0 = x_radius;
   d = 3 - x_radius+x_radius;
   while (x0 < y0) {
      _epoint(x0,y0,x,y,color,x_radius,y_radius,reverse);
      if (d < 0) d = d + 4*x0 + 6;
      else {
         d = d + 4*(x0 - y0) + 10;
         --y0;
         }
      ++x0;
      }
   if (x0 == y0) _epoint(x0,y0,x,y,color,x_radius,y_radius,reverse);
   }

/* ------------------------------------------------------------ */
/*  Draw the 8 symetric points on an ellipse.                 */

_epoint(x,y,x0,y0,color,x_radius,y_radius,reverse)
   int x,y;    /* coordinate of point in 45 to 90 degree region */
   int x0,y0;  /* coordinate of center */
   int x_radius;  /* major axis */
   int y_radius;  /* minor axis (x_radius >= y_radius) */
   int reverse; /* flag to reverse x and y coordinates */
{
   long round = x_radius >> 1;
   int yy, xx;
   int xpos, ypos;
   int *xp, *yp;
   yy = ((long)y_radius * y + round) / (long) x_radius;
   xx = ((long)y_radius * x + round) / (long) x_radius;
   if (reverse) { xp = &ypos; yp = &xpos; }
   else { xp = &xpos; yp = &ypos; }

   ypos = y0 + yy; xpos = x0 + x; writedot(*yp,*xp,color);
   ypos = y0 + xx; xpos = x0 + y; writedot(*yp,*xp,color);
   ypos = y0 - xx; xpos = x0 + y; writedot(*yp,*xp,color);
   ypos = y0 - yy; xpos = x0 + x; writedot(*yp,*xp,color);
   ypos = y0 - yy; xpos = x0 - x; writedot(*yp,*xp,color);
   ypos = y0 - xx; xpos = x0 - y; writedot(*yp,*xp,color);
   ypos = y0 + xx; xpos = x0 - y; writedot(*yp,*xp,color);
   ypos = y0 + yy; xpos = x0 - x; writedot(*yp,*xp,color);
   }

/* ------------------------------------------------------------ */
/*  Set the pattern for filling areas */

int fill_style(colors, width, height)
   char *colors;   /* 2D array of colors to form fill pattern */
   int width;      /* Width of fill pattern */
   int height;     /* Height of fill pattern */
{
   extern char *_vf_pat;
   extern int  _vf_wid, _vf_hgt;
   _vf_pat = colors;
   _vf_wid = width;
   _vf_hgt = height;
   }

/* ------------------------------------------------------------ */
/*  Fill a bounded area with the current fill pattern.          */
/*  The area is enclosed by the boundary color.  If the boundary*/
/*  color does not form an enclosed area, the fill will "leak   */
/*  through" any holes and result in filling the entire screen. */

int fill(boundary_color)
   int boundary_color;
{
   extern int _vxcurs;              /* graphics cursor */
   extern int _vycurs;
   extern char *_vf_pat;            /* fill pattern */
   extern int  _vf_wid, _vf_hgt;    /* pattern dimensions */
   extern int _v_color;             /* pen color */
   extern int _vbcolor;             /* color of boundary */
   extern int  _vminh, _vmaxh;      /* horizontal screen boundaries */
   extern int  _vminv, _vmaxv;      /* vertical screen boundaries */
   extern int _vmode;               /* screen mode */
   extern int _vusemem;             /* direct memory access */
   extern struct vconfig _vconfig;

   if (boundary_color == PENCOLOR) boundary_color = _v_color;
   getvconfig(&_vconfig);
   boundary_color = boundary_color & _vconfig.colormask;
   if (_vxcurs < _vminh) return -1;       /* start point out of window */
   if (_vxcurs > _vmaxh) return -1;
   if (_vycurs < _vminv) return -1;
   if (_vycurs > _vmaxv) return -1;
   if (readdot(_vycurs,_vxcurs) == boundary_color) return -1;
   if (_vusemem) {
      if (_vmode == HERCMODE) return _fill_pm(boundary_color);
      if (_vmode == CGAHIGH) return _fill_pm(boundary_color);
      if (_vmode == CGALOW) return _fill_pm(boundary_color);
      if (_vmode == CGALOWBW) return _fill_pm(boundary_color);
      }
   _vbcolor = boundary_color;
   return _fill_p(_vxcurs,_vycurs,NULL); /* fill with pattern */
   }


struct _fill_chain {
   int y;                     /* vertical coordinate at previous level */
   int xmin;                  /* start of run */
   int xmax;                  /* end of run */
   struct _fill_chain *next;  /* next level */
   };

/*$STACKCHK*/
/* ------------------------------------------------------------ */
/*  Recursive fill area with pattern.  Due to the pattern, the  */
/*  areas that have already been filled are not distinguishable */
/*  from areas that have not been touched.  The previously      */
/*  visited areas are chained together via the stack.  There    */
/*  is an explicit check for previously visited areas.  This    */
/*  test is necessary to allow for filling areas that contain   */
/*  holes.                                                      */

int _fill_p(x,y,previous)
   int x, y;     /* coordinate of starting point */
   struct _fill_chain *previous; /* link to previous line in the pattern */
{
   struct _fill_chain thisrow;
   extern char *_vf_pat;            /* fill pattern */
   extern int  _vf_wid, _vf_hgt;    /* pattern dimensions */
   extern int _vbcolor;             /* color of boundary */
   extern int  _vminh, _vmaxh;      /* horizontal screen boundaries */
   extern int  _vminv, _vmaxv;      /* vertical screen boundaries */

   int xmax;                        /* rightmost edge of fill on this line */
   int xmin;                        /* left edge of fill on this line */
   static char *xlimit;             /* maximum pointer to pattern */
   static char *xstart;             /* origin of this row of pattern */
   static char *p;                  /* fill pattern pointer */
   int nextx, nexty;                /* next row coordinates */
   static int dot;
   int incr;
   struct _fill_chain *prior;

   xstart = _vf_pat + _vf_wid * (y % _vf_hgt);
   xlimit = xstart + _vf_wid;
   p = xstart + (x % _vf_wid);   /* initial pattern pointer */

   /* set dots to left of start point until boundary reached */
   xmin = x;
   p = xstart + (xmin % _vf_wid);   /* initial pattern pointer */
   while ((xmin >= _vminh) && (readdot(y,xmin) != _vbcolor)) {
      writedot(y,xmin,*p);
      --xmin;
      if (--p < xstart) p = xlimit-1;
      }

   /* set dots to right of start point until boundary reached */
   xmax = x+1;
   p = xstart + (xmax % _vf_wid);   /* initial pattern pointer */
   while ((xmax <= _vmaxh) && (readdot(y,xmax) != _vbcolor)) {
      writedot(y,xmax,*p);
      ++xmax;
      if (++p >= xlimit) p = xstart;
      }

   /* save current line for use as a stop */
   thisrow.y = y;
   thisrow.xmin = xmin;
   thisrow.xmax = xmax;
   thisrow.next = previous;

   /* Expand vertically */
   for (incr = -1; incr <= 1; incr+=2) {
      nexty = y + incr;
      if (nexty >= _vminv && nexty <= _vmaxv) {
         nextx = xmin;
         while (nextx < xmax) {
            do /* scan past boundary areas on line above or below */
               dot = readdot(nexty,++nextx);
               while ((dot == _vbcolor) && nextx < xmax);
            /* skip the group that we came from */
            if (nextx < xmax && dot != _vbcolor) {
               prior = previous;
               while (prior != NULL) {
                  if (prior->y == nexty) {
                     if (nextx > prior->xmin && nextx < prior->xmax) {
                        /* already done */
                        nextx = prior->xmax-1;
                        dot = _vbcolor;
                        prior = NULL;
                        }
                     else prior = prior->next;
                     }
                  else prior = prior->next;
                  }
               if (dot != _vbcolor) nextx = _fill_p(nextx,nexty,&thisrow);
               }
            }
         }
      }
   return xmax;
   }

/* ------------------------------------------------------------ */
/* return configuration data for the screen.                    */

getvconfig(config)
   struct vconfig *config;
{
   static struct vconfig cfgtable[17] =
      {{  0,  0, 40, 25,16, 8, 8, 0xff, 10, 12 }, /* 40 x 25 text BW */
       {  0,  0, 40, 25,16, 8, 8, 0xff, 10, 12 }, /* 40 x 25 text color */
       {  0,  0, 80, 25,16, 8, 4, 0xff, 10, 24 }, /* 80 x 25 text BW */
       {  0,  0, 80, 25,16, 8, 4, 0xff, 10, 24 }, /* 80 x 25 text color */
       {320,200,  0,  0, 4, 2, 1, 0x03, 10, 12 }, /* 320 x 200 graphics */
       {320,200,  0,  0, 4, 2, 1, 0x03, 10, 12 }, /* 320 x 200 BW */
       {640,200,  0,  0, 2, 1, 1, 0x01, 10, 24 }, /* 640 x 200 graphics */
       {  0,  0, 80, 25,16, 8, 1, 0xff, 10, 24 }, /* monochrome */
       {160,200,  0,  0,16, 4, 1, 0x0f, 20, 12 }, /* 160 x 200 pc jr */
       {320,200,  0,  0,16, 4, 1, 0x0f, 10, 12 }, /* 320 x 200 pc jr */
       {640,200,  0,  0, 4, 2, 1, 0x03, 10, 12 }, /* 640 x 200 pc jr */
       {  0,  0,  0,  0, 0, 0, 0, 0x00,  0,  0 }, /* undefined */
       {  0,  0,  0,  0, 0, 0, 0, 0x00,  0,  0 }, /* undefined */
       {320,200,  0,  0,16, 4, 8, 0x0f, 10, 12 }, /* 320 x 200 EGA */
       {640,200,  0,  0,16, 4, 4, 0x0f, 10, 24 }, /* 640 x 200 EGA */
       {640,350,  0,  0, 2, 1, 1, 0x01, 35, 48 }, /* 640 x 350 BW EGA */
       {640,350,  0,  0,16, 4, 1, 0x0f, 35, 48 }  /* 640 x 350 EGA */
       {640,480,  0,  0, 2, 1, 1, 0x01,  2,  2 }  /* 640 x 480 VGA, MCGA */
       {640,480,  0,  0,16, 4, 1, 0x0f,  2,  2 }  /* 640 x 480 VGA */
       {320,200,  0,  0,256,8, 1, 0xff,  2,  2 }  /* 320 x 200 VGA, MCGA */
       };
   static struct vconfig herccfg =
       {720,348,  0,  0, 2, 1, 2, 0x1,  2,  3 }; /* Hercules BW */
   int mode;
   mode = getvmode();
   if (mode == HERCMODE) memcpy(config,herccfg,sizeof(struct vconfig));
   else if (mode <= 16) memcpy(config,&cfgtable[mode],sizeof(struct vconfig));
   else memset(config,0,sizeof(struct vconfig));
   }

plots(s)
   char *s;
{
   if (s != NULL) {
      while (*s != '\0') plotch(*s++);
      }
   return s;
   }

setpixel(x, y)
   int  x, y;
{
   extern int _v_color;
   writedot(y,x,_v_color);
   }

int getpixel(x, y)
   int  x, y;
{
   return readdot(y,x);
   }

int setapage(page)   /* set active page */
   int page;
{
   extern int _vapage;
   int oldpage = _vapage;
   _vapage = page;
   return oldpage;
   }

int _vbcolor;                 /* boundary color for fill */
struct vconfig _vconfig;      /* screen configuration */
