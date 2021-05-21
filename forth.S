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

19/05/2021

	Rewrite for plain use of sram as buffer for flash

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

; zzz left or right ???? byte to address

	lsr ips_low
	ror ips_high

    ijmp

;----------------------------------------------------------------------
; 
; using a classic, tos, (1st, 2nd, 3rd, 4th, ...)
;
;----------------------------------------------------------------------
;**********************************************************************
;	init of minimal words
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
; ok @ at ( a -- w )
HEADER "@", "AT"
    NOOP
    pspull ips_low, ips_high
    srload wrk_low
    srload wrk_high
_push:
    pspush wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
; ok ( -- rsp)
HEADER "RP@", "RPAT"
    NOOP
    movw wrk_low, rsp_low
	rjmp _push
;    pspush wrk_low, wrk_high
;    POON

;----------------------------------------------------------------------
; ok ( -- psp )
HEADER "SP@", "SPAT"
    NOOP
    movw wrk_low, psp_low
	rjmp _push
;    pspush wrk_low, wrk_high
;    POON

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
	rjmp _push
;    pspush wrk_low, wrk_high
;    POON

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
	rjmp _push
;    pspush wrk_low, wrk_high
;    POON

;----------------------------------------------------------------------
;ok ( w1 w2 -- w2 AND w1 )
HEADER "+", "PLUS"
    NOOP
    pspull wrk_low, wrk_high
    pspull tos_low, tos_high
    clc
    add wrk_low, tos_low
    adc wrk_high, tos_high
	rjmp _push
;    pspush wrk_low, wrk_high
;    POON

;----------------------------------------------------------------------
;ok ( w1 w2 -- w2 AND w1 )
HEADER "0", "ZERO"
	NOOP
	rjmp _ffalse
;	clr wrk_low
;	clr wrk_high
;    pspush wrk_low, wrk_high
;    POON

;----------------------------------------------------------------------
;	end of minimal words
;**********************************************************************

;----------------------------------------------------------------------
;ok 
HEADER "TIB", "TIBVAR"
    NOOP
    ldi wrk_low, lo8(TIB)
    ldi wrk_high, hi8(TIB)
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
1:  
    sbis 0x0b, 5
    rjmp 1b
    pspull wrk_low, wrk_high
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
	; next word
    ldi ips_low, lo8(WARM)
    ldi ips_high, hi8(WARM)
    rspush ips_low, ips_high
    POON

;----------------------------------------------------------------------
; fake
HEADER  "WARM", "WARM"
    NOOP
	; verify error code
	; resets etc
    POON

;----------------------------------------------------------------------
;
; ok ( --- a2 u ) 
HEADER "(literal)", "literal"
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
; ok ( --- a u | 0 ) 
;    search TIB start at TOIN for next word delimited by 32 or \0
;    returns start of word and u lenght
;	 or zero if no word
;
HEADER "(parse)", "parse"
    NOOP
1:    
    ; start at 
    ldi ips_low, lo8(TOIN)
    ldi ips_high, hi8(TOIN)
2:  
	; skips while equal delimiter (space)
    srload wrk_high
    ; if \0  
    cpi wrk_high, 0
    breq 10f
    cpi wrk_high, 32
    breq 2b
3:  
    ; keep address
    sbiw ips_low, 1
    pspush ips_low, ips_high
    pspush ips_low, ips_high
4:  
	; skips while not equal delimiter (space)
    srload wrk_high
	; if \0
    cpi wrk_high, 0
    breq 5f
    cpi wrk_low, 32
    brne 4b
5:  
    ; keep length
    sbiw ips_low, 1
    pspull wrk_low, wrk_high
    sub ips_low, wrk_low
    sbc ips_high, wrk_high
	movw wrk_low, ips_low
	rjmp 20f
10:
	; end of buffer
	clr wrk_low
	clr wrk_high
20:
    pspush wrk_low, wrk_high
    POON

;----------------------------------------------------------------------
;
; ok ( a u --- u ) 
;   refills address till u chars read, u < 256
; 	its refill ( a u -- u )  NO ECHOES !!!
;
HEADER "(refill)", "refill"
    NOOP
10: 
	pspull wrk_low, wrk_high
	pspull ips_low, ips_high
	 
    clr tos_low  ; clear comments \
    clr tos_high ; clear comments ()

	clr wrk_high ; counter to 255
	dec wrk_low  ; save for \0

11: 
    ; end of     
    cp wrk_low, wrk_high
    brbs BIT_ZERO, 21f

12: 
    ; waits a ASCII char
    sbis 0xb, 7
    nop
    rjmp 12b
    in _work_, 0xc

