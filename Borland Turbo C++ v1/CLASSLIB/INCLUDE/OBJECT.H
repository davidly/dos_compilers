#ifndef __OBJECT_H
#define __OBJECT_H

//
// This file contains proprietary information of Borland International.
// Copying or reproduction without prior written approval is prohibited.
//
// Copyright (c) 1990
// Borland International
// 1800 Scotts Valley Dr.
// Scotts Valley, CA 95066
// (408) 438-8400
//

// Contents ----------------------------------------------------------------
//
//      Object
//      NOOBJECT
//      Object::Object                          constructor
//      Object::Object                          copy constructor
//
//      Error
//
//      operator <<
// 	    operator ==
// 	    operator !=
//
// Description
//
//      Defines the abstract base class Object.  Object is the class
//      at the root of the class library hierarchy.  Also defines the
//      instance class Error, which is used to indicate the presence of
//      no object reference.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __IOSTREAM_H
#include <iostream.h>
#define __IOSTREAM_H
#endif

#ifndef __STDDEF_H
#include <stddef.h>
#define __STDDEF_H
#endif

#ifndef __CLSTYPES_H
#include <clstypes.h>
#endif

#ifndef __CLSDEFS_H
#include <clsdefs.h>
#endif

// End Interface Dependencies ------------------------------------------------


// Class //

class Object
{
public:
            Object();
            Object( Object& );    
    virtual ~Object();

    virtual classType       isA() const = 0;
    virtual char            *nameOf() const = 0;
    virtual hashValueType   hashValue() const = 0;
    virtual int             isEqual( const Object& ) const = 0;
    virtual int             isSortable() const;
    virtual int             isAssociation() const;

            void           *operator new( size_t s );
	virtual void            forEach( iterFuncType, void * );
    virtual Object&         firstThat( condFuncType, void * ) const;
    virtual Object&         lastThat( condFuncType, void * ) const;
    virtual void            printOn( ostream& ) const = 0;

	static  Object         *ZERO;

protected:
	friend	ostream& operator <<( ostream&, const Object& );
};

// Description -------------------------------------------------------------
//
// 	Defines the abstract base class Object.  Object is the root of the
// 	hierarchy, as most classes within the hierarchy are derived from it.
// 	To create an class as part of this hierarchy, derive that class
// 	from Object and provide the required functions.  You may then
// 	use the derived class anywhere Object is called for.
//
// Constructors
//
//      Object()
//
//      Vanilla constructor.  Forces each derived class to provide one,
//      even if it's one that the compiler has to generate.
//
//      Object( Object& )
//
//      Copy constructor.  Constructs an object, then copies the contents
//      of the given object onto the new object.
//
// Destructors
//
//      ~Object
//
//      Run-of-the-mill destructor.  Turns out to be a useful place to set
//      breakpoints sometimes.
//
// Public Members
//
// 	    isA
//
// 	    Returns an unique identifying quantity of type classType.  You may
// 	    test this quantity to make sure that the object is of the class
// 	    desired.
//
// 	    nameOf
//
// 	    Returns a pointer to the character string which is the class name.
// 	
// 	    hashValue
//
// 	    Returns a unique key based on the value of an object.  The method
// 	    used in obtaining the key depends upon the implementation of the
// 	    function for each class.
//
//      isEqual
//
//      Returns 1 if the objects are the same type and the elements of the
//      object are equal, 0 otherwise.
//
//      operator new
//
//      Returns ZERO if the allocation of a new object fails.
//
//      forEach
//
//      Performs a function on each of the subobjects in an object.  If
//      an object has no subobject, forEach operates on that object.
//
//      firstThat
//
//      Returns a reference to the first object for which the given
//      conditional function returns a 1.  For object of non-container
//      classes, this will always be a reference to the object.
//
//      lastThat
//
//      Returns a reference to the last object for which the given
//      conditional function returns a 1.  For object of non-container
//      classes, this will always be a reference to the object.
//
//      ZERO
//
//      A reference to an error object.  Note that this differs from a
//      reference to a null object.  This is used by the Error class
//      to handle problems when the operator new cannot allocate space
//      for an object.
//
// 	    printOn
//
// 	    Displays the contents of an object.  The format of the output
// 	    is dictated by the implementation of the printOn function for
// 	    each class.
//
// Remarks
//
// Friends:
// 	    The operator << is overloaded and made of friend of the class Object 
// 	    so that invocations of << may call the protected member function,
// 	    printOn.
//
// End ---------------------------------------------------------------------


