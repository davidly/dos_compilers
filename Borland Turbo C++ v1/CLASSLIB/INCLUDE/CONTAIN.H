#ifndef __CONTAIN_H
#define __CONTAIN_H

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
//      Container
//      ContainerIterator
//
// Description
//
//      Defines the abstract class Container.  Containers operate
//      on groups of other objects.
//      Defines the ContainerIterator class.  Container iterators are
//      use to step through the objects in a container class without
//      knowing the internals of the container class.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __IOSTREAM_H
#include <iostream.h>
#define __IOSTREAM_H
#endif

#ifndef __CLSTYPES_H
#include <clstypes.h>
#endif

#ifndef __OBJECT_H
#include <object.h>
#endif

// End Interface Dependencies ------------------------------------------------

// ForwardReference //

class ContainerIterator;


// Class //

class Container:  public Object
{
public:
            Container() { itemsInContainer = 0; }
            Container( const Container& );
    virtual ~Container();

    virtual ContainerIterator& initIterator() const = 0;

    virtual void            forEach( iterFuncType, void * );
    virtual Object&         firstThat( condFuncType, void * ) const;
    virtual Object&         lastThat( condFuncType, void * ) const;

    virtual classType       isA() const = 0;
    virtual char           *nameOf() const = 0;
    virtual hashValueType   hashValue() const = 0;
    virtual int             isEqual( const Object& ) const;
    virtual void            printOn( ostream& ) const;
    virtual void            printHeader( ostream& ) const;
    virtual void            printSeparator( ostream& ) const;
    virtual void            printTrailer( ostream& ) const;

            int             isEmpty() const { return (itemsInContainer == 0); }
            countType       getItemsInContainer() const { return itemsInContainer; }

protected:
            countType       itemsInContainer;

private:
    friend  class ContainerIterator;

};

// Description -------------------------------------------------------------
//
//      Defines the abstract class Container.  A Container is an object
//      which groups some number of other objects together.  This is
//      an abstract class and provides no method for adding and
//      removing objects from the container.  Those functions are
//      provided by derived classes.
//      
//      Constructor
//
//      Container
//
//      Copy constructor
//
// Public Members
//
//      isEmpty
//
//      Returns a 1 if the container has no members.  Returns a 0
//      otherwise.
//
//      initIterator
//
//      Initializes an iterator for this container.
//
//      firstThat
//
//      Returns the first object that satisfies the given condition.
//
//      lastThat
//
//      Returns the last object that satisfies the given condition.
//
//      isA
//
//      Inherited from Object and redeclared as pure virtual.
//
//      hashValue
//
//      Inherited from Object and redeclared as pure virtual.
//
//      nameOf
//
//      Inherited from Object and redeclared as pure virtual.
//     
//      isEqual
//
//      A deep-comparison equality operator.
//
//      getItemsInContainer
//
//      Returns the current number of objects in any container.
//
//      printOn
//
//      Displays each of the objects which make up a container.
//
//      printHeader
//
//      Displays a standard header.
//
//      printSeparator
//
//      Displays a standard trailer.
//
//      printTrailer
//
//      Displays a standard trailer.
//
// Inherited Members
//
//      operator new
//
//      Inherited from Object.
//
// Protected Members
//
//      itemsInContainer
//
//      A count of the number of items in currently in the container.
//
// Private Members
//
//      The class ContainerIterator is made a friend of class Object so that
//      objects can be iterated without knowing the internals of each class.
//
// End ---------------------------------------------------------------------


// Class //

class ContainerIterator
{
public:
    virtual ~ContainerIterator();

    virtual             operator int() = 0;
    virtual             operator Object&() = 0;
    virtual Object&     operator ++() = 0;
    virtual void        restart() = 0;
};

// Description -------------------------------------------------------------
//
//      Defines a container iterator object.
//
// Destructor
//
//      ~ContainerIterator
//
// Public Members
//
//      operator int
//
//      We are allowed one cast operator to a predefined type.  This
//      operator defines an explicit or an implicit cast from a
//      ContainerIterator to an integer.
//
//      operator Object&
//
//      Conversion from ContainerIterator to Object.
//
//      operator ++
//
//      The increment operator.
//
//      restart
//
//      Restarts an iterator without destroying it.
//
// End ---------------------------------------------------------------------


#endif // ifndef __CONTAIN_H //
