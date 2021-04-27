
/*
 *  DISCLAIMER:
 *
 *  Copyright © 2020, Alvaro Barcellos,
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
 *
*/

/*

  inspired on eforth from books and papers from C. H. Ting
 
  just experience for small microcontrolers
 
  emulates a virtual uCi,  
	
  still no interrupts
 
  still no multitasks
 
	
	
	the little endian method, the low byte of the address or value occupies the lower memory address. 

	Notation: top is at right, eg ROT (w1 w2 -- w1 w2 w1) w1 is 2nd at stack, w2 is 1st at stack
 
;---------------------------------------------------------------------
; dictionary structure
;
 .word  link    link to previous
 .byte  size    sizeof name OR mask 0x1F
 .ascii "name"  name, plus a pad byte with BL (0x32) if size is odd
 .word  param,  many

;----------------------------------------------------------------------

18/04/2021

	Rewrite all from u2f*, using a new minimal forth engine as LAST word 

*/

    .NOLIST

    .LIST

;----------------------------------------------------------------------
; get some magic constants
 
#include <avr/io.h>

;----------------------------------------------------------------------

#include "equates.inc" 

;----------------------------------------------------------------------

#include "macros.inc"

;----------------------------------------------------------------------

#include "sram.inc"

;----------------------------------------------------------------------

#include "boot.inc"

;----------------------------------------------------------------------
; start of dictionary
;
;----------------------------------------------------------------------

;----------------------------------------------------------------------
;
; any leaf must start with NOOP and end with POON
;
;.macro NOOP
;        nop
;        nop
;.endm
;
;.macro POON
;		rjmp _EXIT
;.endm

;----------------------------------------------------------------------
;
; it is the forth engine,
;
; any twig must end with a reference to LAST
;
; any leaf must start with NOOP and ends with POON
;
; zzz size must be mask or 0xE0
;
; instruction pointer r31:r30 as Z 
; return stack pointer r29:r28 as Y
; working register r25:r24 as W
; scratch register r0
;
; only LPM access flash ? YES!
;
;	if a vocabulary is in ram ? for atmega8 it will could not.
;
; all forth constants in flash
;
; all forth variables in sdram
;
;----------------------------------------------------------------------
.section .text
.org 0x100
.global forth
forth:
;----------------------------------------------------------------------
; inner interpreter, must have antoher name no LAST
;
LEAF 4, "_LAST"
_LAST:			
; does nothing and mark instructions code
	NOOP

; pull ip from rsp
_EXIT: 			
	rspull ips_low, ips_high

; load w with contents of cell at ip, only works in program memory (flash)  
_NEXT:			
	lpm wrk_low, Z+
	lpm wrk_high, Z+


; if zero then is a exec 
_EXEC:
	mov _work_, wrk_low
	or  _work_, wrk_high
	brbc BIT_ZERO, _ENTER
	ijmp

; else is a reference
; push ip into rsp
_ENTER:			
	rspush ips_low, ips_high
	movw ips_low, wrk_low
	rjmp _NEXT


;----------------------------------------------------------------------
; 
; using a classic, tos, (1st, 2nd, 3rd, 4th, ...)
;

;----------------------------------------------------------------------
; ok ( w -- ) ( -- W) 
LEAF 2, ">R"
GTR:
	NOOP
	pspull wrk_low, wrk_high
	rspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
; ok ( -- w ) ( w -- )
LEAF 2, "R>"
RGT:
	NOOP
	rspull wrk_low, wrk_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
; ok ( -- w ) ( w -- w )
LEAF 2, "R@"
RAT:
	NOOP
	rspull wrk_low, wrk_high
	rspush wrk_low, wrk_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
; ok ( -- rsp)  
LEAF 2, "RP@"
RPAT:
	NOOP
	movw wrk_low, rsp_low
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
; ok ( rsp -- )
LEAF 2, "RP!"
RPTO:
	NOOP
	pspull wrk_low, wrk_high
	movw rsp_low, wrk_low
	POON

