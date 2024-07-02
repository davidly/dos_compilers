/* Copyright 1989 Manx Software Systems, Inc. All rights reserved
 	Synopsis
 
 	int abs(int j);
 
 
 	Description
 
 	    The abs function computes the absolute value of an integer j. If
 	the result cannot be represented, the behavior is undefined.
 
 
 	Returns
 
 	    The abs function returns the absolute value.
*/

int
abs(register int x)
{
	return ((x<0)?-x:x);
}
