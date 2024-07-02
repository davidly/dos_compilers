/* Copyright 1989 Manx Software Systems, Inc. All rights reserved
 	Synopsis
 
 	long int labs(long int j);
 
 
 	Description
 
 	    The labs function computes the absolute value of a long integer j.
 	If the result cannot be represented, the behavior is undefined.
 
 
 	Returns
 
 	    The labs function returns the absolute value.
*/

long int
labs(long int x)
{
	return ((x < 0)?-x:x);
}
