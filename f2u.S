
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
 
	
	"Where AVRs use addresses or othe values which need two bytes, 
	they would seem to use the little endian method, 
	i.e. the low byte of the address or value occupies the lower memory address. 
	The GCC compiler, which is part of WinAVR, uses the same convention (at the moment)."

;---------------------------------------------------------------------
; dictionary structure
;
 .word  link    link to previous
 .byte  size    sizeof name OR mask 0x1F
 .ascii "name"  name, plus a pad byte with BL (0x32) if size is odd
 .word  param,  many

*/

;----------------------------------------------------------------------

18/04/2021
	Rewrite all from u2f*, using a new minimal forth engine as NOOP word 

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

#include "boot.inc"

;----------------------------------------------------------------------
; start of dictionary
;
;----------------------------------------------------------------------

;----------------------------------------------------------------------
;
; any leaf must start with NOOP and end with POON
;
.macro NOOP
        nop
        nop
.endm

.macro POON
        rjmp _EXIT
.endm

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
/*	

this is an explicit implementation without macros

LEAF 4, "LAST"
LAST:			; does nothing and mark instructions code
	nop
	nop
_EXIT: 			; pull ip from rsp
	ld r30, Y+
	ld r31, Y+
_THIS:			; load w with contents of cell at ip
	lpm r24, Z+
	lpm r25, Z+
_EXEC:			; check is contents is zero,  if not then bracj to ip, else continue 
	mov r0, r25
	or  r0, r24
	brne _ENTER
	ijmp
_ENTER:			; push ip into rsp
	st -Y, r31
	st -Y, r30
_NEXT:			; point to next reference
	movw r30, r24
	rjmp _THIS

*/

;----------------------------------------------------------------------
;
;
LEAF 4, "LAST"
LAST:			
; does nothing and mark instructions code
	NOOP
; pull ip from rsp
_EXIT: 			
	rsp_pull ip_low, ip_high
; load w with contents of cell at ip, only works in program memory (flash)  
_THIS:			
	next_wrk
; check if is reference is zero, then jump imediate next cell, else continue 
_EXEC:			
	mov r0, r25
	or  r0, r24
	brne _ENTER
	ijmp
; push ip into rsp
_ENTER:			
	rsp_push ip_low, ip_high
; point to next reference
_NEXT:			
	movw ip_low, wrk_low
	rjmp _THIS

;----------------------------------------------------------------------
; init instruction pointer and etc
;
LEAF 3, "BYE"
BYE:
	NOOP
; in a uC better sleep or reset ?
	rjmp RESET
	POON

;----------------------------------------------------------------------
;
; init return stack
;
LEAF 5, "ABORT"
ABORT:
	NOOP
;	init registers
    eor _work_, _work_
    eor _zero_, _zero_
    eor tos_high, tos_high
    eor tos_low, tos_low
    eor nds_high, nds_high
    eor nds_low, nds_low
    eor wrk_high, wrk_high
    eor wrk_low, wrk_low
    ldi zh, hi8(_INIT)
    ldi zl, lo8(_INIT)
; init return stack
    ldi rsp_high, hi8(RSP_TOP)
    ldi rsp_low, lo8(RSP_TOP)
	rjmp QUIT

;----------------------------------------------------------------------
;
; init parameter stack
;
LEAF 4, "QUIT"
QUIT:
	NOOP
; init parameter stack
    ldi psp_high, hi8(PSP_TOP)
    ldi psp_low, lo8(PSP_TOP)
	POON

;----------------------------------------------------------------------
;
; init registers 
;

;----------------------------------------------------------------------
#include "uart.inc"

;----------------------------------------------------------------------
; ok load a value from flash and push into parameter stack
;
LEAF 7, "doLIT"
DOLIT:
	NOOP
    pspush nds_low, nds_high
    movw nds_low, tos_low
    next_wrk
	movw tos_low, wrk_low
    POON

;----------------------------------------------------------------------
; get address of a variable ????
;
LEAF 4, "doVAR"
DOVAR:
	NOOP
    ; zzz ?
    POON

;----------------------------------------------------------------------
; get address of a constant ????
;
LEAF 4, "doCON"
DOCON:
	NOOP
    ; zzz ?
    POON

;----------------------------------------------------------------------
;
; ok if 0 branch ( a -- F | T )
;
LEAF 7, "?BRANCH"
QMBRANCH:
	NOOP
	pull_wrk
	or wrk_ligh, wrk_low
    breq BRANCH
	rsp_pull wrk_low, wrk_high
	adiw wrk_low, CELL	
	rsp_push wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
; ok branch
LEAF 6, "BRANCH"
BRANCH:
	NOOP
	rsp_pull ip_low, ip_high
    lpm wrk_low, Z+
    lpm wrk_high, Z+
	rsp_push wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
; ?? ok +! to
LEAF 2, "+!"
PLUSTO:
	NOOP
    rspush xl, xh
    movw xl, tos_low
    ld wrk_high, X+
    ld wrk_low, X+
    add wrk_low, nds_low
    adc wrk_high, nds_high
    st -X, wrk_low
    st -X, wrk_high
    rspull xl, xh
    rjmp TWODROP

