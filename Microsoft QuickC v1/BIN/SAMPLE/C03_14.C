#include <stdio.h>
#include <ctype.h>
main()
{
   FILE *fopen(), *fp_in, *fp_out;
   char fn_in[12], fn_out[12];  /* allow room for filename.ext */

   printf ("enter name of input file: ");
   scanf ("%s", fn_in);
   printf ("enter name of output file: ");
   scanf ("%s", fn_out);
   fp_out = fopen (fn_out, "w");
   fp_in = fopen (fn_in,"r");
   /* check for nonexistent input file and exit if fopen failed */
   if (fp_in == NULL) {
      printf ("No input file %s\n",fn_in);
      exit (1);
   }

   /* if fopen is OK then execute the rest of the program */
   convert_file(fp_in,fp_out);
   printf ("\nFile %s cleaned up\n",fn_in);
   printf ("Output in file: %s\n",fn_out);
   fclose (fp_in);
   fclose (fp_out);
   return (0);
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

