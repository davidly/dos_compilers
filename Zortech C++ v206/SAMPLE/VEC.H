/*_ vec.h   Thu May 28 1987   Modified by: Walter Bright */

#ifndef VEC_H
#define VEC_H

typedef unsigned vec_base_t;		/* base type of vector		*/
typedef vec_base_t *vec_t;

#define vec_numbits(v)	((v)[-1])
#define vec_dim(v)	((v)[-2])

#define VECBITS (sizeof(vec_base_t)*8)		/* # of bits per entry	*/
#define VECMASK	(VECBITS - 1)			/* mask for bit position */
#define VECSHIFT ((VECBITS == 16) ? 4 : 5)	/* # of bits in VECMASK	*/

#if PROTOTYPING
extern	void vec_init(void),vec_term(void),vec_free(vec_t),
	vec_setbit(unsigned,vec_t),vec_clearbit(unsigned,vec_t),
	vec_and(vec_t,vec_t,vec_t),vec_or(vec_t,vec_t,vec_t),
	vec_xor(vec_t,vec_t,vec_t),
	vec_sub(vec_t,vec_t,vec_t),vec_clear(vec_t),vec_set(vec_t),
	vec_copy(vec_t,vec_t),vec_clearextrabits(vec_t),vec_print(vec_t);
extern	vec_t vec_calloc(unsigned),vec_realloc(vec_t,unsigned);
extern	int vec_testbit(unsigned,vec_t),vec_equal(vec_t,vec_t);
extern	unsigned vec_index(unsigned,vec_t);
#else
extern	void vec_init(),vec_term(),vec_free(),
	vec_setbit(),vec_clearbit(),
	vec_and(),vec_xor(),vec_or(),
	vec_sub(),vec_clear(),vec_set(),
	vec_copy(),vec_clearextrabits(),vec_print();
extern	vec_t vec_calloc(),vec_realloc();
extern	int vec_testbit(),vec_equal();
extern	unsigned vec_index();
#endif

#endif /* VEC_H */
