#define MAX 100
#include <stdio.h>    /* include standard IO header */
#include "sort.c"     /* include sort function */

typedef struct {
           char     last[15];
           char     first[15];
        } NAME;

typedef struct {
           char     street[25];
           char     city[15];
           char     state[15];
           long     zip;
        } ADDRESS;

typedef struct {
            NAME    name;
            ADDRESS address;
        } LABEL;

getlabel(fp, customer)
FILE  *fp;
LABEL *customer;
{
    if (fp == stdin) printf("Enter Name              : ");
    fscanf(fp, "%s%s%*c", customer->name.first,
                          customer->name.last);
    if (fp == stdin) printf("Enter street            : ");
    fgets(customer->address.street, 25, fp);
    if (fp == stdin) printf("Enter city, state & zip : ");
    return fscanf(fp, "%s%s%ld%*c", customer->address.city,
                                    customer->address.state,
                                    &customer->address.zip);
}

putlabel(fp, customer)
FILE  *fp;
LABEL *customer;
{
    fprintf(fp, "\n%s %s\n%s%s %s %ld\n",
                customer->name.first,
                customer->name.last,
                customer->address.street,
                customer->address.city,
                customer->address.state,
                customer->address.zip);
}

main()
{
  int i, number = 0;
  char more = 'Y', *names[MAX], in_name[15], out_name[15];
  FILE *in_file, *out_file;
  puts("***        Label Sorting Program         ***");
  puts("press the enter key to map files to terminal\n");
  printf("Input file containing unsorted labels : ");
  gets(in_name);
  printf("Output file to contain sorted labels  : ");
  gets(out_name);
  if (strlen(in_name) == 0) in_file = stdin;
  else {
     in_file = fopen(in_name, "r");
     if (in_file == NULL)
        {printf("Can't open input: %s", in_name); exit(0);}
  }
  if (strlen(out_name) == 0) out_file = stdout;
  else {
     out_file = fopen(out_name, "w");
     if (out_file == NULL) {
        printf("Can't open output: %s", out_name); exit(0);
     }
  }
  while (more == 'Y' || more == 'y') {
     if (number < MAX) {
        names[number] = calloc(1, sizeof(LABEL));
        if (names[number] != NULL) {
           if (getlabel(in_file, names[number]) == EOF)
              {cfree(names[number]); break;}
           ++number;
           if (in_file == stdin) {
              printf("More labels? (Y/N): ");
              more = getchar();
           }
        }
        else {printf("<<< Out of Memory >>>\n"); break;}
     }
     else
        {printf("<<< Maximum No. of Labels is %d >>>\n",
                MAX); break;}
  }
  sort(names, number);
  for (i=0; i<number; i++) putlabel(out_file, names[i]);
}
