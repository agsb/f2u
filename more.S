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

;----------------------------------------------------------------------
; 
; ok ( w -- ) ( -- W) 
; 	F18A push
HEADER ">R", "TOR"
	NOOP
	pspull wrk_low, wrk_high
	rspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
; ok ( -- w ) ( w -- )
;	F18A pull
HEADER "R>", "RTO"
	NOOP
	rspull wrk_low, wrk_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
; ok ( -- w ) ( w -- w )
HEADER "R@", "RAT"
	NOOP
	rspull wrk_low, wrk_high
	rspush wrk_low, wrk_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
; ok ( rsp -- )
HEADER "RP!", "RPTO"
	NOOP
	pspull wrk_low, wrk_high
	movw rsp_low, wrk_low
	POON

;----------------------------------------------------------------------
; ok ( psp -- )
HEADER "SP!", "SPTO"
	NOOP
	pspull wrk_low, wrk_high
	movw psp_low, wrk_low
	POON

;----------------------------------------------------------------------
; ok ( -- w )
;	F18A
HEADER "PUSH", "PUSH"
	NOOP
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
; ok ( w -- )
;	F18A drop
HEADER "DROP", "DROP"
PULL:
	NOOP
	pspull wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
; ok ( w -- w w)
; 	F18A dup
HEADER "DUP", "DUP"
	NOOP
	pspull wrk_low, wrk_high
	pspush wrk_low, wrk_high
	pspush wrk_low, wrk_high
	POON 

;----------------------------------------------------------------------
; ok ( w1 w2 -- w2 w1 )
HEADER "SWAP", "SWAP"
	NOOP
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	pspush wrk_low, wrk_high
	pspush tos_low, tos_high
	POON

;----------------------------------------------------------------------
; ok ( w1 w2 -- w1 w2 w1 )
; 	F18A over
HEADER "OVER", "OVER"
	NOOP
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	pspush tos_low, tos_high
	pspush wrk_low, wrk_high
	pspush tos_low, tos_high
	POON

;----------------------------------------------------------------------
; ok ( w1 w2 w3 -- w2 w3 w1 )
HEADER "ROT", "ROT"
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
HEADER "?DUP", "ZDUP"
	NOOP
	pspull wrk_low, wrk_high
	cp wrk_low, wrk_high
	brbs BIT_ZERO, 1f
	pspush wrk_low, wrk_high
1:	
	pspush wrk_low, wrk_high
	POON 

;----------------------------------------------------------------------
;ok ( u -- )
;	F18A	T=0
HEADER "?BRANCH", "QBRANCH"
	NOOP
	pspull wrk_low, wrk_high
	cp wrk_low, wrk_high
	brbs BIT_ZERO, 1f
	rspull wrk_low, wrk_high
	adiw wrk_low, CELL_SIZE
	rspush wrk_low, wrk_high
1:	
	POON

;----------------------------------------------------------------------
;ok ( branch next reference )
HEADER "BRANCH", "BRANCH"
	NOOP
    rspull ips_low, ips_high
    pmload wrk_low, wrk_high
    rspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok ( branch next reference )
HEADER "EXEC", "EXEC"
	NOOP
	pspull wrk_low, wrk_high
	rspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
; ok ( w1 w2 -- w2-w1 )
HEADER "-", "MINUS" 
	NOOP
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	clc
	sub wrk_low, tos_low
	sbc wrk_high, tos_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
; ok ( w1 w2 -- 0 | -1)
HEADER "=", "EQUAL"
	NOOP
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	cp wrk_low, tos_low
	cpc wrk_high, tos_high
	brne FFALSE+2
	rjmp FTRUE+2

;----------------------------------------------------------------------
; nok ( w1 w2 -- 0 | -1 )
HEADER "<", "LTHAN"
	NOOP
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	cp wrk_low, tos_low
	cpc wrk_high, tos_high
	brcs FFALSE+2
	rjmp FTRUE+2

;----------------------------------------------------------------------
; nok ( w1 w2 -- 0 | -1 )
HEADER ">", "GTHAN"
	NOOP
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	cp wrk_low, tos_low
	cpc wrk_high, tos_high
	brcc FFALSE+2
	rjmp FTRUE+2

;----------------------------------------------------------------------
; ok ( -- -1 )
HEADER "TRUE", "FTRUE"
	NOOP
	ser wrk_low
	ser wrk_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok ( -- 0 )
