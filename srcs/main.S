
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
; UPDATE: 10/2022 to include stuff for atmega328 
;---------------------------------------------------------------------- 
;
; version information
;
.equ version, 12 ; 0.00.10

#include "macros.S"
;----------------------------------------------------------------------
;
; for sake stacks grows down, heaps grows up
;
;----------------------------------------------------------------------
.section .eeprom
.org 0x0

e_void:	.word 0 ; always zero
e_seed:	.word 0 ; seed for random
e_turn:	.word 0 ; routine after boot
e_rest:	.word 0 ; routine before reset
e_last:	.word 0 ; link to last word in dictionary
e_dp:	.word 0 ; next free flash address for dictionary
e_up:	.word 0 ; next free sram address for variables, as stack
e_ep:	.word 0 ; next free eprom address for values, as heap 

;----------------------------------------------------------------------
.section data
.org SRAM_START

;----------------------------------------------------------------------
; those are non volatile, must be saved in eeprom
VOID:	.word 0		; always 0x0000
SEED:	.word 0		; seed for pseudo random

TURN:	.word 0		; routine to run after boot
REST:	.word 0		; routine to run before reset

LAST:	.word 0		; reference to latest word in dictionary
VDP:	.word 0		; next free cell in flash dictionary

VUP:    .word 0     ; next free cell in static ram (from end)
VEP: 	.word 0		; next free cell in eeprom

;----------------------------------------------------------------------
; those are volatile, dont care
STAT:	.word 0		; state of interpreter, 0 interprete, 1 compile
RADX:	.word 0		; numeric radix for convertion

TOIN:   .word 0     ; offset in TIB
SPAN:   .word 0     ; offsets

VUH:   .word 0      ; heap for user words, from tib, UH0
VUS:   .word 0      ; stack for user variables, from stacks, US0 

TMP0:   .word 0     ; temporary
TMP1:   .word 0     ; temporary
TMP2:   .word 0     ; temporary
TMP3:   .word 0     ; temporary

;----------------------------------------------------------------------
TIB0:	.space TIB_SIZE, 0x0
UH0 = .

;----------------------------------------------------------------------
; stacks at end of sram
SP0 = SRAM_END
PS0 = SP0 - STACK_SIZE
RS0 = PS0 - STACK_SIZE
US0 = RS0 - STACK_SIZE

;.equ free_sram, US0 - UH0

;----------------------------------------------------------------------
;
; code segment, flash
;
.section .text

;----------------------------------------------------------------------
.p2align 1, 0x00
#include "bios.S"

;----------------------------------------------------------------------
.p2align 1, 0x00
#include "messages.S"

;----------------------------------------------------------------------
.p2align 1, 0x00
#include "forth-leafs.S"

;----------------------------------------------------------------------
.p2align 1, 0x00
#include "flush.S"

;----------------------------------------------------------------------
.p2align 1, 0x00
#include "forth-twigs.S"

;----------------------------------------------------------------------
.p2align 1, 0x00
#include "doubles.S"

;----------------------------------------------------------------------
;.p2align 1, 0x00
;#include "math.S"

;----------------------------------------------------------------------
;.p2align 1, 0x00
#include "interpreter.S"

;----------------------------------------------------------------------
.equ free_flash, .

;FULL: .word  _list_

;----------------------------------------------------------------------

/*
1 	1st 	fst,    first  
2 	2nd 	snd,    second
3 	3rd 	thd,    third
4 	4th 	fth,    fourth
and so on is th :)
*/


