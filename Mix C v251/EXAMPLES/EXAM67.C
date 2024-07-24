/* NO_OF_NAMES is the maximum number of names */
/* SIZE is the maximum number of characters in each name */

#define NO_OF_NAMES  50
#define SIZE         31

main()
{                                   /* Example 6.7 */
    /* counter */
    int  i;
    /* number of names read */
    int  number;
    /* 2 dimension array of names */
    char name[NO_OF_NAMES][SIZE];
    /* array of pointers to names */
    char *nameptr[NO_OF_NAMES];

    /* read the names into the two dimension array */
    printf("--- Enter one name per line, ");
    printf(" EOF to terminate ---\n");
    for (number=0; gets(name[number]) &&
         number<NO_OF_NAMES; number++)
              nameptr[number] = name[number];
    if (number == NO_OF_NAMES)
         printf("\n *** only %d names allowed ***\n",
              NO_OF_NAMES);
    printf("--- The names listed in alphabetic order ---\n");

    /* sort the names */
    sort(nameptr, number);

    /* print the sorted names */
    for (i=0; i<number; i++) puts(nameptr[i]);
}

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
