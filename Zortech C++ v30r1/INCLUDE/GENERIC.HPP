/*_ generic.hpp   Tue Jul  5 1988   Modified by: Walter Bright */

#ifndef __GENERIC_H
#define __GENERIC_H	1

/* Name concatenator functions	*/
#define name2(n1,n2)		n1 ## n2
#define name3(n1,n2,n3)		n1 ## n2 ## n3
#define name4(n1,n2,n3,n4)	n1 ## n2 ## n3 ## n4

typedef int (*GPT)	(int,char *);
extern  int genericerror(int,char *);

#define set_handler(generic,type,x)	set_##type##generic##_handler(x)
#define errorhandler(generic,type)	type##generic##handler
#define callerror(generic,type,a,b)	(*errorhandler(generic,type))(a,b)

#define declare(a,type)			a##declare(type)
#define implement(a,type)		a##implement(type)
#define declare2(a,type1,type2)		a##declare2(type1,type2)
#define implement2(a,type1,type2)	a##implement2(type1,type2)

#endif /* __GENERIC_H */
