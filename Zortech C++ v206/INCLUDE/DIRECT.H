/*_ DIRECT.H   Wed Jun 28 1989   Modified by: Walter Bright */

#if __cplusplus
extern "C" {
#endif

#define size_t	unsigned

char * cdecl getcwd(char *,size_t);
int cdecl chdir(char *);
int cdecl mkdir(char *);
int cdecl rmdir(char *);

#if __cplusplus
}
#endif
