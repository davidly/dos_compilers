#include <stdio.h>
#include <graph.h>
char buffer [255];
main()
{
   int i;
   long int j, delay;
   _setvideomode (_TEXTC80);         
   for (j=0; j<= 7; j++) {
         _setbkcolor (j);            /* background colors */
         _settextposition (1,1);
         printf ("bkcolor: %d\n", j);
         for (i=0; i<= 15; i++) {
            _settextcolor (i);      /* text colors */
            _settextposition (5+i,1);
            sprintf (buffer, "Color: %d\n", i);
            _outtext (buffer);
         }
            for (delay = 0; delay <= 200000; delay++);  /* pause */
                       ;
    }
   _clearscreen (_GCLEARSCREEN);
   _setvideomode (_DEFAULTMODE);
}

