#include <stdio.h>
#include <graph.h>

main()
{
   _setvideomode (_ERESCOLOR);
   _settextposition (1,1);   /* normal palette */
   printf ("Normal palette\n");
   printf ("Hit enter to change palette");
   _setcolor (4);   /* red in default palette */
   _rectangle (_GFILLINTERIOR, 50,50,200,200);
   getchar();      /* wait for Enter key */
   _remappalette  (4, _BLUE);    /* make red into blue */
   _settextposition (1,1);
   printf ("Remapped palette\n");
   printf ("Hit enter to change palette");
   _setcolor (4);   /* formerly red, now blue */
   _rectangle (_GFILLINTERIOR, 50,50,200,200);
   getchar();   /* wait for Enter key */
   _remappalette  (4, _RED);   /* restore  */
   _settextposition (1,1);
   printf ("Restored palette\n");
   printf ("Hit enter to clear the screen");
   _setcolor (4);   /* red */
   _rectangle (_GFILLINTERIOR,50,50,200,200);
   getchar();   /* wait for Enter key */
   _clearscreen (_GCLEARSCREEN);
   _setvideomode (_DEFAULTMODE);
} 
