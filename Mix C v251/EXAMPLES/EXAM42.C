/* This is a complete listing of example 4.2 */
main()
{                                                     
   int i,sq,cu;

   printf("This function prints the square");
   printf(" and the cube of a number\n");
   printf("Enter the number now: ");
   scanf("%d",&i);
   printf("\nThe value entered = %d\n",i);
   sq = square(i);
   printf("\nThe value squared = %d\n",sq);
   cu = cube(i);
   printf("\nThe value cubed = %d\n",cu);
}

square(ii)
int ii;
{
   return(ii * ii);
}

cube(iii)
int iii;
{
   return(iii * square(iii));
}