13: 
    ; no 8bits
    cpi _work_, 128
    brge 12b

	; not a control 
    cpi _work_, 31
    brge 14f

31:
    ; verify CR
    cpi _work_, 13 ; CR
    breq 21f

32:
    ; verify LF
    cpi _work_, 10 ; LF
    breq 21f

33: 
    ; verify BS
    cpi _work_,  8 ; BS
    brne 34f

    ; process BS
    ; had any char ?
    cp wrk_high, wrk_high
    breq 12b

    ; back one
    dec wrk_high
    sbiw ips_low, 1
    rjmp 12b    

34:
    ; verify ESC 
    cpi _work_, 27 ; ESC
    brne 35f
    ; process ESC void still
    rjmp 12b

35:
    ; verify XON 
    cpi _work_, 17 ; XON
    brne 36f
    ; process XON void still
    rjmp 12b

36:
    ; verify XOFF 
    cpi _work_, 19 ; XOFF
    brne 37f
    ; process XOFF void still
    rjmp 12b

37:
    ; not allow more controls
	rjmp 12b

; verify comments
14: 
    ; is a ( ?
    cpi _work_, 40
    brne 15f
    inc tos_high
    rjmp 12b

15: 
    ; is a ) ?
    cpi _work_, 41
    brne 16f
    dec tos_high
    rjmp 12b

16: 
    ; is a \ ?
    cpi _work_, 92 
    brne 19f
    inc tos_low
    rjmp 12b

19: 
   ; skip comments
    tst tos_low
    brne 12b
    tst tos_high
    brne 12b

.ifdef UPPERCASE    
    ; to uppercase
    cpi _work_, 61
    brge 20f
    cpi _work_, 123
    brge 20f
    subi _work_, 32
.endif

20: 
    ; save char to buffer
    inc wrk_high
    srsave _work_
    rjmp 11b
  
21: 
    ; push counter
    ; always add a space and a \0 terminator
    clr wrk_low
    srsave wrk_low

    ; update zero to TOIN
    sts (TOIN+1), wrk_low
    sts (TOIN+0), wrk_low

	; save counter
    mov wrk_low, wrk_high
	clr wrk_high
	pspush wrk_low, wrk_high
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
	; get count in low
    pspull tos_low, tos_high
	; get address
    pspull nds_low, nds_high
    ; save stack
    rspush psp_low, psp_high
    
	; prepare loop    
    ldi ips_low, lo8(LAST)
    ldi ips_high, hi8(LAST)
	
	; push for first loop
    rspush ips_low, ips_high

1: 
    ; load link 
    rspull ips_low, ips_high

	; load contents
    pmload wrk_low, wrk_high

    ; if null ends
    cp wrk_low, wrk_high
    brbs BIT_ZERO, 10f

    ; save link
    rspush wrk_low, wrk_high

    ; load size and first char
    pmload wrk_low, wrk_high

    ; must ummask
    ; ( a1 u1 --- f )
    mov _work_, wrk_low
    andi wrk_low, F_UNMASK
    
    ; ping-pong
    ; verify sizes
    cp wrk_low, tos_low
    brne 1b

    ; points to a1
    movw psp_low, nds_low
    
	; save count
	mov _zero_, tos_low
    
    ; load chars
;
; 	verify first char
3:  
	ld wrk_low, X+
    cp wrk_low, wrk_high
    brne 1b
	dec _zero_
	breq 4f 
8:	
	pmload wrk_low, wrk_high
	ld tmp_low, X+
	ld tmp_high, x+
	cp wrk_low, tmp_low
	brne 1b
	dec _zero_
	breq 4f
	cp wrk_high, tmp_high
	brne 1b
	dec _zero_
	breq 4f
	rjmp 8b

4:  
    ; found
    ; drop link for next name
    rspull wrk_low, wrk_high

    ; restore psp
    rspull psp_low, psp_high

	; push CFA
    pspush ips_low, ips_high

    ; return with flags
    clr wrk_high
    mov wrk_low, _work_
    andi wrk_low, F_TOMASK
    ori  wrk_low, F_FOUND
    rjmp 99f

10: 
    ; not found
    ; restore psp
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
    ;ldi _work_, lo8(STATE)
    ;ldi _zero_, hi8(STATE)
	; zzz

    ; load flags
    pspull wrk_low, wrk_high

	; in dictionary
	cp wrk_low, wrk_high
	brne 10f
8:
	; not in dictionary
	
10:
	; if not IMMEDIATE and COMPILE 
    andi wrk_low, F_IMMEDIATE
	or   wrk_low, _work_
    dec wrk_low
    brne 2f
    ; compile
2:
    ; execute
    rspush wrk_low, wrk_high
3:
    POON 

