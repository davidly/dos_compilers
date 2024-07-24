#include <stdio.h>
main()         /* Example 8.1 */
{
   struct {
      int hours;
      int minutes;
      int temp;
   } input_rec;
   double convert(),ctemp;
   char c;

   printf("This program calculates military time");
   printf(" and centigrade temperatures\n");
   printf("Enter current time (hh:mm) : ");
   scanf("%d:%d%*c",&input_rec.hours,
                       &input_rec.minutes);
   printf("Is it PM ? (Y or N) ");
   c = getchar();
   if (c == 'Y' || c == 'y')
      input_rec.hours = input_rec.hours + 12;
   printf("Enter Fahrenheit temperature : ");
   scanf("%d", &input_rec.temp);
   ctemp = convert(input_rec.temp);
   printf("Time using 24-hr clock = %02d:%02d\n",
      input_rec.hours,input_rec.minutes);
   printf("Temperature is %3.1f degrees Celsius. \n",
      ctemp);
}

double convert(ftemp)
int ftemp;
{
   return((ftemp - 32.) * 5./9.);
}
