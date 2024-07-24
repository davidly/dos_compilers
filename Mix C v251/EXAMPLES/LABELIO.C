
getlabel(customer)
struct label *customer;
{
    printf("Enter Name              : ");
    scanf("%s%s%*c", customer->name.first,
                     customer->name.last);
    printf("Enter street            : ");
    gets(customer->address.street);
    printf("Enter city, state & zip : ");
    scanf("%s%s%ld%*c", customer->address.city,
                        customer->address.state,
                        &customer->address.zip);
}

putlabel(customer)
struct label *customer;
{
    printf("\n%s %s\n%s\n%s %s %ld\n",
            customer->name.first,
            customer->name.last,
            customer->address.street,
            customer->address.city,
            customer->address.state,
            customer->address.zip);
}

