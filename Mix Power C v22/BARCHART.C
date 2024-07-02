/*
   Create a bar chart on the screen.
   The command line may contain the graphics mode.  If no
   mode is specified, a default mode is used.  EGA users
   may wish to try modes 14 or 16.
   */

#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include <graphics.h>
#include "screen.c"     /* include function that sets screen mode */
#define MODE  CGA_320   /* default screen mode */
#define CHARWIDTH 8
#define CHARHEIGHT 8
#define DATASIZE  15

/*
    display a bar chart
                        */

main(int argc, char *argv[]) {
   struct vconfig screen_data;
   int oldmode, mode;
   double data[DATASIZE] = {95.10, 96.11, 107.94, 135.76, 122.55,
                            140.64, 164.93, 167.24, 211.28, 242.17,
                            247.08, 277.72, 353.40, 330.22, 417.09};
   static char title[] = "S&P 500 Average (12/31)";
   static char pattern[] = {0, 0, 0, 0, 0,  /* pattern for 0 color modes */
                            0, 1, 1, 1, 0,
                            0, 1, 0, 1, 0,
                            0, 1, 1, 1, 0,
                            0, 0, 0, 0, 0};
   double vinterval = 50.0;  /* labeling interval for vertical axis */
   double maxval, value;
   double height, vscale;
   int    width, base, i;
   int    year;
   char   color;
   char text[30];

   /* the screen mode may be specified on the command line */
   if (argc > 1) mode = atoi(argv[1]); else mode = MODE;
   oldmode = getvmode();   /* current screen mode */
   if ((mode = screen(oldmode,mode)) == -1) {
      puts("** Unable to set the screen to graphics mode **");
      setvmode(oldmode);
      return 1;
      }
   getvconfig(&screen_data);   /* fetch the screen parameters */

   /* draw axes */
   pen_color(screen_data.colors-1);
   clrscrn2(0);
   base = screen_data.ypixels-CHARHEIGHT*2-4;   /* allow space for title */
   move_to(CHARWIDTH*4,base+1);
   line_to(screen_data.xpixels-4,base+1);  /* draw base line */
   move_to(CHARWIDTH*4,base+1);
   line_to(CHARWIDTH*4,4);                /* draw vertical axis */

   /* calculate scale factors */
   maxval = data[0];
   for (i = 1; i < DATASIZE; ++i)
      if (maxval < data[i]) maxval = data[i];
   height = (double) (vinterval * (int) (maxval + vinterval)/vinterval );
   width = (screen_data.xpixels-CHARWIDTH*4-8)/DATASIZE;
   vscale = (base - 4) / height;

   /* label vertical axis */
   if (screen_data.colors > 2) pen_color(2);
   for (value = vinterval; value < height; value += vinterval) {
      move_to(CHARWIDTH*3+CHARWIDTH/2 ,base - (int)(value*vscale) );
      line_by(CHARWIDTH,0);   /* axis marker */
      move_by(-CHARWIDTH*4-CHARWIDTH/2,-CHARHEIGHT/2);
      sprintf(text,"%3.0f",value);
      plots(text);
      }

   /* label horizontal axis */
   if ((CHARWIDTH*4+2) < width) {
      for (year = 1977; year <= 1991; year++) {
         move_to(CHARWIDTH*4+width*2/3+width*(year-1977)-CHARWIDTH*2,base+3);
         sprintf(text,"%4d",year);
         plots(text);
         }
      }
   else {
      for (year = 77; year <= 91; year++) {
         move_to(CHARWIDTH*4+width*2/3+width*(year-77)-CHARWIDTH,base+3);
         sprintf(text,"%2d",year);
         plots(text);
         }
      }

   /* label chart */
   move_to(screen_data.xpixels/2 - (CHARWIDTH*strlen(title))/2,
           base+CHARHEIGHT+3);
   plots(title);

   /* draw the bars */
   pen_color(1);
   color = 1;
   if (screen_data.colors == 2) fill_style(&pattern,5,5);
   else fill_style(&color,1,1);
   line_style(&color,1);
   for (i = 0; i < DATASIZE; ++i) {
      move_to(CHARWIDTH*4+width/3+width*i,base);
      box(width*2/3,(int)(-data[i]*vscale),1);
      }

   getch();   /* wait for a key */
   setvmode(oldmode);
   }