;----------------------------------------------------------------------
; ok ( -- psp )
LEAF 2, "SP@"
SPAT:
	NOOP
	movw wrk_low, psp_low
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
; ok ( psp -- )
LEAF 2, "SP!"
SPTO:
	NOOP
	pspull wrk_low, wrk_high
	movw psp_low, wrk_low
	POON

;----------------------------------------------------------------------
; ok ( -- w )
LEAF 4, "PUSH"
PUSH:
	NOOP
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
; ok ( w -- )
LEAF 4, "DROP"
PULL:
DROP:
	NOOP
	pspull wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
; ok ( w -- w w)
LEAF 3, "DUP"
DUP:
	NOOP
	pspull wrk_low, wrk_high
	pspush wrk_low, wrk_high
	pspush wrk_low, wrk_high
	POON 

;----------------------------------------------------------------------
; ok ( w1 w2 -- w2 w1 )
LEAF 4, "SWAP"
SWAP:
	NOOP
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	pspush wrk_low, wrk_high
	pspush tos_low, tos_high
	POON

;----------------------------------------------------------------------
; ok ( w1 w2 -- w1 w2 w1 )
LEAF 4, "OVER"
OVER:
	NOOP
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	pspush tos_low, tos_high
	pspush wrk_low, wrk_high
	pspush tos_low, tos_high
	POON

;----------------------------------------------------------------------
; ok ( w1 w2 w3 -- w2 w3 w1 )
LEAF 4, "ROT"
ROT:
	NOOP
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	pspull nds_low, nds_high
	pspush wrk_low, wrk_high
	pspush nds_low, nds_high
	pspush tos_low, tos_high
	POON

;----------------------------------------------------------------------
; ok ( w -- 0 | w w )
LEAF 4, "?DUP"
NZDUP:
	NOOP
	pspull wrk_low, wrk_high
	pspush wrk_low, wrk_high
	mov _work_, wrk_low
	or  _work_, wrk_high
	brbs BIT_ZERO, NZDUP_1
	pspush wrk_low, wrk_high
NZDUP_1:
	POON 

;----------------------------------------------------------------------
; ok ( w1 w2 -- w2+w1 )
LEAF 1, "+"
PLUS: 
	NOOP
	clc
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	add wrk_low, tos_low
	adc wrk_high, tos_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
; ok ( w1 w2 -- w2-w1 )
LEAF 1, "-"
MINUS: 
	NOOP
	clc
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	sub wrk_low, tos_low
	sbc wrk_high, tos_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
; ok ( w1 w2 -- 0 | -1)
LEAF 1, "="
EQUAL: 
	NOOP
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	cp wrk_low, tos_low
	cpc wrk_high, tos_high
	brne FFALSE+2
	rjmp FTRUE+2

;----------------------------------------------------------------------
; nok ( w1 w2 -- 0 | -1 )
LEAF 1, "<"
LT: 
	NOOP
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	cp wrk_low, tos_low
	cpc wrk_high, tos_high
	brcs FFALSE+2
	rjmp FTRUE+2

;----------------------------------------------------------------------
; nok ( w1 w2 -- 0 | -1 )
LEAF 1, ">"
GT: 
	NOOP
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	cp wrk_low, tos_low
	cpc wrk_high, tos_high
	brcc FFALSE+2
	rjmp FTRUE+2

;----------------------------------------------------------------------
; ok ( -- -1 )
LEAF 4, "TRUE"
FTRUE:
	NOOP
	ser wrk_low
	ser wrk_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok ( -- 0 )
LEAF 5, "FALSE"
FFALSE:
	NOOP
	eor wrk_low, wrk_low
	eor wrk_high, wrk_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok ( if tos = 0 branch )
