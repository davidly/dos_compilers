/* INTRO34.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>
#include <stdlib.h>

FILE *textfile;        /* Pointer to file being used */
char line[81];         /* Char array to hold lines read from file */

int main()
{
   /* Open file, testing for success */
   if ((textfile = fopen("intro34.txt", "w")) == NULL) {
      printf("Error opening text file for writing\n");
      exit(0);
   }

   /* Write some text to the file */
   fprintf(textfile, "%s\n", "one");
   fprintf(textfile, "%s\n", "two");
   fprintf(textfile, "%s\n", "three");

   /* Close the file */
   fclose(textfile);

   /* Open file again */
   if ((textfile = fopen("intro34.txt", "r")) == NULL) {
      printf("Error opening text file for reading\n");
      exit(0);
   }

   /* Read file contents */
   while ((fscanf(textfile, "%s", line) != EOF))
      printf("%s\n", line);

   /* Close file */
   fclose(textfile);

   return 0;
}
