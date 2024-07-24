#include <stdio.h>
#define  BUFSIZE  81

main()
{
    FILE  *input_file, *output_file;
    char  input_name[15], output_name[15], buffer[BUFSIZE];
    int   c;
    fputs("*** File Copy Program ***\n", stdout);

    fprintf(stdout, "Enter the name of the input file  : ");
    fscanf(stdin, "%s", input_name);
    fprintf(stdout, "Enter the name of the output file : ");
    fscanf(stdin, "%s", output_name);

    input_file = fopen(input_name, "r");
    if (input_file == NULL) {
        fputs("*** Can't open input file ***", stdout);
        exit(0);
    }
    output_file = fopen(output_name, "w");
    if (output_file == NULL) {
        fputs("*** Can't open output file ***", stdout);
        exit(0);
    }
    while (fgets(buffer, BUFSIZE, input_file) != NULL)
        fputs(buffer, output_file);
}
