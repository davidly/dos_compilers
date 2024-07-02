#ifndef __LDATE_H
#define __LDATE_H


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
// 	BaseDate
//
// Description
//
/*  Provides BaseDate as an abstract base class for handling date    */
/*  storage and formatting                                           */
//
/*  Provides the Date class for storing dates and converting them    */
/*  to an ASCII string of the form                                   */
/*                                                                   */
/*      January 1, 1990                                              */
//
// End ---------------------------------------------------------------------

#include <assert.h>
#include <dos.h>
#include "strng.h"

class BaseDate : public Sortable
{
public:
    unsigned Month() const;
    unsigned Day() const;
	unsigned Year() const;
    void SetMonth( unsigned char );
    void SetDay( unsigned char );
	void SetYear( unsigned );

    virtual classType       isA() const = 0;
    virtual char            *nameOf() const = 0;
    virtual hashValueType   hashValue() const;
    virtual int             isEqual( const Object& ) const;
    virtual int             isLessThan( const Object& ) const;
    virtual void            printOn( ostream& ) const = 0;
protected:
	BaseDate();
    BaseDate( unsigned char, unsigned char, unsigned );
	BaseDate( const BaseDate& );
	~BaseDate();
private:
	unsigned char MM;
	unsigned char DD;
	unsigned int YY;
};

inline BaseDate::BaseDate()
{
	struct date d;
	getdate( &d );
	MM = d.da_mon - 1;
	DD = d.da_day;
	YY = d.da_year + 1980;
}

inline BaseDate::BaseDate( unsigned char M, unsigned char D, unsigned Y )
{
	SetMonth( M );
	SetDay( D );
	SetYear( Y );
}

inline BaseDate::BaseDate( const BaseDate& B ) :
	MM(B.MM), DD(B.DD), YY(B.YY)
{
}

inline unsigned BaseDate::Month() const
{
	return MM;
}

inline unsigned BaseDate::Day() const
{
	return DD;
}

inline unsigned BaseDate::Year() const
{
	return YY;
}

inline void BaseDate::SetMonth( unsigned char M )
{
	assert( M > 0 && M < 13 );
	MM = M - 1;
}

inline void BaseDate::SetDay( unsigned char D )
{
	assert( D < 32 );
	DD = D;
}

inline void BaseDate::SetYear( unsigned Y )
{
	YY = Y;
}

class Date : public BaseDate
{
public:
	Date();
	Date( unsigned char, unsigned char, unsigned );
	Date( const Date& );
	~Date();
	virtual classType       isA() const;
	virtual char            *nameOf() const;
    virtual void            printOn( ostream& ) const;
};

inline Date::Date()
{
}

inline Date::Date( unsigned char M, unsigned char D, unsigned Y ) : BaseDate( M, D, Y )
{
}

inline Date::Date( const Date& D ) : BaseDate( D )
{
}

#endif  // ifndef __LDATE_H //
