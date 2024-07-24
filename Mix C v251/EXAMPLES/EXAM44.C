#define TRUE 1
main()                           /* Example 4.4 */
{
/*  print a number in one of several formats */
   int go = TRUE,type,dnum; 
   float fnum;
   void fltout(), intout();

   printf("Print a number as ");
   printf("binary or hexadecimal\n");
   while(go) {
      printf("Is your number floating point ?\n");
      printf("Enter 0 for no, ");
      printf("anything else for yes: ");
      scanf("%d",&type);
      if(type) {
          printf("Enter your floating number: ");
          scanf("%f",&fnum);
          fltout(fnum);
       }
       else {
          printf("Enter your integer number : ");
          scanf("%d",&dnum);
          intout(dnum,'D');
          intout(dnum,'B');
          intout(dnum,'H');
       }
   printf("Do you wish to enter another number?\n");
   printf("Enter 0 for no, anything else for yes\n");
   scanf("%d",&go);
   }   
}

void fltout(dnum)
double dnum;
{
   float fnum;
   
   printf("\nFloating Point number: %f\n",dnum);
   printf("in e format: %e\n",dnum);
}

void intout(inum,type)
int inum,type;
{
   void binary();

   if (inum < 0) {
      printf("Only positive numbers accepted\n");
      inum = - inum;
   }
   if (type == 'B') {
      printf("Binary: ");
      binary(inum);
      printf("\n");
   }
   else if (type == 'H') 
      printf("Hex: %x\n",inum);
   else 
      printf("Decimal: %d\n",inum);

}

void binary(inum)
int inum;
{
   if (inum > 1)  binary(inum/2);
      printf("%d",inum%2);
}