LEAF 6, "?BRANCH"
QMBRANCH:
	NOOP
	pspull wrk_low, wrk_high
	mov _work_, wrk_high
	or  _work_, wrk_low
	brbs BIT_ZERO, BRANCH+2
	rspull wrk_low, wrk_high
	adiw wrk_low, CELL_SIZE
	rspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok ( branch next reference )
LEAF 5, "BRANCH"
BRANCH:
	NOOP
	POON

;----------------------------------------------------------------------
;ok ( w1 w2 -- w2 AND w1 )
LEAF 3, "AND"
AND:
	NOOP
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	and  wrk_high, tos_high
	and  wrk_low, tos_low
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok ( w1 w2 -- w2 OR w1 )
LEAF 2, "OR"
OR:
	NOOP
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	or   wrk_high, tos_high
	or   wrk_low, tos_low
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok ( w1 w2 -- w2 XOR w1 )
LEAF 3, "XOR"
XOR:
	NOOP
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	eor   wrk_high, tos_high
	eor   wrk_low, tos_low
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok ( w -- w * 2 ) same as shift left << 1, unsigned
LEAF 2, "2*"
SHL:
	NOOP
	pspull wrk_low, wrk_high
	lsl   wrk_low
	rol   wrk_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok ( w -- w / 2 ) same as shift right >> 1, unsigned
LEAF 2, "2/"
SHR:
	NOOP
	pspull wrk_low, wrk_high
	clc
	lsr   wrk_low
	ror   wrk_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok ( w -- w * 2 ) same as shift left << 1, signed
LEAF 2, "2*A"
SHLA:
	NOOP
	pspull wrk_low, wrk_high
	clc
	bst wrk_high, 7
	cbr	wrk_high, 7
	lsl   wrk_low
	rol   wrk_high
	bld wrk_high, 7
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok ( w -- w / 2 ) same as shift right >> 1, signed
LEAF 3, "2/A"
SHRA:
	NOOP
	pspull wrk_low, wrk_high
	clc
	bst wrk_high, 7
	cbr	wrk_high, 7
	lsr   wrk_low
	ror   wrk_high
	bld wrk_high, 7
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok ( nAnB -- nBnA ) swap bytes in a word
LEAF 2, "><"
ENDIAN:
	NOOP
	pspull wrk_low, wrk_high
	pspush wrk_high, wrk_low
	POON

;----------------------------------------------------------------------
;  os doLIT ( -- w ), from flash program memory to data stack
LEAF 5, "DOLIT"
DOLIT:
	NOOP
	rspull ips_low, ips_high
; load from flash program memory
	pmload wrk_low, wrk_high
	rspush ips_low, ips_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;  os doVAR ( -- w ) from sram memory to data stack
LEAF 5, "DOVAR"
	NOOP
	rspull ips_low, ips_high
; load from static ram memory
	srload wrk_low
	srload wrk_high
	rspush ips_low, ips_high
	pspush wrk_low, wrk_high
	POON

DOVAR:
;----------------------------------------------------------------------
;  os doCON ( -- w ) from sram memory to data stack
LEAF 5, "DOCON"
DOCON:
	NOOP
	rspull ips_low, ips_high
; load from static ram memory
	srload wrk_low
	srload wrk_high
	rspush ips_low, ips_high
	movw ips_low, wrk_low
; load from static ram memory
	srload wrk_low
	srload wrk_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
; ok ! to (x a -- )
LEAF 1, "!"
TO:
	NOOP
	pspull ips_low, ips_high
	pspull wrk_low, wrk_high
	srsave wrk_low
	srsave wrk_high
	POON

;----------------------------------------------------------------------
; ok C! ( c a -- )
LEAF 1, "C!"
CTO:
	NOOP
	pspull ips_low, ips_high
	pspull wrk_low, wrk_high
	srsave wrk_low
	POON

