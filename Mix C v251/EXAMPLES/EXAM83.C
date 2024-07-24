#define MAX 100

#include <stdio.h>     /* include standard IO header */
#include "structs.h"   /* include structure header */
#include "labelio.c"   /* include getlabel & putlabel */
#include "sort.c"      /* include sort function */

main()    /* Example 8.3 */
{
    struct label customer[MAX];
    int    i, number = 0;
    char   more = 'Y';
    char   *names[MAX];
    while (more == 'Y' || more == 'y')  {
        if (number < MAX) {
           names[number] = customer[number].name.last;
           getlabel(&customer[number++]);
           printf("More labels? (Y/N): ");
           more = getchar();
        }
        else {
           printf("* Maximum number of labels is %d *\n",
                     MAX);
           break;
        }
    }
    sort(names, number);
    for (i=0; i<number; i++) putlabel(names[i]);
}
