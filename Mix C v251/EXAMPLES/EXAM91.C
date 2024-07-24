#include <stdio.h>

main()
{
    FILE  *input_file, *output_file;
    char  input_name[15], output_name[15];
    int   c;

    puts("*** File Copy Program ***");

    printf("Enter the name of the input file  : ");
    scanf("%s", input_name);
    printf("Enter the name of the output file : ");
    scanf("%s", output_name);

    input_file = fopen(input_name, "r");
    if (input_file == NULL) {
        puts("*** Can't open input file ***");
        exit(0);
    }

    output_file = fopen(output_name, "w");
    if (output_file == NULL) {
        puts("*** Can't open output file ***");
        exit(0);
    }

    while ((c = getc(input_file)) != EOF)
        putc(c, output_file);
}
