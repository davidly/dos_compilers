// D.J.Bustin. May 1991.
// CL transposes MS flags into equivalent ZTC flags
// compile with:
//      ztc -mi -o+space cl _mains.obj list mem
//

#define MAXARGS 128

#include <ctype.h>
#include <dos.h>
#include <errno.h>
#include <process.h>
#include <stdlib.h>
#include <stream.hpp>
#include <string.h>

extern "C"
{
#include "mem.h"
#include "list.h"
#include "assert.h"
}

struct flags_info {
    char *msc_flag;
    char *ztc_flag;
    };

const char *title = "CL - Zortech CL v3.0r1 Copyright (C) 1991 by Zortech\nAll Rights Reserved, written by D.J.Bustin.\n\n";

char *zargs[MAXARGS];

list_t flags_list = NULL;
int line;
int reading_config = 0; // set to 1 when reading CL.CFG to display warnings
int verbose = 0;
char file_name[80];
char *zflg;

void fatal_error(int l,int i);
int  read_config_file(char *);
void del_list();
char* checkin(char*);

void usage()
{
    cout << title;
    cout << "This small utility mimicks the Microsoft CL program and\n";
    cout << "saves the need to change makefiles, batch files and so on\n";
    cout << "by reading a file called CL.CFG which equates the various\n";
    cout << "MS-C compiler flags to the equivalent ZTC flags. It then\n";
    cout << "translates its command line flags and spawns ZTC with the\n";
    cout << "appropriate flags.\n\n";
    cout << "If the flag -V is specified then a warning is displayed\n";
    cout << "for unknown command line flags.\n\n";
    cout << "Usage:\n\tCL [flags] file(s) [@file]\n";
}

//---------------------------------------------------------------------------
// Main

main(int argc, char *argv[])
{
int i=0,j=0;
char *zcmd = "ZTC";

response_expand(&argc, &argv);

int nargs = argc;

if (argc==1)
    {
    usage();
    return 1;
    }

// initialization

    mem_init();
    list_init();
    read_config_file(argv[0]);

if (argv[1][0] == '?')
    {
    usage();
    return 0;
    }

zargs[j++] = mem_strdup(zcmd); // place holder

while (--nargs > 0)
    {
    i++;
    if ((argv[i][0] != '-') && (argv[i][0] != '/'))
        zargs[j] = mem_strdup(argv[i]);
    else
        switch(argv[i][1])
            {
            case '?':
                usage();
                return 0;
            case 'V':
                verbose = 1;
                break;
            default:
                if ((zflg=checkin(&argv[i][1]))!= NULL)
                    {
                    int lenarg = strlen(&argv[i][1]);
                    int extra_chars = lenarg - strlen(zflg);
                    if (extra_chars <0 )
                        extra_chars = 0;
                    zargs[j] = mem_malloc(strlen(zflg)+2+extra_chars);
                    assert(zargs[i-1]!=NULL);
                    zargs[j][0] = '-';
                    strcpy(&zargs[j][1],zflg);
                    if (extra_chars)
                        strcat(&zargs[j][1],&argv[i][1+strlen(zflg)]);
                    }
            }
        j++;
        }
zargs[++i] = NULL;
for (j=0;j<i;j++)
    cout << zargs[j] << " ";
cout << "\n";
if (spawnvp(0,zcmd,zargs) == -1)
    cerr << "Cannot execute ztc.com - check path\n";

for (j=0;j<i;j++)
    mem_free(zargs[j]);
del_list();
mem_term();
}

//---------------------------------------------------------------------------

int compare(flags_info *fip, char *str)
{
    int cmp;
    cmp = strncmp(str,fip->msc_flag,strlen(fip->msc_flag));
    if (cmp == 0 && reading_config)
        cout << "\n" << file_name << "(" << line
             << ") Warning: Redefinition attempted on flag /" << str << "\n";
return cmp;
}

//---------------------------------------------------------------------------
// Returns NULL if str not in flag list otherwise returns equivalent
// ztc flag