// Macro //

#define NOOBJECT		*(Object::ZERO)

// Summary -----------------------------------------------------------------
//
//      Provides an easy reference to theErrorObject
//
// End ---------------------------------------------------------------------


// Constructor //

inline  Object::Object()

// Summary -----------------------------------------------------------------
//
//      Default constructor for an object.  Not useful for much, but it
//      does provide a good place for setting breakpoints, because every
//      time an object gets created, this function must be called.
//
// End ---------------------------------------------------------------------
{
}
// End Constructor Object::Object //


// Constructor //

inline  Object::Object( Object& )

// Summary -----------------------------------------------------------------
//
//      Copy constructor for an object.  Again, not useful for much except
//      breakpoints.  This function will be called every time one object
//      is copied to another.
//
// End ---------------------------------------------------------------------
{
}
// End Constructor Object::Object //


// Class //

class Error:  private Object
{
public:
    virtual ~Error();
    virtual classType       isA() const;
    virtual char            *nameOf() const;
    virtual hashValueType   hashValue() const;
    virtual int             isEqual( const Object& ) const;
    virtual void            printOn( ostream& ) const;
            void            operator delete( void * );
};

// Description -------------------------------------------------------------
//
//      Defines the class Error.  The is exactly one instantiation of
//      class Error, namely theErrorObject.  The static object pointer
//      Object::ZERO points to this object.  The define NOOBJECT
//      redefines Object::ZERO (see CLSDEFS.H).  The operator Object::new
//      returns a pointer to theErrorObject if an attempt to allocate
//      an object fails.  You may test the return value of the new
//      operator against NOOBJECT to see whether the allocation failed.
//
// Public Members
//
// 	    isA
//
// 	    Returns the correct value for the Error class.
//
// 	    nameOf
//
// 	    Returns a pointer to the character string "Error".
// 	
//      hashValue
//
//      Returns a pre-defined value for the Error class.  All objects
//      of class Error (there is usually only one, theErrorObject) have
//      the same hash value.  This makes them hard to distinguish from
//      each other, but since there's only one, it doesn't matter.
//
//      isEqual
//
//      Determines whether the given object is theErrorObject.
//
//      printOn
//
//      Overrides the default printOn function since the Error class is
//      an instance class.
//
// End ---------------------------------------------------------------------


// Friend //

inline ostream& operator <<( ostream& outputStream, const Object& anObject )

// Summary -----------------------------------------------------------------
//
// 	    Write an object value to an output stream.
//
// Parameters
//
// 	    outputStream
// 	    The stream on which to display the formatted contents of the object.
//
// 	    anObject
// 	    The object to display.
//
// End ---------------------------------------------------------------------
{
    anObject.printOn( outputStream );
    return outputStream;
}
// End Friend operator << //


// Function //

inline  int operator ==( const Object& test1, const Object& test2 )

// Summary -----------------------------------------------------------------
//
//      Determines whether the first object is equal to the second.  We
//      do type checking on the two objects (objects of different
//      classes can't be equal, even if they're derived from each other).
//
// Parameters
//
//      test1
//
//      The first object we are testing.
//
//      test2
//
//      The second object we are testing.
//
// End ---------------------------------------------------------------------
{
    return ( (test1.isA() == test2.isA()) && test1.isEqual( test2 ) );
}
// End Function operator == //


// Function //

inline  int operator !=( const Object& test1, const Object& test2 )

// Summary -----------------------------------------------------------------
//
//      Determines whether the given object is not equal to this.  We
//      just reverse the condition returned from operator ==.
//
// Parameters
//
//      test1
//
//      The first object we are testing.
//
//      test2
//
//      The second object we are testing.
//
// End ---------------------------------------------------------------------
{
    return ( !( test1 == test2 ) );
}
// End Function operator != //


#endif // ifndef __OBJECT_H //
