; atmega8 avr

;---------------------------------------------------------------------

; sram mapped as: 	internal mapped 0x000 to 0x05F, free use 0x060 to 0x45F
; flash mapped as:  bios 0x000 to 0x45F, forth 0x460 to 0xCFFF, boot 0xCFFF to 0x1FFF

#include "macros.S"

.section data
.org 0x0060
VOID:	.word 0
NULL:	.word 0
.equ	LINE, .

.equ free_sram, SRAM - 0x60
.equ	SRAM, TIB - 20
.equ	EROM, TIB - 18
.equ	SEED, TIB - 16
.equ	THIS, TIB - 14	; pointer to next in line
.equ	TOIN, TIB - 12	; pointer to next in tib
.equ	KEEP, TIB - 10	; keep real here till update line
.equ	HERE, TIB - 8	; pointer to next in flash
.equ	LAST, TIB - 6	; last linked word
.equ	BASE, TIB - 4
.equ	STATE, TIB - 2
.equ	TIB, PIC - TIB_SIZE
.equ	PIC, END - PIC_SIZE
.equ	END, PSP - STACK_SIZE 
.equ	PSP, RSP - STACK_SIZE
.equ	RSP, SPZ - STACK_SIZE
.equ	SPZ, RAMEND		

.align 2
#include "bios.S"

.align 2
#include "forth.S"

.align 2
#include "more.S"

.align 2
#include "math.S"

.equ free_flash, .

.align 2
#include "nrww.S"


/*
1 	1st 	first
2 	2nd 	second
3 	3rd 	third
4 	4th 	fourth
*/



