#include <stdio.h>
#include <graph.h>
long bkcolor[8] = {_BLACK, _BLUE, _GREEN, _CYAN,
    _RED, _MAGENTA, _BROWN, _WHITE};
char *bkcolor_name [] = {"_BLACK", "_BLUE", "_GREEN",
    "_CYAN", "_RED", "_MAGENTA", "_BROWN", "_WHITE"};
main()
{
   int i, j, k, delay;
   _setvideomode (_MRES4COLOR);  /* uses CGA color mode */
   for (i=0; i<= 3; i++) {
      _selectpalette (i);
      for (k=0; k <= 7; k++) {
         _setbkcolor (bkcolor[k]);
         for (j=0; j<=3; j++) {
              _settextposition (1,1);
              printf ("background color: %8s\n", bkcolor_name[k]);
              printf ("palette: %d\ncolor: %d\n",i,j);
              _setcolor (j);
              _rectangle (_GFILLINTERIOR,160,100,320,200);
              for (delay=0; delay <= 20000; delay++)
                         ;
         } 
      }
   }
   _setvideomode (_DEFAULTMODE);
}

