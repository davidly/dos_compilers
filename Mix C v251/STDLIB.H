/*$no list*//*$no trace <<<   start of stdlib.h   >>> */

typedef char jmp_buf[32];

typedef union {
    struct {
       char al, ah, bl, bh, cl, ch, dl, dh;
    } byte;
    struct {
       int ax, bx, cx, dx, si, di, bp, es, ds, cs;
    } word;
} REGS;

/*$list   *//*$trace    <<<     end of stdlib.h   >>> */
