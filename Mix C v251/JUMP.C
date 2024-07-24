#include <stdlib.h>

jmp_buf env;

main()
{
    puts("Example of using setjmp and longjmp");

    for (;;) {
        switch (setjmp(env)) {
            case 0: func1(3);
            case 1: puts("returned from func1"); break;
            case 2: puts("returned from func2"); func1(1);
            case 3: puts("returned from func3"); func1(2);
           default: puts("never prints this message");
        }
        puts("----------------------------");
    }

    exit(0);
}

func1(val)
int val;
{
    puts("inside func1");
    if (val == 1) longjmp(env, 1);
    else func2(val);
    puts("never prints this message");
}

func2(val)
int val;
{
    puts("inside func2");
    if (val == 2) longjmp(env, 2);
    else func3(val);
    puts("never prints this message");
}

func3(val)
int val;
{
    puts("inside func3");
    longjmp(env, 3);
    puts("never prints this message");
}
