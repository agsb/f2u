maybeRiscV.md

# RISCV considerations 

Using same ideias from f2u for atmega8
and exerpts from forth implementations for ARM
amforth.S

use

    NIP next instruction pointer
    PSP, parameter stack pointer
    RSP, return stack pointer
    WRK, work register

    .macro PUSHRSP reg
	    str	\reg, [RSP, #-4]!	@ store at RSP-4, decrement RSP
	.endm

	.macro POPRSP reg
	    ldr	\reg, [RSP], #4		@ load from RSP, increment RSP
	.endm

    .macro PUSHPSP reg
	    str	\reg, [PSP, #-4]!	@ store at RSP-4, decrement RSP
	.endm

	.macro POPPSP reg
	    ldr	\reg, [PSP], #4		@ load from RSP, increment RSP
	.endm

    ; header for (ends)
    _ends: 
        .equ 00

    _exit: ; semis
	    POPRSP	NIP

    _next: ; next
        ldr	WRK, [NIP], #4	@ load WORD from NIP and increment 
        cmp	WRK, 0		@ NULL?
	    beq	_exec		@ is a primitive do _exec
	    
    _enter: ; docol
        PUSHRSP	NIP		@ push NIP on return stack
        mv NIP, WRK
	    B _next
     
     _exec: ?????  
        blx NIP

