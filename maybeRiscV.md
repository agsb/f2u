maybeRiscV.md

# RISCV considerations 

from https://github.com/larsbrinkhoff/lbForth/blob/master/targets/riscv/next.fth 

; as intructions are OP rd, rs1, rs2 ;

.equ    S   X20     ; parameter stack
.equ    R   X21     ; return stack
.equ    I   X22     ; instruction record
.equ    W   X23     ; work register
.equ    T   X24     ; temporary 
.equ    N   X25     ; temporary extra

Using same ideias from f2u for atmega8
and exerpts from forth implementations for ARM
amforth.S

use

    NIP next instruction pointer
    PSP, parameter stack pointer
    RSP, return stack pointer
    WRK, work register

    .macro PUSHRSP reg
	    str	\reg, [R, #-4]!	@ store at RSP-4, decrement R
	.endm

	.macro POPRSP reg
	    ldr	\reg, [R], #4		@ load from RSP, increment R
	.endm

    .macro PUSHPSP reg
	    str	\reg, [S, #-4]!	@ store at RSP-4, decrement S
	.endm

	.macro POPPSP reg
	    ldr	\reg, [S], #4		@ load from RSP, increment S
	.endm

    ; header for (ends)
    _ends: 
        .equ 00

    _exit: ; semis
	    POPRSP	I

    _next: ; next
        ldr	W, [I], #4	@ load WORD from NIP and increment 
        cmp	W, 0		@ NULL?
	    beq	_exec		@ is a primitive do _exec
	    
    _enter: ; docol
        PUSHRSP	I		@ push NIP on return stack
        mv I, W
	    B _next
     
     _exec: ?????  
        blx I

