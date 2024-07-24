#include <stdio.h>

main()         /* Example 6.9 */
{
   double amount, rate, factor;
   int option, months;
   int i;

   /* declaration of functions */
   int present_value(); /* present value of future payment */
   int future_value();  /* future value of present payment */
   int monthly();       /* monthly installments on a present payment */
   int monthly_value(); /* present value of monthly installments */

   /* declaration of array of pointers to functions */
   int (*function[4])() = {present_value, future_value,
                           monthly, monthly_value};

   menu(&option,&months,&rate,&amount);  /* display menu */

   for(;;) {                             /* loop forever */
      for (factor = 1+rate, i = 1; i < months; i++)
         factor = factor * (1 + rate);
      /* call appropriate function */
      (*function[option])(factor, amount, rate, months);
      menu(&option,&months,&rate,&amount);
   }
}

menu(option,months,rate,amount) /* display menu and collect
                                   the input values */
int *option, *months;
double *rate, *amount;
{
   printf(
      "\n1) present value of a single future payment\n");
   printf(
      "2) future value of a single present payment\n");
   printf(
      "3) monthly installments on a present payment\n");
   printf(
      "4) present value of monthly installments\n");
   printf(
      "5) <<exit program>>\n\n");
   printf("     enter option --> ");
   scanf("%d",option);
   if (*option<0 || *option>4) exit(0); /* exit program */
   else (*option)--;                    /* make option 0..3 */
   printf("\nenter # of months --> ");
   scanf("%d",months);
   printf("enter annual interest rate (%%) --> ");
   scanf("%lf",rate);
   *rate = *rate/1200;
   printf("enter dollar amount --> ");
   scanf("%lf%*c",amount);
}

present_value(factor, amount)
double factor, amount;
{
   printf("the present value is %9.2f\n", amount/factor);
}

future_value(factor, amount)
double factor, amount;
{
   printf("the future value is %9.2f\n", amount*factor);
}

monthly(factor, amount, rate, months)
double factor, amount, rate;
int    months;
{
   int answer, i;
   double result;
   double accum_interest = 0;
   double owed, interest, principle;

   if (rate == 0) result = amount/months;
   else result = factor * amount * rate / (factor-1);
   printf("the monthly payment is %9.2f\n", result);
   printf("do you wish to see the table (y or n)? ");
   answer = getchar();
   putchar('\n');
   if( answer == 'y' || answer == 'Y') {
      accum_interest = 0;
      owed = amount;
      for (i = 1; i<=months; i++) {
         interest = rate * owed;
         principle = result - interest;
         owed = owed - principle;
         accum_interest = accum_interest + interest;
         printf(" month    principle          interest   ");
         printf("  amount owed    accumulated interest\n");
         printf("  %2d      %9.2f       %9.2f",
            i,principle,interest);
         printf("       %9.2f       %9.2f\n",
            owed,accum_interest);
      }
   }
}

monthly_value(factor, amount, rate)
double factor, amount, rate;
{
   printf("the present value is %9.2f\n",
      rate == 0 ? amount : amount * (factor-1)/(rate * factor));
}
