#include <malloc.h>     /* needed for buffer use */
#include <stdio.h>
#include <graph.h>
#include <math.h>
#include <conio.h>

struct videoconfig vc;
char error_message [] = "This video mode is not supported";
char far *buffer;  /* used with _getimage & _putimage */

main()
{
   if (_setvideomode(_MRES4COLOR) == 0) {
      printf ("%s\n", error_message);
      exit(0);
   }
   _getvideoconfig (&vc);
    draw_and_store_figure();  /* place figure in buffer */
   _clearscreen (_GCLEARSCREEN);
    hypcycle();      /* call drawing function */
   _clearscreen(_GCLEARSCREEN);
   _setvideomode (_DEFAULTMODE); /* restore video mode */
}
hypcycle()
{
   float pi=3.14159;                 /* declare and initialize */
   float a,h,b,r,x0,y0,x,y, ang;
   int i;
   x0 = vc.numxpixels/2 -1;
   y0 = vc.numypixels/2 -1;
   printf ("Enter circle ratio (>=1): ");
   scanf ("%f", &r);
   printf ("\nEnter pen position (>1): ");
   scanf ("%f",&h);
   _clearscreen(_GCLEARSCREEN);
   _setcolor (1);
   _moveto (x0,0);                   /* draw axes */
   _lineto (x0,vc.numypixels);
   _moveto (0,y0);
   _lineto (vc.numxpixels,y0);
    a = 0.5*r*vc.numypixels/(r+h-1);
   b = a/r;
   h = h*b;
   _setcolor (2);
   ang = 0;
   while (!kbhit()) {                 /* draw hypocycloid */
        for (i=1; i<= 20; i++) {
           ang = ang + 2*pi/100;
           x = x0+(a-b)*cos(ang)+h*cos(ang*(a-b)/b);
           y = y0-(a-b)*sin(ang)+h*sin(ang*(a-b)/b);
           _putimage (x,y,buffer,_GXOR);
        }
   }
}
draw_and_store_figure()
{
   _setbkcolor (0L);
   _setcolor (1);
   _rectangle (_GBORDER,0,0,10,10);
   _setcolor (2);
   _rectangle (_GFILLINTERIOR,1,1,9,9);
   _setcolor (3);
   _moveto (1,1);
   _lineto (9,9);
   _moveto (1,9);
   _lineto (9,1);
   buffer=(char far *)malloc((unsigned int)_imagesize(0,0,10,10));
   _getimage (0,0,10,10, buffer);
}

