#if (sizeof(int (*)()) == 4)
#define _LARGECODE
#endif

#if (sizeof(char *) == 4)
#define _LARGEDATA
#endif
