/*_ sound.h   Sat Jun  3 1989   Modified by: Walter Bright */
/* Copyright (C) 1988-1989 by Walter Bright	*/
/* All Rights Reserved				*/
/* Written by Walter Bright			*/

#if __cplusplus
extern "C" {
#endif

#if __OS2__
void _cdecl sound_note(int frequency,int duration);
#else
void _cdecl sound_tone(int cycles,int uptime,int dntime);
#endif

void _cdecl sound_beep(int freq);
void _cdecl sound_click(void);

#if __cplusplus
}
#endif


