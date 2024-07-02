/*_ direct.h   Mon Jun  4 1990   Modified by: Walter Bright */

#if __cplusplus
extern "C" {
#endif

typedef unsigned size_t;

char * _cdecl getcwd(char *,size_t);
int _cdecl _chdrive(int);
int _cdecl _getdrive(void);
int _cdecl chdir(char *);
int _cdecl mkdir(char *);
int _cdecl rmdir(char *);

#if __cplusplus
}
#endif