;----------------------------------------------------------------------
; ok ! to (works only in sram)
LEAF 1, "!"
TO:
	NOOP
    movw wrk_low, ip_low
	movw ip_low, tos_low
    st Z+, nds_high
    st Z+, nds_low
_TO1:
    movw ip_low, wrk_low
    rjmp TWODROP

;----------------------------------------------------------------------
; ok C!
LEAF 1, "C!"
CTO:
	NOOP
    movw wrk_low, ip_low
	movw ip_low, tos_low
    st Z+, nds_low
    rjmp _TO1

;----------------------------------------------------------------------
; ok @ at (works only in sram)
LEAF 1, "@"
AT:
	NOOP
    movw wrk_low, ip_low
	movw ip_low, tos_low
    ld tos_high, z+
    ld tos_low, z+
_AT1:
    movw ip_low, wrk_low
    POON

;----------------------------------------------------------------------
; ok C@ cat
LEAF 1, "C@"
CAT:
	NOOP
    movw wrk_low, ip_low
	movw ip_low, tos_low
    ld tos_low, z+
    eor tos_high, tos_high
    rjmp _AT1

;----------------------------------------------------------------------
#include "stacks.inc"

;----------------------------------------------------------------------
;
;    ok 
LEAF 5, "1+"
ONEPLUS:
	NOOP
    movw wrk_low, tos_low
    adiw wrk_low, 1
    movw tos_low, wrk_low
    POON

;----------------------------------------------------------------------
;
;    ok
LEAF 2, "1-"
ONEMINUS:
	NOOP
    movw wrk_low, tos_low
    sbiw wrk_low, 1
    movw tos_low, wrk_low
    POON

;----------------------------------------------------------------------
#include "bits.inc"

;----------------------------------------------------------------------
;  ok 0>
LEAF 2, "0>"
ZEROGT:
	NOOP
    pull_wrk
    sbiw wrk_low, 1
    brge _ZEROGT1
    rjmp FTRUE
_ZEROGT1:
	NOOP
    rjmp FFALSE
;----------------------------------------------------------------------
;  ok 0<
LEAF 2, "0<"
ZEROLT:
	NOOP
	pull_wrk
    sbiw wrk_low, 1
    brge _ZEROLT1
    rjmp FFALSE
_ZEROLT1:
	NOOP
    rjmp FTRUE

;----------------------------------------------------------------------
; ok 0=
LEAF 2, "0="
ZEROEQ:
	NOOP
	pull_wrk
    sbiw wrk_low, 1
    breq _ZEROEQ1
    rjmp FFALSE
_ZEROEQ1:
	NOOP
    rjmp FTRUE

;----------------------------------------------------------------------
; ok XOR
LEAF 3, "XOR"
XOR:
	NOOP
    eor nds_low, tos_low
    eor nds_high, tos_high
    rjmp DROP

;----------------------------------------------------------------------
; ok AND
LEAF 3, "AND"
AND:
	NOOP
    and nds_low, tos_low
    and nds_high, tos_high
    rjmp DROP

;----------------------------------------------------------------------
; ok OR
LEAF 2, "OR"
OR:
	NOOP
    or nds_low, tos_low
    or nds_high, tos_high
    rjmp DROP

;----------------------------------------------------------------------
; ok +
LEAF 1, "+"
PLUS:
	NOOP
    add nds_low, tos_low
    adc nds_high, tos_high
    rjmp DROP

;----------------------------------------------------------------------
; ok -
LEAF 1, "-"
MINUS:
	NOOP
    sub nds_low, tos_low
    sbc nds_high, tos_high
    rjmp DROP

;----------------------------------------------------------------------
; <
LEAF 1, "<"
LTHAN:
	NOOP
    sub nds_low, tos_low
    sbc nds_high, tos_high
    brlt _LTHAN1
    rjmp FTRUE
_LTHAN1:
	NOOP
    rjmp FFALSE

;----------------------------------------------------------------------
; >
LEAF 1, ">"
GTHAN:
	NOOP
    sub nds_low, tos_low
    sbc nds_high, tos_high
    brge _GTHAN1
    rjmp FFALSE
_GTHAN1:
	NOOP
    rjmp FTRUE

;----------------------------------------------------------------------
; >
LEAF 1, "="
EQUAL:
	NOOP
    sub nds_low, tos_low
    sbc nds_high, tos_high
    breq _EQUAL1
    rjmp FFALSE
_EQUAL1:
	NOOP
    rjmp FTRUE

;----------------------------------------------------------------------
; ok INV
LEAF 3, "INV"
INV:
	NOOP
    com tos_low
    com tos_high
    POON

;----------------------------------------------------------------------
; ok NEG
LEAF 3, "NEG"
NEG:
	NOOP
    neg tos_low
    neg tos_high
    POON

;----------------------------------------------------------------------
; ok 2*
LEAF 2, "2*"
SHL:
	NOOP
    lsl tos_low
    rol tos_high
    POON

;----------------------------------------------------------------------
; ok 2/
LEAF 2, "2/"
SHR:
	NOOP
    asr tos_high
    ror tos_low
    POON