;----------------------------------------------------------------------
; ok @ at ( a -- w )
LEAF 1, "@"
AT:
	NOOP
	pspull ips_low, ips_high
    srload wrk_low
    srload wrk_high
	pspush wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
; ok C@ cat
LEAF 1, "C@"
CAT:
	NOOP
	pspull ips_low, ips_high
    srload wrk_low
	clr wrk_high
	pspush wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
;  ok 0>
LEAF 2, "0>"
ZEROGT:
	NOOP
	pspull wrk_low, wrk_high
    sbiw wrk_low, 1
    brge _ZEROGT1
    rjmp FTRUE
_ZEROGT1:
    rjmp FFALSE

;----------------------------------------------------------------------
;  ok 0<
LEAF 2, "0<"
ZEROLT:
	NOOP
	pspull wrk_low, wrk_high
    sbiw wrk_low, 1
    brge _ZEROLT1
    rjmp FFALSE
_ZEROLT1:
    rjmp FTRUE

;----------------------------------------------------------------------
; ok 0=
LEAF 2, "0="
ZEROEQ:
	NOOP
	pspull wrk_low, wrk_high
	or  wrk_high, wrk_low
	brbs BIT_ZERO, _ZEROEQ1
    rjmp FFALSE
_ZEROEQ1:
    rjmp FTRUE

;----------------------------------------------------------------------
; ok INV
LEAF 3, "INV"
INV:
	NOOP
	pspull wrk_low, wrk_high
    com wrk_low
    com wrk_high
	pspush wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
; ok NEG
LEAF 3, "NEG"
NEG:
	NOOP
	pspull wrk_low, wrk_high
    neg wrk_low
    neg wrk_high
	pspush wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
; ok ABS
LEAF 3, "ABS"
ABS:
	NOOP
	pspull wrk_low, wrk_high
    cbr wrk_high, 7
	pspush wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
;
; compare cells from source++ to destination++, decrease count--
; ( a1 u1 a2 u2 -- flag)
;
LEAF 4, "COMPARE"
COMPARE:
	NOOP
    ; WARNING No bound check and counter equal 0 moves nothing

	; puul lenght 
	pspull tos_low, tos_high

	; pull address
	pspull ips_low, ips_high
	
	; pull lenght
	pspull nds_low, nds_high

    ; pull length
	pspull wrk_low, wrk_high

	; push psp
	rspush psp_low, psp_high

	; copy address
	movw psp_low, wrk_low

    ; no offset

_COMPARE:
	ld wrk_low, Z+
	ld wrk_high, X+
	or wrk_low, wrk_high
	brne _COMPARE_NOT_EQUAL

_COMPARE_TEST_LENGTH_1:
	movw wrk_low, tos_low
	sbiw wrk_low, 1
	brbs BIT_ZERO, _COMPARE_EQUAL
	movw tos_low, wrk_low

_COMPARE_TEST_LENGTH_2:
	movw wrk_low, nds_low
	sbiw wrk_low, 1
	brbs BIT_ZERO, _COMPARE_EQUAL
	movw nds_low, wrk_low
	rjmp _COMPARE

_COMPARE_EQUAL:
	clr wrk_low
	clr wrk_high
	rjmp _COMPARE_ENDS
_COMPARE_NOT_EQUAL:
	ser wrk_low
	ser wrk_high
_COMPARE_ENDS:
	rspull psp_low, psp_high
	pspush wrk_low, wrk_high	
	POON

;----------------------------------------------------------------------
;
; MOVE copy cells from source++ to destination++, decrease count--
LEAF 4, "MOVE"
MOVE:
	NOOP
    ; WARNING No bound check and counter equal 0 moves nothing

	; pull origin
	pspull tos_low, tos_high
	
	; pull destination
	pspull ips_low, ips_high

    ; pull counter
	pspull wrk_low, wrk_high

	; push psp
	rspush psp_low, psp_high

	; copy orign
	movw psp_low, tos_low

    ; no offset

