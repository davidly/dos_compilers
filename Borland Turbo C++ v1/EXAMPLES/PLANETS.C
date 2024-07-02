/* PLANETS.C--Example from chapters 4 and 7 of User's Guide */

#include <graphics.h>           /* For graphics library functions */
#include <stdlib.h>             /* For exit() */
#include <stdio.h>
#include <conio.h>

int set_graph(void);            /* Initialize graphics */
void calc_coords(void);         /* Scale distances onscreen */
void draw_planets(void);        /* Draw and fill planet circles */

/* Draw one planet circle */
void draw_planet(float x_pos, float radius,
                 int color, int fill_style);
void get_key(void);         /* Display text on graphics screen, */
                            /* wait for key */

/* Global variables -- set by calc_coords() */
int max_x, max_y;           /* Maximum x- and y-coordinates */
int y_org;                  /* Y-coordinate for all drawings */
int au1;                    /* One astronomical unit in pixels
                               (inner planets) */
int au2;                    /* One astronomical unit in pixels
                               (outer planets) */
int erad;                   /* One earth radius in pixels */

int main()
{
   /* Exit if not EGA or VGA */
   /* Find out if they have what it takes */
   if (set_graph() != 1) {
      printf("This program requires EGA or VGA graphics\n");
      exit(0);
   }
   calc_coords();       /* Scale to graphics resolution in use */
   draw_planets();      /* Sun through Uranus (no room for others) */
   get_key();           /* Display message and wait for key press */
   closegraph();        /* Close graphics system */

   return 0;
}

int set_graph(void)
{
   int graphdriver = DETECT, graphmode, error_code;

   /* Initialize graphics system; must be EGA or VGA */
   initgraph(&graphdriver, &graphmode, "..\\bgi");
   error_code = graphresult();
   if (error_code != grOk)
      return(-1);               /* No graphics hardware found */
   if ((graphdriver != EGA) && (graphdriver != VGA))
   {
      closegraph();
      return 0;
   }
   return(1);                   /* Graphics OK, so return "true" */
}

void calc_coords(void)
{
   /* Set global variables for drawing */
   max_x = getmaxx();           /* Returns maximum x-coordinate */
   max_y = getmaxy();           /* Returns maximum y-coordinate */
   y_org = max_y / 2;           /* Set Y coord for all objects */
   erad = max_x  / 200;         /* One earth radius in pixels */
   au1 = erad * 20;             /* Scale for inner planets */
   au2 = erad * 10;             /* scale for outer planets */
}

void draw_planets()
{
   /* Each call specifies x-coordinate in au, radius, and color */
   /* arc of Sun */
   draw_planet(-90, 100, EGA_YELLOW, EMPTY_FILL);
   /* Mercury */
   draw_planet(0.4 * au1, 0.4 * erad, EGA_BROWN, LTBKSLASH_FILL);
   /* Venus */
   draw_planet(0.7 * au1, 1.0 * erad, EGA_WHITE, SOLID_FILL);
   /* Earth */
   draw_planet(1.0 * au1, 1.0 * erad, EGA_LIGHTBLUE, SOLID_FILL);
   /* Mars */
   draw_planet(1.5 * au1, 0.4 * erad, EGA_LIGHTRED, CLOSE_DOT_FILL);
   /* Jupiter */
   draw_planet(5.2 * au2, 11.2 * erad, EGA_WHITE, LINE_FILL);
   /* Saturn */
   draw_planet(9.5 * au2, 9.4 * erad, EGA_LIGHTGREEN, LINE_FILL);
   /* Uranus */
   draw_planet(19.2 * au2, 4.2 * erad, EGA_GREEN, LINE_FILL);
}

void draw_planet(float x_pos, float radius, int color, int fill_style)
{
   setcolor (color);                /* This becomes drawing color */
   circle(x_pos, y_org, radius);    /* Draw the circle */
   setfillstyle(fill_style, color); /* Set pattern to fill interior */
   floodfill(x_pos, y_org, color);  /* Fill the circle */
}

void get_key(void)
{
   outtextxy(50, max_y - 20, "Press any key to exit");
   getch();
}
