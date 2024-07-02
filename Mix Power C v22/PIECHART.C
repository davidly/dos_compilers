#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include <graphics.h>
#include <malloc.h>

#define MODE  CGA_320   /* set screen mode */
#define CHARSIZE 8      /* size of plotted characters */

main(int argc, char *argv[]) {
   int oldmode;
   int mode;
   int sections;
   int index;
   struct vconfig screen_data;
   struct fill_pattern *fill_data;
   double *data;
   char title[80];
   int  xtitle, ytitle;
   extern int screen(int oldmode, int dfltmode);
   extern struct fill_pattern *patterns(struct vconfig *screen_data,
                                        int sections);

   puts("This program displays a pie chart on the screen.  You must");
   puts("have graphics capability (CGA, EGA, MCGA or VGA) to run it.\n");
   puts("Press <esc> to terminate, any other key to continue.\n");
   if (getch() == '\x1b') return 0;

   printf("Title: ");
   gets(title);
   printf("%s","Enter the number of sections in the pie: ");
   scanf("%d",&sections);
   data = calloc(sections,sizeof(double));

   printf("\nEnter %d values: ",sections);
   for (index = 0; index < sections; ++index)
      scanf("%*c%lf",&data[index]);

   oldmode = getvmode();   /* current screen mode */
   if (argc > 1) mode = atoi(argv[1]); else mode = MODE;
   if ((mode = screen(oldmode,mode)) == -1) {
      puts("** Unable to set the screen to graphics mode **");
      setvmode(oldmode);
      return 1;
      }
   getvconfig(&screen_data);   /* fetch the screen parameters */
   fill_data = patterns(&screen_data,sections);

   /* create the pie chart in the center of the screen */
   clrscrn2(0);
   pen_color(screen_data.colors-1);
   move_to(screen_data.xpixels>>1, screen_data.ypixels>>1);
   pie(screen_data.xpixels/4, data, sections, fill_data);

   /* display the title in the center of the screen */
   move_to((screen_data.xpixels - CHARSIZE*strlen(title))/2,0);
   plots(title);

   /* display the values */
   for (index = 0; (index < 10) && (index < sections); ++index) {
      /* calculate screen coordinates */
      if (index >= 5) xtitle = screen_data.xpixels*4/5; else xtitle = 0;
      ytitle = screen_data.ypixels-(CHARSIZE+2)*(5-index%5)-2;
      move_to(xtitle,ytitle);
      fill_style(fill_data->pattern,fill_data->width,fill_data->height);
      ++fill_data;
      flood(CHARSIZE*2,CHARSIZE);
      sprintf(title,"%g",data[index]);
      move_to(xtitle+3*CHARSIZE,ytitle);
      plots(title);
      }

   getch();   /* wait for a key */

   setvmode(oldmode);
   }  /* end of main */
