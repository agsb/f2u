

/*
 *  DISCLAIMER
 *
 *  Copyright © 2020, Alvaro Gomes Sobral Barcellos,
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions:
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
 *  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

;---------------------------------------------------------------------
; atmega8 avr
;
; UPDATE: 10/2022 to include stuff for atmega328 P;---------------------------------------------------------------------

;----------------------------------------------------------------------
;
; version information
;
.equ version, 12 ; 0.00.10

#include "macros.S"

;----------------------------------------------------------------------
.section data
.org SRAM_START
; those are non volatile, must be saved in eeprom
VOID:	.word 0		; always 0x0000
SEED:	.word 0		; seed for pseudo random

TURN:	.word 0		; routine to run after boot
REST:	.word 0		; routine to run before reset

LIST:	.word 0		; reference to latest word in dictionary
LAST:	.word 0		; next free cell in flash dictionary
HEAP:   .word 0		; next free cell in static ram 
KEEP:	.word 0		; next free cell in eeprom

; those are volatile, dont care
STAT:	.word 0		; state of interpreter, 0 interprete, 1 compile, 2 postpone
RADX:	.word 0		; numeric radix for convertion

PAGE:   .word 0     ; flash page to flush 
TOIN:   .word 0     ; offset in TIB

TIBS:	.word 0		; count down
CURS:   .word 0     ; count down 

TIB0:	.space TIB_SIZE, 0x0

SP0 = SRAM_END
PS0 = SP0 - STACK_SIZE
RS0 = PS0 - STACK_SIZE
FREE = RS0 - STACK_SIZE

;.equ free_sram, FREE - TIB_SIZE

;----------------------------------------------------------------------
.p2align 1, 0x00
#include "bios.S"

;----------------------------------------------------------------------
.p2align 1, 0x00
#include "messages.S"

;----------------------------------------------------------------------
.p2align 1, 0x00
#include "forth.S"

;----------------------------------------------------------------------
;.p2align 1, 0x00
;#include "inside.S"

;----------------------------------------------------------------------
;.p2align 1, 0x00
;#include "math.S"

;----------------------------------------------------------------------
.p2align 1, 0x00
;#include "flush.S"

;----------------------------------------------------------------------
.equ free_flash, .

;----------------------------------------------------------------------

/*
1 	1st 	fst,    first  
2 	2nd 	snd,    second
3 	3rd 	thd,    third
4 	4th 	fth,    fourth
and so on is th :)
*/


