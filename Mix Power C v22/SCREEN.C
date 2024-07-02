#include <graphics.h>

/* Set the screen to graphics mode. */
/* If the screen is set	to monochrome, test whether it is a hercules */
/*    graphics card.  If 32k of	screen memory exists, assume	  */
/*    that the monochrome board	is herules compatable. */

int screen(int oldmode,	int dfltmode)
{
   int mode = -1;
   char	far *memory, far *FP_SET();
   char	mem;
   if (oldmode == MONOCHROME) {
      /* check for hercules graphics card */
      memory = FP_SET(0xb000,0x7ffe);	/* check for extra screen memory */
      mem = *memory;	      /* save current contents */
      *memory =	0x55;	      /* store and check each bit as both 1 and	0 */
      if (*memory == 0x55) {
	 *memory = 0xAA;
	 if (*memory ==	0xAA) {
	    mode = HERCMODE;
	    setvmode(HERCMODE);
	    }
	 }
      *memory =	mem;	      /* restore original value	*/
      }
   else	{
      if ((mode	= setvmode(dfltmode)) != dfltmode) mode	= -1;
      }
   return mode;
   }

