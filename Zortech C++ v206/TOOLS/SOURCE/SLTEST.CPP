#include <stream.hpp>
#include <slist.hpp>

struct any {
    int len;
    char *cp;
};

typedef struct any* pany;

declare(gslist,pany);
declare(gslist_iterator,pany);

char *x[] = {
    "first",
    "second",
    "third",
    "fourth",
    "fifth"
};

struct any  xx[] = {
    5,"first",
    6,"second",
    5,"third",
    6,"fourth",
    5,"fifth"
};

stest()
{
    slist w;
    int i;

    for (i = 0; i < 5; ++i)
        w.insert(x[i]);
    for (i = 5; i--; )
        printf("%s\n",(char *) w.get());
    for (i = 0; i < 5; ++i)
        w.append(x[i]);
    for (i = 5; i--; )
        printf("%s\n",(char *) w.get());
}

gstest()
{
    gslist(pany) w;
    gslist_iterator(pany) z(w);
    int i;
    pany p;

    for (i = 0; i < 5; ++i)
        w.insert(&xx[i]);
    while ((p = z()) != 0)
        cout << p->len << " " << p->cp << "\n";
    cout << "\n";
    for (i = 0; i < 5; ++i)
        w.append(&xx[i]);
    while ((p = z()) != 0)
        cout << p->len << " " << p->cp << "\n";
}

main()
{
    cout << "Testing a base class slist first\n\n";
    stest();
    cout << "\nThen a derived gslist for objects consisting of an\n";
    cout << "integer length, and a string\n\n";
    gstest();
}