;----------------------------------------------------------------------
;
; ok ( --- a2 u ) 
HEADER "(comma)", "comma"
	NOOP
	
	; copy from psp to sram buffer
	lds ips_low, THIS+0
	lds ips_high, THIS+1
	pspull wrk_low, wrk_high
	st Z+, wrk_low
	st Z+, wrk_high
	; update this 
	sts THIS+0, ips_low
	sts THIS+1, ips_high
	
; extras for sram and flash

	; verify free ram
	lds wrk_low, SRAM+0
	lds wrk_high, SRAM+1
	cp wrk_high, ips_high
	cpc wrk_low, ips_low
	brlt 2f

	; no more free ram	
	ldi wrk_low, INVALID_MEMORY
	rjmp WARM

2:
	; update here
	lds wrk_low, HERE+0
	lds wrk_high, HERE+1
	adiw wrk_low, 2
	sts HERE+0, wrk_low
	sts HERE+1, wrk_high

	; verify free flash
	cpi wrk_high, hi8(FLASH_STOP)
	cpi wrk_low, lo8(FLASH_STOP)
	brlt 3f

	; no more free flash
	ldi wrk_low, WRITE_TO_READ_ONLY
	rjmp WARM

3:
	POON

;---------------------------------------------------------------------
;	
; must be called from colon
; ok flash start of line buffer with %page used to HERE, update THIS 
;
HEADER "(flash)", "flash"

	; where it is ?	
	lds	ips_low, HERE+0
	lds ips_high, HERE+1

	; save fraction
	mov wrk_low, ips_low
	andi wrk_low, lo8(pagesize) ; pagesize must be less than 256, in bytes

	; make absolute
	andi ips_low,  lo8(pagemask)
	andi ips_high, hi8(pagemask)
	
	; save page
	sts KEEP+0, ips_low
	sts KEEP+1, ips_high

	; prepare loop
	rspush psp_low, psp_high
	ldi psp_low, lo8(LINE)
	ldi psp_high, hi8(LINE)

	; adjust address for lpm
	lsr ips_low
	rol ips_high
2:
	lpm _work_, Z+
	st X+, _work_
	dec wrk_low
	brne 2b

4:	
	; update where
	sts THIS+0, psp_low
	sts THIS+1, psp_high
	; restore data stack
	rspull psp_low, psp_high
	POON
	
;----------------------------------------------------------------------
;
; must be called from semi
; ok flush sram buffer to flash, 
;	spm instruction uses r31:r30 for address and r1:r0 for data
;   this will use a protect do_spm;
;
;	not using optiboot do_spm
;	that do_spm uses r25:r24 for address, R21:r20 for data, r22 for code operation erase/fill/write
;	and destroys r24 :(
;
HEADER "(flush)", "flush"
	NOOP

; buffer full or doing a SEMMI

	rspush psp_low, psp_high

	; from
	ldi psp_low, lo8(LINE)
	ldi psp_high, hi8(LINE)

	; how many
	lds tos_low, THIS+0
	lds tos_high, THIS+1

	; to page
	lds ips_low, KEEP+0
	lds ips_high, KEEP+1

	andi ips_low,  lo8(pagemask)
	andi ips_high, hi8(pagemask)

	movw nds_low, ips_low

10:
	;  next page 
	movw ips_low, nds_low

; zzzz must include code to protect NRWW and core forth

	; erase page
	ldi tmp_low, (1<<PGERS) | (1<<SPMEN)
	rcall do_spm

	; re-enable the RWW section
	;ldi tmp_low, (1<<RWWSRE) | (1<<SPMEN)
    ;rcall do_spm

	; one page loop
	ldi wrk_low, lo8(SPM_PAGESIZE)

20:
	; fill page flash from sram buffer
	ld r0, X+
	ld r1, X+
	ldi tmp_low, (1<<SPMEN)
	rcall do_spm
	adiw ips_low, 2
	dec wrk_low
	dec wrk_low
	brne 20b

	; save next page
	movw wrk_low, ips_low

30:
	; load page 
	movw ips_low, nds_low

	; write page
	ldi tmp_low, (1<<PGWRT) | (1<<SPMEN)
	rcall do_spm

	; re-enable the RWW section
	;ldi tmp_low, (1<<RWWSRE) | (1<<SPMEN)
    ;rcall do_spm

40:
	; verify end, if PAGE GE HERE
	cp psp_high, tos_high
	cpc psp_low, tos_low
	brge 60f
 
50:
	; load next page
	movw nds_low, wrk_low
	rjmp 10b

60:
	; no mess with HERE, KEEP, THIS, flash will do.
	; clean house
	rspull psp_low, psp_high
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
