main()          /* Example 3.6*/
{ 
   char in = 'a'; 

   printf("Test for upper or lowercase letters,");
   printf(" terminate on non-alpha\n");
   while((in <= 'z' && in >= 'a') || 
               (in <= 'Z' && in >= 'A')){
      printf("Enter a character and");
      printf(" press the enter key: "); 
      scanf("%c%*c",&in);
      printf("Character read is %c\n",in);
   }
   printf("Program Terminated - ");
   printf("non-alphabetic character entered\n");
} 
