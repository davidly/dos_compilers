/* i386.h - 80386 processor specific header file
 * $Version: 1.12 $
 * Copyright 1990 Intel Corporation, ALL RIGHTS RESERVED.
 */

#if !defined(_I386_)
#define _I386_

#include <i286.h>

#pragma _builtin_("getcontrolregister"==41)
unsigned int	getcontrolregister( const unsigned char );

#pragma _builtin_("setcontrolregister"==42)
void	setcontrolregister( const unsigned char, unsigned int );

#define CR0_EXTENSION_TYPE	0x0010
#define CR0_PAGING_ENABLED	0x8000

#pragma _builtin_("getdebugregister"==43)
unsigned int	getdebugregister( const unsigned char );

#pragma _builtin_("setdebugregister"==44)
void	setdebugregister( const unsigned char, unsigned int );

#pragma _builtin_("gettestregister"==45)
unsigned int	gettestregister( const unsigned char );

#pragma _builtin_("settestregister"==46)
void	settestregister( const unsigned char, unsigned int );

#pragma _builtin_("inhword"==67)
unsigned short inhword(unsigned short port);

#pragma _builtin_("outhword"==68)
void    outhword(unsigned short  port,
                unsigned short  value);

#pragma _builtin_("blockinhword"==69)
void    blockinhword(    unsigned short  port,
                        unsigned short *destination,
                        unsigned int    count);

#pragma _builtin_("blockouthword"==70)
void    blockouthword(   unsigned short          port,
                        unsigned short const      *source,
                        unsigned int            count);


#pragma ALIGN("i387_protected_addr")
struct i387_protected_addr
{
		unsigned	ip_offset	: 32;
		unsigned	cs_sel		: 16;
		unsigned	opcode		: 11, : 5;
		unsigned	op_offset	: 32;
		unsigned	op_sel		: 16, : 16;
};

#pragma ALIGN("i387_real_address")
struct i387_real_address
{
		unsigned	ip1		: 16, : 16;
		unsigned	opcode		: 11, : 1;
		unsigned	ip2		: 16, : 4;
		unsigned	op1		: 16, : 16, : 12;
		unsigned	op2		: 16, : 4;
};

union i387_address
{
        struct i387_real_address real;
		struct i387_protected_addr prot;
};

#pragma ALIGN("i387_environment")
struct i387_environment
{
        unsigned                control: 16, : 16;
        unsigned                status : 16, : 16;
        unsigned                tag    : 16, : 16;
        union i387_address      ptrs_n_opcode;
};

struct i387_state
{
        struct i387_environment environment;
        tempreal_t              stack[8];
};

#if _ARCHITECTURE_ >= 386
#pragma _builtin_("saverealstatus"==18)
void    saverealstatus(struct i387_state *savearea);

#pragma _builtin_("restorerealstatus"==19)
void    restorerealstatus(struct i387_state const *savearea);
#endif

#define FLAG_RESUME		0x10000
#define FLAG_VM			0x20000

#pragma _builtin_("word_rol"==78)
unsigned int    word_rol(unsigned int, unsigned int);

#pragma _builtin_("word_ror"==79)
unsigned int    word_ror(unsigned int, unsigned int);

#endif