;----------------------------------------------------------------------
; UM+
LEAF 3, "UM+"
UPLUS:
	NOOP
    ; do signed plus
    add nds_low, tos_low
    adc nds_high, tos_high
    ; preserve carry at tos
    eor tos_low, tos_low
    eor tos_high, tos_high
    rol tos_low
    POON

;----------------------------------------------------------------------
;
; CMOVE copy from source++ to destination++, decrease w
LEAF 5, "CMOVE"
CMOVE:
	NOOP
    ; WARNING No bound check
    ; tos source
    ; nds destination
    ; w   1 or many, 0 does nothing

;    source exchange tos to psp (Y)

    movw wrk_low, tos_low
    movw tos_low, psp_low
    movw psp_low, wrk_low

;    destination exchange nds and rsp (X)

    movw wrk_low, nds_low
    movw nds_low, rsp_low
    movw rsp_low, wrk_low

    ; get the counter
    pspull wrk_low, wrk_high

    ; no offset

_CMOVE1:
	NOOP
    ; decrease counter

    sbiw wrk_low, 1
    brlt _CMOVE2

    ; move a byte
    ld _work_, Y+
    st X+, _work_

    ; again
    rjmp _CMOVE1

_CMOVE2:
	NOOP

    movw psp_low, tos_low
    movw rsp_low, nds_low

    rspull tos_low, tos_high
    rspull nds_low, nds_high

    rjmp  CORE

;----------------------------------------------------------------------
; CMOVE> copy from source+w to destination+w, decrease w
LEAF 5, "CMOVE>"
CMOVEGT:
	NOOP
    ; WARNING No bound check
    ; tos source
    ; nds destination
    ; w 1 or many, 0 does nothing

;    source exchange tos and psp (Y)

    movw wrk_low, tos_low
    movw tos_low, psp_low
    movw psp_low, wrk_low

;    destination exchange nds and rsp (X)

    movw wrk_low, nds_low
    movw nds_low, rsp_low
    movw rsp_low, wrk_low

    ; get the counter
    pspull wrk_low, wrk_high

    ; offset predecrements

    adiw wrk_low, 1

    add psp_low, wrk_low
    adc psp_high, wrk_high

    add rsp_low, wrk_low
    adc rsp_high, wrk_high

    sbiw wrk_low, 1

_CMOVEGT1:
	NOOP
    ; decrease counter
    sbiw wrk_low, 1
    brlt _CMOVEGT2

    ; move a byte
    ld _work_, -Y
    st -X, _work_

    ; again
    rjmp _CMOVEGT1

_CMOVEGT2:
	NOOP

    movw psp_low, tos_low
    movw rsp_low, nds_low

    rspull tos_low, tos_high
    rspull nds_low, nds_high

    rjmp  CORE

;----------------------------------------------------------------------
;
; ok ALIGN, easy as cell is 2 bytes
; if lsb set sum 1
;
LEAF 5, "ALIGN"
ALLIGN:
	NOOP
    movw wrk_low, tos_low
    adiw wrk_low, 1
    movw tos_low, wrk_low
    lsr tos_low
    lsl tos_low
    POON

;----------------------------------------------------------------------
;
; ok CELL is 2 ; size of a cell
;
LEAF 2, "CELL"
CELLSZ:
	NOOP
    ldi wrk_low, CELL_SIZE
    eor wrk_high, wrk_high
    rjmp PUSHS

;----------------------------------------------------------------------
;
; ok CELL is 2, multiply by 2
;
LEAF 5, "CELLS"
CELLS:
	NOOP
    rjmp SHL

;----------------------------------------------------------------------
;
; ok add CELL_SIZE
;
LEAF 5, "CELL+"
CELLPLUS:
	NOOP
    movw wrk_low, tos_low
    adiw wrk_low, CELL_SIZE
    movw tos_low, wrk_low
    POON

;----------------------------------------------------------------------
;
; ok sub CELL_SIZE
;
LEAF 5, "CELL-"
CELLMINUS:
	NOOP
    movw wrk_low, tos_low
    sbiw wrk_low, CELL_SIZE
    movw tos_low, wrk_low
    POON

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
    lds wrk_low, _RANDW
    lds wrk_high, _RANDW + 1
;
;    run magics
;
    eor    wrk_low, wrk_high
    swap wrk_low
    add wrk_high, wrk_low

;    save seed
    sts _RANDW, wrk_low
    sts _RANDW + 1, wrk_high
;
    rjmp PUSHS
    
;----------------------------------------------------------------------
; ????
LEAF 3, "D2/"
DSHR:
	NOOP
    lsr nds_low
    ror nds_high
    ror tos_low
    ror tos_high
    POON

;----------------------------------------------------------------------
; ????
LEAF 3, "D2*"
DSHL:
	NOOP
    lsl nds_low
    rol nds_high
    rol tos_low
    rol tos_high
    POON

;----------------------------------------------------------------------
#include "constants.inc" 

;----------------------------------------------------------------------
#include "variables.inc" 

;----------------------------------------------------------------------
#include "twigs.inc" 

;----------------------------------------------------------------------

