/*
 *  DISCLAIMER"
 *
 *  Copyright © 2020, Alvaro Barcellos,
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

/*
;
;	Small Forth for ATmega8
;
;---------------------------------------------------------------------
; dictionary structure
;	
;	cell size is a word of 16 bits
;
 .word  link    link to previous
 .byte  size    sizeof name OR flags
 .ascii "name" name, plus a pad byte with BL (0x32) if size is odd
 .word  param,  many

;----------------------------------------------------------------------

24/05/2021
    
    Done comma, flash, flush for solve sram//flash

    implemented postpone as a flag to always compile next word only, solves compile and [compile]
    
    matriz of interpret now is:

                            state 1        state 0        postone 1
         common word        compile        execute        compile
      immediate word        execute        execute        compile
    
    why not same for  ', [']

19/05/2021

    Rewrite for plain use of sram as buffer for flash, 

02/05/2021

    Rewrite again using sectorforth as minimal design

18/04/2021

    Rewrite all from u2f*, using a new minimal forth engine as LAST word 

*/

;
; classics
;
    .NOLIST

    .LIST

;----------------------------------------------------------------------
; start of dictionary
;

;----------------------------------------------------------------------
;
; this is the forth engine,
;
; any twig must end with a reference to LAST
;
; any leaf must start with NOOP and ends with POON
;
; the size byte must be masked by  or 0xF0
;
; instruction pointer r31:r30 as Z 
; return stack pointer r29:r28 as Y
; working register r25:r24 as W
; scratch register r0
;
; only LPM access flash ? YES!
;
; all constants in flash
; all variables in sdram
;
;----------------------------------------------------------------------
.section .text
.org 0x100
.global forth
forth:
;;----------------------------------------------------------------------
; inner interpreter,
;
HEADER "ENDS", "_ends"
; does nothing and mark instructions code
    NOOP

; pull ip from rsp
_exit:             
    rspull wrk_low, wrk_high

; load w with contents of cell at ip  
_next:            
	mov isp_low, wrk_low
    pmload wrk_low, wrk_high

; if zero then is a exec 
    cp wrk_low, wrk_high
    brbs BIT_ZERO, _exec

; else is a reference
_enter:            
    rspush ips_low, ips_high
    rjmp _next

; then exec it 
_exec:

.ifdef TRAMPOLIM
    pmload wrk_low, wrk_high
    movw ips_low, wrk_low
.endif

    ijmp

;----------------------------------------------------------------------
; 
; using no cached
; (1st, 2nd, 3rd, 4th, ...)
;
;----------------------------------------------------------------------
;**********************************************************************
;
;    init of minimal words
;
.macro pushw
.ifndef EXTENDED
	rjmp _push
.else
    pspush wrk_low, wrk_high
    POON
.endif
.endm

;----------------------------------------------------------------------
;ok ( w1 w2 -- w2 AND w1 )
HEADER "0", "ZERO"
    NOOP
_ffalse:
    clr wrk_low
    clr wrk_high
_push:
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
	pushw

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
	pushw

;----------------------------------------------------------------------
; ok ( -- rsp)
HEADER "RP@", "RPAT"
    NOOP
    movw wrk_low, rsp_low
	pushw

;----------------------------------------------------------------------
; ok ( -- psp )
HEADER "SP@", "SPAT"
    NOOP
    movw wrk_low, psp_low
	pushw

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
    pushw

;----------------------------------------------------------------------
;ok ( w1 w2 -- w2 AND w1 )
HEADER "+", "PLUS"
    NOOP
    pspull wrk_low, wrk_high
    pspull tos_low, tos_high
    clc
    add wrk_low, tos_low
    adc wrk_high, tos_high
    pushw

;----------------------------------------------------------------------
;    end of minimal words
;**********************************************************************

;----------------------------------------------------------------------
;ok 
HEADER "TIB", "tib_"
    NOOP
    ldi wrk_low, lo8(TIB)
    ldi wrk_high, hi8(TIB)
	pushw

