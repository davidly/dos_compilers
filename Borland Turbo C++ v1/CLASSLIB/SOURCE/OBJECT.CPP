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
//      Object::~Object
//      Object::isSortable
//      Object::isAssociation 
//      Object::operator new
//      Object::forEach
//      Object::firstThat 
//      Object::lastThat  
//      Object::operator delete 
//
//      Error::~Error
//      Error::isA
//      Error::nameOf 
//      Error::printOn
//      Error::hashValue  
//      Error::isEqual
//
//      theErrorObject
// 	    Object::ZERO							initializer
//
// Description
//
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __OBJECT_H
#include <object.h>
#endif

// End Interface Dependencies ------------------------------------------------


Object::~Object()

// Summary -----------------------------------------------------------------
//
//      Default destructor for an object.  Doesn't do much, but it
//      forces all classes derived from Object to have virtual
//      destructors, which is essential for proper cleanup.  It also
//      provides a good place for setting breakpoints, because every
//      time an object gets destroyed, this function will be called.
//
// End ---------------------------------------------------------------------
{
}
// End Destructor Object::~Object //


// Member Function //

int Object::isSortable() const

// Summary -----------------------------------------------------------------
//
//      indicates whether the object defines comparison operators
//
// Parameters
//
//      none
//
// Remarks
//
//      A basic Object is not sortable
//
// End ---------------------------------------------------------------------
{
    return 0;
}
// End Member Function Object::isSortable //


// Member Function //

int Object::isAssociation() const

// Summary -----------------------------------------------------------------
//
//      indicates whether the object is derived from class Association
//
// Parameters
//
//      none
//
// Remarks
//
//      A basic Object is not derived from class Association
//
// End ---------------------------------------------------------------------
{
    return 0;
}
// End Member Function Object::isAssociation //


// Member Function //

void *Object::operator new( size_t s )

// Summary -----------------------------------------------------------------
//
//      replacement for the standard operator new().  Returns ZERO
//      if attempted allocation fails.
//
// Parameters
//
//      s
//
//      number of bytes to allocate
//
// Functional Description
//
//      we call the global operator new() and check whether it succeeded.
//      If it succeeded, we return the block that it allocated.  If it
//      failed, we return ZERO.
//
// End ---------------------------------------------------------------------
{
    void *allocated = ::operator new( s );
    if( allocated == 0 )
        return ZERO;
    else
        return allocated;
}
// End Member Function Object::operator new //


// Member Function //

void Object::forEach( iterFuncType actionPtr, void *paramListPtr )

// Summary -----------------------------------------------------------------
//
//      Calls the given iterator function on this object.
//
// Parameters
//
//      actionPtr
//
//      Pointer to the action routine which is to be called for this object.
//
//      paramListPtr
//
//      Pointer to the list of parameters which will be passed along to
//      the action routine.
//
// Functional Description
//
//      We call the given function, passing our object and the list of
//      parameters that was given to us.
//
// Remarks
//
//  warnings:
//      The action routine must have a prototype of the form:
//          void action( Object&, void * );
//
// End ---------------------------------------------------------------------
{
    ( *actionPtr )( *this, paramListPtr );
}
// End Member Function Object::forEach //


// Member Function //

Object& Object::firstThat( condFuncType testFuncPtr, void *paramListPtr ) const

// Summary -----------------------------------------------------------------
//
//      Calls the given conditional test function on this object.
//
// Parameters
//
//      testFuncPtr
//
//      Pointer to the conditional test routine which is to be called 
//      for this object.
//
//      paramListPtr
//
//      Pointer to the list of parameters which will be passed along to
//      the conditional test routine.
//
// Return Value
//
//      Returns this if the this satisfies the condition.  Returns
//      NOOBJECT otherwise.
//
// Functional Description
//
//      We call the given function, passing our object and the list of
//      parameters that was given to us.  If the function returns
//      a 1, we return this object, otherwise we return NOOBJECT.
//
// Remarks
//
//  warnings:
//      The conditional test routine must have a prototype of the form:
//          int test( Object&, void * );
//      The conditional test routine must return 1 if the given object
//      satisfies the condition.
//
// End ---------------------------------------------------------------------
{
    if( ( *testFuncPtr )( *this, paramListPtr ) )
    {
        return( *this );
    }
    else // our object doesn't satisfy the condition //
    {
		return( NOOBJECT );
    }
}
// End Member Function Object::firstThat //


