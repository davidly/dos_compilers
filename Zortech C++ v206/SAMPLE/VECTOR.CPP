// File Vector.cpp
//////////////////////////////////////////////////////
// Vector is an integer array type, which allows the 
// creation of bounds checked integer arrays.

#include <stdlib.h>
#include <stream.hpp>				// standard C++ i/o header
#include "vector.hpp"				// class definition for Vector


// a constructor with no arguments - this allows us 
// to have arrays of Vectors!

Vector::Vector(void)
{
	size = 10;						// default Vectoror size
	p = new int[size];				// uses new to allocate
									// space from the heap
}

// Now a constructor which takes a size argument
// note that we can have two constructors, the 
// compiler will distinguish between then on the 
// basis of their arguments.

Vector::Vector(int n)
{

	// if the size is negative use stream i/o to 
	// print an error message to stderr and exit

	if (n < 0) {
		cerr << "illegal Vector size: " << n << "\n";
		exit(1);
	}

	// Ok we can allocate room for the array from the 
	// heap using C++ new (neater than malloc)

	size = n;
	p = new int[size];
}

// Yet another constructor - make a Vector from a 
// normal array

Vector::Vector(int a[], int n)
{
	// as before

	if (n < 0) {
		cerr << "illegal Vector size: " << n << "\n";
		exit(1);
	}
	size = n;
	p = new int[size];

	// now copy the array into the Vector
	// notice how we declare i actually inside the for
	// loop - another "better C" facility

	for (int i = 0; i < size; ++i)
		p[i] = a[i];
}

// Finally a copy constructor, lets us use the syntax
// Vector a[4];
// ... initialize a here
// Vector b = a;
// and also use a Vector as a parameter to functions.
// Notice it takes a reference to a Vector as parameter
// Yes, C++ has pass by reference!

Vector::Vector(Vector& v)
{
	// This is how you access a member

	size = v.size;
	p = new[size];

	for (int i = 0; i < size; ++i)
		p[i] = v.p[i];
}


// Now we need to be able to get at the elements of a
// Vector. We overload the [] operator so that we can do 
// it in exactly the same way as we would a normal 
// array. See that we return a reference to the Vector,
// this means we can use the operator on either side 
// of an assignment:
//	Vector v[4];
// v[2] = 5;
// int x = v[2];


int& Vector::operator[](int i)
{
	if (i < 0 || i > ub()) {
		cerr << "illegal Vector index: " << i << "\n";
		exit(1);
	}

	// ub() is an access function defined inline in 
	// the class definition. Inline means the actual code 
	// generated is inserted, not a function call

	return (p[i]);			// reference to the int value of
							// the requested element
}

// Finally we also overload the equality operator so 
// that we can copy one Vector into another. The function
// will only copy the number of elements equal to the 
// size of the smallest Vector.
// Vector x[2], y[4]
// x = y;
// will copy two elements of y into x (and warn you).

// note only one argument, the other is implied

Vector& Vector::operator=(Vector& v)
{
	int s = (size < v.size) ? size : v.size;

	if (v.size != size)
		cerr << "Warning: copying different size arrays "
			<< size << " and " << v.size << "\n";

	for (int i = 0; i < s; ++i)
		p[i] = v.p[i];

	// return a reference to the implied argument
	// this is always a pointer to the object which 
	// has invoked the member function

	return *this;
}

// Finally an addition operator so that we can add 
// Vectors together. YOU can try your hand at adding 
// subtraction, multiplication, division etc.

// Look! we have a function that returns a Vector, just
// as if it we an inbuilt data type!

Vector Vector::operator+(Vector& v)
{
	int s = (size < v.size) ? size : v.size;
	Vector sum(s);				// here's where we add them

	if (v.size != size)
		cerr << "Warning: adding different size arrays "
			<< size << " and " << v.size << "\n";

	for (int i = 0; i < s; ++i)
		sum.p[i] = p[i] + v.p[i];

	return (sum);
}

