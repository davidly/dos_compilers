#include <money.hpp>

main()
{
    money a(22.99), b("-111.50");
    money c;

    c = a+b;
    char  buffer[20];
    printf("%s\n",c.format(buffer,14));
    a = c+22.217;
    printf("%s\n",a.format(buffer,14));
    a = -(a+b+c);
    printf("%s\n",a.format(buffer,14));
    a = c*3.2;
    printf("%s\n",a.format(buffer,14));
    printf("%14ld\n",a/17.99);
    c = a%17.99;
    printf("%s\n",c.format(buffer,14));
    if ( a >= c)
        puts("a > c");
    else
        puts("a < c");
    if (c == -13.38)
        puts("equality test ok");
    a = "123.45";
    double z = sqrt(a);
    printf("%f\n",z);
}
