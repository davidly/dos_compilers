/* INTRO4.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

int main()
{
   char inbuf[130];
   long transaction_number;
   int cashier_number;
   char transaction_code;
   float purchase_amount;

   printf("Enter transaction number: ");
   gets(inbuf);
   sscanf(inbuf, "%8ld", &transaction_number);

   printf("\nEnter your cashier number: ");
   gets(inbuf);
   sscanf(inbuf, "%2d", &cashier_number);

   printf("\nEnter transaction type code: ");
   gets(inbuf);
   sscanf(inbuf, "%c", &transaction_code);

   printf("\nEnter amount of purchase: ");
   gets(inbuf);
   sscanf(inbuf, "%f", &purchase_amount);

   return 0;
}
