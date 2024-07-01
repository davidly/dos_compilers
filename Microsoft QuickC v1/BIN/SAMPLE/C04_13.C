#include <stdio.h>
#include <graph.h>
char mask1 [] = {0,66,36,24,24,36,66,0};   /* two fill patterns */
char mask2 [] = {0,24,0,102,102,0,24,0};
char error_message [] = "This video mode is not supported";
main()
{
   if (_setvideomode(_MRES4COLOR) == 0) {
      printf ("%s\n", error_message);
      exit(0);
   }
   _setfillmask (mask1);
   _setcolor (1);                      /* use multiple colors */
   _rectangle (_GBORDER,0,0,150,150);
   _setcolor (2);
   _floodfill (100,100,1);      /* stop at border of color 1 */
   _setcolor (3);
   _setfillmask (mask2);
   _floodfill (100,100,1);
   getchar();                   /* wait for carriage return */
   _clearscreen(_GCLEARSCREEN);
   _setvideomode (_DEFAULTMODE); /* restore video mode */
}

