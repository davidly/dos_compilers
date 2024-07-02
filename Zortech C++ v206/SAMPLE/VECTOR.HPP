// File Vector.hpp
//////////////////////////////////////////////////////
// Vector is an integer array type, which allows the 
// creation of bounds checked integer arrays.

#ifndef VECT_HPP					// prevent multiple includes
#define VECT_HPP

// Here we create a new data type Vector with the same 
// rights and privileges as an inbuilt data type

class Vector {
	// private variables cannot be accessed by 
	// functions which do not belong to class Vector
	int* p;					// base pointer
	int size;				// number of elements
public:
	// constructors and destructor
	Vector();				// create a size 10 array
	Vector(int n);				// create a size n array
	Vector(Vector& v);			// initialization by Vector
	Vector(int a[], int n);			// initialization by array
	~Vector() { delete p; }			// destructor coded inline
	// other member functions
	int ub() { return (size-1); }		// upper bound (inline)
	int& operator[] (int i);		// range checked element
	Vector& operator=(Vector& v);		// assignment operator
	Vector operator+(Vector& v);		// addition operator
};										// dont forget the ';'

#endif
