/*** 
*wild.c - wildcard expander
*
*   Copyright (c) 1985-1988, Microsoft Corporation.  All rights reserved.
*
*Purpose:
*    expands wildcards in argv
*
*    handles '*' (none or more of any char), '?' (exactly one char), and
*    '[string]' (chars which match string chars or between n1 and n2 if
*    'n1-n2'in string inclusive)
*
*******************************************************************************/

#include <stdio.h>
#include <register.h>
#include <ctype.h>
#include <msdos.h>


/*
** these are the data structures
**
**     __argv
**     -------     ------
**     |     |---->|    |---->"arg0"
**     -------     ------
**                 |    |---->"arg1"
**                 ------
**                  ....
**                 ------
**                 |    |---->"argn"
**                 ------
**                 |NULL|
**                 ------
**                                       argend
**                                       -------
**     -------                           |     |
**     |     | __argc                    -------
**     -------                              |
**                                          |
**  arghead                                 V
**  ------     ---------                ----------
**  |    |---->|   |   |----> .... ---->|   |NULL|
**  ------     ---------                ----------
**               |                        |
**               V                        V
**            "narg0"                  "nargn"
*/

#define SLASHCHAR   '\\'
#define FWDSLASHCHAR '/'
#define SLASH       "\\"
#define FWDSLASH    "/"
#define STAR        "*.*"

#define WILDSTRING  "*?"

char *strdup();
char *strpbrk();
char *strcpy();
char *strncpy();
char *strcat();
char *malloc();
char *_find();

static int match ();
static int add ();
static sort ();

extern int __argc;
extern char **__argv;

struct argnode {
    char *argptr;
    struct argnode *nextnode;
};

static struct argnode *arghead;
static struct argnode *argend;

/*** 
*int _cwild() - wildcard expander
*
*Purpose:
*    expands wildcard in file specs in argv
*
*    handles '*' (none or more of any char), '?' (exactly one char), and
*    '[string]' (chars which match string chars or between n1 and n2
*    if 'n1-n2' in string inclusive)
*
*Entry:
*
*Exit:
*    returns 0 if successful, -1 if any malloc() calls fail
*    if problems with malloc, the old argc and argv are not touched
*
*Exceptions:
*
*******************************************************************************/

int
_cwild ()
{
    REG1 char **argv = __argv;
    REG2 struct argnode *nodeptr;
    REG3 int argc;
    REG4 char **tmp;
    char *wchar;
    int  ptr, sptr, arglen;

    arghead = argend = NULL;

    for (argv = __argv; *argv; argv++)  /* for each arg... */
        if ( *(*argv)++ == '"' )
            /* strip leading quote from quoted arg */
        {
            if (add(*argv))
                return(-1);
        }
        else if (wchar = strpbrk( *argv, WILDSTRING )) {
            /* attempt to expand arg with wildcard */
            if (match( *argv, wchar ))
                return(-1);
        }
        else if (add( *argv ))  /* normal arg, just add */
            return(-1);

    /* count the args */
    for (argc = 0, nodeptr = arghead; nodeptr;
            nodeptr = nodeptr->nextnode, argc++)
            ;

    /* try to get new arg vector */
    if (!(tmp = (char **)malloc(sizeof(char *)*(argc+1))))
        return(-1);

    /* the new arg vector... */
    __argv = tmp;

    /* the new arg count... */
    __argc = argc;

    /* install the new args */
    for (nodeptr = arghead; nodeptr; nodeptr = nodeptr->nextnode)
        *tmp++ = nodeptr->argptr;

    /* the terminal NULL */
    *tmp = NULL;

    /* free up local data */
    for (nodeptr = arghead; nodeptr; nodeptr = arghead) {
        arghead = arghead->nextnode;
        free(nodeptr);
    }

    /* return success */
    return(0);
}


/*** 
*match(arg, ptr) - [STATIC]
*
*Purpose:
*
*Entry:
*
*Exit:
*
*Exceptions:
*
*******************************************************************************/

static int
match (arg, ptr)
REG4 char *arg;
REG1 char *ptr;
{
    REG2 char *new;
    REG3 int length;
    char *all;
    REG5 struct argnode *first;
    REG6 int gotone = 0;

    while (ptr != arg && *ptr != SLASHCHAR && *ptr != FWDSLASHCHAR
        && *ptr != ':') {
        /* find first slash or ':' before wildcard */
        ptr--;
    }

    if (*ptr == ':' && ptr != arg+1) /* weird name, just add it as is */
        return(add(arg));

    if (*ptr == SLASHCHAR || *ptr == FWDSLASHCHAR 
        || *ptr == ':') /* pathname */
        length = ptr - arg + 1; /* length of dir prefix */

    if (new = _find(arg)) { /* get the first file name */
        first = argend;

        do  { /* got a file name */
            if (strcmp(new, ".") && strcmp(new, "..")) {
                if (*ptr != SLASHCHAR && *ptr != ':'
                    && *ptr != FWDSLASHCHAR ) {
                    /* current directory; don't need path */
                    if (!(arg = strdup(new)) || add(arg))
                        return(-1);
                }
                else    /* add full pathname */
                    if (!(all=malloc(length+strlen(new)+1))
                        || add(strcpy(strncpy(all,arg,length)+length,new)
                        - length))
                        return(-1);

                gotone++;
            }

        } 
        while (new = _find(NULL));  /* get following files */

        if (gotone) {
            sort(first ? first->nextnode : arghead);
            return(0);
        }
    }

    return(add(arg)); /* no match */
}

/*** 
*add(arg) - [STATIC]
*
*Purpose:
*
*Entry:
*
*Exit:
*
*Exceptions:
*
*******************************************************************************/

static int
add (arg)
char *arg;
{
    REG1 struct argnode *nodeptr;

    if (!(nodeptr = (struct argnode *)malloc(sizeof(struct argnode))))
        return(-1);

    nodeptr->argptr = arg;
    nodeptr->nextnode = NULL;

    if (arghead)
        argend->nextnode = nodeptr;
    else
        arghead = nodeptr;

    argend = nodeptr;
    return(0);
}


/*** 
*sort(first) - [STATIC]
*
*Purpose:
*
*Entry:
*
*Exit:
*
*Exceptions:
*
*******************************************************************************/

static
sort (first)
REG2 struct argnode *first;
{
    REG1 struct argnode *nodeptr;
    REG3 char *temp;

    if (first) /* something to sort */
        while (nodeptr = first->nextnode) {
            do  {
                if (strcmp(nodeptr->argptr, first->argptr) < 0) {
                    temp = first->argptr;
                    first->argptr = nodeptr->argptr;
                    nodeptr->argptr = temp;
                }
            } 
            while (nodeptr = nodeptr->nextnode);

            first = first->nextnode;
        }
}