;----------------------------------------------------------------------
;ok 
HEADER ">IN", "toin_"
    NOOP
    ldi wrk_low, lo8(TOIN)
    ldi wrk_high, hi8(TOIN)
	pushw

;----------------------------------------------------------------------
;ok 
HEADER "HERE", "here_"
    NOOP
    ldi wrk_low, lo8(HERE)
    ldi wrk_high, hi8(HERE)
	pushw

;----------------------------------------------------------------------
;ok 
HEADER "LAST", "last_"
    NOOP
    ldi wrk_low, lo8(LAST)
    ldi wrk_high, hi8(LAST)
	pushw

;----------------------------------------------------------------------
;ok 
HEADER "BASE", "base_"
    NOOP
    ldi wrk_low, lo8(BASE)
    ldi wrk_high, hi8(BASE)
	pushw

;----------------------------------------------------------------------
;ok 
HEADER "STATE", "state_"
    NOOP
    ldi wrk_low, lo8(STATE)
    ldi wrk_high, hi8(STATE)
	pushw

;----------------------------------------------------------------------
;ok 
HEADER "BL", "BL"
    NOOP
    ldi wrk_low, 32
    clr wrk_high
	pushw

;----------------------------------------------------------------------
;----------------------------------------------------------------------
;ok 
HEADER "(sram)", "sram"
    NOOP
    ldi wrk_low, lo8(SRAM)
    ldi wrk_high, hi8(SRAM)
	pushw

;----------------------------------------------------------------------
;ok 
HEADER "(erom)", "erom"
    NOOP
    ldi wrk_low, lo8(EROM)
    ldi wrk_high, hi8(EROM)
	pushw

;----------------------------------------------------------------------
;----------------------------------------------------------------------
;
; beware, it blocks! test if can receive a char
;
HEADER "key", "key_"
    NOOP
1:  
    sbis 0x0b, 7
    rjmp 1b
    in wrk_low, 0x0c
    clr wrk_high
	pushw

;----------------------------------------------------------------------
;
; beware, it blocks! test if can send a char 
;
HEADER "emit", "emit_"
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
HEADER "millis", "millis_"
    NOOP
    movw wrk_low, tmr_low
	pushw

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
; ok ( --- ) 
; tricky 
; all new word starts at THIS=0, 1 and 2 bytes is link, 3 byte is size+flags
HEADER "(immediate)", "immediate"
    NOOP
    ldi ips_low, lo8(LINE)
    ldi ips_high, hi8(LINE)
    adiw ips_low, 3
    srload wrk_low
    ori wrk_low, F_IMMEDIATE
    sbiw ips_low, 1
    srsave wrk_low
    POON
    
;----------------------------------------------------------------------
;
; ok ( --- w ) 
;
; push the contents of next to stack, updates next
; 
HEADER "(doval)", "doval"
    NOOP
    rspull wrk_low, wrk_high
    movw ips_low, wrk_low    
    adiw wrk_low, 2
    rspush wrk_low, wrk_high
    pmload wrk_low, wrk_high
	pushw

;----------------------------------------------------------------------
;
; ok ( --- a )
;
; push the reference of next to stack, updates next
;
HEADER "(doref)", "doref"
    NOOP
    rspull wrk_low, wrk_high
    movw ips_low, wrk_low    
    adiw wrk_low, 2
    rspush wrk_low, wrk_high
    movw wrk_low, ips_low    
	pushw

;----------------------------------------------------------------------
;
; ok ( c --- a u | 0 ) 
;    search TIB start at TOIN for next word delimited by c or \0
;    returns start of word and u lenght
;     or zero if no word
;
HEADER "(parse)", "parse"
    NOOP
1:    
    ; start at 
    lds ips_low, TOIN+0
    lds ips_high, TOIN+1
	; pull delimiter
	pspull tos_low, tos_high
	; for \0 check
	clr tos_high

