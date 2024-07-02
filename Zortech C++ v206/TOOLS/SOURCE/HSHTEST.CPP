#include <stream.hpp>
#include <ctype.h>
#include <stdlib.h>
#include <hash.hpp>
#define NL "\n"

struct dummy {
    int len;
};

typedef dummy *dname;

declare(ghsearch,dname);

char hold[2][30];

main(int argc, char* argv[])
{
    ghsearch(dname) hasher(1024);
    FILE *fp;
    char *p, *q, buf[82], wbuf[80];
    dname nb;
    int eol,i,n, wordcount = 0, tot = 0;

    if (argc != 2) {
        cout << "Give a text file name as argument\n";
        exit(1);
    }
    fp = fopen(argv[1],"r");
    if (!fp) {
        cout << "No such file\n";
        exit(1);
    }
    cout << "Put some structures into hash table\n";
    while (fgets(buf,80,fp)) {
        for (eol = 0, p = buf; *p;) {
            while (*p && !isalpha(*p))
                ++p;
            if (!*p)
                break;
            for (q = p; isalpha(*q); ++q) ;
            if (!*q)
                ++eol;
            *q = '\0';
            strlwr(p);
            i = strlen(p);
            if (i) {            // got a word
                nb = new dummy;
                nb->len = i;
                if (!hasher.insert(p,nb)) {
                    if (wordcount < 2)
                        strcpy(hold[wordcount],p);  // keep a couple to remove
                    wordcount++;    // put in table and count it if new
                }
            }
            if (eol)
                break;
            p = q+1;
        }
    }
    rewind(fp);
    hasher.remove(hold[0]);
    while (fgets(buf,80,fp)) {
        for (eol = 0, p = buf; *p;) {
            while (*p && !isalpha(*p))
                ++p;
            if (!*p)
                break;
            for (q = p; isalpha(*q); ++q) ;
            if (!*q)
                ++eol;
            *q = '\0';
            strlwr(p);
            if (strlen(p) > 1) {
                if (!hasher.lookup(p))  // look up each word
                    tot++;
            }
            if (eol)
                break;
            p = q+1;
        }
    }
    rewind(fp);
    hash_report(hasher);
    cout << "Were " << wordcount << " distinct words, now missing " << tot
            << "\n";
    cout << "(missing is number of occurrences of first word of the text.)\n";
}
