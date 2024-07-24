main()          /* Example 6.4 */
{
   char name[45], first[15], middle[15], last[15];
   char *format;
   strcpy(first, "Billy ");
   strcpy(middle, "Bob ");
   strcpy(last, "Texas ");
   strcat(name, first);
   strcat(name, middle);
   strcat(name, last);
   format = "The complete name is %s\n";
   printf(format, name);
}
