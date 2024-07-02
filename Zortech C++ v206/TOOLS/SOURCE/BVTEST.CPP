#include <stream.hpp>
#include <string.h>
#include <bitvec.hpp>
#define NL "\n"

main()
{
    bitvec a(20);
    int i;

    for (i = 3; i < 20; i += 3)
        a.set(i);
    bitvec c = a;
    for (i = 0; i < 20; ++i)
        cout << i << " " << a[i] << NL;
    for (i = 3; i < 20; i += 3)
        a.reset(i);
    for (i = 0; i < 20; ++i)
        cout << i << " " << a[i] << NL;
    for (i = 0; i < 20; ++i)
        cout << i << " " << c[i] << NL;
}
