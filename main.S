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

/*
eeprom = 0x00
    e_void = eeprom + 0 ; always zero
    e_turn = eeprom + 2 ; turnkey rotine after boot
    e_seed = eeprom + 4 ; seed for random
    e_last = eeprom + 6 ; last link addres to dictionary 
    e_here = eeprom + 8 ; next free flash address for dictionary
    e_eram = eeprom + 10 ; next free sram address for variables, as stack
    e_erom = eeprom + 12 ; next free eprom address for values, as stack
*/

.equ free_sram, SRAM - 0x60
.equ	SRAM, TIB - 20  ; address to next free sram
.equ	EROM, TIB - 18  ; address to next free erom
.equ	SEED, TIB - 16  ; random seed
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

.p2align 1, 0x00
#include "bios.S"

.p2align 1, 0x00
#include "forth.S"

.p2align 1, 0x00
#include "more.S"

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



