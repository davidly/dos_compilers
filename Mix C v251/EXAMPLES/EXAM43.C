double cir_area(radius)  /* function definition */
double radius;           /* Example 4.3 */
{
   return(3.14159 * radius * radius);
}
main()
{
   double cir_area();   /* function declaration */
   double radius;
   double area;
   printf("This program calculates the");
   printf(" area of a circle\n");
   printf("Enter the radius of the circle: ");
   scanf("%lf",&radius);
   area = cir_area(radius);
   printf(" The area = %f ",area);
}
   
