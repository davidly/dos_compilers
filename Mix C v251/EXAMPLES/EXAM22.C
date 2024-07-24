main()            /* Example 2.2 */
{
  long total, stock, sales;
  float price, commission, cost, income;
  double profit;
  char type;

      /* input values to be used */
  printf("Please enter the following items ");
  printf("to calculate gross profit,\n net profit,");
  printf(" and sales commision on a item \n");
  printf("Enter the type of item (1 char.) : ");
  scanf("%c",&type);
  printf("Enter the number of items sold : ");
  scanf("%ld",&sales); /* items sold */
  printf("Enter the number of items on hand");
  printf(" at the beginning of the month :");
  scanf("%ld",&stock); /* items on hand */
  printf("Enter the current selling price : ");
  scanf("%f",&price);  /* selling price */
  printf("Enter the cost of the item  : ");
  scanf("%f",&cost);  /* cost of item */

   /*  calculate values  */
  total = stock - sales;
  income = price * sales;
  profit =  (price - cost) * sales;
  commission = profit * 0.03;

   /*  print answers */
  printf(
   "End of month total inventory = %ld of type %c\n",
     total,type);
  printf("On a gross income of ");
  printf("%6.2f profit = %6.2f\n",
     income, profit);
  printf("Commissions at a rate of 0.03 = %6.2f\n",
     commission);
}

