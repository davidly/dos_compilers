
/*   Copyright (c) Mix Software 1988    */
/* ------------------------------------------------------------ */
/*  bessel functions: j0, j1, jn                                */
/*                    y0, y1, yn                                */
double yn(n,x)
   int n;
   double x;
{
   double y0(), y1();
   double yz, yx, y, fx;
   double _domerr();
   extern double HUGE;
   int negative = 0;
   int i;
   if (n == 0) return y0(x);
   if (n == 1) return y1(x);
   if (n < 0) {
      n = -n;
      if (n & 0x0001) negative = 1;
      }
   if (x <= 0.0) {_domerr("yn",x,x); return HUGE;}
   yz = y0(x);
   yx = y1(x);
   fx = 2.0/x;
   i = 1;
   while (i < n) {
      y = fx * i * yx - yz;
      yz = yx;
      yx = y;
      i++;
      }
   if (negative) return -y;
   return y;
}  /* yn */

double jn(n,x)
   int n;
   double x;
{
   double j0(), j1();
   double jz, jx, j, fx;
   int i;
   if (n == 0) return j0(x);
   if (n == 1) return j1(x);
   if (n < 0) return jn(-n,-x);
   jz = j0(x);
   jx = j1(x);
   fx = 2.0/x;
   i = 1;
   while (i < n) {
      j = fx * i * jx - jz;
      jz = jx;
      jx = j;
      i++;
      }
   return j;
}  /* jn */

double y0(x)
   double x;
{
   double xsquare, xx, x8, y0;
   double p, q;
   double sin(), cos(), sqrt(), log(), j0();
   double _domerr();
   extern double HUGE;
   void _pandq0();
   static double pi = 3.1415926535897932;
   static double piby4 = 0.78539816339744831;
   static double twobypi = 0.63661977236758134;
   static struct {
      int terms;
      double tbl[8];
      } y0P = {8,
              -0.40421653126104926e19,
               0.96736537146262430e19,
              -0.75173702582406051e18,
               0.18702004643462448e17,
              -0.20430408868635631e15,
               0.10869647137874908e13,
              -0.27725001364628094e10,
               0.27295402301235549e7
              };
   static struct {
      int terms;
      double tbl[9];
      } y0Q = {9,
               0.54768700204477752e20,
               0.72620404690767952e18,
               0.49441312329373299e16,
               0.22900727639481849e14,
               0.80363630456265291e11,
               0.22400416108570433e9,
               0.50069757439413062e6,
               0.86456632023518903e3,
               0.10000000000000000e1
               };

   extern double (far *$0DPOWER)();
   if (x <= 0.0) {_domerr("y0",x,x); return HUGE;}
   if (x < 8.0) {
      xsquare = x*x;
      y0 = $0DPOWER(xsquare,&y0P)/$0DPOWER(xsquare,&y0Q);
      return y0 + twobypi*j0(x)*log(x);
      }
   xx = x - piby4;
   x8 = 8.0/x;
   _pandq0(x8,&p,&q);
   return sqrt(2.0/(pi*x)) * (p*sin(xx) + q*cos(xx));
}  /* y0 */

double y1(x)
   double x;
{
   double xsquare, xx, x8, y1;
   double p, q;
   double sin(), cos(), sqrt(), log(), j1();
   double _domerr();
   extern double HUGE;
   void _pandq1();
   static double pi = 3.1415926535897932;
   static double piby34 = 2.35619449019234493;
   static double twobypi = 0.63661977236758134;
   static struct {
      int terms;
      double tbl[8];
      } y1P = {8,
              -0.29238219615329625e20,
               0.77485206821868396e19,
              -0.34410480630841144e18,
               0.59151607604900706e16,
              -0.48633169425671751e14,
               0.20496966737456622e12,
              -0.42894719688552488e9,
               0.35569240098305261e6
              };
   static struct {
      int terms;
      double tbl[9];
      } y1Q = {9,
               0.14913115113029204e21,
               0.18186628417061350e19,
               0.11316393826988845e17,
               0.47551735888881377e14,
               0.15002216991567090e12,
               0.37166607986219303e9,
               0.72691473071988846e6,
               0.10726961437789255e4,
               0.10000000000000000e1
               };

   extern double (far *$0DPOWER)();
   if (x <= 0.0)  {_domerr("y1",x,x); return HUGE;}
   if (x < 8.0) {
      xsquare = x*x;
      y1 = x*$0DPOWER(xsquare,&y1P)/$0DPOWER(xsquare,&y1Q);
      return y1 + twobypi*(j1(x)*log(x)-1.0/x);
      }
   xx = x - piby34;
   x8 = 8.0/x;
   _pandq1(x8,&p,&q);
   return sqrt(2.0/(pi*x)) * (p*sin(xx) + q*cos(xx));
}  /* y1 */

