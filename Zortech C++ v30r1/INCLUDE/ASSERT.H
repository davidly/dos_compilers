/*_ assert.h   Fri May 12 1989   Modified by: Walter Bright */

#if __cplusplus
extern "C" {
#endif

#undef assert

#ifdef NDEBUG
    #define assert(ignore)	((void) 0)
#else
    #define assert(e)	((void)((e) || (_assert(#e,__FILE__,__LINE__),1)))
    extern void
    #ifndef __STDC__
	_cdecl
    #endif
	    _assert(const char *,const char *,unsigned);
#endif

#if __cplusplus
}
#endif

