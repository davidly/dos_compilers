struct _name {
    char    last[15];
    char    first[15];
};

struct _address {
    char    street[25];
    char    city[15];
    char    state[15];
    long    zip;
};

struct label {
    struct  _name name;
    struct  _address address;
};

main()
{
    struct label customer;
    getlabel(&customer);
    putlabel(&customer);
}

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
