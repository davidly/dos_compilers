;/*
; *                 INTEL CORPORATION PROPRIETARY INFORMATION
; *
; *           This software is supplied under the terms of a
; *           license agreement or non-disclosure agreement with
; *           Intel Corporation and may not be copied or disclosed
; *           except in accordance with the terms of that agreement.
; *
; *   Title:  cstart
; */
; This is the starting point for all c programs.
; $Version: 1.46 $
; Copyright (C) 1988 Intel Corporation, ALL RIGHTS RESERVED

%define(controls)(module=cq_cstart fixedparams %controls)

%'      environment symbols

%set(MS_DOS,0)
%set(RMX,0)
%set(NUK,0)
%set(ARGS,1)

%*define(embedded)      (%set(HOSTED,0))
%*define(nucleus)       (%set(HOSTED,0)%set(RMX,1)%set(NUK,1)%set(ARGS,0))
%*define(rmx1)          (%set(HOSTED,1)%set(RMX,1))
%*define(rmx2)          (%set(HOSTED,1)%set(RMX,1))
%*define(rmx3)          (%set(HOSTED,1)%set(RMX,1))
%*define(rmx4)          (%set(HOSTED,1)%set(RMX,1))
%*define(db386)         (%set(HOSTED,1)%set(ARGS,1))
%*define(dos)           (%set(HOSTED,1)%set(MS_DOS,1))

%*define(em)	(%embedded)
%*define(nuc)	(%nucleus)


%'      define the default environment
%dos

$include(:include:util.ah)

%set(medium_rom, %far_code and %const_in_code)

	%DATA	segment
		dw	?
	%DATA	ends

	%CONST	segment
		dw	?
	%CONST	ends

%if(%i86_asm)
then(
	%STACK	segment
	stacktop	dw	?
	%STACK	ends
)fi

;
;	External data and program linkage:
;
%if(%HOSTED)
then(
  %' If the C-Libraries execute in an environment with operating system
  %' support, then the following externals must be declared:

  %' Define the external linkage for the parameters to main():
  %'
  %if(%ARGS)
  then(
    %if(%medium_rom)
    then(
	extrn	_argc:word
	extrn	_argv:%ptr
    )else(
	%extern(%int, _argc)
	%extern(%ptr, _argv)
    )fi
  )fi
  %' Define the external linkage for the C-Library functions that
  %' require operating system support:
  %'
	%extern_fnc(_exit_init)
	%extern_fnc(exit)
	%extern_fnc(_exit)
	%extern_fnc(_stdio_init)
  %if(%ARGS)
  then(
	%extern_fnc(_get_args)
  )fi

)fi
%' The RMX operating system environment requires additional initialization:
%'
%if(%RMX)
then(
	%extern_fnc(_global_init)
)fi

%' Define the external linkage for initializing the E80187 emulator (86 only):
%'
%if(%i86_asm)
then(
	extrn	xq_inite187:far
)fi

%' Define the external linkage for initializing the coprocessor:
%'
%if(%i386_asm)
then(
	extrn	init87:near
)else(
	extrn	init87:far
)fi

%' All environments must execute the following routines:
%'
	%extern_fnc(_thread_init)
	%extern_fnc(main)

%' Define the size of the memory blocks requested
%' through the sbrk() interface:
%'
%data segment

	public	_amblksiz

	_amblksiz	%dint	?

%if(%RMX)
then(
	public	_num_eios_bufs
	public	_rmx_nucleus

	_num_eios_bufs	%dint	?
	_rmx_nucleus	%dint	?
)fi
%data ends

%code	segment

begin:
	;
	; Initialize the C-Library and, if necessary, the target
	; environment:
	;
	cld				;
%if(%i86_asm)
then(
	call	xq_inite187		; initialize E80187 emulator
)fi
	call	init87			; initialize the coprocessor

	mov	_amblksiz,8192
%if(%RMX)
then(
	mov	_num_eios_bufs,2
  %if(%NUK)
  then(	mov	_rmx_nucleus,1
  )else(mov	_rmx_nucleus,0
  )fi
)fi

%' For embedded environments, the following call to _thread_init() is
%' the only initialization required by the C-Library.  Other ebmedded
%' environment specific initializations should be put after this call.
%'
%if(not %HOSTED)
then(
  %if(%NUK)
  then(
	call	_global_init		; initialize RMX specific global data
	or	%ax, %ax
	jz	L1
	hlt
L1:
  )fi
	call	_thread_init		; initialize CLIB thread data
	or	%ax, %ax
	jz	L2
	hlt
L2:
)else(
  %if(%RMX)
  then(
	call	_global_init		; initialize RMX specific global data
	or	%ax, %ax
	jz	L1
	push	%ax
	call	_exit
L1:
  )fi
	call	_thread_init		; initialize CLIB thread data
	or	%ax, %ax
	jz	L2
	push	%ax
	call	_exit
L2:
	call	_exit_init		; initialize CLIB exit handlers
	or	%ax, %ax
	jz	L3
	push	%ax
	call	_exit
L3:
	call	_stdio_init		; initialize CLIB standard streams
	or	%ax, %ax
	jz	L4
	push	%ax
	call	_exit
L4:
  %if(%ARGS)
  then(
	call	_get_args		; setup parameters to main()
	or	%ax, %ax
	jz	L5
	push	%ax
	call	_exit
L5:
  )fi

  %if(%ARGS)
  then(
    %if(%far_data)
    then(
      %' define code for passing paramerers to main() for compact and large models
      %'
      %*define(push_argc)
      (
        %if(%set_ds or %medium_rom)
        then(	mov	cx, seg _argc
        )else(	mov	cx, ds
        )fi
	mov	es, cx
	push	%reg_size es:_argc	; push number of arguments to main()
      )
      %*define(push_argv)
      (
        %if(%set_ds or %medium_rom)
        then(	mov	cx, seg _argv
        )else(	mov	cx, ds
        )fi
	mov	es, cx
	%movsx	%ax, word ptr es:_argv+%int_size
	push	%ax			; push segment selector and
	push	%reg_size es:_argv	; offset of array containing argument
      )
    )else(
      %' define code for passing paramerers to main() for small and medium model
      %'
      %*define(push_argc)
      (
	push	%reg_size  _argc	; push number of arguments to main()
      )
      %*define(push_argv)
      (
	push	%reg_size _argv		; push address of array containing argument addresses
      )
    )fi

  )fi
)fi
	;
	; Invoke the user's program:
	;
%if(not %HOSTED)
then(
	call	main			; no parameters passed to main()
	hlt				; ERROR:  no return expected in a 
					;         non-hosted environment

)else(
  %' set up command line arguments for main()
  %'
  %if(%ARGS)
  then(
    %if(%fpl)
    then(
	%push_argc
	%push_argv
    )else(
	%push_argv
	%push_argc
    )fi
  )fi
	call	main			; call the user's programs
	push	%ax			; set the termination value
	call	exit			; and quietly exit
)fi

%code	ends

	end	begin,	ds:%dgroup, %'
			ss:%sgroup %if(%i86_asm)then( :stacktop )fi
