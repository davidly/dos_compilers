;       .sall
modbeg  macro   modname
        name    modname

module  segment
        assume  cs:module
        endm
;
procbeg  macro   procname,arg1,arg2,arg3,arg4
         public  procname
procname proc    far
         push    bp
         mov     bp,sp
         lea     si,[bp+6]
         ifnb    <arg1>
         mov     arg1, word ptr [bp+6]
         endif
         ifnb    <arg2>
         mov     arg2, word ptr [bp+8]
         endif
         ifnb    <arg3>
         mov     arg3, word ptr [bp+10]
         endif
         ifnb    <arg4>
         mov     arg4, word ptr [bp+12]
         endif
         endm
 ;
getarg   macro  number,register
         mov    register,word ptr [bp+(number*2+4)]
         endm
;
callc   macro   funcname,parm1,parm2,parm3,parm4
        ifndef  funcname
        extrn   funcname:far
        endif
        ifnb    <parm4>
        push    parm4
        endif
        ifnb    <parm3>
        push    parm3
        endif
        ifnb    <parm2>
        push    parm2
        endif
        ifnb    <parm1>
        push    parm1
        endif
        call    far ptr funcname
        ifnb    <parm4>
        add     sp,8
        else
        ifnb    <parm3>
        add     sp,6
        else
        ifnb    <parm2>
        add     sp,4
        else
        ifnb    <parm1>
        add     sp,2
        endif
        endif
        endif
        endif
        endm
;
procend  macro   procname
        pop     bp
        ret
procname endp
         endm
;
modend       macro
module       ends
             end
             endm
