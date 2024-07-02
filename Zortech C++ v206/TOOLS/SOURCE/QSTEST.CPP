#include <stream.hpp>
#include <bios.h>
#include <slist.hpp>

typedef double* pdouble;
declare(gqueue,pdouble);
declare(gstack,pdouble);

iqstest()
{
    iqueue x;
    istack y;
    int i;

    for (i = 0; i < 10; ++i) {
        x.queue(i);
        y.push(i);
    }
    while (x.any())
        cout << x.dequeue() << "\n";
    while (y.any())
        cout << y.pop() << "\n";
}

gqstest()
{
    gqueue(pdouble) x;
    gstack(pdouble) y;
    int i;
    double* t;

    for (i = 0; i < 10; ++i) {
        t = new double;
        *t = i+i/100.0;
        x.queue(t);
        y.push(t);
    }
    for (i = 10; i--;)
        cout << *x.dequeue() << "\n";
    for (i = 10; i--;)
        cout << *y.pop() << "\n";
}

main()
{
    cout << "Test generalised queue and stack first\n";
    cout << "Queue/push 10 doubles then dequeue/pop them\n\n";
    gqstest();
    cout << "Press a key to continue";
    cout.flush();
    bioskey(0);
    cout << "\nNow the specific versions for integer\n";
    iqstest();
    cout << "\nThats all";
}
