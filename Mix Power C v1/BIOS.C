
/* IBM PC BIOS Functions */
/*   Copyright (c) Mix Software 1988    */

cursblk()
{
    _setcurs(0, _graphic() ? 7 : 13);
}

/* ------------------------------------------------------------ */

curslin()
{
    int start;
    _setcurs((start = _graphic() ? 7 : 13), start);
}

/* ------------------------------------------------------------ */

_graphic()  /* returns 1 if graphics display, 0 if monochrome */
{
    union REGS reg;
    int display;
    bios(0x11, &reg); /* get display type (bits 4 and 5 of ax) */
    if ((reg.x.ax & 0x30) < 0x30) return 1; /* graphics   */
    else return 0;                        /* monochrome */
}

/* ------------------------------------------------------------ */

curson()  /* set bit 5 of start scan line to 0 : IBM PC      */
{         /* set bit 6 of start scan line to 0 : Tandy 2000
             use & 0x00BF                                    */
    unsigned cursor, _getcurs();
    cursor = _getcurs();
    _setcurs((cursor >> 8) & 0x00DF, cursor & 0x00FF);
}

/* ------------------------------------------------------------ */

cursoff() /* set bit 5 of start scan line to 1 : IBM PC      */
{         /* set bit 6 of start scan line to 1 : Tandy 2000
             use | 0x0040                            */
    unsigned cursor, _getcurs();
    cursor = _getcurs();
    _setcurs((cursor >> 8) | 0x0020, cursor & 0x00FF);
}

/* ------------------------------------------------------------ */

unsigned _getcurs()
{
    extern int _vapage;
    union REGS reg;
    reg.h.ah = 3;
    reg.h.bh = _vapage;
    bios(0x10, &reg);
    return reg.x.cx;
}

/* ------------------------------------------------------------ */

_setcurs(start, stop)
int start, stop;
{
    union REGS reg;
    reg.h.ah = 1;
    reg.h.ch = start;
    reg.h.cl = stop;
    bios(0x10, &reg);
}

/* ------------------------------------------------------------ */

clrscrn()
{
    extern int _vattr;
    clrscrn2(_vattr);
}

/* ------------------------------------------------------------ */

setcolor(background, palette)
int background, palette;
{
    union REGS reg;
    reg.h.ah = 11;
    reg.h.bh = 0;
    reg.h.bl = background;
    bios(0x10, &reg);
    reg.h.bh = 1;
    reg.h.bl = palette;
    bios(0x10, &reg);
}

/* ------------------------------------------------------------ */

int readch()
{  /* read character at current cursor position */
    extern int _vapage;
    union REGS reg;
    reg.h.ah = 8;
    reg.h.bh = _vapage;
    bios(0x10, &reg);
    return reg.h.al;
}

/* ------------------------------------------------------------ */

int readattr()
{  /* read attribute of character at current cursor position */
    extern int _vapage;
    union REGS reg;
    reg.h.ah = 8;
    reg.h.bh = _vapage;
    bios(0x10, &reg);
    return reg.h.ah;
}

/* ------------------------------------------------------------ */

#ifndef V_ASM

clrscrn2(attribute)
unsigned int attribute;
{
    union REGS reg;
    extern int _vattr;
    _vattr = attribute;
    reg.h.ah = 6;
    reg.h.al = reg.h.ch = reg.h.cl = 0;
    reg.h.dh = 24; reg.h.dl = 79;
    reg.h.bh = attribute;
    bios(0x10, &reg);
    poscurs(0,0);
}

curscol()
{
   extern int _vapage;
   union REGS reg;
    reg.h.ah = 3;
    reg.h.bh = _vapage;
    bios(0x10, &reg);
    return reg.h.dl;
}

cursrow()
{
   extern int _vapage;
   union REGS reg;
    reg.h.ah = 3;
    reg.h.bh = _vapage;
    bios(0x10, &reg);
    return reg.h.dh;
}

poscurs(row, col)
   int row,col;
{
   union REGS reg;
   extern int _vapage;
   reg.h.ah = 2;
   reg.h.bh = _vapage;
   reg.h.dh = row;
   reg.h.dl = col;
   bios(0x10, &reg);
}

writechs(ch, attr, n)
   int ch;     /* character to write */
   int attr;   /* attribute */
   int n;      /* number of copies*/
{
   union REGS reg;
   extern int _vapage;
   reg.h.ah = 9;
   reg.h.bh = _vapage;
   reg.h.bl = attr;
   reg.x.cx = n;
   bios(0x10, &reg);
}

getvmode()
{
    union REGS reg;
    reg.h.ah = 15;
    bios(0x10, &reg);
    return reg.h.al;
}

setvmode(mode)
int mode;
{
    union REGS reg;
    reg.h.ah = 0;
    reg.h.al = mode;
    bios(0x10, &reg);
}

int _vapage = 0;             /* current crt page number */
int _vattr = 7;              /* default attribute for scroll functions */
#endif

