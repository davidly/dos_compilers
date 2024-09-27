int i,j;
long l,k;
float f,g;
double d,e;

main()
{
  printf("************************************************\n");
  printf("**       WELCOME TO DIGITAL RESEARCH C        **\n");
  printf("**                                            **\n");
  printf("**  This sample program tests the C compiler, **\n");
  printf("**  linker and libraries.   If the number in  **\n");
  printf("**  parentheses matches the number to the     **\n");
  printf("**  immediate left, each component is working **\n");
  printf("**  properly.                                 **\n");
  printf("************************************************\n");
  printf("\n");

  printf("Test      int math: 4567 * 10 = "); i = 4567; j = 10;
  printf("%u (45670)\n",i * j);

  printf("Test long int math: 1234 * 4567 = "); l = 1234; k = 4567;
  printf("%ld (5635678)\n",l * k);

  printf("Test float    math: 1.234 + 0.001 = "); f = 1.234; g = 0.001;
  printf("%g (1.235)\n",f + g);

  printf("Test double   math: 5635678.0 / 1234.0 = ");
  d = 5635678.0;
  e = 1234.0;
  printf("%g (4567)\n",d / e);

  printf("\nGood Luck!\n");
}

