struct exception {
	int type;
	char *name;
	double arg1;
	double arg2;
	double retval;
	} ;

struct complex {
	double x,y;
	} ;

#define DOMAIN		1
#define SING		2
#define OVERFLOW	3
#define UNDERFLOW	4
#define TLOSS		5
#define PLOSS		6

#define EDOM	33
#define ERANGE	34

extern int errno;

#define	HUGE_VAL	1.797693134862316E+308

double acos(double);
double asin(double);
double atan(double);
double atan2(double, double);
double ceil(double);
double cos(double);
double exp(double);
double fabs(double);
double floor(double);
double frexp(double, int *);
double ldexp(double, double);
double log(double);
double log10(double);
double modf(double, double *);
double pow(double, double);
double sin(double);
double sqrt(double);
double tan(double);

#ifndef atof
double strtod(const char *, char **);
#define atof(c)		 strtod((c), (char**)0);
#endif

double _pi(void);
double _pi_2(void);
