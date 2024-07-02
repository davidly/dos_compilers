#ifndef __LTIME_H
#define __LTIME_H

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
// 	    BaseTime
// 	    BaseTime::BaseTime						default constructor
// 	    BaseTime::BaseTime						copy constructor
// 	    BaseTime::BaseTime						constructor
// 	    BaseTime::hour
// 	    BaseTime::minute
// 	    BaseTime::second
// 	    BaseTime::hundreths
//
// 	    BaseTime::setHour
// 	    BaseTime::setMinute
// 	    BaseTime::setSecond
// 	    BaseTime::setHundreths
//
// 	    Time
// 	    Time::Time								default constructor
// 	    Time::Time								copy constructor
// 	    Time::Time								constructor
//
// Description
//
//  	Provides the class BaseTime as an abstract base class for
//  	storing and formatting times.
//  	times.
//
//  	Provides the Time class for storing times and converting them
//  	to ASCII strings of the form "1:23:45.67 pm"
//
// End ---------------------------------------------------------------------

// Interface Dependencies ---------------------------------------------------

#ifndef __ASSERT_H
#include <assert.h>
#define __ASSERT_H
#endif

#ifndef __DOS_H
#include <dos.h>
#define __DOS_H
#endif

#ifndef __STRNG_H
#include <strng.h>
#endif

// End Interface Dependencies ------------------------------------------------


// Class //

class BaseTime : public Sortable
{
public:
			unsigned hour() const;
			unsigned minute() const;
			unsigned second() const;
			unsigned hundredths() const;
			void 		setHour( unsigned char );
			void 		setMinute( unsigned char );
			void 		setSecond( unsigned char );
			void 		setHundredths( unsigned char );

    virtual classType       isA() const = 0;
    virtual char            *nameOf() const = 0;
    virtual hashValueType   hashValue() const;
    virtual int             isEqual( const Object& ) const;
    virtual int             isLessThan( const Object& ) const;
	virtual void            printOn( ostream& ) const = 0;
protected:
			BaseTime();
			BaseTime( const BaseTime& );
			BaseTime( unsigned char, unsigned char = 0, unsigned char = 0, unsigned char = 0 );
private:
			unsigned char HH;
			unsigned char MM;
			unsigned char SS;
			unsigned char HD;
};

// Description -------------------------------------------------------------
//
// 	    Defines a base time class.  This class provides a starting place
// 	    for deriving usuable time classes.
//
// Constructors
//
// 	    BaseTime()
//
// 	Default constructor
//
// 	    BaseTime( BaseTime& )
//
// 	Copy constructor
//
// 	    BaseTime( H, . . . )
//
// 	    Constructs a base time object from a parameter list.
//
// Public Members
//
// 	    hour
//
// 	    Returns the hour portion of the base time object.
//
// 	    minute
//
// 	    Returns the hour portion of the base time object.
//
// 	    second
//
// 	    Returns the second portion of the base time object.
//
// 	    hundreths
//
// 	    Returns the hundreths portion of the base time object.
//
// 	    setHour
//
// 	    Sets the hour portion of the base time object.
//
// 	    setMinute
//
// 	    Sets the minute portion of the base time object.
//
// 	    setHundreths
//
// 	    Sets the hundreths portion of the base time object.
//
// 	    operator String()
//
// 	    Conversion operator to type string.
//
// Private Members
//
// 	    HH
//
// 	    The hour portion of the base time object.
//
// 	    MM
//
// 	    The minute portion of the base time object.
//
// 	    SS
//
// 	    The second portion of the base time object.
//
// 	    HD
//
// 	    The hundreths portion of the base time object.
//
// End ---------------------------------------------------------------------


// Constructor //

inline BaseTime::BaseTime()

// Summary -----------------------------------------------------------------
//
// 	    Default constructor. Constructs a base time object.
//
// End ---------------------------------------------------------------------
{
	struct time t;              // From dos.h
	gettime( &t );
	HH = t.ti_hour;
	MM = t.ti_min;
	SS = t.ti_sec;
	HD = t.ti_hund;
}
// End Constructor BaseTime::BaseTime //


// Constructor //

inline BaseTime::BaseTime( const BaseTime& B ) :
	HH(B.HH), MM(B.MM), SS(B.SS), HD(B.HD)

// Summary -----------------------------------------------------------------
//
// 	    Copy constructor.  Constructs a base time object from another
// 	    base time object.
//
// Functional Description
//
//      We initialized each of the private data members of the class in
//      the prototype, hence the function body is null.
//
// End ---------------------------------------------------------------------
{
}
// End Constructor BaseTime::BaseTime //


// Constructor //

inline BaseTime::BaseTime( unsigned char H, unsigned char M, unsigned char S, unsigned char D )

// Summary -----------------------------------------------------------------
//
// 	    Constructor.  Constructs a base time object from the given
// 	    parameters.
//
// End ---------------------------------------------------------------------
{
	setHour( H );
	setMinute( M );
	setSecond( S );
	setHundredths( D );
}
// End Constructor BaseTime::BaseTime //


