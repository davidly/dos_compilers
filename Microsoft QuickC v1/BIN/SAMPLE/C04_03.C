#include <stdio.h>
#include <ctype.h>
#include <graph.h>

struct videoconfig vc;  /* variable vc of type videoconfig */

/* define an array of video modes and mode names
   since the numbers are not continuous */

int modes[12] = {_TEXTBW40, _TEXTC40, _TEXTBW80, _TEXTC80,
    _MRES4COLOR, _MRESNOCOLOR, _HRESBW, _TEXTMONO,
    _MRES16COLOR, _HRES16COLOR, _ERESNOCOLOR, _ERESCOLOR};

char *modenames[]  = {"_TEXTBW40", "_TEXTC40", "_TEXTBW80",
		      "_TEXTC80", "_MRES4COLOR", "_MRESNOCOLOR",
		      "_HRESBW", "_TEXTMONO", "_MRES16COLOR",
		      "_HRES16COLOR","_ERESNOCOLOR","_ERESCOLOR" };
main()
{

   int i;
   /* test all video modes */
   for (i=0; i<= 11; i++) {
       if (!_setvideomode (modes[i])) {   /* if _setvideomode fails */
            _clearscreen (_GCLEARSCREEN);
            _setvideomode (_DEFAULTMODE);
            printf ("video mode:\t%s\n",modenames[i]);
            printf ("This video mode is not supported\n");
            printf ("Hit return for next video mode");
            getchar();
            }
       else
            {
            _getvideoconfig (&vc);
            printf ("\n video mode:\t%s\n",modenames[i]);
            printf (" x pixels:\t%d\n",vc.numxpixels);
            printf (" y pixels:\t%d\n",vc.numypixels);
            printf (" text columns:\t%d\n",vc.numtextcols);
            printf (" text rows:\t%d\n",vc.numtextrows);
            printf (" # of colors:\t%d\n",vc.numcolors);
            printf (" bits/pixel:\t%d\n",vc.bitsperpixel);
            printf (" video pages:\t%d\n",vc.numvideopages);
            printf (" mode:\t\t%d\n",vc.mode);
            printf (" adapter:\t%d\n",vc.adapter);
            printf (" monitor:\t%d\n",vc.monitor);
            printf (" memory:\t%d\n",vc.memory);
            printf (" Hit return for next video mode");
	    _setcolor (1);
            _rectangle (_GBORDER,0,0,vc.numxpixels-5,vc.numypixels-5);
            getchar();
            _clearscreen (_GCLEARSCREEN);
            }
   }
   _setvideomode (_DEFAULTMODE);
}

