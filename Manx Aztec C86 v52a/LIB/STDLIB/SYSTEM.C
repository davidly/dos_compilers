/* Copyright (C) 1984 by Manx Software Systems */

static int swt_char;

system(cmd)
char *cmd;
{
	register char *prog;
	char *getenv();
	char buffer[130];

	if (!cmd)
		return -1;
	;	/* this is needed so that the following #asm code gets executed */
#asm
	mov	ax,3700h		;ask dos for current switch character
	int	21h
	sub	dh,dh
	mov	swt_char_,dx
#endasm
	if ((prog = getenv("COMSPEC")) == 0)
		prog = "/command.com";
	sprintf(buffer+1, "%cC %.123s\r", swt_char, cmd);
	buffer[0] = strlen(buffer+1) - 1;
	if (fexec(prog,0,buffer,(char *)0,(char *)0) == -1)
		return -1;
	return wait();
}
