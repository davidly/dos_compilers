/*ident	"@(#)complex.h	1.3   6/2/90" */

#ifndef __COMPLEX_H
#define __COMPLEX_H	1

/*
**  (c) Copyright 1988-1990 by Dyad Software Corp.
**  All Rights Reserved
**
**  Authors: lwd, geb
*/

#include <math.h>

class ostream;
class istream;


class complex
{

 public:
   friend double real ( const complex& );     
   friend double imag ( const complex& );     

   friend complex cos ( const complex& );
   friend complex cosh ( const complex& );
   friend complex sin ( const complex& );
   friend complex sinh ( const complex& );
   friend complex tan ( const complex& );
   friend complex tanh ( const complex& );
   friend complex log ( const complex& );
   friend complex log10 ( const complex& );
   friend complex sqrt ( const complex& );
   friend double abs ( const complex& );
   friend complex conj ( const complex& );
   friend double norm ( const complex& );
   friend double modulus ( const complex& );
   friend double arg ( const complex& );
   friend complex asin ( const complex& );
   friend complex acos ( const complex& );
   friend complex atan ( const complex& );
   friend complex asinh ( const complex& );
   friend complex atanh ( const complex& );
   friend complex exp ( const complex& );
   friend complex polar ( double r, double theta = 0);

   friend complex operator + ( const complex&, const complex& );
   friend complex operator + ( double, const complex& );
   friend complex operator + ( const complex&, double );

   friend complex operator - ( const complex&, const complex& );
   friend complex operator - ( double, const complex& );
   friend complex operator - ( const complex&, double );

   friend complex operator * ( const complex&, const complex& );
   friend complex operator * ( double, const complex& );
   friend complex operator * ( const complex&, double );

   friend complex operator / ( const complex&, const complex& );
   friend complex operator / ( double, const complex& );
   friend complex operator / ( const complex&, double );

   friend complex pow( const complex& lhs, double rhs );
   friend complex pow( const complex& lhs, const complex & rhs );
   friend complex pow( double lhs, const complex & rhs);
   friend complex pow( const complex& lhs, int rhs);

   friend int operator && ( const complex&, const complex& );
   friend int operator && ( double, const complex& );
   friend int operator && ( const complex&, double );

   friend int operator || ( const complex&, const complex& );
   friend int operator || ( double, const complex& );
   friend int operator || ( const complex&, double );

   friend int operator != ( const complex&, const complex& );
   friend int operator != ( double, const complex& );
   friend int operator != ( const complex&, double );

   friend int operator == ( const complex&, const complex& );
   friend int operator == ( double, const complex& );
   friend int operator == ( const complex&, double );

   friend ostream& operator << ( ostream& s, const complex& x);
   friend istream& operator >> ( istream& s, complex& x);

 public:

   complex ( );
   complex ( double r, double i ); /*   this is not declared (double r, double i = 0)
                                        to avoid implicit conversion. Binary operations
                                        are explicitly declared thus avoiding potential 
                                        ambiguities. */
   complex ( const complex & );   
   double& real ( );
   double& imag ( );
   
   complex& operator = ( const complex& );
   complex& operator = ( double );
   
   complex& operator += ( const complex& );
   complex& operator += ( double );
   
   complex& operator -= ( const complex& );
   complex& operator -= ( double );
   
   complex& operator *= ( const complex& );
   complex& operator *= ( double );
   
   complex& operator /= ( const complex& );
   complex& operator /= ( double );
   
   int operator ! () const;
   complex operator - () const;
   
 private:
   double re;
   double im;
 };

inline complex::complex ( )
{ 
  /* remove these comments for initialization to (0,0)
     re = im = 0; 
     */
}

inline complex::complex ( double r, double i ): re(r), im(i) {}
     inline complex::complex( const complex& z)
{
  re = z.re;
  im = z.im;
}    

inline double real ( const complex& z){ return z.re; }     
inline double imag ( const complex& z){ return z.im; }
     
inline double& complex::real (){ return re; }     
inline double& complex::imag (){ return im; }
     
/* operator + */
inline complex operator + ( const complex& lhs, const complex& rhs )
{
  return  complex ( lhs.re + rhs.re, lhs.im + rhs.im );
}
inline complex operator + ( double  lhs, const complex& rhs )
{
  return  complex ( lhs + rhs.re, rhs.im );
}
inline complex operator + ( const complex& lhs, double rhs )
{
  return  complex ( lhs.re + rhs, lhs.im );
}

/* operator - */
inline complex operator - ( const complex& lhs, const complex& rhs )
{
  return  complex ( lhs.re - rhs.re, lhs.im - rhs.im );
}
inline complex operator - ( double lhs, const complex& rhs )
{
  return  complex ( lhs - rhs.re, - rhs.im );
}
inline complex operator - ( const complex& lhs, double rhs )
{
  return  complex ( lhs.re - rhs, lhs.im );
}

/* operator * */
inline complex operator * ( const complex& lhs, const complex& rhs )
{
  return  complex ( lhs.re * rhs.re - lhs.im * rhs.im, 
		   lhs.re * rhs.im + lhs.im*rhs.re );
}
inline complex operator * ( double lhs, const complex& rhs )
{
  return  complex ( lhs * rhs.re, lhs * rhs.im );
}
inline complex operator * ( const complex& lhs, double rhs )
{
  return  complex ( lhs.re * rhs, lhs.im*rhs );
}

/* operator / */

inline complex operator / ( const complex& lhs, double rhs )
{
  return complex( lhs.re / rhs, lhs.im /rhs );
}

