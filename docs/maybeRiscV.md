maybeRiscV.md

# RISCV considerations 

Using same ideias from f2u for atmega8
and exerpts from forth implementations for ARM
amforth.S

Linux free RisV registers (pointed by Lars, lbforth)

X20 as Ir, instruction register for BL BR
X21 as Sr, parameter stack pointer
X22 as Rr, return stack pointer
X23 as Wr, work register
X24 as Tr, temporary scratch register
X25 as Nr, temporary scratch register
```
.macro PUSHRSP reg
    str	\reg, [Rr, #-4]!	@ decrement RSP, store at RSP
.endm

.macro POPRSP reg
	ldr	\reg, [Rr], #4		@ load from RSP, increment RSP
.endm

.macro PUSHPSP reg
    str	\reg, [Sr, #-4]!	@ decrement PSP, store at RSP
.endm

.macro POPPSP reg
    ldr	\reg, [Sr], #4		@ load from RSP, increment RSP
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

_link: ????     
_exec: ?????  
    blx NIP

