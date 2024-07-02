#include <stream.hpp>
#include <vms.hpp>

struct example {
    int id;
    char text[502];
};

declare(gvms,example);


void zeroit(void *p)
{
    example *lp = p;

    lp->id = -1;
    memset(lp->text,'\0',502);
    strcpy(lp->text,"This element has its text in initial state");
}

main(int argc, char *argv[])
{
    int create = (argc > 1 && !strcmp(argv[1],"-c"));
    gvms(example) v(1400,32,100,"thing",create,zeroit);
    long i,j;
    int rand();
    example e, *p;

    if (create) {
        for (i = 0; i < 1400; i += 3) {
              p = &v[i];       // get a pointer to avoid multiple accesses
              p->id = i;
              strcpy(p->text,"This has been altered");
        }
        v.flush();
    } else 
        printf("File size is %lu\n",v.nelems());
    for (i = 300; i < 500; ++i)
        printf("%d %s\n",v(i).id,v(i).text);
    j = 300;
    while (v(j).id != -1)
        ++j;
    p = &v[j];
    p->id = (int) j;
    strcpy(p->text,"This is a supplementary");
    printf("File size is %lu\n",v.nelems());
// should one record each time the test is run without the -c argument
}
