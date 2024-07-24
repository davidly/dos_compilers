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

