main()   /* Example 7.5 - part B */
{
   int   allocbin(), printbin();
   long  partno = 1;
   int   bin_number;
   printf("-- Enter 0 to terminate data entry --\n");
   do {
      printf("Enter part number: ");
      scanf("%ld", &partno);
      if (partno) allocbin(partno);
   } while (partno);
   printbin();
}
