# ifdef NDEBUG

# define assert(e)

# else

# define assert(e) if(!(e)) {\
	printf("Assertion (" # e ") failed: file %s, line %d\n", __FILE__, __LINE__);\
	abort();\
	}

# endif