HEADER "FALSE", "FFALSE"
	NOOP
	clr wrk_low
	clr wrk_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok ( w1 w2 -- w2 AND w1 )
HEADER "AND", "AND"
	NOOP
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	and  wrk_high, tos_high
	and  wrk_low, tos_low
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok ( w1 w2 -- w2 OR w1 )
HEADER "OR", "OR"
	NOOP
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	or   wrk_high, tos_high
	or   wrk_low, tos_low
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok ( w1 w2 -- w2 XOR w1 )
HEADER "XOR", "XOR"
	NOOP
	pspull wrk_low, wrk_high
	pspull tos_low, tos_high
	eor   wrk_high, tos_high
	eor   wrk_low, tos_low
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok ( w -- w * 2 ) same as shift left << 1, unsigned
HEADER "2*", "SHL"
	NOOP
	pspull wrk_low, wrk_high
	clc
	lsl   wrk_low
	rol   wrk_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok ( w -- w / 2 ) same as shift right >> 1, unsigned
HEADER "2/", "SHR"
	NOOP
	pspull wrk_low, wrk_high
	clc
	lsr   wrk_low
	ror   wrk_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;ok ( w -- w * 2 ) same as shift left << 1, signed
HEADER "2*A", "SHLA"
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
HEADER "2/A", "SHRA"
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
HEADER "><", "ENDIAN"
	NOOP
	pspull wrk_low, wrk_high
	pspush wrk_high, wrk_low
	POON

;----------------------------------------------------------------------
;  os doLIT ( -- w ), from flash program memory to data stack
HEADER "DOLIT", "DOLIT"
	NOOP
	rspull ips_low, ips_high
; load from flash program memory
	pmload wrk_low, wrk_high
	rspush ips_low, ips_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;  os doVAR ( -- w ) from sram memory to data stack
HEADER "DOVAR", "DOVAR"
	NOOP
	rspull ips_low, ips_high
; load from static ram memory
	srload wrk_low
	srload wrk_high
	rspush ips_low, ips_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;  os doCON ( -- w ) from sram memory to data stack
HEADER "DOCON", "DOCON"
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
; ok C! ( c a -- )
HEADER "C!", "CTO"
	NOOP
	pspull ips_low, ips_high
	pspull wrk_low, wrk_high
	srsave wrk_low
	POON

;----------------------------------------------------------------------
; ok C@ ( c a -- )
HEADER "C@", "CAT"
	NOOP
	pspull ips_low, ips_high
	srload wrk_low
	clr wrk_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;  ok 0>	must be signed
HEADER "0>", "ZEROGT"
	NOOP
	pspull wrk_low, wrk_high
    sbiw wrk_low, 1
    brge 1f
    rjmp FTRUE
1:  
	rjmp FFALSE

;----------------------------------------------------------------------
;  ok 0<
HEADER "0<", "ZEROLT"
	NOOP
	pspull wrk_low, wrk_high
    sbiw wrk_low, 1
    brge 1f
    rjmp FFALSE
1:  
	rjmp FTRUE

;----------------------------------------------------------------------
; ok INV
HEADER "INV", "INV"
	NOOP
	pspull wrk_low, wrk_high
    com wrk_low
    com wrk_high
	pspush wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
; ok NEG
HEADER "NEG", "NEG"
	NOOP
	pspull wrk_low, wrk_high
    neg wrk_low
    neg wrk_high
	pspush wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
; ok ABS
HEADER "ABS", "ABS"
	NOOP
	pspull wrk_low, wrk_high
    cbr wrk_high, 7
	pspush wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
;
; compare bytes from source++ to destination++, decrease count--
; ( a1 u1 a2 u2 -- flag)
;
HEADER "COMPARE", "COMPARE"
	NOOP
    ; WARNING No bound check and counter equal 0 moves nothing

	; pull lenght 
	pspull tos_low, tos_high

	; pull address
	pspull ips_low, ips_high
	
	; pull lenght
	pspull nds_low, nds_high

    ; pull address
	pspull wrk_low, wrk_high

	; push psp
	rspush psp_low, psp_high

	; copy address
	movw psp_low, wrk_low

    ; no offset

1:  
	cp  tos_low, tos_high
	brbs BIT_ZERO, 2f

	cp  nds_low, nds_high
	brbs BIT_ZERO, 2f

	ld wrk_low, X+
	ld wrk_high, Z+
	cp wrk_low, wrk_high
	brbc BIT_ZERO, 3f

	subi tos_low, 1
	sbci tos_high, 0

	subi nds_low, 1
	sbci nds_high, 0

    ; again
	rjmp 1b