// Member Function //

Object& Object::lastThat( condFuncType testFuncPtr, void *paramListPtr ) const

// Summary -----------------------------------------------------------------
//
//      Calls the given conditional test function on this object.  For
//      non-container objects, lastThat is the same as firstThat.
//
// Parameters
//
//      testFuncPtr
//
//      Pointer to the conditional test routine which is to be called 
//      for this object.
//
//      paramListPtr
//
//      Pointer to the list of parameters which will be passed along to
//      the conditional test routine.
//
// Functional Description
//
//      We call the firstThat function.
//
// Remarks
//
//  warnings:
//      The conditional test routine must have a prototype of the form:
//          int test( Object&, void * );
//      The conditional test routine must return 1 if the given object
//      satisfies the condition.
//
// End ---------------------------------------------------------------------
{
    return Object::firstThat( testFuncPtr, paramListPtr );
}
// End Member Function Object::lastThat //


// Destructor //

Error::~Error()

// Description -------------------------------------------------------------
//
//      We can't really destroy theErrorObject.
//
// End ---------------------------------------------------------------------
{
}
// End Destructor Error::~Error //


// Member Function //

void Error::operator delete( void * )

// Summary -----------------------------------------------------------------
//
//      Can't delete an Error object... so we pretend that we did.
//
// End ---------------------------------------------------------------------
{
}
// End Member Function Error::operator delete //

// Member Function //

classType Error::isA() const

// Summary -----------------------------------------------------------------
//
// 	    Returns the class type of the error object.
//
// End ---------------------------------------------------------------------
{
    return errorClass; 
}
// End Member Function Error::isA //


// Member Function //

char *Error::nameOf() const

// Summary -----------------------------------------------------------------
//
// 	    Returns a pointer to the character string "Error."
//
// End ---------------------------------------------------------------------
{
    return "Error";
}
// End Member Function Error::nameOf //


// Member Function //

void Error::printOn( ostream& outputStream ) const

// Summary -----------------------------------------------------------------
//
//      Error class override of the usual printOn.  Since there isn't
//      really any object to print, we emit an appropriate message.
//
// Parameters
//
// 	outputStream
// 	The stream on which to display the formatted contents of the object.
//
// End ---------------------------------------------------------------------
{
    outputStream << "Error\n";
}
// End Member Function Error::printOn //


// Member Function //

hashValueType   Error::hashValue() const

// Summary -----------------------------------------------------------------
//
//      Returns the value for use when hashing an error object.
//      There should be only one object of class Error, so it's ok
//      to return the same value every time.
//
// End ---------------------------------------------------------------------
{
    return ERROR_CLASS_HASH_VALUE;
}
// End Member Function Error::hashValue //


// Member Function //

int Error::isEqual ( const Object& testObject ) const

// Summary -----------------------------------------------------------------
//
//      Determines whether the given object is theErrorObject.
//
// Parameters
//
//      testObject
//
//      The object we are testing against theErrorObject.
//
// Return Value
//
//      Returns 1 if the given object is theErrorObject, 0 otherwise.
//
// Functional Description
//
//      The only way we get called here is if this is a pointer to 
//      theErrorObject.  We test the address of our given object to see
//      if it is the address of theErrorObject.
//
// End ---------------------------------------------------------------------
{
    return &testObject == this;
}
// End Member Function Error::isEqual //


// Variable //

Error    theErrorObject;

// Description -------------------------------------------------------------
//
//      Defines a dummy object to which Object::ZERO will point.  We only
//      need this so we don't ever try to dereference a null pointer.
//
// End ---------------------------------------------------------------------


// Initializer //

Object *Object::ZERO = (Object *)&theErrorObject;

// Description -------------------------------------------------------------
//
//      Initializes Object::ZERO.   We wait to do this here because we
//      have to get theErrorObject defined before we initialize Object::ZERO.
//
// End ---------------------------------------------------------------------
