#include <stream.hpp>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <bintree.hpp>

struct name {                       // an arbitrary data object
    int len;
    char str[30];
};

typedef name* pname;                // make a simple type name for it

declare(gbsearch,pname);

name hold[2];

int namecmp(pname a, pname b)
{
    return(strcmp(a->str,b->str));
}

void printit(pname a)
{
    cout << a->len << " " << a->str << "\n";
}

void print_again(void* p)
{
    pname t = (pname) p;
    cout << t->str << "\n";
}

main(int argc, char* argv[])
{
    gbsearch(pname) tree(namecmp,printit);
    FILE *fp;
    char *p, *q, *r, buf[82], wbuf[80];
    pname np;
    struct name inst;
    int eol,i, wordcount = 0, missing = 0;

    if (argc != 2) {
        cout << "Give a text file name as argument\n";
        exit(1);
    }
    fp = fopen(argv[1],"r");
    if (!fp) {
        cout << "No such file\n";
        exit(1);
    }
    cout << "Put some structures into tree\n";
    while (fgets(buf,80,fp)) {
        for (eol = 0, p = buf; *p;) {   // get a word from the test file
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
            if (i) {                // got a word
                np = (pname) new char[sizeof(int)+i+1];
                                        // make a data object from it
                if (!np) {
                    cout << "Out of memory\n";
                    exit(1);
                }
                strcpy(np->str,p);
                np->len = i;
                tree.insert(np,i);      // put it into the tree
                if (i) {                // count if successful
                    if (wordcount < 1)
                        hold[wordcount] = *np;  // keep first word
                    wordcount++;
                } else
                    delete np;
            }
            if (eol)
                break;
            p = q+1;
        }
    }
    tree.remove(hold);                  // delete first word of text
    rewind(fp);                         // back to beginning
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
            if (strlen(p) > 1) {        // get same words again
                np = (pname) (p-2);     // pretend its a name object
                if (!tree.seek(np))     // look it up
                    missing++;
            }
            if (eol)
                break;
            p = q+1;
        }
    }
    tree.inorder();
    tree.set_process(print_again);
    tree.inorder();
    cout << "Were " << wordcount << " distinct words, now missing " << missing
            << "\n";
    cout << "(missing is number of occurrences of first word of the text.)\n";
}
