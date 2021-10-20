;
; atmega8 avr
;
;---------------------------------------------------------------------

;---------------------------------------------------------------------
; sram mapped as: 	internal mapped 0x000 to 0x05F, free use 0x060 to 0x45F
; flash mapped as:  bios 0x000 to 0x45F, forth 0x460 to 0xCFFF, boot 0xCFFF to 0x1FFF

#include "macros.S"

.section data
.org 0x0060
; those are non volatile
VOID:	.word 0		; always 0x0000
SEED:	.word 0		; seed for pseudo random
TURN:	.word 0		; routine to run after boot
REST:	.word 0		; routine to run before reset
LAST:	.word 0		; reference to latest word in dictionary
HERE:	.word 0		; next free cell in flash dictionary
SRAM:	.word 0		; next free cell in static ram ~ 740
PROM:	.word 0		; next free cell in eeprom < 512

; those are volatile
STAT:	.word 0		; state of interpreter, 0 interprete, 1 compile, 2 postpone
BASE:	.word 0		; numeric radix for convertion

PAGE:	.word 0
LINE:	.word 0

CURS:	.byte 0
TOIN:	.byte 0		; next free char in terminal input buffer
THIS:	.byte 0		; next free cell in PAD for flash flush
KEEP:	.byte 0		; actual page of flash memory, HERE/64 

/*
TIB0:	.byte TIB_SIZE	; terminal input buffer
PAD0:	.byte PAD_SIZE 	; scratch pad for compile to flash
PIC0:	.byte PIC_SIZE	; picture numeric format buff
USE0:	.word 0 		; start or user free sram
*/

;.equ free_sram, END - FREE

.equ	TIB, PAD - TIB_SIZE
.equ	PAD, PIC - PAD_SIZE
.equ	PIC, END - PIC_SIZE
.equ	END, PSP - STACK_SIZE
.equ	PSP, RSP - STACK_SIZE
.equ	RSP, SPZ - STACK_SIZE
.equ	SPZ, RAMEND		

.p2align 1, 0x00
#include "bios.S"

.p2align 1, 0x00
#include "forth.S"

.p2align 1, 0x00
#include "inside.S"

.p2align 1, 0x00
#include "math.S"

.equ free_flash, .

.p2align 1, 0x00
#include "nrww.S"


/*
1 	1st 	fst,    first  
2 	2nd 	snd,    second
3 	3rd 	thd,    third
4 	4th 	fth,    fourth
*/



