#define NULL 0
struct NAME {
    char    first[40];
    char    *middle;
    char    *last;
};
struct NAMES {
    char    first[40];
    char    *middle;
    char    *last;
    struct  NAMES *next;
};
/******************* external variables *******************/
int x = 0;
int *xptr = &x;
int xarray[3] = {10, 20, 30};
struct {
    int x;
    int xarray[1000];
} xstruct = {40};

/*************** functions and auto variables **************/

main()
{
    char     c;
    short    s;
    int      i;
    unsigned u;
    long     l;
    float    f;
    double   d;
    for (;;) {
        for(c = 'A'; c <= 'Z'; c++) {
            s = c;
            i = s + 1;
            u = i + 1;
            l = u + 1;
            f = l + 1;
            d = f + 1;

        }
    func1();
    }
}


func1()
{
    int i;
    char *strptr = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    char string[27] = "abcdefghijklmnopqrstuvwxyz";
    char name[7][30] = { "George Armstrong Custer",
                         "William F. Buckley",
                         "Billy Bob Texas",
                         "Daniel T. Boone",
                         "Howard K. Smith",
                         "Tommy Lee Jones",
                         "Ronald MacDonald"};
    for (i = 25; i >= 0; i--) {
        *(strptr+i) = '\0';
        string[i] = i + 'A';
    }
    for (i = 0; i <= 25; i++) {
        string[i] = i + 'a';
        *(strptr+i) = i + 'A';
    }
    for (i = 0; i < 7; i++) func2(name[i]);
}


func2(string)
char string[];
{
    char *ptr;
    struct NAME name;
    strcpy(name.first, string);
    ptr = name.first;
    name.middle = NULL;
    name.last = NULL;
    while (*ptr) {
        if (*ptr == ' ') {
            *ptr++ = '\0';
            if (name.middle == NULL) name.middle = ptr;
            else if (name.last == NULL) name.last = ptr;
        }
        ptr++;
    }
    if (name.last == NULL) {
        if (name.middle != NULL) {
            name.last = name.middle;
            name.middle = ptr;
        }
        else name.last = name.middle = ptr;
    }
    func3(&name);
}

func3(name)
struct NAME *name;
{
    struct NAMES *temp;
    static struct NAMES *namelist;
    temp = calloc(1, sizeof(NAMES));
    if (temp != NULL) {
        movmem(name->first, temp->first, 40);
        temp->middle = temp->first + (name->middle - name->first);
        temp->last = temp->first + (name->last - name->first);
        temp->next = namelist;
        namelist = temp;
        x = x + 1;
    }
    temp = namelist;
    while (temp != NULL) {
        printf("%s ", temp->first);
        printf("%s ", temp->middle);
        puts(temp->last);
        temp = temp->next;
    }
    puts("-----------------------------");
}
