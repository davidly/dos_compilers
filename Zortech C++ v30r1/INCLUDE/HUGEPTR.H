/*_ hugeptr.h   Sun Dec 23 1990   Modified by: Walter Bright */

#ifndef __HUGEPTR_H
#define __HUGEPTR_H

#if __cplusplus
extern "C" {
#endif

#if M_I386 || M_I486

#define hugeptr_cmp(h1,h2) ((h1) - (h2))
#define hugeptr_diff(h1,h2) ((h1) - (h2))
#define hugeptr_add(h,offset) ((h1) + (offset))

#else

long _pascal hugeptr_diff(void _far *h1,void _far *h2);
void _far * _pascal hugeptr_add(void _far *h1,long offset);

#define hugeptr_cmp(h1,h2) ((long)(h1) - (long)(h2))
#define hugeptr_diff(h1,h2) (hugeptr_diff((h1),(h2)) / sizeof(*h1))
#define hugeptr_add(h,offset) (hugeptr_add(h,(long)offset * sizeof(*h)))

#endif

#if __cplusplus
}
#endif

#endif /* __HUGEPTR_H */
