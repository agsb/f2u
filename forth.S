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
;.org 0x100
; maps pseudo memory address, all access behind is sram
;.org SRAM_END+1
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
    POON

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
    clc
    add wrk_low, tos_low
    adc wrk_high, tos_high
    pspush wrk_low, wrk_high
    POON

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
    ldi wrk_low, lo8(TOIN)
    ldi wrk_high, hi8(TOIN)
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
; ok push timer counter
;
HEADER "millis", "MILLIS"
    NOOP
    pspush tmr_low, tmr_high
    POON

;----------------------------------------------------------------------
; init instruction pointer and etc
;
HEADER "BYE", "BYE"
    NOOP
    rjmp RESET
    POON

;----------------------------------------------------------------------
;
HEADER "COLD", "COLD"
    NOOP

; disable interrupts
    cli

; clear scratchs
    clr r0
    clr r1

; clear timer0 counter
    clr r2
    clr r3

; define timer0 offset
    ldi r16, 141
    mov r4, r16

; enable interrupts
    sei

; restart return stack
    ldi rsp_low, lo8(RSP)
    ldi rsp_high, hi8(RSP)

; restart parameter stack
    ldi psp_low, lo8(PSP)
    ldi psp_high, hi8(PSP)

; preload to WARM
    ldi ips_low, lo8(WARM)
    ldi ips_high, hi8(WARM)
    rspush ips_low, ips_high
    POON

;----------------------------------------------------------------------
; fake
HEADER  "WARM", "WARM"
    NOOP
    POON


;----------------------------------------------------------------------
;
; ok ( a1 c --- a2 u ) 
;    
;   
;
;----------------------------------------------------------------------
;
; ok ( a1 c --- a2 u ) 
;    search start at a1 for next word delimited by c or \0
;    returns start a2 and u lenght
;
HEADER "token", "token"
    NOOP
    pspull ips_low, ips_high
    pspull wrk_low, wrk_high
    ; skip while equal
    srload wrk_high
	; if \0 end of buffer
1:  cp wrk_high, wrk_high
    brbs BIT_ZERO, 2f
	; if same
    cp wrk_low, wrk_high
    breq 1b
    ; keep address
2:  sbiw ips_low, 1
    pspush ips_low, ips_high
    pspush ips_low, ips_high
    ; skip wile not equal
3:  srload wrk_high
    cp wrk_high, wrk_high
    brbs BIT_ZERO, 4f
    cp wrk_low, wrk_high
    brne 3b
    ; keep length
4:  pspull wrk_low, wrk_high
    sub ips_low, wrk_low
    sbc ips_high, wrk_high
    pspush ips_low, ips_high
    POON

;----------------------------------------------------------------------
;
; ok accept ( -- u )  NO ECHOES !!!
;    read chars into tib until CR or size=0
;    
HEADER "accept", "accept"
    NOOP
    ldi ips_low, lo8(TIB)
    ldi ips_high, hi8(TIB)
    ldi wrk_high, TIB_SIZE
    ; always add \0 terminator
    sts TIB+TIB_SIZE, _zero_
    clr _work_     ; clear length

    clr tos_low ; clear comments \
    clr tos_high ; clear comments ()

    ; decrease counter    
1:  dec wrk_high
    brbs BIT_ZERO, 2f

    ; waits a char
3:  sbis 0xb, 7
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

    ; verify BS
4:  cp wrk_low,  8 ; BS
    brne 5f

    ; process BS
    cp _work_, _work_
    brbs BIT_ZERO, 3b
    dec _work_
    sbiw ips_low, 1
    rjmp 3b    

    ; is valid char 7-bit ASCII
    ; no controls
5:  cpi    wrk_low, 32
    brlo 3b
    ; no graphics
    cpi wrk_low, 128
    brge 3b

    ; is a ( ?
7:  cpi wrk_low, 40
    brne 8f
    inc tos_high
    rjmp 3b

    ; is a ) ?
