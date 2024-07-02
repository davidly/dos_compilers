#include <stream.hpp>
#include <stdlib.h>
#include <vma.hpp>

declare(gvma,double);

void zeroit(void *p)
{
     double *lp = p;
    *lp = 0.0;
}
main(int argc, char *argv[])
{
    int create = (argc > 1 && !strcmp(argv[1],"-c"));
    gvma(double) v(40960,512,10,"a:thing.dat",create,zeroit);
    long i,j;

    if (create) {
        for (i = 0; i < 40960; ++i) {
            v[i] = (double) i;
        }
    }
    for (i = 50; i--;) {
        j = rand();
        j = (j*j)%40960;
        printf("%5ld %7.1f\n",j,v(j));
    }
}
