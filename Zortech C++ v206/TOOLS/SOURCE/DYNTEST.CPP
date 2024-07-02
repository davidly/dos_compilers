#include <stream.hpp>
#include <dynarr.hpp>

declare(gdynarr,double);

main()
{
    gdynarr(double) a;
    unsigned i;
    unsigned u;

    for (i = 100; i--;)
        a[i] = i;
    double *p = &a;
    u = a.size();
    cout << u << " elements\n";
    for (i = u; i--;)
        cout << *p++ << "\n";
}