8:  cpi wrk_low, 41
    brne 9f
    dec tos_high
    rjmp 3b

    ; is a \ ?
9:  cpi wrk_low, 92 
    brne 10f
    dec tos_low
    rjmp 3b

   ; skip comments
10: tst tos_low
    brne 3b
    tst tos_high
    brne 3b

.ifdef UPPERCASE    
    ; to uppercase
    cpi wrk_low, 61
    brge 6f
    cpi wrk_low, 123
    brge 6f
    subi wrk_low, 32
.endif

    ; save char to buffer
6:  inc _work_
    srsave wrk_low
    rjmp 1b
  
    ; push counter
    ; always add a space and a \0 terminator
2:  ldi wrk_low, 32
    srsave wrk_low
    clr wrk_low
    srsave wrk_low

    ; update TOIN
    sts (TOIN+1), wrk_low
    mov wrk_low, _work_
    sts (TOIN+0), wrk_low
    pspush wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
;
; ok find a word in a vocabulary
;    ( a u -- a | 0 )
; counted strings are 254 chars maximum
; names are 15 or 32 maximum
;
HEADER "find", "find"
    NOOP
    pspull tos_low, tos_high
    pspull nds_low, nds_high
    ; save stack
    rspush psp_low, psp_high
    ; prepare loop    
    ldi    ips_low, lo8(LAST)
    ldi ips_high, hi8(LAST)
    rspush ips_low, ips_high

    ; load next link 
1:  rspull ips_low, ips_high
    pmload wrk_low, wrk_high

    ; if null ends
    cp wrk_low, wrk_high
    brbs BIT_ZERO, 10f

    ; save next link
    rspush wrk_low, wrk_high

    ; load size
    ld tos_high, Z+

    ; must ummask
    ; ( a1 u1 --- f )
    mov _work_, tos_high
    andi tos_high, F_UNMASK
    
    ; ping-pong
    ; verify sizes
    cp tos_high, tos_low
    brne 1b

    ; points to a1
    movw psp_low, nds_low
    
    ; load chars
3:  ld wrk_low, Z+
    ld wrk_high, X+
    cp wrk_low, wrk_high
    brne 1b
    dec tos_high
    brbc BIT_ZERO, 3b

    ; found
    ; drop link for next name
4:  rspull wrk_low, wrk_high
    ; restore psp
    rspull psp_low, psp_high
    ; must check oddies
    sbrc  _work_, 0
    ; bypass pad byte
    adiw ips_low, 1
    pspush ips_low, ips_high
    ; return with flags
    clr wrk_high
    mov wrk_low, _work_
    andi wrk_low, F_TOMASK
    ori  wrk_low, F_FOUND
    rjmp 99f

    ; not found
    ; restore psp
10: rspull psp_low, psp_high
    ; restore a1
    movw wrk_low, nds_low
    pspush wrk_low, wrk_high
	; set flag false
    clr wrk_low
    clr wrk_low
    ; save results
99: pspush wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
;	ok ( a1 f -- ) 
;
;	s flag
;	if state = 1 and flag = 0, does compile
;	else does execute
;
HEADER  "evaluate", "evaluate"
	NOOP
	; load state
    ldi ips_low, lo8(STATE)
    ldi ips_high, hi8(STATE)
	pmload tos_low, tos_high
	; load flags
	pspull wrk_low, wrk_high
	andi wrk_low, F_IMMEDIATE
	or wrk_low, tos_low 
	dec wrk_low
	brne 2f
	; compile
	srsave 
	; execute
2:	rspush wrk_low, wrk_high
	POON 

/*
: execute >R ;
: compile comma ;
: interpret
	begin accept
		begin token
		while 
			name? if eval	if execute
									else compile  
									then
			else number?  if state	if compile
				  					else execute
									then
						  else abort	
						  then
			then
		repeat
	again
 ;

*/			
