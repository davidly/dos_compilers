/* i86.h - 8086 processor specific header file
 * $Version: 1.9 $
 * Copyright 1988, 89, 90 Intel Corporation, ALL RIGHTS RESERVED.
 */

#if !defined(_I86_)
#define _I86_

#pragma extend
#pragma _selector_("selector")

/*** For manipulation of selector ***/
#pragma _builtin_("buildptr"==2)
void far        *buildptr(      selector        sel,
                                void near       *offset);

#pragma _builtin_("lockset"==3)
unsigned char   lockset(unsigned char   *lockptr,
                        unsigned char   newvalue);

#pragma _builtin_("enable"==4)
void    enable(void);

#pragma _builtin_("disable"==5)
void    disable(void);

#pragma _builtin_("causeinterrupt"==6)
void    causeinterrupt(unsigned char number);

#pragma _builtin_("halt"==7)
void    halt(void);

#pragma _builtin_("getflags"==8)
unsigned int  getflags(void);

#pragma _builtin_("setflags"==9)
void    setflags(unsigned int value);

#define FLAG_CARRY      0x0001
#define FLAG_PARITY     0x0004
#define FLAG_AUXCARRY   0x0010
#define FLAG_ZERO       0x0040
#define FLAG_SIGN       0x0080
#define FLAG_TRAP       0x0100
#define FLAG_INTERRUPT  0x0200
#define FLAG_DIRECTION  0x0400
#define FLAG_OVERFLOW   0x0800

#pragma _builtin_("inbyte"==10)
unsigned char   inbyte(unsigned short port);

#pragma _builtin_("inword"==11)
unsigned int    inword(unsigned short port);

#pragma _builtin_("outbyte"==12)
void    outbyte(unsigned short  port,
                unsigned char   value);

#pragma _builtin_("outword"==13)
void    outword(unsigned short  port,
                unsigned int    value);

#pragma _builtin_("initrealmathunit"==14)
void    initrealmathunit(void);

#pragma _builtin_("setrealmode"==15)
void    setrealmode(unsigned short mode);

#pragma _builtin_("getrealstatus"==16)
unsigned short  getrealstatus(void);

#pragma _builtin_("getrealerror"==17)
unsigned short  getrealerror(void);

#define I87_INVALID_OPERATION   0x0001
#define I87_DENORMALIZED_OPERAND 0x0002
#define I87_ZERO_DIVIDE         0x0004
#define I87_OVERFLOW            0x0008
#define I87_UNDERFLOW           0x0010
#define I87_PRECISION           0x0020

#define I87_CONTROL_PRECISION   0x0300
#define I87_PRECISION_24_BIT    0x0000
#define I87_PRECISION_53_BIT    0x0200
#define I87_PRECISION_64_BIT    0x0300

#define I87_CONTROL_ROUNDING    0x0C00
#define I87_ROUND_NEAREST       0x0000
#define I87_ROUND_DOWN          0x0400
#define I87_ROUND_UP            0x0800
#define I87_ROUND_CHOP          0x0C00

#define I87_CONTROL_INFINITY    0x1000
#define I87_INFINITY_PROJECTIVE 0x0000
#define I87_INFINITY_AFFINE     0x1000

#define I87_STATUS_ERROR        0x0080
#define I87_STATUS_STACKTOP_MASK 0x3800
#define I87_STATUS_STACKTOP_SHIFT 11
#define I87_STATUS_STACKTOP(env) (((env).status & I87_STATUS_STACKTOP_MASK) \
                                        >> I87_STATUS_STACKTOP_SHIFT)
#define I87_STACK_TOP(env)      I87_STATUS_STACKTOP(env)
#define I87_STATUS_BUSY         0x8000

#define I87_STATUS_CONDITION_CODE 0x4700
#define I87_CONDITION_C0        0x0100
#define I87_CONDITION_C1        0x0200
#define I87_CONDITION_C2        0x0400
#define I87_CONDITION_C3        0x4000

#pragma ALIGN("i87_real_address")
struct i87_real_address
{
        unsigned        offset  : 16, : 0;
        unsigned        opcode  : 11, : 1;
        unsigned        selector: 4,  : 0;
};

#define I87_REAL_ADDRESS(addr)  buildptr((selector)((addr).selector & 0xF000),\
                                        (void near *)(addr).offset)

union i87_address
{
        struct i87_real_address real;
        void far                *protected;
};

#pragma ALIGN("i87_environment")
struct i87_environment
{
        unsigned                control: 16, : 0;
        unsigned                status : 16, : 0;
        unsigned                tag    : 16, : 0;
        union i87_address       instruction;
        union i87_address       operand;
};

#define I87_TAG_MASK    0x0003
#define I87_TAG_SHIFT   2
#define I87_TAG(x, y)   (((x).tag >> (I87_TAG_SHIFT * (y))) & I87_TAG_MASK)

#pragma NOALIGN("i87_tempreal")
struct i87_tempreal
{
        char            significand[8];
        unsigned        exponent: 15;
#if defined(SBITFIELD)
        signed          sign: 1;
#else
        unsigned        sign: 1;
#endif
};

typedef struct i87_tempreal     tempreal_t;
struct i87_state
{
        struct i87_environment  environment;
        tempreal_t              stack[8];
};

#if _ARCHITECTURE_ < 386
#pragma _builtin_("saverealstatus"==18)
void    saverealstatus(struct i87_state *savearea);

#pragma _builtin_("restorerealstatus"==19)
void    restorerealstatus(struct i87_state const *savearea);
#endif

#pragma _builtin_("byte_rol"==74)
unsigned char   byte_rol(unsigned char, unsigned int);

#pragma _builtin_("byte_ror"==75)
unsigned char   byte_ror(unsigned char, unsigned int);

#pragma _builtin_("hword_rol"==76)
unsigned short  hword_rol(unsigned short, unsigned int);

#pragma _builtin_("hword_ror"==77)
unsigned short  hword_ror(unsigned short, unsigned int);

#endif
