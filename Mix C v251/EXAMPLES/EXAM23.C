#define TAXRATE 0.06125
#define READ_LONG(longvar)     scanf("%ld", &longvar)
#define READ_FLOAT(floatvar)   scanf("%f", &floatvar)

main()      /* Example 2.3 */
{
    long  number;
    float price, cost, tax;
    printf("Enter number of units: ");
    READ_LONG(number);
    printf("Enter price per unit: ");
    READ_FLOAT(price);
    printf("Cost  = %8.2f\n", cost = price * number);
    printf("Tax   = %8.2f\n", tax  = cost * TAXRATE);
    printf("Total = %8.2f\n", cost + tax);
}
