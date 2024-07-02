/*
	EXAMPLE THREE
	
	This program illustrates the various types of data available
	in a 'C' program.
*/

#include <stdio.h>

int			i=1;
unsigned	ui=2;
long		l=3;
unsigned long ul=4;

char		c1='A';
char		c2='\n';
char		c3=0xa3;

float		f1=1.3;
float		f2=1.678912;
double		d1=1.0;
double		d2=123456789.123456;

char		a_c[128]= "this is a test string";
int			a_i[10]={100,101,102,103,104,105,106,107,108,109};

struct	test_s {
	int		i;
	int		j;
	unsigned fl1:4;
	unsigned fl2:2;
	unsigned fl3:6;
	unsigned fl4:6;
};

struct	test_s	str;
struct	test_s	a_str[4];

char	*p_c=a_c;
struct	test_s	*p_str=a_str;
int		*p_i=a_i;

main()
{
	char	*p;

	printf("EXAMPLE 3\n");
	p = a_c;
	for (i=0;i<10;i++) {
		int		j;
		unsigned k;

		j = i*i;
		k = j*i;
		sprintf(p,"%d squared is %d and cubed is %d",i,j,k);
		puts(a_c);
	}
	printf("EXAMPLE 3 finished\n");
	exit(0);
}