2:  
    ; skips while equal delimiter
    srload wrk_low
    ; if \0
    cp wrk_low, tos_high
    breq 10f
    cp wrk_low, tos_low
    breq 2b
3:  
    ; keep address
    sbiw ips_low, 1
	movw nds_low, ips_low
4:  
    ; skips while not equal delimiter
    srload wrk_low
    ; if \0
    cp wrk_low, tos_high
    breq 5f
    cp wrk_low, tos_low
    brne 4b
5:  
	; keep length
    sbiw ips_low, 1
    sub ips_low, nds_low
    sbc ips_high, nds_high
    movw wrk_low, ips_low
	movw ips_low, nds_low
    rjmp 20f
10:
    ; end of buffer
    ldi ips_low, lo8(TIB)
    ldi ips_high, hi8(TIB)
    clr wrk_low
    clr wrk_high
20:
    ; update TOIN
    sts TOIN+0, ips_low
    sts TOIN+1, ips_high
	pushw

;----------------------------------------------------------------------
;
; ok ( a u --- u ) 
;
;   refills address till u chars read, u < 256
;     its refill ( a u -- u )  NO ECHOES !!!
;
HEADER "(refill)", "refill"
    NOOP
10: 
    pspull nds_low, nds_high
    pspull ips_low, ips_high

    ; keep a spc at start, so every word starts with spc, used later to make a counted string in site
    ldi tos_low, 32
    srsave tos_low
    dec nds_low

    clr tos_low  ; clear comments \
    clr tos_high ; clear comments ()

    clr nds_high ; counter to 255
    dec nds_low  ; save for \0

11: 
    ; end of     
    cp nds_low, nds_high
    brbs BIT_ZERO, 21f

12: 
    ; waits a ASCII char
    sbis 0xb, 7
    rjmp 12b
    in wrk_low, 0xc

13: 
    ; no 8bits
    cpi wrk_low, 128
    brge 12b

    ; not a control 
    cpi wrk_low, 30
    brge 40f

30:
    ; verify CR	\r
    cpi wrk_low, 13 ; CR
    breq 21f

    ; verify LF \n
    cpi wrk_low, 10 ; LF 
    breq 21f

    ; verify BS \b
    cpi wrk_low,  8  ; BS
    brne 32f

    ; process BS
    ; no char ?
    cp nds_high, nds_high
    breq 12b

    ; back one
    dec nds_high
    sbiw ips_low, 1
    rjmp 12b    

32:
	; verify TAB \t
    cpi wrk_low, 9
    brne 34f

    ; magic to 32
	ldi wrk_low, 32
    rjmp 40f
    
34:
    ; verify ESC \e
    cpi wrk_low, 27 ; ESC
    brne 35f
    ; process ESC void still
    rjmp 12b

35:
    ; verify XON 
    cpi wrk_low, 17 ; XON
    brne 36f
    ; process XON void still
    rjmp 12b

36:
    ; verify XOFF 
    cpi wrk_low, 19 ; XOFF
    brne 37f
    ; process XOFF void still
    rjmp 12b

37:
    ; not allow more controls
    rjmp 12b

40:    
    ; is a spc ?
    cpi wrk_low, 32
    brne 42f

;	; verify if a " \ " alone
;	tst tos_low
;	brne 41f
;	dec tos_low
;	dec tos_low

41:
	; highlander it !
    cp wrk_low, wrk_high
    breq 12b

; verify comments
42: 
    ; is a ( ?
    cpi wrk_low, 40
    brne 44f
    inc tos_high
    rjmp 12b

44: 
    ; is a ) ?
    cpi wrk_low, 41
    brne 46f
    dec tos_high
    rjmp 12b

46: 
    ; is a \ ?
    cpi wrk_low, 92 
    brne 48f
    inc tos_low
    rjmp 12b

