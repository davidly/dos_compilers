/*_ sound.h   Sat Jun  3 1989   Modified by: Walter Bright */
/* Copyright (C) 1988-1989 by Northwest Software	*/
/* All Rights Reserved				*/
/* Written by Walter Bright			*/

#if __cplusplus
extern "C" {
#endif

#if __OS2__
void cdecl sound_note(int frequency,int duration);
#else
void cdecl sound_tone(int cycles,int uptime,int dntime);
#endif

void cdecl sound_beep(int freq);
void cdecl sound_click(void);

#if __cplusplus
}
#endif


