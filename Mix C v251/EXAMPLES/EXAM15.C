main()            /* Example 1.5 */
{
  long total, stock;
  unsigned sales;
  float price, commission, cost, income;
  double profit;
  char type;

  sales = 45678;  /* items sold */
  stock = 112502; /* items on hand */
  price = 42.50;  /* selling price */
  cost =  19.95;  /* cost of item */
  type = 'A';

   /*  calculate values  */
  total = stock - sales;
  income = price * sales;
  profit =  (price - cost) * sales;
  commission = profit * 0.03;

   /*  print answers */
  printf(
   "total inventory = %ld of type %c\n",total,type);
  printf("On sales of %u items: profit = %f\n",
     sales, profit);
  printf("Commissions at a rate of 0.03 = %f\n",
     commission);
}