48: 
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
    inc nds_high
    srsave wrk_low
    mov wrk_high, wrk_low
    rjmp 11b
  
21: 
    ; push counter
    ; always add \0 terminator
    clr wrk_low
    srsave wrk_low

    ; update zero to TOIN
    sts (TOIN+1), wrk_low
    sts (TOIN+0), wrk_low

    ; save counter
    mov wrk_low, wrk_high
    clr wrk_high
	pushw

;----------------------------------------------------------------------
;
; ok find a word in a vocabulary
;    ( a u -- xt f | a 0 )
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
    lds ips_low, (LAST+0)
    lds ips_high, (LAST+1)
    
    ; push for first loop
    pspush ips_low, ips_high

10: 
    ; load link 
    pspull ips_low, ips_high

    ; load contents
    pmload wrk_low, wrk_high

    ; if null ends
    cp wrk_low, wrk_high
    brbs BIT_ZERO, 30f

    ; save next link
    pspush wrk_low, wrk_high

    ; load size and first char
    pmload wrk_low, wrk_high

    ; save for flags
    mov tos_high, wrk_low

    ; must ummask
    ; ( a1 u1 --- f )
    andi wrk_low, F_UNMASK
    
    ; ping-pong
    ; verify sizes
    cp wrk_low, tos_low
    brne 10b

    ; save count
    mov _zero_, tos_low

    ; points to a1
    movw psp_low, nds_low
    ld wrk_low, X+
    
12:  
	; verify first char
    cp wrk_low, wrk_high
    brne 10b
    dec _zero_
    breq 20f 
    
14:    
    ; verify next chars
    pmload wrk_low, wrk_high

    ld _work_, X+
    cp wrk_low, _work_
    brne 10b
    dec _zero_
    breq 20f

    ld _work_, x+
    cp wrk_high, _work_
    brne 10b
    dec _zero_
    breq 20f

	; next chars
    rjmp 14b

20:  
    ; found
    ; drop link for next name
    pspull wrk_low, wrk_high

    ; restore psp
    rspull psp_low, psp_high

    ; push CFA, (xt)
    ; if need LFA just subtract tos
	;
    pspush ips_low, ips_high

    ; return flags
    clr wrk_low
    clr wrk_high
    andi tos_high, F_IMMEDIATE
	brne 24f
22:
	; immediate (1)
	inc wrk_low
	pushw
24:
	; common (-1)
	dec wrk_low
	pushw

30: 
    ; not found (0)
    ; restore psp
    rspull psp_low, psp_high
    ; restore address
    movw wrk_low, nds_low
    pspush wrk_low, wrk_high
    ; set flag false
    clr wrk_low
    clr wrk_low
    ; save results
	pushw

;----------------------------------------------------------------------
; ok ( mul mut -- d )
; 16*8 multiplication, 24 bit result, two words result
; multipicand nd_high:nds_low by multiplier wrk_low, 
; result low word quotient in tos_high:tos_low, remainder in wrk_low
;
HEADER "(basemul)", "basemul"
	NOOP
	; pull multiplicanrd
    pspull nds_low, nds_high
	; pull multiplier
    pspull wrk_low, wrk_high
	clr wrk_high
;
; Multiply
;
	; Multiply LSB
	mul nds_low, wrk_low 
	; copy result to result register
	mov tos_low, R0 
	mov tos_high, R1
	; Multiply MSB
	mul nds_high, wrk_low 
	; copy MSB result to result byte 3
	mov wrk_high, R1 
	; add LSB result to result byte 2
	add tos_high, R0 
	brcc 10f ; if not carry, jump
	inc wrk_high
10:
	pspush tos_low, tos_high	
	mov wrk_low, wrk_high
	clr wrk_high
	pushw

;----------------------------------------------------------------------
;
; 16/8 division, 16 bit result, 8 bit remainder, two words result
; dividend nds_high:tos_low by divisor tos_low, 
; quotient in tos_high:tos_low, remainder in wrk_low
;
HEADER "(basediv)", "basediv"
	NOOP
	; pull dividend
    pspull nds_low, nds_high
	; pull divisor
    pspull tos_low, tos_high
