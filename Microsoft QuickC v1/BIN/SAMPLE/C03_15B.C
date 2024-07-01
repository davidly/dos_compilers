#include <stdio.h>
#include <ctype.h>
main(argc,argv)
char *argv[];
int argc;
{
   FILE *fopen(), *fp_in, *fp_out;
   /* check for correct number of arguments */
   if (argc != 3) {
      printf ("correct usage is:\n");
      printf ("c03_15b  input-file  output-file\n");
      exit(0);
   }
   fp_out = fopen (argv[2], "w");
   fp_in = fopen (argv[1],"r");
   /* check for nonexistent input file and exit if fopen failed */
   if (fp_in == NULL) {
      printf ("input file error : %s\n",argv[1]);
      exit (1);
   }
   /* if fopen is OK then execute the rest of the program */
   convert_file(fp_in,fp_out);
   printf ("\nFile %s converted\n",argv[1]);
   printf ("Output in file: %s\n",argv[2]);
   fclose (fp_in);
   fclose (fp_out);
   return (1);
}
convert_file (input,output)
FILE *input, *output;
{
   int c;
   /* get characters until EOF */
   while ((c = getc (input)) != EOF){
      if (isupper(c))   /* convert case */
         c = tolower (c);
      else                 
         c = toupper (c);
   fputc(c,output);  /* print it to the output file */
   }
}
