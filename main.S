/*
 *  DISCLAIMER"
 *
 *  Copyright © 2020, Alvaro Gomes Sobral Barcellos,
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions"
 *
 *  The above copyright notice and this permission notice shall be
 *  included in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 *  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 *  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 *  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 *
 */

;---------------------------------------------------------------------
; atmega8 avr
;
; sram mapped as: internal mapped 0x000 to 0x05F, free use 0x060 to 0x45F
; flash mapped as: bios 0x000 to 0x45F, forth 0x460 to 0x1eff, boot 0x1f00 to 0x1FFF
;---------------------------------------------------------------------
#include "macros.S"

.section data
.org 0x0060
; those are non volatile
VOID:	.word 0		; always 0x0000
SEED:	.word 0		; seed for pseudo random
TURN:	.word 0		; routine to run after boot
REST:	.word 0		; routine to run before reset
LAST:	.word 0		; reference to latest word in dictionary
FSHM:	.word 0		; next free cell in flash dictionary
SRAM:	.word 0		; next free cell in static ram < 740
EROM:	.word 0		; next free cell in eeprom < 480

; those are volatile
STAT:	.word 0		; state of interpreter, 0 interprete, 1 compile, 2 postpone
BASE:	.word 0		; numeric radix for convertion

PAGE:	.word 0
LINE:	.word 0

CURS:	.byte 0
TOIN:	.byte 0		; next free char in terminal input buffer
THIS:	.byte 0		; next free cell in FIB for flash flush
KEEP:	.byte 0		; actual page of flash memory, HERE/64 

.equ 	FREE, .
.equ	TIB, FIB - TIB_SIZE
.equ	FIB, PIC - FIB_SIZE
.equ	PIC, END - PIC_SIZE
.equ	END, PSP - STACK_SIZE
.equ	PSP, RSP - STACK_SIZE
.equ	RSP, SPZ - STACK_SIZE
.equ	SPZ, SRAM_END		

;.equ free_sram, TIB - FREE

.p2align 1, 0x00
#include "bios.S"

.p2align 1, 0x00
#include "forth.S"

.p2align 1, 0x00
#include "inside.S"

.p2align 1, 0x00
#include "math.S"

.p2align 1, 0x00
#include "newff.S"

.equ free_flash, .

/*
1 	1st 	fst,    first  
2 	2nd 	snd,    second
3 	3rd 	thd,    third
4 	4th 	fth,    fourth
*/