10:
	; clear remainder
    clr wrk_low               
	; 16 bits rounds
    ldi wrk_high,0x10         
20:  
	; next dividend bit to wrk_low
    lsl tos_low
    rol tos_high
    rol wrk_low             
	; this should never, ever, happen
    brcs 30f                    
	; trial subtraction
    cp wrk_low, nds_low    
	; not big enough
    brcs 40f                    
30:
	; ok, subtract it
    sub wrk_low, nds_low      
	; add this power of 2 to quotient
    inc tos_low               
40:  
	; count bit
    dec wrk_high      
	; do until done
    brne 20b           
     
	; push quotient
    pspush tos_low, tos_high
    ; push remainder
	pushw

;----------------------------------------------------------------------
;    ok ( -- ) 
;    set STATE
HEADER "]", "isexecute"
    NOOP
    ; 
    lds wrk_low, STATE+0
    cbr wrk_low, BIT_COMPILE
states:
    sts STATE, wrk_low
    POON

;----------------------------------------------------------------------
;    ok ( -- ) 
;    set STATE
HEADER "[", "iscompile"
    NOOP
    ; 
    lds wrk_low, STATE+0
    sbr wrk_low, BIT_COMPILE
    rjmp states

;----------------------------------------------------------------------
;    ok ( -- ) 
;    set STATE to postpone 
HEADER "(postpone)", "ispostpone"
    NOOP
    ; clear postpone
    lds wrk_low, STATE+0
    sbr wrk_low, BIT_POSTONE 
    rjmp states
    
;----------------------------------------------------------------------
;    ok ( -- ) 
;    set STATE to postpone 
HEADER "(nopostpone)", "nopostpone"
    NOOP
    ; clear postpone
    lds wrk_low, STATE+0
    cbr wrk_low, BIT_POSTONE 
    rjmp states
    
;----------------------------------------------------------------------
;    ok ( xt f -- ) 
;
;    f flag  1 immediate, -1 common
;	 state = 0 execute, 1 compile,  3 postone
;
HEADER  "(eval)", "evaluate"
    NOOP

    ; load flags
    pspull wrk_low, wrk_high

10:
    ; load state
    lds tos_low, STATE+0

    ; ever execute 
	cpi tos_low, 0
    breq 18f

	; default check
	cpi tos_low, 1
    breq 14f

    ; ever compile
    ; clear postpone
    cbr tos_high, BIT_POSTONE ; must not be bit 0
    sts STATE+0, tos_high
    rjmp 16f    
    
14:
    ; if not IMMEDIATE and COMPILE 
    cpi wrk_low, 1
    breq 18f
 
16:
    ; compile
    ldi wrk_low, lo8(comma)
    ldi wrk_high, hi8(comma)
    rjmp 20

18:
    ; execute
    pspull wrk_low, wrk_high

20:
    ; resolve 
    rspush wrk_low, wrk_high
    POON 

;----------------------------------------------------------------------
;
;   not official ? (ud1 c-addr1 u1 -- ud2 c-addr2 u2)
;
;	ok (a -- a 0 | ud n)	
;	assumes a not a counted string, but ends with 32 or \0
;
;	uses all but X, Y
;	ips, wrk, tos, nds, _zero_, _work_, r0, r1
;
HEADER "(number)", "number"
    NOOP

	; pull address from
    pspull ips_low, ips_high
	; keep it
    pspush ips_low, ips_high

  	clr _zero_
	; clear result
	clr tos_low
	clr tos_high

	; get actual base
    lds wrk_low, BASE+0
2:
	; hold base
    mov _work_, wrk_low
10:
    srload wrk_low

	; allow first char change base
	tst _zero_
	brne 18f
