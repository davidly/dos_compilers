Changes to AS:

4/9/92 ------------- Released v5.2a beta 1 --------------------

6/4/92 jd
	changed EVEN directive to output NOP opcode instead of 0.

8/3/92 jd
	definition of record instance could not specify a number 
	as a field override.

9/10/92 jd: maktrm()
	assembler was counting two fixups for the expr "seg myseg", where myseg
	is a segment or group. Also for statement "dd myseg".

9/23/92 jd: options
	-o option didn't work when using -f option to generate OMF

10/4/92 ---------------- Released v5.2a beta 2 ----------------------------

10/5/92 jd: execvp()
	Relinked 'as' to use fixed execvp() - previous execvp() didn't always 
	correctly search all directories specified in PATH.
