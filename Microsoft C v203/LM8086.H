/**
*
* The following definitions specify which memory addressing model is in use
* for wacky chips of the Intel 8086 variety.
*
*	I8086S		64K program, 64K data
*	I8086D		64K program, 1M data
*	I8086P		1M program, 64K data
*	I8086L		1M program, 1M data
*
*/
#define I8086L 1

/**
*
* The following definitions indicate which type of integer has the same size
* as a pointer.
*
*	SPTR		defined if sizeof(pointer) == sizeof(short int)
*	LPTR		defined if sizeof(pointer) == sizeof(long int)
*
*/
#define LPTR 1
