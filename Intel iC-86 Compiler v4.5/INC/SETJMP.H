/* setjmp.h - define the set jump stuff
 * $Version: 1.11 $
 * Copyright (C) 1988-91 Intel Corporation, ALL RIGHTS RESERVED
 */

#ifndef _setjmph
#define _setjmph
/*lint -library */

#pragma fixedparams("longjmp", "setjmp")

#define _JBLEN  9
typedef int jmp_buf[_JBLEN];

/*
 * Function prototypes:
 */
void longjmp(jmp_buf, int);
int setjmp(jmp_buf);

#endif /* _setjmph */