char *checkin(char *str)
{
int i, cmp;
list_t le;
flags_info *fip;
int start = 0;

int endstop = list_nitems(flags_list);
int size = endstop - start;
if (size == 0) return 0;
fip = (flags_info*)list_ptr(flags_list);                // test start
if (compare(fip, str) == 0)
    return fip->ztc_flag;
fip = (flags_info*)list_ptr(list_last(flags_list));     // test end
if (compare(fip, str) == 0)
    return fip->ztc_flag;

if (size == 1)
    return NULL;

while (size>0)
    {
    i = (start+endstop) / 2;
    le = list_nth(flags_list, i);
    fip = (flags_info*)list_ptr(le);
    cmp = compare(fip, str);
    if (cmp == 0)
        return fip->ztc_flag;
    else
        if (cmp > 0)
            start = i;
        else
            if (cmp < 0)
                endstop = i;
    size /= 2;
    }
if (verbose)
        cout << "Warning: No equivalent flag found in CL.CFG for /" << str << "\n";
return NULL;
}

//---------------------------------------------------------------------------

int add_flag(char *msc, char *ztc)
{
if ((msc == NULL) || checkin(msc)!=NULL)
    return 0;

flags_info *flp = mem_malloc(sizeof(flags_info));
assert (flp != NULL);

flp->msc_flag = mem_strdup(msc);
assert(flp->msc_flag);

if (ztc != NULL)
    {
    flp->ztc_flag = mem_strdup(ztc);
    assert(flp->msc_flag);
    }
else
    flp->ztc_flag = NULL;

list_t le,ll;
void *vop;
char *cp;
for (le=flags_list;le;le = list_next(le)) // find out where to insert str
    {
    ll = le;
    vop = list_ptr(le);
    cp = ((flags_info*)vop)->msc_flag;
    if (strcmp(msc, cp) < 0)
        break;
    }
if (le != NULL && strcmp(msc, cp) < 0)
    {
    if ((le = list_prepend(&le, flp)) == NULL)
        fatal_error(__LINE__,ENOMEM);
    if (ll == flags_list)
        flags_list = le;
    else
        list_next(list_prev(flags_list,ll)) = le;
    }
else
    {
    if (le == NULL)
        le = flags_list;
    if ((le = list_append(&le, flp)) == NULL)
        fatal_error(__LINE__,ENOMEM);
    }
if (flags_list == NULL)
    flags_list = le;
return 1;
}

//---------------------------------------------------------------------------
// Delete all elements in flags_list

void del_list()
{
list_t le;
flags_info *fip;
if (flags_list == NULL)
    return;
for (le=flags_list; le;le=list_next(le))
    {
    fip = list_ptr(le);
    mem_free(fip->msc_flag);
    if (fip->ztc_flag != NULL)
        mem_free(fip->ztc_flag);
    }
list_free(&flags_list,mem_freefp);
}

//---------------------------------------------------------------------------

int  read_config_file(char *cldir)
{
FILE *fp;
char buffer[256];
char ch;
char *str;
char *ptr;
char *equals;

strcpy(file_name,cldir);
ptr = strrchr(file_name, '\\');
if (ptr++ != NULL)
    *ptr = NULL;
strcat(file_name,"CL.CFG");

if ((fp = fopen(file_name, "rb")) == NULL)
    {
    cerr << "\nError: Cannot open file: " << file_name << "\n";
    return 1;
    }

line = 0;
reading_config = 1;
while ((fgets(buffer, 255, fp)) != NULL)
    {
    str = buffer;
    line++;

    if (str[0] == '\n' || str[0] == '\r' || str[0] == '*')
        continue;
    equals = strchr(str, '=');
    ptr = strchr(str, '\r');
    if (ptr != NULL)
        *ptr = NULL;
    else
        {
        ptr = strchr(str, '\n');
        if (ptr != NULL)
            *ptr = NULL;
        }
    if (equals == NULL)
        {
        cerr << file_name << "(" << line << ") - Error in configuration file\n";
        return 1;
        }
    *equals++ = NULL;
    add_flag(str, equals);
    } // end of main while

fclose(fp);
reading_config = 0;
return 0;   // ok
}

//---------------------------------------------------------------------------

void fatal_error(int l,int i)
{
cout << "\n";
cerr << "Fatal Error: ";
switch(i)
    {
    case ENOMEM:
        cerr << "Out of memory";
        break;
    default:
        cerr << "RC = "<< i;
    }
#if DEBUG
    cerr << " at line " << l;
#endif
cerr << "\n";
exit(i);
}



