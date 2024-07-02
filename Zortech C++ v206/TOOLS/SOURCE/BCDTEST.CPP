// BCDTEST.CPP

#include <stream.hpp>
#include <bcd.hpp>
#define nl "\n"

main()
{
    int i, n, v = 13;
    bcd bcd24;
    bcd a(1234567890,48);        // test constructors
    bcd b("998877665544332211",48);
    bcd c = b;
    long l;
    double x;

    cout << "Result of default initialisation = " << bcd24 << nl;
    cout << "a is " << a << nl;         // test output
    cout << "b is " << b << nl;
    cout << "c is " << c << nl;
    c = b = a;                          // test assignment
    cout << "c is now " << c << nl;
    a = 1; b = v;                       // more assignments
    cout << "\nPowers of 13\n\n";
    for(;;) {
        a = a * b;                      // watch multiply perform
        cout << a << nl;
        if (a.state())                  // until a overflows
            break;
    }
    cout << "\noverflowed 48 digits\n\nNow divide down largest no by 1357\n\n";
    a = "999999999999999999999999999999999999999999999999";
    b = 1357L;
    x = a;
    cout << x << nl;          // see what largest no looks like as a double
    for(;;) {
        a = a / b;                      // now watch divide
        cout << a << nl;
        if (!a.test())                  // until down to zero
            break;
        if (a.state())
            break;
    }
    cout << "\nNow cross zero doing subtractions/additions\n\n";
    a = 10L;
    b = 1L;
    for (i = 20; i--;) {                // check that sign behaves ok
        a = a - b;
        cout << a << nl;
    }
    for (i = 20; i--;) {
        a = a + b;
        cout << a << nl;
    }
    cout << "\nNow overflow doing increments\n\n";
    a = "999999999999999999999999999999999999999999999990";
    for (i = 20; i--;) {
        a++;
        cout << a << nl;
        if (a.state())
            break;
    }
    cout << "Negative Powers of 13 \n\n";
    a = 1L;
    b = -13L;
    for(;;) {
        a = a * b;
        cout << a << nl;
        if (a.state())
            break;
    }
    cout << "\noverflowed 48 digits\n\nNow divide down largest negative no by 1357\n\n";
    a = "-999999999999999999999999999999999999999999999999";
    cout << a << nl;
    b = 1357L;
    for(;;) {
        a = a / b;
        cout << a << nl;
        if (!a.test())
            break;
        if (a.state())
            break;
    }
    cout << "\nNow underflow doing subtractions\n\n";
    a = "-999999999999999999999999999999999999999999999990";
    b = 1L;
    for (i = 20; i--;) {
        a = a - b;
        cout << a << nl;
        if (a.state())
            break;
    }
    cout << "\n\nDo it all again using alternative forms\n\n";
    cout << "Powers of 13 \n\n";
    a = 1L;
    for(;;) {
        a = a * 13L;
        cout << a << nl;
        if (a.state())
            break;
    }
    cout << "\noverflowed 48 digits\n\nNow divide down largest no by 1357\n\n";
    a = "999999999999999999999999999999999999999999999999";
    cout << a << nl;
    for(;;) {
        a = a / 1357L;
        cout << a << nl;
        if (!a.test())
            break;
        if (a.state())
            break;
    }
    cout << "\nNow cross zero doing subtractions/additions\n\n";
    a = 10L;
    for (i = 20; i--;) {
        a--;
        cout << a << nl;
    }
    for (i = 20; i--;) {
        a++;
        cout << a << nl;
    }
    cout << "\nNow overflow doing additions\n\n";
    a = "999999999999999999999999999999999999999999999990";
    for (i = 20; i--;) {
        a++;
        cout << a << nl;
        if (a.state())
            break;
    }
    cout << "Negative Powers of 13 \n\n";
    a = 1L;
    for(;;) {
        a = a * -13L;
        cout << a << nl;
        if (a.state())
            break;
    }
    cout << "\noverflowed 48 digits\n\nNow divide down largest negative no by 1357\n\n";
    a = "-999999999999999999999999999999999999999999999999";
    for(;;) {
        a = a / 1357L;
        cout << a << nl;
        if (!a.test())
            break;
        if (a.state())
            break;
    }
    cout << "\nNow overflow doing subtractions\n\n";
    a = "-999999999999999999999999999999999999999999999990";
    for (i = 20; i--;) {
        a--;
        cout << a << nl;
        if (a.state())
            break;
    }
    a = "123456789000000000000000000000000123456789";
    x = a;
    cout << x << nl;
}
