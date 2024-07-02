/*$no list*//*$no trace <<< setjmp.h >>> */
/*   Copyright (c) Mix Software 1988     */

#if !Defined(jmp_buf)
typedef int jmp_buf[32];
#endif

void longjmp(jmp_buf env, int value);
int setjmp(jmp_buf env);

/*$list*//*$trace       <<< setjmp.h >>> */