_MOVE1:
    ; decrease counter

    sbiw wrk_low, 1
    brlt _MOVE2

    ; move a byte
    ld _work_, X+
    st Z+, _work_
    
	; move a byte
    ld _work_, X+
    st Z+, _work_

    ; again
    rjmp _MOVE1

_MOVE2:
	; pull psp
	rspull psp_low, psp_high
	POON

;----------------------------------------------------------------------
;
; CMOVE copy bytes from source++ to destination++, decrease count--
LEAF 5, "CMOVE"
CMOVE:
	NOOP
    ; WARNING No bound check and counter equal 0 moves nothing

	; pull origin
	pspull tos_low, tos_high
	
	; pull destination
	pspull ips_low, ips_high

    ; pull counter
	pspull wrk_low, wrk_high

	; push psp
	rspush psp_low, psp_high

	; copy orign
	movw psp_low, tos_low

    ; no offset

_CMOVE1:
    ; decrease counter

    sbiw wrk_low, 1
    brlt _CMOVE2

    ; move a byte
    ld _work_, X+
    st Z+, _work_
    
    ; again
    rjmp _CMOVE1

_CMOVE2:
	; pull psp
	rspull psp_low, psp_high
	POON

;----------------------------------------------------------------------
;
; CMOVE copy bytes from source+count-- to destination+count--, decrease count--
LEAF 5, "CMOVE>"
CMOVEGT:
	NOOP
    ; WARNING No bound check and counter equal 0 moves nothing

	; pull origin
	pspull tos_low, tos_high
	
	; pull destination
	pspull ips_low, ips_high

    ; pull counter
	pspull wrk_low, wrk_high

	; push psp
	rspush psp_low, psp_high

	; copy orign
	movw psp_low, tos_low

    ; do offset

    adiw wrk_low, 1

    add psp_low, wrk_low
    adc psp_high, wrk_high

    add ips_low, wrk_low
    adc ips_high, wrk_high

    sbiw wrk_low, 1

_CMOVEGT1:
    ; decrease counter

    sbiw wrk_low, 1
    brlt _CMOVEGT2

    ; move a byte
    ld _work_, -X
    st -Z, _work_
    
    ; again
    rjmp _CMOVEGT1

_CMOVEGT2:
	; pull psp
	rspull psp_low, psp_high
	POON

;----------------------------------------------------------------------
;  data space pointer align to CELL, ZZZZ
LEAF 5, "ALIGN"
ALLIGN:
	NOOP
    POON

;----------------------------------------------------------------------
;
; ok CELL is 2 ; size of a cell
;
LEAF 2, "CELL"
CELLSZ:
	NOOP
    ldi wrk_low, CELL_SIZE
    clr wrk_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;
; ok CELL is 2, multiply by 2
;
LEAF 5, "CELLS"
CELLS:
	NOOP
    rjmp SHL+2

;----------------------------------------------------------------------
; ????
;
; http:
	NOOP//www.avr-asm-tutorial.net/avr_en/apps/random_tn13/random_calc_tn13.html
;
;    good seeds
;
;    B167 4A3C 9879 B61E 7B26 
;    A858 1F88 50D5 419D 5537
;    0224 0527 5EB6 1E6D BCDC
;    92FF C206 0ECD 9361 2823
;    BE0B B303 6462 0E4C 3D24
;
LEAF 3, "_RND_"
RND:
	NOOP
;    load seed
    lds wrk_low, _wRANDW
    lds wrk_high, _wRANDW + 1
;
;    run magics
;
    eor wrk_low, wrk_high
    swap wrk_low
    add wrk_high, wrk_low

;    save seed
    sts _wRANDW, wrk_low
    sts _wRANDW + 1, wrk_high
;
	pspush wrk_low, wrk_high
    POON
    
;----------------------------------------------------------------------
;
#include "variables.inc"

#include "constants.inc"

#include "uart.inc"

