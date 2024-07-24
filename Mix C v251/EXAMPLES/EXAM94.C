#include <stdio.h>

main()
{
    char input_name[15], output_name[15];

    puts("*** Append File Example ***");
    fputs("Enter the input file name : ", stdout);
    gets(input_name);
    fputs("Enter the output file name: ", stdout);
    gets(output_name);
    if (append(input_name, output_name) == NULL)
        puts("Dismal Failure");
    else
        puts("Extremely Successful");
}

append(name1, name2)
char *name1, *name2;
{
    #define FAILURE  0
    #define SUCCESS  1
    FILE *input, *output;
    int  c;

    input =  fopen(name1, "r");
    output = fopen(name2, "a");
    if (input == NULL) {
        fprintf(stderr, "Can't open input: %s\n", name1);
        return FAILURE;
    }
    if (output == NULL) {
        fprintf(stderr, "Can't open output: %s\n", name2);
        return FAILURE;
    }
    while ((c = getc(input)) != EOF) putc(c, output);
    fclose(input);
    fclose(output);
    return SUCCESS;
}
