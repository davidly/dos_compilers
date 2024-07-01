
/* Random numbers */
/*   Copyright (c) Mix Software 1988    */

/* ------------------------------------------------------------ */

double drand(n)
   int n;
{
   extern double (far *$0DFIXR)();
   double d;
   d = (double) rand() / (double) 0x7FFF;
   if (n == 0) return d;
   return $0DFIXR(d * n);
   }

/* ------------------------------------------------------------ */

rand()
{
    extern long _seed;
    _seed = _seed * 15790321;
    return  (int) ((_seed >> 17) & 0x7FFF);
}

/* ------------------------------------------------------------ */

void srand(seed)
   unsigned seed;
{
   extern long _seed;
   union REGS r;
   union {
      long lval;
      struct {
         unsigned lsword;
         unsigned msword;
         } words;
      } val;
   if (seed == 1) _seed = 13849l;
   else {
      r.x.ax = 0x2c00;
      intdos(&r,&r);
      val.words.lsword = r.x.dx;
      val.words.msword = r.x.cx;
      _seed = val.lval;
      }
}

long    _seed = 13849;