double j0(x)
   double x;
{
   double xsquare, xx, x8;
   double p, q;
   double sin(), cos(), sqrt(), fabs();
   void _pandq0();
   static double pi = 3.1415926535897932;
   static double piby4 = 0.78539816339744831;
   static struct {
      int terms;
      double tbl[12];
      } j0P = {12,
               0.18108389921416431e9,
              -0.44464759561502412e8,
               0.26292976097233912e7,
              -0.66351202963350577e5,
               0.90000108663859700e3,
              -0.74117799951193489e1,
               0.39771954892980604e-1,
              -0.14463518634545936e-3,
               0.36127859495623837e-6,
              -0.60893587508087894e-9,
               0.64247367849791009e-12,
              -0.33133602728361709e-15
              };
   static struct {
      int terms;
      double tbl[4];
      } j0Q = {4,
               0.18108389921416430e9,
               0.80621524203869792e6,
               0.14154950117074173e4,
               0.10000000000000000e1
               };
   static struct {
      int terms;
      double tbl[5];
      } j0pP = {5,
               0.21807736478830516e7,
               0.30343163608475270e7,
               0.11035444210405852e7,
               0.11252515255664381e6,
               0.22399036697750965e4
               };
   static struct {
      int terms;
      double tbl[6];
      } j0pQ = {6,
               0.21807736478830516e7,
               0.30367122303337213e7,
               0.11068209412295708e7,
               0.11366275712613906e6,
               0.23403140106394541e4,
               0.10000000000000000e1
               };
   static struct {
      int terms;
      double tbl[5];
      } j0qP = {5,
              -0.17665456233082465e4,
              -0.28720316121456664e4,
              -0.12598828601325539e4,
              -0.16263421062270593e3,
              -0.44237584856933353e1
               };
   static struct {
      int terms;
      double tbl[6];
      } j0qQ = {6,
               0.11305891989633582e6,
               0.18484510850351025e6,
               0.82274660980144657e5,
               0.11085805836751487e5,
               0.35655140058576331e3,
               0.10000000000000000e1
               };

   extern double (far *$0DPOWER)();
   x = fabs(x);
   if (x < 8.0) {
      xsquare = x*x;
      return $0DPOWER(xsquare,&j0P)/$0DPOWER(xsquare,&j0Q);
      }
   xx = x - piby4;
   x8 = 8.0/x;
   _pandq0(x8,&p,&q);
   /*
   xsquare = x8*x8;
   p = $0DPOWER(xsquare,&j0pP)/$0DPOWER(xsquare,&j0pQ);
   q = x8*$0DPOWER(xsquare,&j0qP)/$0DPOWER(xsquare,&j0qQ);
   */
   return sqrt(2.0/(pi*x)) * (p*cos(xx) - q*sin(xx));
}  /* j0 */

