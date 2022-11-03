
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
; inside routines, not for user
;
;----------------------------------------------------------------------
;
; ok ( a1 c --- a2 | 0 ) 
;   skips chars in address while not equal to c or 0x0
;   not standart, 0x0 ends buffer
;   works only in sram
;
HEADER "(skip)", "skip"
    NOOP
    clr tos_high
    pspull zpm_low, zpm_high
1:
    ld nos_low, Z
    ; if \0
    cp tos_high, nos_low 
    breq 2f
    cp tos_low, nos_low 
    breq 3f
    adiw zpm_low, 1
    rjmp 1b
2:  mov tos_low, tos_high
    POON
3:  movw tos_low, zpm_low
    POON

;----------------------------------------------------------------------
;
; ok ( a1 c --- a2 | 0 ) 
;   scan chars in address while equal to c or 0x0
;   not standart, 0x0 ends buffer
;   works only in sram
;
HEADER "(scan)", "scan"
    NOOP
    clr tos_high
    pspull zpm_low, zpm_high
1:
    ld nos_low, Z
    ; if \0
    cp tos_high, nos_low 
    breq 2f
    cp tos_low, nos_low 
    brne 3f
    adiw zpm_low, 1
    rjmp 1b
2:  mov tos_low, tos_high
    POON
3:  movw tos_low, zpm_low
    POON

;----------------------------------------------------------------------
;
; ok ( a1 a2 u --- ) 
;   copy u chars from a1 into a2, forward copy
;   not standart, no check for overlaps, works only in sram
;
HEADER "(copy)", "copy"
    NOOP
    clr tos_high
    pspull nos_low, nos_high
    pspull zpm_low, zpm_high

    rspush psp_low, psp_high
    movw psp_low, nos_low
10:
    cp tos_low, tos_low
    brbs BIT_ZERO, 20f
    
    ld nos_low, Z+
    st Y+, nos_low
    dec tos_low
    rjmp 10b
20:
    rspull psp_low, psp_high
    pspull tos_low, tos_high
    POON
    
;----------------------------------------------------------------------
;
; ok ( a u --- u ) 
;
;   refills address till u chars read, u < 256
;     its refill ( a u -- u )  NO ECHOES !!!
;       no standart, always read from USART
;
HEADER "(refill)", "refill"
    NOOP
10: 
    ; get buffer pointer 
    pspull zpm_low, zpm_high
    
    ; keep a spc at start, so every word starts with spc, 
    ; used later to make a counted string in site
    ldi wrk_low, 32
    srsave wrk_low
    ; save for spc at init
    dec tos_low 
    ; save for \0 at end
    dec tos_low

    ; clear count
    clr tos_high
    ; clear last char
    clr wrk_high

;   loop counts from 0 to u
20: 
    ; end of buffer ?   
    cp tos_low, tos_high
    brbs BIT_ZERO, 70f

30: 
    ; waits a ASCII char
    sbis 0xb, 7
    rjmp 30b
    in wrk_low, 0xc

    ; no 8bits
    cpi wrk_low, 128
    brge 30b

; process allowed control

    ; not a control 
    cpi wrk_low, 30
    brge 60f

40:
    ; verify CR    \r
    cpi wrk_low, 13 ; CR
    breq 70f

    ; verify LF \n
    cpi wrk_low, 10 ; LF 
    breq 70f

42:
    ; verify NAK, reset line 
    cpi wrk_low, 21 ; NAK
    brne 44f

    ; process NAK
    clr wrk_high
    sub zpm_low, tos_high
    sbc zpm_high, wrk_high
    clr tos_high
    rjmp 20b

44:
    ; verify BS \b
    cpi wrk_low, 8 ; BS
    brne 46f

    ; process BS
    ; no char ?
    cp tos_high, tos_high
    brbs BIT_ZERO, 30b

    ; back one
    dec tos_high
    sbiw zpm_low, 1
    rjmp 30b    

46:
    ; verify TAB \t
    cpi wrk_low, 9
    brne 48f

    ; magic to 32
    ldi wrk_low, 32
    rjmp 60f
    
48:
    ; not allow more controls
    rjmp 30b

/* 

those are not for now

    ; verify ESC \e
    cpi wrk_low, 27 ; ESC

    ; verify XON 
    cpi wrk_low, 17 ; XON

    ; verify XOFF 
    cpi wrk_low, 19 ; XOFF

*/

; process ASCII chars
60:    
    ; is a spc ?
    cpi wrk_low, 32
    brne 62f

    ; highlander it !
    cp wrk_low, wrk_high
    breq 30b

62:
.ifdef UPPERCASE    
    ; to uppercase
    cpi wrk_low, 61
    brge 64f
    cpi wrk_low, 123
    brge 64f
    subi wrk_low, 32
