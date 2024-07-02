#include <stream.hpp>
#include <dlist.hpp>

struct any {
    int len;
    char *cp;
};

typedef struct any* pany;

struct any xx[] = {
    4,"head",
    6,"second",
    5,"third",
    6,"fourth",
    5,"fifth",
    5,"sixth"
};

any intruder = {8,"Intruder"};

declare(gdlist,pany);

main()
{
    pany p = xx;
    gdlist(pany) w(p++);
    int i;

    for (i = 1; i < 6; ++i)
        w.linkin(p++);
    w.start();
    for (i = 6; i--; w += 1)
        cout << w()->len << " " << w()->cp << "\n";
    w.start();
    w += 2;
    p = *w;
    cout << "\nExtracted item was (" << p->len << " " << p->cp << ")\n\n";
    w += 2;
    w.linkin(&intruder);
    w.start();
    w++;
    w = &intruder;
    w.start();
    for (i = 6; i--; w += 1)
        cout << w()->len << " " << w()->cp << "\n";
    cout << "\nEnded up with " << w.size() << " items\n";
}

