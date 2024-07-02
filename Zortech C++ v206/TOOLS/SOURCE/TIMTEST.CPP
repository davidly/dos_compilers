// TIMTEST.CPP
#include <time.hpp>

main()
{
    time_info ti, apr1("4/1/89");   // ti from system clock

    printf("Today is %s - time: %s\n",ti.dldate(),ti.tod());
    unsigned today = ti.dayno();
    unsigned allfools = apr1.dayno();
    if (today > allfools)
        printf("%u days after ",today-allfools);
    else if (today < allfools)
        printf("%u days before ",allfools-today);
    printf("April fools day\n");
    ti.set(-1,11,5);                // modify ti to November 5 - same year
    printf("Other date formats are:\n");
    printf("    %s\n",ti.ldate());
    ti.set(89,7,4,12,30);           // then to July 4 1989 12:30
    printf("    %s\n",ti.date());
    printf("20 days after this last date it will be ");
    time_info then = ti;            // copy constructor
    then += 20;
    printf("%s - time: %s\n",then.dldate(),then.tod());
}