.endif

64: 
    ; save char to buffer
    inc tos_high
    srsave wrk_low
    mov wrk_high, wrk_low
    rjmp 20b
  
70: 
    ; push counter
    ; always add \0 terminator
    clr wrk_low
    srsave wrk_low

    ; save counter
    mov tos_low, tos_high
    clr tos_high
    POON

;----------------------------------------------------------------------
;
; ok ( a c --- a u | 0 ) 
;    search address for next word delimited by c or \0
;    returns start of word and u lenght
;    or zero if no word
;    max lenght is 255 bytes
;
HEADER "(word)", "word"
    NOOP
    ; start at 
    pspull zpm_low, zpm_high
    ; for \0 check
    clr tos_high
1:  
    ; skips while equal delimiter
    ld nos_low, Z
    ; if \0
    cp tos_high, nos_low
    breq 10f
    cp tos_low, nos_low
    brne 2f
    adiw zpm_low, 1
    rjmp 1b
2:  
    ; keep address
    movw wrk_low, zpm_low
3:  
    ld nos_low, Z
    ; if \0
    cp tos_high, nos_low
    breq 10f
    cp tos_low, nos_low
    breq 4f
    adiw zpm_low, 1
    rjmp 3b
4:  
    ; found
    sub zpm_low, wrk_low
    sbc zpm_high, wrk_high
    pspull wrk_low, wrk_high
    movw tos_low, zpm_low
    rjmp 20f
15:
    ; end of buffer
    clr tos_low
    clr tos_high
20:
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
    movw nos_low, tos_low

    ; Multiply LSB
    mul nos_low, _work_
    ; copy MSB result to result byte 1
    mov tos_low, R0 
    ; copy MSB result to result byte 2
    mov tos_high, R1

    ; Multiply MSB
    mul nos_high, _work_
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
    movw tos_low, wrk_low
    POON

;----------------------------------------------------------------------
;
; ok find a word in a vocabulary
;   ( aw u -- xt f | aw 0 )
;   names are 15 maximum
;
;   dictionary is in flash and word is in sram
;
HEADER "(find)", "find"
    NOOP

    ; load address
    pspull nos_low, nos_high

    ; save stack
    rspush psp_low, psp_high

    ; move address to Y ! always check in macros.S
    movw psp_low, nos_low
    
    ; prepare loop    
    lds zpm_low, (LIST+0)
    lds zpm_high, (LIST+1)
    
    ; push aword for first loop
    rspush psp_low, psp_high

    ; push alist for first loop
    rspush zpm_low, zpm_high

    ; save count
    mov tos_high, tos_low

10: 
    ; load link 
    rspull zpm_low, zpm_high

    ; load address 
    pmload wrk_low, wrk_high

    ; if null, list ends
    cp wrk_low, wrk_high
    brbs BIT_ZERO, 30f

    ; save next link
    rspush wrk_low, wrk_high

12:
    ; load size and first char
    pmload nos_low, nos_high

    ; save for flags
    mov wrk_high, nos_low

    ; must ummask
    andi nos_low, F_UNMASK
    
    ; ping-pong 
    ; verify sizes
    cp nos_low, tos_low
    brne 10b

    ; points to a1
    ld wrk_low, Y+
    
    ; verify first char
    cp wrk_low, nos_high
    brne 10b

    ; prepare count down
    mov tos_low, tos_high
    
14:
    dec tos_low
    brbs BIT_ZERO, 20f
    
    ; verify next chars
    pmload nos_low, nos_high

    ld wrk_low, Y+
    cp wrk_low, nos_low
    brne 10b
    
    dec tos_low
    brbs BIT_ZERO, 20f

    ld wrk_low, Y+
    cp wrk_low, nos_high
    brne 10b

    ; next chars
    rjmp 14b

20:  
    ; found
    ; anyway zpm is ever even

    ; drops
    rspull wrk_low, wrk_high
    rspull wrk_low, wrk_high

    ; restore psp
    rspull psp_low, psp_high

    ; push (xt)
    ;
    pspush zpm_low, zpm_high

    ; return flags
    clr tos_low
    clr tos_high
    andi wrk_high, F_IMMEDIATE
    brne 24f

22:
    ; immediate (1)
    inc tos_low
    rjmp 40f
24:
    ; common (-1)
    ser tos_low
    ser tos_high
    rjmp 40f

30: 
    ; not found (0)
    ; drops
    rspull wrk_low, wrk_high
    rspull wrk_low, wrk_high
    ; restore psp
    rspull psp_low, psp_high
    ; restore address
    pspush wrk_low, wrk_high
    ; set flag false
    clr tos_low
    clr tos_low
40:    
    ; save results
    POON