2:  
	cp tos_low, nds_low
	brbc BIT_ZERO,3f

	cp tos_high, nds_high
	brbc BIT_ZERO, 3f

	clr wrk_low
	clr wrk_high
	rjmp 4f

3:  
	ser wrk_low
	ser wrk_high

4:  
	rspull psp_low, psp_high
	pspush wrk_low, wrk_high	
	POON

;----------------------------------------------------------------------
;
; CMOVE copy bytes from source++ to destination++, decrease count--
HEADER "CMOVE", "MOVE"
	NOOP
    ; WARNING No bound check and counter equal 0 moves nothing

	; pull origin
	pspull tos_low, tos_high
	
	; pull destination
	pspull ips_low, ips_high

    ; pull counter
	pspull wrk_low, wrk_high

	; test if zero
	cp wrk_low, wrk_high
	brbs BIT_ZERO, 2f

	; push psp
	rspush psp_low, psp_high

	; copy orign
	movw psp_low, tos_low

    ; no offset

  	; move a byte
1:  
	ld _work_, X+
    st Z+, _work_
    
    ; decrease counter
	sbiw wrk_low, 1

    ; again
	brbc BIT_ZERO, 1b

    ; pull psp
2:	
	rspull psp_low, psp_high
	POON

;----------------------------------------------------------------------
;
; CMOVE> copy bytes from source+count-- to destination--, decrease count--
HEADER "CMOVE>", "CMOVEGT"
	NOOP
    ; WARNING No bound check and counter equal 0 moves nothing

	; pull origin
	pspull tos_low, tos_high
	
	; pull destination
	pspull ips_low, ips_high

    ; pull counter
	pspull wrk_low, wrk_high

	; test if zero
	cp wrk_low, wrk_high
	brbs BIT_ZERO, 2f

	; push psp
	rspush psp_low, psp_high

	; copy orign
	movw psp_low, tos_low

    ; do offset
	add ips_low, wrk_low
	adc ips_high, wrk_high
	add psp_low, wrk_low
	adc psp_high, wrk_high

    ; move a byte
1:  
	ld _work_, -X
    st -Z, _work_
    
    ; decrease counter
	sbiw wrk_low, 1
	brbc BIT_ZERO, 1b

	; pull psp
2:	
	rspull psp_low, psp_high
	POON

;----------------------------------------------------------------------
;  data space pointer align to CELL, atmega is always
HEADER "ALIGN", "ALLIGN"
	NOOP
	pspull wrk_low, wrk_high
	adiw wrk_low, 1
	cbr wrk_low, 0
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;
; ok CELL is 2 ; size of a cell
;
HEADER "CELL", "CELLSZ"
	NOOP
    ldi wrk_low, CELL_SIZE
    clr wrk_high
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;
; ok CELL is 2, multiply by 2, easy way
;
HEADER "CELLS", "CELLS"
	NOOP
    rjmp SHL+2

;----------------------------------------------------------------------
;
; ok 
;
HEADER "CELL+", "CELLPLUS"
	NOOP
	pspull wrk_low, wrk_high
	adiw wrk_low, CELL_SIZE
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;
; ok 
;
HEADER "CELL-", "CELLMINUS"
	NOOP
	pspull wrk_low, wrk_high
	sbiw wrk_low, CELL_SIZE
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;
; ok 
;
HEADER "1+", "ONEPLUS"
	NOOP
	pspull wrk_low, wrk_high
	adiw wrk_low, 1
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;
; ok 
;
HEADER "1-", "ONEMINUS"
	NOOP
	pspull wrk_low, wrk_high
	sbiw wrk_low, 1
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;
; ok 
;
HEADER "2+", "TWOPLUS"
	NOOP
	pspull wrk_low, wrk_high
	adiw wrk_low, 2
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;
; ok 
;
HEADER "2-", "TWOMINUS"
	NOOP
	pspull wrk_low, wrk_high
	sbiw wrk_low, 2
	pspush wrk_low, wrk_high
	POON

;----------------------------------------------------------------------
;
; ok 
;
HEADER "+!", "PLUSTO"
	NOOP
	pspull ips_low, ips_high
	pspull tos_low, tos_high
	srload wrk_low
	srload wrk_high
	clc
	add wrk_low, tos_low
	adc wrk_low, tos_low
	sbiw ips_low, 2
	srsave wrk_low
	srsave wrk_high
	POON

