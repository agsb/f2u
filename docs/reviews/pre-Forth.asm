
\ https://raw.githubusercontent.com/uho/preForth/master/preForth/preForth-i386-rts.pre

System - i386 (32 bit) dependent part
\ --------------------------
\
\  - registers:
\      EAX, EDX  general purpose
\      ESI  instruction pointer
\      EBP  return stack pointer
\      ESP  data stack pointer

prelude
;;; This is a preForth generated file using preForth-i386-backend.
;;; Only modify it, if you know what you are doing.
 
;

prefix
format ELF 

section '.bss' writeable executable

       DD 10000 dup (0)
stck:  DD 16 dup(0)
  
       DD 10000 dup(0)
rstck: DD 16 dup(0)


section '.text' executable writeable
public main 
extrn putchar
extrn getchar
extrn fflush
extrn exit
  
macro next  {
		; 	lodsd
		load ax, [ip]
		adi ip, 4
       	;	jmp dword [eax]
		jmp [ax]

}


main:  cld
       mov esp, dword stck
       mov ebp, dword rstck
       mov esi, main1
       next

main1: DD _cold
       DD _bye  
  
  
_nest:  
		;	lea ebp, [ebp-4]
		load rp, [rp-4]
        ;	mov [ebp], esi
		mov [rp], ip
		; lea esi, [eax+4]
		load ip, [ax+4]
        next

_O = 0
  
;

code unnest ( -- )
        mov esi,[ebp]
        lea ebp,[ebp+4]
        next
;

code bye ( -- )
    push ebp  
    mov ebp, esp  
    and esp, 0xfffffff0
    mov eax, 0
    mov [esp], eax
    call exit
;
    
code emit ( c -- )
    pop eax

    push ebp  
    mov  ebp, esp
    push eax 
    and  esp, 0xfffffff0

    mov dword [esp], eax
    call putchar

    mov eax, 0
    mov [esp], eax
    call fflush   ; flush all output streams

    mov esp, ebp  
    pop ebp  
    next
;

code key ( -- c )
        push ebp  
        mov  ebp, esp
        and  esp, 0xfffffff0
        
        call getchar
        mov esp, ebp
        pop ebp
        cmp eax,-1
        jnz key1
        mov eax,4
key1:   push eax
        next
;

code dup ( x -- x x )
        pop eax
        push eax
        push eax
        next
;

code swap ( x y -- y x )
        pop edx
        pop eax
        push edx
        push eax
        next
;

code drop ( x -- )
        pop eax
        next
;

code 0< ( x -- flag )
        pop eax
        or eax, eax
        mov eax, 0
        jns zless1
        dec eax
zless1: push eax
        next
;

code ?exit ( f -- )
        pop eax
        or eax, eax
        jz qexit1
        mov esi, [ebp]
        lea ebp,[ebp+4]
qexit1: next
;

code >r ( x -- ) ( R -- x )
        pop ebx
        lea ebp,[ebp-4]
        mov [ebp], ebx
        next
;

code r> ( R x -- ) ( -- x )
        mov eax,[ebp]
        lea ebp, [ebp+4]
        push eax
        next
;

code - ( x1 x2 -- x3 )
        pop edx
        pop eax
        sub eax, edx
        push eax
        next
;

code lit ( -- )
        lodsd
        push eax
        next
;

