
sort(names, number)
char  *names[];     /* array of pointers to names */
int   number;       /* number of names */
{
    #define TRUE  1
    #define FALSE 0
    int  notsorted = TRUE;
    int  i;
    char *ptr;

    /* sort the names by sorting the array of pointers */
    /* sort using a bubble sort algorithm */
    --number;
    while (notsorted) {
       notsorted = FALSE;
       for (i=0; i<number; i++)
          if (strcmp(names[i], names[i+1]) > 0) {
             notsorted = TRUE;
             ptr = names[i];   /* swap the two pointers */
             names[i] = names[i+1];
             names[i+1] = ptr;
          }
    }
}

