#ifndef __CLSTYPES_H
#define __CLSTYPES_H

//
// This file contains proprietary information of Borland International.
// Copying or reproduction without prior written approval is prohibited.
//
// Copyright (c) 1990
// Borland International
// 1800 Green Hills Road
// Scotts Valley, CA 95066
// (408) 438-8400
//

// Contents ----------------------------------------------------------------
//
//      classType
//      hashValueType
//      sizeType
//      iterFuncType
//      condFuncType
//      countType
//
//      objectClass
//      errorClass
//      sortableClass
//      stringClass
//      listElementClass
//      doubleListElementClass
//      containerClass
//      stackClass
//      queueClass
//      dequeClass
//      collectionClass
//      hashTableClass
//      bagClass
//      setClass
//      dictionaryClass
//      associationClass
//      arrayClass
//      sortedArrayClass
//      listClass
//      doubleListClass
//		timeClass
//		dateClass
//		longClass
//
//      __lastLibClass
//      __firstUserClass
//
//      directoryClass
//
//      __lastClass
//
// Description
//
//      Defines types for the class library.
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __LIMITS_H
#include <limits.h>
#endif

// End Interface Dependencies ------------------------------------------------


// Section -----------------------------------------------------------------
//                                  types                                 //
// End ---------------------------------------------------------------------


// Type //

typedef unsigned int classType;

// Description -------------------------------------------------------------
//
//      Defines the type of a class.
//
// End ---------------------------------------------------------------------


// Type //

typedef unsigned int    hashValueType;

// Description -------------------------------------------------------------
//
//      Defines a returned hash value.
//
// End ---------------------------------------------------------------------


// Type //

typedef unsigned int    sizeType;

// Description -------------------------------------------------------------
//
//      Defines the size of a storage area.
//
// End ---------------------------------------------------------------------


// Type //

class Object;
typedef void ( *iterFuncType )( class Object&, void * );

// Description -------------------------------------------------------------
//
//      Defines a pointer to an iteration function.  The iteration function
//      takes an Object reference and a point to a list of parameters to
//      the function.  The parameter list pointer may be NULL.
//
// End ---------------------------------------------------------------------


// Type //

typedef int ( *condFuncType )( const class Object&, void * );

// Description -------------------------------------------------------------
//
//      Defines a pointer to a function which implements a conditional test
//      and returns 0 if the condition was met, non-zero otherwise.  The
//      non-zero values are defined by the individual function.
//
// End ---------------------------------------------------------------------


// End Section types //


// Type //

typedef int    countType;

// Description -------------------------------------------------------------
//
//      Defines a container for counting things in the class library.
//
// End ---------------------------------------------------------------------


// End Section types //


// Section -----------------------------------------------------------------
//                               defines                                  //
// End ---------------------------------------------------------------------

// LiteralSection ----------------------------------------------------------
//
//      class type codes
//
// Description
//
//      Defines codes for the class types in the class library.
//      The ranges for the codes and their use are defined below.
//
//      0 . . __lastLibClass:               Reserved for class provided
//                                          in the library.
//      __firstUserClass . . __lastClass    Available for general use.
//
// End ---------------------------------------------------------------------

#define    objectClass				0
#define    errorClass               (objectClass+1)
#define    sortableClass            (errorClass+1)
#define    stringClass              (sortableClass+1)
#define    listElementClass         (stringClass+1)
#define    doubleListElementClass   (listElementClass+1)
#define    containerClass           (doubleListElementClass+1)
#define    stackClass               (containerClass+1)
#define    queueClass               (stackClass+1)
#define    dequeClass               (queueClass+1)
#define    collectionClass          (dequeClass+1)
#define    hashTableClass           (collectionClass+1)
#define    bagClass                 (hashTableClass+1)
#define    setClass                 (bagClass+1)
#define    dictionaryClass          (setClass+1)
#define    associationClass         (dictionaryClass+1)
#define    arrayClass               (associationClass+1)
#define    sortedArrayClass         (arrayClass+1)
#define    listClass                (sortedArrayClass+1)
#define    doubleListClass          (listClass+1)
#define    timeClass                (doubleListClass+1)
#define	   dateClass				(timeClass+1)
#define	   longClass				(dateClass+1)

#define    __lastLibClass           255
#define    __firstUserClass         __lastLibClass+1

#define    __lastClass              UINT_MAX

// End LiteralSection class type codes //

// End Section defines //


#endif // ifndef __CLSTYPES_H //