double j1(x)
   double x;
{
   double xsquare, xx, x8, value;
   double p, q;
   int    negative = 0;
   double sin(), cos(), sqrt();
   void _pandq1();
   static double pi = 3.1415926535897932;
   static double piby34 = 2.35619449019234493;
   extern double (far *$0DPOWER)();
   static struct {
      int terms;
      double tbl[8];
      } j1P = {8,
               0.22148878804219631e18,
              -0.25123742147032128e17,
               0.84824207447812727e15,
              -0.12498203672620249e14,
               0.93165652967246732e11,
              -0.36866689870229816e9,
               0.74370238171199964e6,
              -0.60795301796074136e3
              };
   static struct {
      int terms;
      double tbl[8];
      } j1Q = {8,
               0.44297757608439262e18,
               0.51247127164848721e16,
               0.29898363077254872e14,
               0.11581921274668893e12,
               0.32819403445341964e9,
               0.69885861844850757e6,
               0.10777412894333044e4,
               0.10000000000000000e1
               };
/* static struct {
      int terms;
      double tbl[5];
      } j1pP = {5,
              -0.17469576694409286e7,
              -0.23669439140521428e7,
              -0.82850363738723775e6,
              -0.79574568713505959e5,
              -0.14279066288270981e4
               };
   static struct {
      int terms;
      double tbl[6];
      } j1pQ = {6,
              -0.17469576694409286e7,
              -0.23637451390226540e7,
              -0.82423699065628189e6,
              -0.78144050089391111e5,
              -0.13084529833390797e4,
               0.10000000000000000e1
               };
   static struct {
      int terms;
      double tbl[5];
      } j1qP = {5,
               0.14465282874995209e3,
               0.17442916890924259e3,
               0.51736532818365916e2,
               0.37994453796980673e1,
               0.36363466476034711e-1
               };
   static struct {
      int terms;
      double tbl[5];
      } j1qQ = {5,
               0.30859270133323172e4,
               0.37343401060163018e4,
               0.11191098527047487e4,
               0.85223920643413404e2,
               0.10000000000000000e1
               };
  */

   if (x < 0.0) {
      negative = 1;
      x = -x;
      }
   if (x < 8.0) {
      xsquare = x*x;
      value = x*$0DPOWER(xsquare,&j1P)/$0DPOWER(xsquare,&j1Q);
      if (negative) return -value; else return value;
      }
   xx = x - piby34;
   x8 = 8.0/x;
/*
   xsquare = x8*x8;
   p = $0DPOWER(xsquare,&j1pP)/$0DPOWER(xsquare,&j1pQ);
   q = x8*$0DPOWER(xsquare,&j1qP)/$0DPOWER(xsquare,&j1qQ);
   */
   _pandq1(x8,&p,&q);
   value = sqrt(2.0/(pi*x)) * (p*cos(xx) - q*sin(xx));
   if (negative) return -value; else return value;
}  /* j1 */

void _pandq0(x, pptr, qptr)
   double x;
   double *pptr;
   double *qptr;
{
double xsquare;
static struct {
      int terms;
      double tbl[5];
      } P0p = {5,
               0.21807736478830516e7,
               0.30343163608475270e7,
               0.11035444210405852e7,
               0.11252515255664381e6,
               0.22399036697750965e4
               };
   static struct {
      int terms;
      double tbl[6];
      } P0q = {6,
               0.21807736478830516e7,
               0.30367122303337213e7,
               0.11068209412295708e7,
               0.11366275712613906e6,
               0.23403140106394541e4,
               0.10000000000000000e1
               };
   static struct {
      int terms;
      double tbl[5];
      } Q0p = {5,
              -0.17665456233082465e4,
              -0.28720316121456664e4,
              -0.12598828601325539e4,
              -0.16263421062270593e3,
              -0.44237584856933353e1
               };
   static struct {
      int terms;
      double tbl[6];
      } Q0q = {6,
               0.11305891989633582e6,
               0.18484510850351025e6,
               0.82274660980144657e5,
               0.11085805836751487e5,
               0.35655140058576331e3,
               0.10000000000000000e1
               };
   extern double (far *$0DPOWER)();

   xsquare = x*x;
   *pptr = $0DPOWER(xsquare,&P0p)/$0DPOWER(xsquare,&P0q);
   *qptr = x*$0DPOWER(xsquare,&Q0p)/$0DPOWER(xsquare,&Q0q);
   }

void _pandq1(x, pptr, qptr)
   double x;
   double *pptr;
   double *qptr;
{
double xsquare;
   static struct {
      int terms;
      double tbl[5];
      } P1p = {5,
              -0.17469576694409286e7,
              -0.23669439140521428e7,
              -0.82850363738723775e6,
              -0.79574568713505959e5,
              -0.14279066288270981e4
               };
   static struct {
      int terms;
      double tbl[6];
      } P1q  = {6,
              -0.17469576694409286e7,
              -0.23637451390226540e7,
              -0.82423699065628189e6,
              -0.78144050089391111e5,
              -0.13084529833390797e4,
               0.10000000000000000e1
               };
   static struct {
      int terms;
      double tbl[5];
      } Q1p  = {5,
               0.14465282874995209e3,
               0.17442916890924259e3,
               0.51736532818365916e2,
               0.37994453796980673e1,
               0.36363466476034711e-1
               };
   static struct {
      int terms;
      double tbl[5];
      } Q1q  = {5,
               0.30859270133323172e4,
               0.37343401060163018e4,
               0.11191098527047487e4,
               0.85223920643413404e2,
               0.10000000000000000e1
               };

   extern double (far *$0DPOWER)();

   xsquare = x*x;
   *pptr = $0DPOWER(xsquare,&P1p)/$0DPOWER(xsquare,&P1q);
   *qptr = x*$0DPOWER(xsquare,&Q1p)/$0DPOWER(xsquare,&Q1q);
   }
