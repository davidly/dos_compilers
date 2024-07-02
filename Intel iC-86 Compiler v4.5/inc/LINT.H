/* lint.h -  PC-Lint configuration file for Intel C
 * $Version: 1.3 $
 * Copyright (c) 1989 Intel Corporation, ALL RIGHTS RESERVED.
 * PC-Lint is a trademark of Gimplel Software.
 */

#ifndef _pclinth
#define _pclinth
/*lint -library */

/*lint -hsb^3   s=space after each message
                b=indicator goes below the source line
                ^=use caret (^) as the "indicator"
                3=height of message is 3 lines
 */
/*lint -w(78,4) 78=number of chars per line
                 4=indent continued lines 4 chars
 */

/*lint -d_ARCHITECTURE_  this preprocessor symbol is pre-defined */
/*lint -d_FAR_CODE_      this preprocessor symbol is pre-defined */
/*lint -d_FAR_DATA_      this preprocessor symbol is pre-defined */
#if _ARCHITECTURE_ == 386
/*lint -d_LONG64_        this preprocessor symbol is pre-defined */
#endif
/*lint -d_NPX_           this preprocessor symbol is pre-defined */
/*lint -d_OPTIMIZE_      this preprocessor symbol is pre-defined */
/*lint -d_ROM_           this preprocessor symbol is pre-defined */


/*lint +fce     continue-on-error true              */
/*lint -fcu     char-is-unsigned false (signed)     */
#if _ARCHITECTURE_ == 86 || _ARCHITECTURE_ == 186 || _ARCHITECTURE_ == 286
/*lint -fdl     ptr-diff-is-long false (int)        */
#elif _ARCHITECTURE_ == 386
/*lint +fdl     ptr-diff-is-long true               */
#endif
/*lint -fie     int-model-for-enum false (strict)   */
/*lint -fkp     k&r-preproc false (ANSI)            */
/*lint +rw(*ms) activate all Microsoft keywords     */
/*lint -rw(_loadds,_export,_saveregs,huge,fortran,pascal,cdecl,interrupt)
                disable these MS keywords           */
/*lint +rw(alien,readonly)
                these are Intel reserved (w/EXTEND) */
/*lint -t4      tabsize=4 (default)                 */
/*lint -$       accept $ in identifiers             */

/*lint -sb8     bits in a byte                  */
/*lint -sc1     sizeof(char)        returns 1   */
/*lint -ss2     sizeof(short)       returns 2   */
#if _ARCHITECTURE_ == 86 || _ARCHITECTURE_ == 186 || _ARCHITECTURE_ == 286
/*lint -si2     sizeof(int)         returns 2   */
#elif _ARCHITECTURE_ == 386
/*lint -si4     sizeof(int)         returns 4   */
#endif
#if   _ARCHITECTURE_ == 386
#  if _LONG64_
/*lint -sl8     sizeof(long)        returns 8   */
#  endif
#else
/*lint -sl4     sizeof(long)        returns 4   */
#endif
/*lint -sf4     sizeof(float)       returns 4   */
/*lint -sd8     sizeof(double)      returns 8   */
/*lint -sld8    sizeof(long double) returns 8   */

/*lint -spNP2   near code pointers are 2 bytes  */
/*lint -spND2   near data pointers are 2 bytes  */
/*lint -spFP4   far code pointers are 4 bytes   */
/*lint -spFD4   far data pointers are 4 bytes   */

/*lint -dselector="void *"
                for linting ONLY, treat selector
                as "void *"
 */

/*lint -e537    disable "repeated include file" */
/*lint -e75     disable "too late to change sizes" */

#endif /* _pclinth */