12:
	; goes hexadecimal
	cpi wrk_low, '$'
	brne 14f
	ldi wrk_low, 16
	rjmp 2b

14: 
	; goes decimal
	cpi wrk_low, '#'
	brne 16f
	ldi wrk_low, 10
	rjmp 2b

16:	
	; no binary, no octal, no more bases

	; how do negative ? just two-complement at end ?

18:
	; test end 

	cpi wrk_low, 0
	breq 80f
	 
	cpi wrk_low, 32
	breq 80f

	; sorry no lowercases
	subi wrk_low, '0'

	; ends ?
	tst wrk_low
	brlt 50f

	cpi wrk_low, 9
	brcc 20f

	; mind the gap !
	subi wrk_low, 7

20:
	; ends ?
    cp wrk_low, _work_
    brge 50f

	; add to result
	clr wrk_high
	add tos_low, wrk_low
	adc tos_high, wrk_high

	; multiply by base
	movw nds_low, tos_low

	; Multiply LSB
	mul nds_low, _work_
	; copy MSB result to result byte 1
	mov tos_low, R0 
	; copy MSB result to result byte 2
	mov tos_high, R1

	; Multiply MSB
	mul nds_high, _work_
	; copy MSB result to result byte 3
	mov wrk_high, R1 
	; add LSB result to result byte 2
	add tos_high, R0 
	brcc 30f ; if not carry, jump
	inc wrk_high
30:
	; test overflow
	tst wrk_high
	brne 40f

	; count digits 
	inc _zero_
	; next digit
	rjmp 10b

40:
	; overflow 16bits
    ldi wrk_low, OVERFLOW
    rjmp WARM
	
50:
    ; NaN    
    ldi wrk_low, NOT_A_NUMBER
    rjmp WARM

80:
	; discards addr
	pspull ips_low, ips_high

	; push value
	pspush tos_low, tos_high

100:
	; push digits
	pushw

;----------------------------------------------------------------------
;
; ok ( --- a2 u ) 
HEADER ".\"", "dotquote"
    NOOP
	POON	
    
;----------------------------------------------------------------------
;    ok ( a u -- ) 
;
;	called after parse ;)
;
HEADER    "<BUILDS", "builds"
    NOOP
	POON

;----------------------------------------------------------------------
;    ok ( a u -- ) 
;
;	called after parse ;)
;
HEADER    "DOES>", "does"
    NOOP
	POON

;----------------------------------------------------------------------
;    ok ( a u -- ) 
;
;	called after parse ;)
;
HEADER    "(create)", "create"
    NOOP
    ; sram buffer
    lds ips_low, THIS+0
    lds ips_high, THIS+1

	; save link 
	lds wrk_low, LAST+0
	lds wrk_high, LAST+1
    st Z+, wrk_low
    st Z+, wrk_high
	
	; save size word
	pspull tos_low, tos_high
	st Z+, tos_low

	; if odd
	sbrc tos_low, 0
	inc tos_low

	; keep size
	mov tos_high, tos_low

	; get address
	pspull wrk_low, wrk_high

	; save psp
	rspush psp_low, psp_high

	; copy it
	movw psp_low, wrk_low
10:
    ld wrk_low, X+
	st Z+, wrk_low
	dec tos_high
	brne 10b

	; load psp
	rspull psp_low, psp_high

	; LAST and HERE are update as SEMI is executed
	; but if is out of a : ; ?
	; if is a  execute ?
/*

; Recall that words defined by CREATE  
; return the address of the next free dictionary 
; location at the time they werecreated.

	; point to next free cell
	; push dp to stack
    lds wrk_low, HERE+0
    lds wrk_high, HERE+1
	; add link
	adiw wrk_low, 2
	; add size 
    add wrk_low, tos_low
    adc wrk_low, tos_high
	; 
	pspush wrk_low, wrk_high
	
	OR just use: create HERE 
*/
	; updates
	rjmp line_void