// Member Function //

inline unsigned BaseTime::hour() const

// Summary -----------------------------------------------------------------
//
// 	    Returns the hours portion of a base time object.
//
// End ---------------------------------------------------------------------
{
	return HH;
}
// End Member Function BaseTime::hour //


// Member Function //

inline unsigned BaseTime::minute() const

// Summary -----------------------------------------------------------------
//
// 	    Returns the minutes portion of a base time object.
//
// End ---------------------------------------------------------------------
{
	return MM;
}
// End Member Function BaseTime::minute //


// Member Function //

inline unsigned BaseTime::second() const

// Summary -----------------------------------------------------------------
//
// 	    Returns the seconds portion of a base time object.
//
// End ---------------------------------------------------------------------
{
	return SS;
}
// End Member Function BaseTime::second //


// Member Function //

inline unsigned BaseTime::hundredths() const

// Summary -----------------------------------------------------------------
//
// 	    Returns the hundreths portion of a base time object.
//
// End ---------------------------------------------------------------------
{
	return HD;
}
// End Member Function BaseTime::hundreths //


// Member Function //

inline void BaseTime::setHour( unsigned char anHour )

// Summary -----------------------------------------------------------------
//
// 	    Sets the hour portion of a base time object.
//
// End ---------------------------------------------------------------------
{
	assert( anHour < 24 );
	HH = anHour;
}
// End Member Function BaseTime::setHour //


// Member Function //

inline void BaseTime::setMinute( unsigned char M )

// Summary -----------------------------------------------------------------
//
// 	    Sets the minute portion of a base time object.
//
// End ---------------------------------------------------------------------
{
	assert( M < 60 );
	MM = M;
}
// End Member Function BaseTime::setMinute //


// Member Function //

inline void BaseTime::setSecond( unsigned char S )

// Summary -----------------------------------------------------------------
//
// 	    Sets the second portion of a base time object.
//
// End ---------------------------------------------------------------------
{
	assert( S < 60 );
	SS = S;
}
// End Member Function BaseTime::setSecond //


// Member Function //

inline void BaseTime::setHundredths( unsigned char D )

// Summary -----------------------------------------------------------------
//
// 	    Sets the hunderths portion of a base time object.
//
// End ---------------------------------------------------------------------
{
	assert( D < 100 );
	HD = D;
}
// End Member Function BaseTime::setHundreths //


// Class //

class Time: public BaseTime
{
public:
			Time();
			Time( const Time& );
			Time( unsigned char, unsigned char = 0, unsigned char = 0, 
				  unsigned char = 0 );
    virtual classType       isA() const;
    virtual char            *nameOf() const;
	virtual void            printOn( ostream& ) const;
};

// Description -------------------------------------------------------------
//
// 	    Defines a usable time class.
//
// Constructors
//
// 	    Time()
//
// 	    Default constructor
//
// 	    Time( Time& )
//
// 	    Copy constructor
//
// 	    Time( H, . . . )
//
// 	    Constructs a time object from a parameter list.
//
// Public Members
//
// 	    operator String()
//
// 	    Conversion operator to type string.
//
// Inherited Members
//
// 	    hour
//
// 	    Inherited from BaseTime
//
// 	    minute
//
// 	    Inherited from BaseTime
//
// 	    second
//
// 	    Inherited from BaseTime
//
// 	    hundreths
//
// 	    Inherited from BaseTime
//
// 	    setHour
//
// 	    Inherited from BaseTime
//
// 	    setMinute
//
// 	    Inherited from BaseTime
//
// 	    setHundreths
//
// 	    Inherited from BaseTime
//
// End ---------------------------------------------------------------------


// Constructor //

inline Time::Time() : BaseTime()

// Summary -----------------------------------------------------------------
//
// 	    Default constructor.
//
// Functional Description
//
//      We construct the Time object using the constructor for BaseTime,
//      hence the body of the constructor is null.
//
// End ---------------------------------------------------------------------
{
}
// End Constructor Time::Time //


// Constructor //

inline Time::Time( const Time& T ) : BaseTime( T )

// Summary -----------------------------------------------------------------
//
// 	    Copy constructor.
//
// Functional Description
//
//      We construct the Time object using the constructor for BaseTime,
//      hence the body of the constructor is null.
//
// End ---------------------------------------------------------------------
{
}
// End Constructor Time::Time //


// Constructor //

inline Time::Time( unsigned char H, unsigned char M, unsigned char S, 
                   unsigned char D ) :  BaseTime( H, M, S, D )

// Summary -----------------------------------------------------------------
//
// 	    Constructor from parameter list.
//
// Functional Description
//
//      We construct the Time object using the constructor for BaseTime,
//      hence the body of the constructor is null.
//
// End ---------------------------------------------------------------------
{
}
// End Constructor Time::Time //

#endif  // ifndef __LTIME_H //
