/*_ new.hpp   Fri Aug 10 1990   Modified by: Walter Bright */

#ifndef __NEW_HPP
#define __NEW_HPP	1

extern "C++" {

#if !__STDDEF_H
inline void *operator new(unsigned, void *p) { return p; }
#endif

void (*set_new_handler (void (*)()))();

}

#endif
