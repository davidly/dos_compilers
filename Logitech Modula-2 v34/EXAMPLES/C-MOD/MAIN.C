/* everything imported must be declared as far */
/* use 'far' or compile with /AL               */

#include "rtsm2exi.h"

extern far pascal IntegerProcedure();
extern int far    extInt;

extern far pascal StringProcedure1();
extern far pascal StringProcedure2();

/* locals do not have to be declared as far */
char *localString;

main()
{
    /* everything that is passed to Modula-2 must be far */
    /* use 'far' or compile with /AL                     */
    char far *stringParam;

    printf("Start in C\n");

    IntegerProcedure(extInt); /* init of module -> extInt still 0 */
    IntegerProcedure(extInt); /* init module passed -> extInt is 10 */

    stringParam="string declared in C, length 31";
    StringProcedure1(31, stringParam);
    StringProcedure2(stringParam);

    localString="End in C\n";
    printf(localString);

    /* exit the program with m2exit */
    m2exit(0);
}
