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
; the size byte must be masked by  or 0xE0
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
; maps pseudo memory address, all access behind is sram
;.org SRAM_END+1
.global forth
forth:
;;----------------------------------------------------------------------
;; inner interpreter, must have another name no LAST
;;
;HEADER "_LAST", "_LAST"
;; does nothing and mark instructions code
;    NOOP
;
;; pull ip from rsp
;_exit:             
;    rspull tos_low, tos_high
;
;; load w with contents of cell at ip, only works in program memory (flash)  
;_next:            
;    movw wrk_low, tos_low
;    adiw wrk_low, 2
;
;    movw ips_low, tos_low
;    pmload tos_low, tos_high
;
;; if zero then is a exec 
;    cp tos_low, tos_high
;    brbs BIT_ZERO, _exec
;
;; point next
;
;; else is a reference
;_enter:            
;    rspush wrk_low, wrk_high
;    rjmp _next
;
;_exec:
;    ; convert to words
;    movw ips_low, wrk_low
;
;.ifdef iTRAMPOLIM
;    pmload tos_low, tos_high
;	movw ips_low, tos_low
;.endif
;
;    asr ips_high
;    ror ips_low
;    ijmp
;
;----------------------------------------------------------------------
; inner interpreter, must have another name no LAST
;
HEADER "_LAST", "_LAST"
; does nothing and mark instructions code
    NOOP

; pull ip from rsp
_exit:             
    rspull wrk_low, wrk_high

; load w with contents of cell at ip, only works in program memory (flash)  
_next:            
    movw ips_low, wrk_low
    pmload wrk_low, wrk_high

; if zero then is a exec 
    cp wrk_low, wrk_high
    brbs BIT_ZERO, _exec

; point next

; else is a reference
_enter:            
    rspush ips_low, ips_high
    rjmp _next

_exec:
    ; convert to words
    movw ips_low, wrk_low

.ifdef iTRAMPOLIM
    pmload wrk_low, wrk_high
	movw ips_low, wrk_low
.endif

    ijmp

;----------------------------------------------------------------------
; 
; using a classic, tos, (1st, 2nd, 3rd, 4th, ...)
;
;----------------------------------------------------------------------
;**********************************************************************
;	init of minimal words
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
    brbc BIT_ZERO, _ffalse
_ftrue:
    ser wrk_low
    ser wrk_high
    rjmp _ZEROEND
_ffalse:
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
;	end of minimal words
;**********************************************************************
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
HEADER ">IN", "TOINVAR"
    NOOP
    ldi wrk_low, lo8(TOIN)
    ldi wrk_high, hi8(TOIN)
    pspush wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
;ok 
HEADER "SEED", "SEEDVAR"
    NOOP
    ldi wrk_low, lo8(SEED)
    ldi wrk_high, hi8(SEED)
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
;ok 
HEADER "STATE", "STATEVAR"
    NOOP
    ldi wrk_low, lo8(STATE)
    ldi wrk_high, hi8(STATE)
    pspush wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
;
; beware, it blocks! test if can receive a char
;
HEADER "key", "KEY"
    NOOP
1:  
    sbis 0x0b, 7
    rjmp 1b
    in wrk_low, 0x0c
    clr wrk_high
    pspush wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
;
; beware, it blocks! test if can send a char 
;
HEADER "emit", "EMIT"
    NOOP
    pspull wrk_low, wrk_high
1:  
    sbis 0x0b, 5
    rjmp 1b
    out 0x0c, wrk_low
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
; does reset
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
    clr _work_
    clr _zero_

; clear timer0 counter
    clr tmr_low
    clr tmr_high

; define timer0 offset
    ldi wrk_low, 141
    mov offs_low, wrk_low

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
; ok ( --- a2 u ) 
HEADER "dolit", "dolit"
    NOOP
    rspull wrk_low, wrk_high
    movw ips_low, wrk_low	
    adiw wrk_low, 2
    rspush wrk_low, wrk_high
    pmload wrk_low, wrk_high
    pspush wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
;
; ok ( --- a2 u ) 
;    search TIB start at TOIN for next word delimited by 32 or \0
;    returns start of word and u lenght
;    refills TIB when necessary. beware no round-robin
;
HEADER "token", "token"
    NOOP
1:    
    ; start at 
    ldi ips_low, lo8(TOIN)
    ldi ips_high, hi8(TOIN)

2:  
	; skips while equal delimiter (space)
    ; getch()
    srload wrk_high

    ; if \0 
    cpi wrk_high, 0
    breq 10f

    ; if same
    cpi wrk_high, 32
    breq 2b

    ; start of a word
    rjmp 3f 

; ok refill TIB ( -- u )  NO ECHOES !!!
10: 
    ldi ips_low, lo8(TIB)
    ldi ips_high, hi8(TIB)
    ldi wrk_high, TIB_SIZE

    ; always add \0 terminator
    sts (TIB+TIB_SIZE-1), _zero_
    clr _work_     ; clear length
    clr tos_low ; clear comments \
    clr tos_high ; clear comments ()

