

/*
 *  DISCLAIMER"
 *
 *  Copyright © 2020, Alvaro Gomes Sobral Barcellos,
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
    lds zpm_low, TOIN+0
    lds zpm_high, TOIN+1
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
    sbiw zpm_low, 1
    movw nds_low, zpm_low
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
    sbiw zpm_low, 1
    sub zpm_low, nds_low
    sbc zpm_high, nds_high
    movw wrk_low, zpm_low
    movw zpm_low, nds_low
    rjmp 20f
10:
    ; end of buffer
    ldi zpm_low, lo8(TIB)
    ldi zpm_high, hi8(TIB)
    clr wrk_low
    clr wrk_high
20:
    ; update TOIN
    sts TOIN+0, zpm_low
    sts TOIN+1, zpm_high
    WOOP

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
    pspull zpm_low, zpm_high

    ; keep a spc at start, so every word starts with spc, 
    ; used later to make a counted string in site
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
    ; verify CR    \r
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
    sbiw zpm_low, 1
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

;    ; verify if a " \ " alone
;    tst tos_low
;    brne 41f
;    dec tos_low
;    dec tos_low

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
    WOOP

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
    lds zpm_low, (LAST+0)
    lds zpm_high, (LAST+1)
    
    ; push for first loop
    pspush zpm_low, zpm_high

10: 
    ; load link 
    pspull zpm_low, zpm_high

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
    pspush zpm_low, zpm_high

    ; return flags
    clr wrk_low
    clr wrk_high
    andi tos_high, F_IMMEDIATE
    brne 24f
22:
    ; immediate (1)
    inc wrk_low
    WOOP
24:
    ; common (-1)
    dec wrk_low
    WOOP

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
    WOOP

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
    WOOP

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
    WOOP

;----------------------------------------------------------------------
;    ok ( -- ) 
;    set bit_compile in STATE to zero
HEADER "]", "isexecute"
    NOOP
    lds wrk_low, STAT+0
    cbr wrk_low, BIT_COMPILE
states:
    sts STAT, wrk_low
    POON

;----------------------------------------------------------------------
;    ok ( -- ) 
;    set bit_compile in STATE to one
HEADER "[", "iscompile"
    NOOP
    lds wrk_low, STAT+0
    sbr wrk_low, BIT_COMPILE
    rjmp states

;----------------------------------------------------------------------
;    ok ( -- ) 
;    set bit_postpone in STATE to zero 
HEADER "(nopostpone)", "nopostpone"
    NOOP
    ; clear postpone
    lds wrk_low, STAT+0
    cbr wrk_low, BIT_POSTPONE 
    rjmp states
    
;----------------------------------------------------------------------
;    ok ( -- ) 
;    set bit_postpone in STATE to one 
HEADER "(postpone)", "ispostpone"
    NOOP
    ; clear postpone
    lds wrk_low, STAT+0
    sbr wrk_low, BIT_POSTPONE 
    rjmp states
    
;----------------------------------------------------------------------
;    ok ( xt f -- ) 
;
;    f flag  1 immediate, -1 common
;     state = 0 execute, 1 compile,  3 postone
;
HEADER  "(eval)", "evaluate"
    NOOP

    ; load flags
    pspull wrk_low, wrk_high

10:
    ; load state
    lds tos_low, STAT+0

    ; ever execute 
    cpi tos_low, 0
    breq 18f

    ; default check
    cpi tos_low, 1
    breq 14f

    ; ever compile
    ; clear postpone
    cbr tos_high, BIT_POSTPONE ; must not be bit 0
    sts STAT+0, tos_high
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
;    ok (a -- a 0 | ud n)    
;    assumes a not a counted string, but ends with 32 or \0
;
;    uses all but X, Y
;    ips, wrk, tos, nds, _zero_, _work_, r0, r1
;
HEADER "(number)", "number"
    NOOP

    ; pull address from
    pspull zpm_low, zpm_high
    ; keep it
    pspush zpm_low, zpm_high

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
    pspull zpm_low, zpm_high

    ; push value
    pspush tos_low, tos_high

100:
    ; push digits
    WOOP

;----------------------------------------------------------------------
;
;     nok ( --- a2 u ) 
HEADER ".\"", "dotquote"
    NOOP
    POON    
    
;----------------------------------------------------------------------
;    ok ( a u -- ) 
;
;    called after parse ;)
;
HEADER    "(create)", "create"
    NOOP
    ; sram buffer
    lds zpm_low, THIS+0
    lds zpm_high, THIS+1

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
    lds zpm_low, THIS+0
    lds zpm_high, THIS+1

    pspull wrk_low, wrk_high
    st Z+, wrk_low
    st Z+, wrk_high

    clr tos_high
    clr tos_low

line_void:

10:
    ; update this 
    sts THIS+0, zpm_low
    sts THIS+1, zpm_high

    ; SRAM hold bottom of free ram
    ; verify free ram
    lds wrk_low, SRAM+0
    lds wrk_high, SRAM+1
    cp wrk_high, zpm_high
    cpc wrk_low, zpm_low
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

