/* swap.h     written by: G. Eric Engstrom
 *            (C)Copyright Concentric Software Designs, Inc. 1990
 *            All Rights Reserved
 */

#define SWAP_FREEMEMERROR -2
/* errno == SWAP_FREEMEMERROR when DOS will not allow swap to shrink the allocation block */
#define SWAP_NOVMSPACE    -3
/* errno == SWAP_NOVMSPACE when there is not enough room for the memory image file */

#ifdef __cplusplus
extern "C"
  {
#endif
/* defaults for _swapX are:
 *
 * swapping is turned on
 * windowing is turned off
 * piping is turned off
 * free paragraphs is turned off
 *
 * this allows you to link _swapX into your program without source code
 * modifications.
 *
 * _SWAPX position in the EXE determines how much of the program will get
 * "swapped out" to disk. For example, if _SWAPX is the first OBJ file in
 * linker's parameter list, then the entire EXE will be swapped to disk,
 * with the exception of the SWAP kernel required to control windowing,
 * piping, and reloading. You can get swap to leave more of the program
 * in memory by positioning it in the linker OBJ file list after the OBJ
 * files you want to remain in memory. For instance, your programs
 * CRITICAL ERROR HANDLER or some other ISR. Any ISR left in memory and
 * active while the rest of the program is "swapped out" must not access
 * any global data as it will mostly likely have been "swapped out" with
 * the rest of the program.
 *
 * on and off switches are incremental, like in the disp and msm libraries.
 * i.e.
 *    swap_off();
 *    swap_off();
 *    swap_on();
 *
 * will result in swap still being off, two swap_on's will be required
 * to neutralize the effect of two swap_off's.
 *
 * swap_tempcheck routines are provided in case TMP/TEMP points to RAM disk
 *		 or other specialized memory that you don't want consumed
 *               by a memory image of the program being swapped.
 *
 * swap_window's parameters are the line and column of the the upper left
 *               corner of the window followed by the width[x] (in columns)
 *               and the depth[y] (in lines). It can be used with or without
 *               a pipe file.
 *
 * swap_pipe's   parameter is the filespec where you would like all output
 *               to be saved. It can be used with or without a window.
 *
 * swap_freeparagraphs' parameter is the number of 16 byte paragraphs of
 *               memory you want SWAP to make available for the spawned
 *               process. SWAP normally free's all the memory it can, but
 *               if you are running a program you know will only require
 *               40K then SWAP will execute faster if you tell it to only
 *               free up 40 * 64 paragraphs of memory. This call is for
 *               speed enhancement only. NOTE: If you the number of paragraph's
 *               specified is greater than SWAP can free, SWAP will free all
 *               it can and still spawn the process.
 */

 int _cdecl swap_ison(void);                           /* default on   returns value of swap control flag, positive non-zero is on */
 int _cdecl swap_istempcheckon(void);                  /* default on   returns value of swap temp check flag, positive non-zero is on */
 int _cdecl swap_iswindowon(void);                     /* default off  returns value of swap window control flag, positive non-zero is on */
 int _cdecl swap_ispipeon(void);                       /* default off  returns value of swap pipe control flag, positive non-zero is on */
 int _cdecl swap_isfreeparagraphson(void);             /* default off  returns value of swap free paragraphs control flag, positive, non-zero is on */
 int _cdecl swap_istrapcbreakon(void);                 /* default on   returns value of swap trap ^C/^Break flag, positive, non-zero is on */
 int _cdecl swap_isclearkeyboardon(void);              /* default on   returns value of swap clear keyboard flag, positive, non-zero is on */
void _cdecl swap_on(void);                             /* turns swap on */
void _cdecl swap_off(void);                            /* turns swap off */
void _cdecl swap_tempcheckon(void);                    /* turns TMP\TEMP checking on, SWAP will put the image file where they say */
void _cdecl swap_tempcheckoff(void);                   /* turns TMP\TEMP checking off, SWAP will put the image file in the CWD */
void _cdecl swap_window(int col,int lin,int x,int y);  /* defines spawned apps screen */
void _cdecl swap_windowon(void);                       /* turns window on */
void _cdecl swap_windowoff(void);                      /* turns window off */
void _cdecl swap_pipe(const char *file);               /* specifies output pipe file */
void _cdecl swap_pipeon(void);                         /* turns output piping on */
void _cdecl swap_pipeoff(void);                                /* turns output piping off */
void _cdecl swap_freeparagraphs(unsigned int sz);      /* specifies number of paragraphs SWAP should attempt to FREE for spawned process */
void _cdecl swap_freeparagraphson(void);               /* turns free paragraphs on */
void _cdecl swap_freeparagraphsoff(void);              /* turns free paragraphs off */
void _cdecl swap_trapcbreakon(void);                   /* turns control C/Break trapping on  */
void _cdecl swap_trapcbreakoff(void);                  /* turns control C/Break trapping off */
void _cdecl swap_clearkeyboardon(void);                        /* turns clear keyboard buffer on */
void _cdecl swap_clearkeyboardoff(void);               /* turns clear keyboard buffer off */
#ifdef __cplusplus
  }
#endif