/* unary operators */
inline complex complex::operator - ( ) const
{
  return  complex ( -re, -im );
}

inline int complex::operator ! ( )  const
{
  return  ( re == 0 ) && ( im == 0 ) ;
}    


inline complex & complex::operator = ( const complex& z)
{
  re = z.re;
  im = z.im;
  return  *this;
}    

inline complex & complex::operator = ( double x)
{
  re = x;
  im = 0;
  return  *this;
}    

/* operator *= */
inline complex & complex::operator *= ( const complex& z)
{
  *this = *this * z;
  return  *this;
}
inline complex & complex::operator *= ( double x )
{
  re *= x;
  im *= x;
  return  *this;
}

inline complex & complex::operator /= ( const complex& z)
{
  *this = *this / z;
  return  *this;
}    
inline complex & complex::operator /= ( double x)
{
  re /= x;
  im /= x;
  return  *this;
}    

inline complex & complex::operator += ( const complex& z)
{
  re += z.re;
  im += z.im;
  return  *this;
}
inline complex & complex::operator += ( double x)
{
  re += x;
  return  *this;
}

inline complex & complex::operator -= ( const complex& z)
{
  re -= z.re;
  im -= z.im;
  return  *this;
}

inline complex & complex::operator -= ( double x)
{
  re -= x;
  return  *this;
}    

/* operator && */
inline int operator && ( const complex & lhs, const complex & rhs )
{
  return  (( lhs.re != 0 ) || ( lhs.im != 0 )) &&
    (( rhs.re != 0 ) || ( rhs.im != 0 )) ;
}    
inline int operator && ( double lhs, const complex & rhs )
{
  return  ( lhs != 0 ) && (( rhs.re != 0 ) || ( rhs.im != 0 )) ;
}    
inline int operator && ( const complex & lhs, double rhs )
{
  return  (( lhs.re != 0 ) || ( lhs.im != 0 )) && ( rhs != 0 ) ;
}    

/* operator || */
inline int operator || ( const complex & lhs, const complex & rhs )
{
  return  (( lhs.re != 0 ) || ( lhs.im != 0 )) ||
    (( rhs.re != 0 ) || ( rhs.im != 0 )) ;
}
inline int operator || ( double lhs, const complex & rhs )
{
  return  ( lhs != 0 ) || (( rhs.re != 0 ) || ( rhs.im != 0 )) ;
}
inline int operator || ( const complex & lhs, double rhs )
{
  return  (( lhs.re != 0 ) || ( lhs.im != 0 )) || ( rhs != 0 );
}    

/* operator != */
inline  int operator != ( const complex& lhs, const complex& rhs )
{
  return  ( lhs.re != rhs.re ) || ( lhs.im != rhs.im );
}
inline  int operator != ( double lhs, const complex& rhs )
{
  return  ( lhs != rhs.re ) || ( 0 != rhs.im );
}
inline  int operator != ( const complex& lhs, double rhs )
{
  return  ( lhs.re != rhs ) || ( lhs.im != 0 );
}

/* operator == */
inline  int operator == ( const complex& lhs, const complex& rhs )
{
  return  ( lhs.re == rhs.re ) && ( lhs.im == rhs.im );
}
inline  int operator == ( double lhs, const complex& rhs )
{
  return  ( lhs == rhs.re ) && ( 0 == rhs.im );
}
inline  int operator == ( const complex& lhs, double rhs )
{
  return  ( lhs.re == rhs ) && ( lhs.im == 0 );
}

inline double arg( const complex& z)
{
  return atan2(z.im,z.re);
}

inline complex atanh( const complex& z) 
{
  complex iz(-z.im, z.re);
  complex ix = atan(iz);
  return complex ( ix.im, -ix.re);
}

inline complex asinh( const complex& z)
{
  complex iz(-z.im, z.re);
  complex ix = asin(iz);
  return complex ( ix.im, -ix.re);
}

inline double norm( const complex& z)
{
  return z.re*z.re + z.im*z.im;
}

inline double modulus( const complex& z)
{
  return abs(z);
}

inline complex conj( const complex& z)
{
  return complex( z.re, -z.im );
}

inline complex cos( const complex& z )
{
  return complex( cos(z.re) * cosh( z.im ),  -( sin( z.re) * sinh(z.im)));
}

inline complex cosh( const complex& z )
{
  return complex ( cosh(z.re) * cos(z.im), sinh(z.re) * sin(z.im) );
}

inline complex sin( const complex& z )
{
  return complex ( sin(z.re) * cosh(z.im), cos(z.re) * sinh(z.im) );
}

inline complex sinh( const complex& z )
{
  return complex ( sinh(z.re) * cos(z.im), cosh(z.re) * sin(z.im) );
}

inline complex tan( const complex& z )
{
  double x = 2*z.re;
  double y = 2*z.im;
  double t = 1.0/(cos(x) +cosh(y));
  
  return complex( t*sin(x), t*sinh(y) );
}

inline complex tanh( const complex& z )
{
  double x = 2*z.re;
  double y = 2*z.im;
  double t = 1.0/(cosh(x) +cos(y));
  
  return complex( t*sinh(x), t*sin(y) );
}    

inline complex exp( const complex& z )
{
  double x = exp(z.re);
  return complex( x*cos(z.im), x*sin(z.im) );
}    

inline complex log( const complex& z )
{
  return complex( log( abs(z) ), arg( z ) );
}    

inline complex log10( const complex& z )
{
  return complex( 0.2171472409516259*log( norm(z) ), arg( z ) );
}    

inline complex polar ( double r, double theta )
{
  return complex ( r * cos(theta), r * sin(theta));
}

#endif










