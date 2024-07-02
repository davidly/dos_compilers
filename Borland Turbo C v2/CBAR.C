/*      CBAR.C

        Sample program for interfacing Turbo C with Turbo Prolog

        Copyright (c) Borland International 1987,88
        All Rights Reserved.
*/

#include <dos.h>

videodot(int x, int y, int color)
{
  union REGS inr,outr;

  inr.h.ah = 12;             /* write pixel */
  inr.h.al = color;
  inr.x.cx = x;
  inr.x.dx = y;
  _int86(16,&inr,&outr); /* call video intr */
}

/* Draws a line on the screen from (x1, y1) to (x2, y2) in a selected color */
line(int x1, int y1, int x2, int y2, int color)
{
  int xdelta;  /* The change in x coordinates */
  int ydelta;  /* The change in y coordinates */
  int xstep;   /* The change to make in the x coordinate in each step */
  int ystep;   /* The change to make in the y coordinate in each step */
  int change;  /* The amount that the x or y coordinate has changed */

  xdelta = x2 - x1;               /* Calculate the change in x coordinates */
  ydelta = y2 - y1;               /* Calculate the change in y coordinates */
  if (xdelta < 0)
  {                                               /* The line will be drawn from right to left */
    xdelta = -xdelta;
    xstep = -1;
  }
  else                                    /* The line will be drawn from left to right */
    xstep = 1;
  if (ydelta < 0)
  {                                               /* The line will be drawn from bottom to top */
    ydelta = -ydelta;
    ystep = -1;
  }
  else                                    /* The line will be drawn from top to bottom */
    ystep = 1;
  if (xdelta > ydelta)    /* x changes quicker than y */
  {
    change = xdelta >> 1;  /* change set to twice the value of xdelta */
    while (x1 != x2)           /* Draw until the terminating dot is reached */
    {
      videodot(x1, y1, color);        /* Draw a dot on the screen */
      x1 += xstep;                            /* Update x coordinate */
      change += ydelta;                       /* Update change */
      if (change > xdelta)
      {
        y1 += ystep;       /* Update the y coordinate */
        change -= xdelta;  /* Reset change */
      }
    }
  }
  else                                       /* y changes quicker than x */
  {
    change = ydelta >> 1;  /* change set to twice the value of ydelta */
    while (y1 != y2)           /* Draw until the terminating dot is reached */
    {
      videodot(x1, y1, color);        /* Draw a dot on the screen */
      y1 += ystep;                            /* Update y coordinate */
      change += xdelta;                       /* Update change */
      if (change > ydelta)
                   /* If change is large enough to update the x coordinate */
      {
        x1 += xstep;            /* Update the x coordinate */
        change -= ydelta;       /* Reset change */
      }
    }
  }
} /* line */

cbar_0(int x1, int y1, int width, int height, int color)
{
  int count;  /* Counter variable used in filling bar */
  int x2, y2, x3, y3, x4, y4;  /* Additional points on the bar */
  int wfactor;    /* The number of pixels to shift the bar to the right */
  int hfactor;    /* The number of pixels to shift the bar up */
/*

The x and y values are as follows:

        x1 x2   x3 x4
	|  |	|  |
	|  v	|  v
    y2--|>/⁄ƒƒƒƒ|ƒƒø
	v/ ≥	v /≥
    y1->…ÕÕÕÕÕÕÕª/ ≥
	∫  ≥	∫  ≥
	∫  ≥	∫  ≥
	∫  ≥	∫  ≥
	∫  ≥	∫  ≥
	∫  ≥	∫  ≥
    y3---->¿ƒƒƒƒ∫ƒƒŸ
	∫ /	∫ /
    y4->»ÕÕÕÕÕÕÕº/

*/

  wfactor = width / 5;     /* figure out wfactor and hfactor */
  hfactor = height / 12;
  x2 = x1 + wfactor;       /* compute the location of the points on the bar */
  x3 = x1 + width;
  x4 = x3 + wfactor;
  y2 = y1 - hfactor;
  y3 = y1 + height - hfactor;
  y4 = y1 + height;
  line(x1, y1, x3, y1, 2);        /* draw front of the bar */
  line(x3, y1, x3, y4, 2);
  line(x3, y4, x1, y4, 2);
  line(x1, y4, x1, y1, 2);
  line(x3, y1, x4, y2, 2);        /* draw side of the bar */
  line(x4, y2, x4, y3, 2);
  line(x4, y3, x3, y4, 2);
  line(x1, y1, x2, y2, 2);        /* draw top of the bar */
  line(x2, y2, x4, y2, 2);
  line(x1, y4, x2, y3, 3);
  line(x2, y3, x4, y3, 3);        /* draw back of the bar */
  line(x2, y3, x2, y2, 3);
  for (count = y1 + 1; count < y4; count++)         /* fill in the bar */
    line(x1 + 1, count, x3, count, color);
} /* cbar_0 */