11: 
    ; decrease counter    
    dec wrk_high
    brbs BIT_ZERO, 21f

12: 
    ; waits a ASCII char
    sbis 0xb, 7
    nop
    rjmp 12b
    in wrk_low, 0xc

13: 
    ; no 8bits
    cpi wrk_low, 128
    brge 12b

	; is not a control 
    cpi wrk_low, 32
    brge 14f

31:
    ; verify CR
    cpi wrk_low, 13 ; CR
    breq 21f

32:
    ; verify LF
    cpi wrk_low, 10 ; CR
    breq 21f

33: 
    ; verify BS
    cpi wrk_low,  8 ; BS
    brne 34f

    ; process BS
    ; had any char ?
    cp _work_, _work_
    breq 12b

    ; back one
    dec _work_
    sbiw ips_low, 1
    rjmp 12b    

34:
    ; verify ESC 
    cpi wrk_low, 27 ; ESC
    brne 35f
    ; process ESC void still
    rjmp 12b

35:
    ; verify XON 
    cpi wrk_low, 17 ; ESC
    brne 36f
    ; process XON void still
    rjmp 12b

36:
    ; verify XOFF 
    cpi wrk_low, 19 ; ESC
    brne 37f
    ; process XOFF void still
    rjmp 12b

37:
    ; no more controls
	rjmp 12b

; verify comments
14: 
    ; is a ( ?
    cpi wrk_low, 40
    brne 15f
    inc tos_high
    rjmp 12b

15: 
    ; is a ) ?
    cpi wrk_low, 41
    brne 16f
    dec tos_high
    rjmp 12b

16: 
    ; is a \ ?
    cpi wrk_low, 92 
    brne 19f
    dec tos_low
    rjmp 12b

19: 
   ; skip comments
    tst tos_low
    brne 12b
    tst tos_high
    brne 12b

.ifdef UPPERCASE    
    ; to uppercase
    cpi wrk_low, 61
    brge 20f
    cpi wrk_low, 123
    brge 20f
    subi wrk_low, 32
.endif

20: 
    ; save char to buffer
    inc _work_
    srsave wrk_low
    rjmp 11b
  
21: 
    ; push counter
    ; always add a space and a \0 terminator
    ldi wrk_low, 32
    srsave wrk_low
    clr wrk_low
    srsave wrk_low

    ; update zero to TOIN
    sts (TOIN+1), wrk_low
    mov wrk_low, _work_
    sts (TOIN+0), wrk_low
    rjmp 1b

2:  
    ; keep address
    sbiw ips_low, 1
    pspush ips_low, ips_high
    pspush ips_low, ips_high

3:  
    ; skip wile not equal
    srload wrk_high
    cpi wrk_high, 0
    breq 4f
    cpi wrk_low, 32
    brne 3b

4:  
    ; keep length
    pspull wrk_low, wrk_high
    sub ips_low, wrk_low
    sbc ips_high, wrk_high
    pspush ips_low, ips_high
    POON

;----------------------------------------------------------------------
;
; ok find a word in a vocabulary
;    ( a u -- a f | 0 )
; counted strings are 254 chars maximum
; names are 15 or 32 maximum
;
HEADER "(find)", "find"
    NOOP
    pspull tos_low, tos_high
    pspull nds_low, nds_high
    ; save stack
    rspush psp_low, psp_high
    ; prepare loop    
    ldi ips_low, lo8(LAST)
    ldi ips_high, hi8(LAST)
    rspush ips_low, ips_high

    ; load next link 
1:  
    rspull ips_low, ips_high
    pmload wrk_low, wrk_high

    ; if null ends
    cp wrk_low, wrk_high
    brbs BIT_ZERO, 10f

    ; save next link
    rspush wrk_low, wrk_high

    ; load size
    pmload tos_low, tos_high

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
;
; can not be doing like this !!! not in sram !!! and lpm gets address in strange way
;    ZZZZ
3:  
    ld wrk_low, Z+
    ld wrk_high, X+
    cp wrk_low, wrk_high
    brne 1b
    dec tos_high
    brbc BIT_ZERO, 3b

    ; found
    ; drop link for next name
4:  
    rspull wrk_low, wrk_high
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
10: 
    rspull psp_low, psp_high
    ; restore a1
    movw wrk_low, nds_low
    pspush wrk_low, wrk_high
    ; set flag false
    clr wrk_low
    clr wrk_low
    ; save results
99: 
    pspush wrk_low, wrk_high
    POON

/*
;----------------------------------------------------------------------
;    ok ( a1 f -- ) 
;
;    s flag
;    if state = 1 and flag = 0, does compile
;    else does execute
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
2:    rspush wrk_low, wrk_high
3:
    POON 

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