;----------------------------------------------------------------------
;
; ok ( w --- ) 
HEADER "(comma)", "comma"
    NOOP
    ; copy from psp to sram buffer
    lds ips_low, THIS+0
    lds ips_high, THIS+1

    pspull wrk_low, wrk_high
    st Z+, wrk_low
    st Z+, wrk_high

	clr tos_high
	clr tos_low

line_void:

10:
    ; update this 
    sts THIS+0, ips_low
    sts THIS+1, ips_high

	; SRAM hold bottom of free ram
    ; verify free ram
    lds wrk_low, SRAM+0
    lds wrk_high, SRAM+1
    cp wrk_high, ips_high
    cpc wrk_low, ips_low
    brlt 20f

    ; no more free ram    
    ldi wrk_low, INVALID_MEMORY
    rjmp WARM

20:
    ; update here
    lds wrk_low, HERE+0
    lds wrk_high, HERE+1
    add wrk_low, tos_low
    adc wrk_low, tos_high
	; point to next free cell
	adiw wrk_low, 2
    sts HERE+0, wrk_low
    sts HERE+1, wrk_high

; FLASH_STOP is bottom of free flash
    ; verify free flash
    cpi wrk_high, hi8(FLASH_STOP)
    cpi wrk_low, lo8(FLASH_STOP)
    brlt 30f

    ; no more free flash
    ldi wrk_low, WRITE_TO_READ_ONLY
    rjmp WARM

30:
    POON

;---------------------------------------------------------------------
;    
; must be called from colon
; ok flash start of line buffer with %page used to HERE, update THIS 
;
HEADER "(flash)", "flash"

    ; where it is ?    
    lds    ips_low, HERE+0
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

    ; preserve stack
    rspush psp_low, psp_high

    ; prepare loop
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
;    spm instruction uses r31:r30 for address and r1:r0 for data
;   this will use a protect do_spm;
;
;    not using optiboot do_spm
;    that do_spm uses r25:r24 for address, R21:r20 for data, r22 for code operation erase/fill/write
;    and destroys r24 :(
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

    ; erase page
    ldi _work_, (1<<PGERS) | (1<<SPMEN)
    rcall do_spm

    ; re-enable the RWW section
    ;ldi _work_, (1<<RWWSRE) | (1<<SPMEN)
    ;rcall do_spm

    ; one page loop
    ldi wrk_low, lo8(SPM_PAGESIZE)

20:
    ; fill page flash from sram buffer
    ld r0, X+
    ld r1, X+
    ldi _work_, (1<<SPMEN)
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
    ldi _work_, (1<<PGWRT) | (1<<SPMEN)
    rcall do_spm

    ; re-enable the RWW section
    ;ldi _work_, (1<<RWWSRE) | (1<<SPMEN)
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
    
;----------------------------------------------------------------------
;
; ok interpret
HEADER "(quit)", "quit"
	NOOP
	POON

;----------------------------------------------------------------------
;
; ok comma
HEADER ":", "colon"
	.word iscompile, flash, HERE, AT, ; for LAST link
	.word create, HERE, SWAP, ENDS


;----------------------------------------------------------------------
;
; ok semmi
HEADER ";", "semmi"
	.word isexecute, flush, updateep, ENDS

;----------------------------------------------------------------------
;
; ok 
;	
HEADER "(updateep)", "updateep"
	NOOP
	.word LAST, TO, hereto, lastto, ENDS


;----------------------------------------------------------------------
;
; ok 
;	
HEADER "CREATE", "CREATE"
	NOOP
	.word create, HERE, ENDS

;----------------------------------------------------------------------
; ok variable
;	ZZZZZ must check init sram and limits
;
HEADER "(variable)", "variable"
	.word (sram), DUP, AT, 
	.word DUP, create, comma, 
	.word DUP, ZERO, SWAP, TO, 
	.word TWOMINUS, SWAP, TO,
	.word updateep, ENDS

