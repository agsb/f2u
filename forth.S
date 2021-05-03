/*
 *  DISCLAIMER"
 *
 *  Copyright © 2020, Alvaro Barcellos,
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

/*
;---------------------------------------------------------------------
; dictionary structure
;
 .word  link    link to previous
 .byte  size    sizeof name OR mask 0x1F
 .ascii "name" name, plus a pad byte with BL (0x32) if size is odd
 .word  param,  many

;----------------------------------------------------------------------

02/05/2021

    Rewrite again using sectorforth as minimal design

18/04/2021

    Rewrite all from u2f*, using a new minimal forth engine as LAST word 

*/

    .NOLIST

    .LIST

;----------------------------------------------------------------------
; start of dictionary
;

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
; all forth constants and variables in sdram
;
;----------------------------------------------------------------------
.section .text
.org 0x100
.global forth
forth:
;----------------------------------------------------------------------
; inner interpreter, must have another name no LAST
;
HEADER "_LAST", "_LAST"
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
    cp wrk_low, wrk_high
    brbs BIT_ZERO, _EXEC

; else is a reference
_ENTER:            
    rspush ips_low, ips_high

; push ip into rsp
    movw ips_low, wrk_low
    rjmp _NEXT

_EXEC:
    ijmp

;----------------------------------------------------------------------
; 
; using a classic, tos, (1st, 2nd, 3rd, 4th, ...)
;
;----------------------------------------------------------------------
; ok @ at ( a -- w )
HEADER "@", "AT"
    NOOP
    pspull ips_low, ips_high
    srload wrk_low
    srload wrk_high
    pspush wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
; ok ! to (x a -- )
HEADER "!", "TO"
    NOOP
    pspull ips_low, ips_high
    pspull wrk_low, wrk_high
    srsave wrk_low
    srsave wrk_high
    POON

;----------------------------------------------------------------------
; ok ( -- rsp)
HEADER "RP@", "RPAT"
    NOOP
    movw wrk_low, rsp_low
    pspush wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
; ok ( -- psp )
HEADER "SP@", "SPAT"
    NOOP
    movw wrk_low, psp_low
    pspush wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
; ok 0=
HEADER "0=", "ZEROEQU"
    NOOP
    pspull wrk_low, wrk_high
    cp wrk_high, wrk_low
    brbc BIT_ZERO, _FFALSE
_FTRUE:
    ser wrk_low
    ser wrk_high
    rjmp _ZEROEND
_FFALSE:
    clr wrk_low
    clr wrk_high
_ZEROEND:
    pspush wrk_low, wrk_high
    rjmp FTRUE+2

;----------------------------------------------------------------------
;ok ( w1 w2 -- w2 AND w1 )
HEADER "NAND", "NAND"
	NOOP
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	and wrk_high, tos_high
	and wrk_low, tos_low
	com wrk_high
	com wrk_low
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok ( w1 w2 -- w2 AND w1 )
HEADER "+", "PLUS"
	NOOP
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	add wrk_low, tos_low
	adc wrk_high, tos_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;----------------------------------------------------------------------
;ok 
HEADER "TIB", "TIBVAR"
	NOOP
	ldi wrk_low, lo8(TIB)
	ldi wrk_high, hi8( TIB)
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok 
HEADER "STATE", "STATEVAR"
	NOOP
	ldi wrk_low, lo8(STATE)
	ldi wrk_high, hi8(STATE)
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok 
HEADER ">IN", "TOINVAR"
	NOOP
	ldi wrk_low, lo8(TIN)
	ldi wrk_high, hi8(TIN)
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok 
HEADER "HERE", "HEREVAR"
	NOOP
	ldi wrk_low, lo8(HERE)
	ldi wrk_high, hi8(HERE)
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok 
HEADER "LAST", "LASTVAR"
	NOOP
	ldi wrk_low, lo8(LAST)
	ldi wrk_high, hi8(LAST)
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok 
HEADER "BASE", "BASEVAR"
	NOOP
	ldi wrk_low, lo8(BASE)
	ldi wrk_high, hi8(BASE)
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;
; beware, it blocks! test if can receive a char
;
HEADER "key", "KEY"
RXAT:
    NOOP
    sbis 0xb, 7
    rjmp RXAT
    in wrk_low, 0xc
    clr wrk_high
    pspush wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
;
; beware, it blocks! test if can send a char 
;
HEADER "emit", "EMIT"
TXTO:
    NOOP
    sbis 0xb, 5
    rjmp TXTO
    pspull wrk_low, wrk_high
    out 0xc, wrk_low
    POON

;----------------------------------------------------------------------
;
; ok ( a1 c --- a2 u ) 
;	search start at a1 for next word delimited by c or \0
;	returns start a2 and u lenght
;
HEADER "TOKEN", "TOKEN"
	NOOP
	pspull ips_low, ips_high
	pspull wrk_low, wrk_high
1:	; skip while equal
	srload wrk_high
	cp wrk_high, wrk_high
	brbs BIT_ZERO, 2f
	cp wrk_low, wrk_high
	breq 1b
	; keep address
2:	sbiw ips_low, 1
	pspush ips_low, ips_high
	pspush ips_low, ips_high
3:	; skip wile not equal
	srload wrk_high
	cp wrk_high, wrk_high
	brbs BIT_ZERO, 4f
	cp wrk_low, wrk_high
	brne 3b
4:	; keep length
	pspull wrk_low, wrk_high
	sub ips_low, wrk_low
	sbc ips_high, wrk_high
	pspush ips_low, ips_high
	POON
	

;----------------------------------------------------------------------
;
; ok accept ( -- u ) 
;	read chars into tib until CR or size=0
;
HEADER "accept", "accept"
    NOOP
	ldi	ips_low, lo8(TIB)
	ldi ips_high, hi8(TIB)
	ldi	wrk_high, SIZE_TIB
	clr _work_	 ; clear length

1:	; decrease counter	
	dec wrk_high
	brbs BIT_ZERO, 2f
3:	; waits a char
    sbis 0xb, 7
    rjmp 3b
    in wrk_low, 0xc
	; verify CR
	cp wrk_low, 13 ; CR
	breq 2f
	; verify ESC 
	cp wrk_low, 27 ; ESC
	brne 4f
	; process ESC
	rjmp 3b
4:	; verify BS
	cp wrk_low,  8 ; BS
	brne 5f
	; process BS
	cp _work_, _work_
	brbs BIT_ZERO, 3b
	dec _work_
	sbiw ips_low, 1
	rjmp 3b	
5:	; is valid char
	cpi	wrk_low, 32
	brlo 3b
	cpi wrk_low, 127
	brge 3b
	; to uppercase
	cpi wrk_low, 61
	brge 6f
	cpi wrk_low, 123
	brge 6f
	subi wrk_low, 32
6:	; save char to buffer
	inc _work_
	srsave wrk_low
	rjmp 1b
2:	; push counter
	; always add \0 terminator
	clr wrk_low
	srsave wrk_low
	; update TOIN
	sts (TOIN+1), _wrk_low
	mov wrk_low, _work_
	sts (TOIN+0), _wrk_low
	pspush wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
;
; ok push timer counter
;
HEADER "millis", "MILLIS"
    NOOP
    pspush tmr_low, tmr_high
    POON



