

/*
 *  DISCLAIMER
 *
 *  Copyright © 2020, Alvaro Gomes Sobral Barcellos,
 *
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
 *  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

;----------------------------------------------------------------------
;
; great DJB hash, adapted for 16bits
;
; hash = (hash << 5) + str[i]
; for ascii chars in sram, in bytes not cells
; ( a u -- h ) djb hash
;
.equ djbHASH, 5381
HEADER "HASH", "HASH", F_LEAP
    NOOP
    clr _zero_
    ldi nos_low, lo8(djbHASH)
    ldi nos_high, hi8(djbHASH)
    pspull zpm_low, zpm_high

    ; get a char
1:    
    
    cp tos_high, tos_low
    brbs BIT_ZERO, 2f

    ld _work_, Z+
    add nos_low, _work_
    adc nos_high, _zero_

    lsl nos_low
    rol nos_high
    lsl nos_low
    rol nos_high
    lsl nos_low
    rol nos_high
    lsl nos_low
    rol nos_high
    lsl nos_low
    rol nos_high

    sbiw tos_low, 1
    rjmp 1b
    
2:
    movw tos_low, nos_low
    POON

;----------------------------------------------------------------------
;
;   ok  ( -- w)
;
;     ©2000-2021 by Gerhard Schmidt,
;      http://www.avr-asm-tutorial.net/avr_en/apps/random_tn13/random_calc_tn13.html
;
;    seed ~ 0x02A8
;
;     also good seeds
;
;    B167 4A3C 9879 B61E 7B26 
;    A858 1F88 50D5 419D 5537
;    0224 0527 5EB6 1E6D BCDC
;    92FF C206 0ECD 9361 2823
;    BE0B B303 6462 0E4C 3D24
;
HEADER "RANDOM", "RANDOM", F_LEAP
    NOOP
;    load seed
    lds wrk_low, SEED
    lds wrk_high, SEED
;    run magics
    eor wrk_low, wrk_high
    swap wrk_low
    add wrk_high, wrk_low
    movw tos_low, wrk_low
    rjmp _seed

;----------------------------------------------------------------------
;
;   ok ( w -- ) 
;   sets seed for rand
;
HEADER "RAND", "RAND", F_LEAP
    NOOP
    movw wrk_low, tos_low
    pspull tos_low, tos_high
_seed:
    sts SEED, wrk_low
    sts SEED + 1, wrk_high
    POON
    
;----------------------------------------------------------------------
;
;   ok ( w -- u) 
;
HEADER "ABS", "ABS", F_LEAP 
    .word DUP, LIT, 0x8000, AND, ZBRANCH, 2f
    .word NEGATE
2:  .word ENDS

;----------------------------------------------------------------------
;
;   is ( w1 w2 -- w) 
;
HEADER "MAX", "MAX", F_LEAP
    .word TWODUP, LTHAN, IF, SWAP, THEN, DROP, ENDS

;----------------------------------------------------------------------
;
;   is ( w1 w2 -- w) 
;
HEADER "MIN", "MIN", F_LEAP
    .word SWAP, MAX, ENDS

;----------------------------------------------------------------------
;
;   is ( w1 w2 w3 -- f ) 
;
HEADER "WITHIN", "WITHIN", F_LEAP
    .word OVER, MINUS, TOR, MINUS, RTO, UMLESS, ENDS

;----------------------------------------------------------------------
; a 64 bit half number, 7FFF FFFF FFFF FFFF is 9.223.372.036.854.775.807
;----------------------------------------------------------------------



;----------------------------------------------------------------------
; adapted from AVR-200 
; "mpy16u" "- 16x16 Bit Unsigned Multiplication
;
; ok UM*
HEADER "UM*", "UMUL", F_LEAP
    NOOP
;
;    move operanos
;
    ; pspull tos_low, tos_high    ; pull multiplicand
    pspull nos_low, nos_high    ; pull multiplier
;
;***** Code
;
mul16u: 
    ldi wrk_low, 16
    mov _work_, wrk_low       ;init loop counter
    clr wrk_low               ;clear high result Low byte
    clr wrk_high              ;clear high result High byte and carry

    ; multiplier shift rigth
    lsr nos_high
    ror nos_low

m16u_1: 
    brcc noad8                 ;if carry, bit 0, of multiplier set
    add wrk_low, tos_low       ;add multiplicand Low to byte 2 of res
    adc wrk_high, tos_high     ;add multiplicand high to byte 3 of res

noad8: 
    ror wrk_high               ;shift right result byte 3
    ror wrk_low                ;rotate right result byte 2
    ror nos_high               ;rotate result byte 1 and multiplier High
    ror nos_low                ;rotate result byte 0 and multiplier Low
    dec _work_                 ;decrement loop counter
    brne m16u_1                ;if not done, loop more

m16ures: 
m16result:    
    pspush wrk_low, wrk_high    ; high bytes
    pspush nos_low, nos_high    ; low bytes
    POON

;----------------------------------------------------------------------
;
;     adapted from AVR-200 
;   "div16u" "- 16/16 Bit Unsigned Division
;
; ok UM/MOD
HEADER "UM/MOD", "UMBYMOD", F_LEAP
    NOOP
;
;    move operanos
;
    ; pspull tos_low, tos_high    ; pull divisor
    pspull nos_low, nos_high    ; pull dividend
;
;***** Code

div16u: 
    ldi wrk_low, 17
    mov _work_, wrk_low     ;init loop counter
    clr wrk_low             ;clear remainder Low byte
    clr wrk_high            ;clear remainder High byte and carry

d16u_1: 
    rol nos_low              ;shift left dividend
    rol nos_high
    dec _work_               ;decrement counter
    breq d16ures             ;if done

d16u_2: 
    rol wrk_low              ;shift dividend into remainder
    rol wrk_high
    sub wrk_low, tos_low     ;remainder = remainder - divisor
    sbc wrk_high, tos_high   

    brcc d16u_3              ;if result negative
    add wrk_low, tos_low     ; restore remainder
    adc wrk_high, tos_high
    clc                      ; clear carry to be shifted into result
    rjmp d16u_1              ;else

d16u_3: 
    sec                      ; set carry to be shifted into result
    rjmp d16u_1

d16ures:
    rjmp m16result

;----------------------------------------------------------------------
;
;     adapted from AVR-200 
;     "mpy16s" "- 16x16 Bit Signed Multiplication
; ok *
HEADER "*", "SMUL", F_LEAP
    NOOP
;
;***** Code
;
;    move operanos
;
    ; pspull tos_low, tos_high        ; pull multiplicand
    pspull nos_low, nos_high        ; pull multiplier
;
;***** Code
mpy16s: 
    ldi wrk_low, 16
    mov _work_, wrk_low     ;init loop counter
    sub wrk_low, wrk_low    ;clear high result Low byte
    sub wrk_high, wrk_high  ;clear high result High byte and carry

m16s_1: 
    brcc m16s_2             ;if carry (previous bit) set
    add  wrk_low, tos_low   ;    add multiplicand Low to result byte 2
    adc  wrk_high, tos_high ;    add multiplicand High to result byte 3
m16s_2: 
    sbrc nos_low, 0         ;if current bit set
    sub  wrk_low, tos_low   ;    sub multiplicand Low from result byte 2
    sbrc nos_low, 0         ;if current bit set
    sbc  wrk_high, tos_high ;    sub multiplicand High from result byte 3
    asr  wrk_high           ;shift right result and multiplier
    ror  wrk_low
    ror  nos_high
    ror  nos_low
    dec  _work_             ;decrement counter
    brne m16s_1             ;if not done, loop more

m16sres:
    rjmp m16result

;----------------------------------------------------------------------
;
;     adapted from AVR-200 
;   "div16s" "- 16/16 Bit Signed Division
;
; ok /
HEADER "/", "SDIV", F_LEAP
    NOOP
;
;***** Subroutine Register Variables
;
;    move operanos
;
    ; pspull tos_low, tos_high        ; pull divisor
    pspull nos_low, nos_high        ; pull dividend
;
;***** Code
;
div16s: 
    mov    _work_, nos_high   ;move dividend High to sign register
    eor    _work_, tos_high   ;xor divisor High with sign register
    bst _work_, 7                ;save it, but could be BST

d16s_0:
    sbrs   nos_high, 7          ;if MSB in dividend set
    rjmp   d16s_1
    
    com    nos_high            ;    change sign of dividend
    com    nos_low
    subi   nos_low, lo8(-1)
    sbci   nos_low, hi8(-1)

d16s_1: 
    sbrs   tos_high, 7    ;if MSB in divisor set
    rjmp   d16s_2
    
    com    tos_high    ;    change sign of divisor
    com    tos_low
    subi   tos_low, lo8(-1)
    sbci   tos_low, hi8(-1)

d16s_2: 

    ldi wrk_low, 17
    mov _work_, wrk_low     ;init loop counter
    sub wrk_low, wrk_low    ;clear high remainder Low byte
    sub wrk_high, wrk_high  ;clear high remainder High byte and carry

d16s_3: 
    rol    nos_low    ;shift left dividend
    rol    nos_high
    dec    _work_     ;decrement counter
    brne    d16s_5    ;if done

    bld _work_, 7           ;save it, but could be BST
    sbrs    _work_, 7    ;    if MSB in sign register set
    rjmp    d16sres
    com    nos_high      ;    change sign of result
    com    nos_low
    subi   nos_low,lo8(-1)
    sbci   nos_high,hi8(-1)

d16sres:
    rjmp m16result

d16s_5: 
    rol    wrk_low              ;shift dividend into remainder
    rol    wrk_high
    sub    wrk_low, tos_low     ;remainder = remainder - divisor
    sbc    wrk_high, tos_high   ;
    brcc    d16s_6              ;if result negative

    add    wrk_low, tos_low     ;    restore remainder
    adc    wrk_high, tos_high
    clc                         ;    clear carry to be shifted into result
    rjmp    d16s_3    ;else
d16s_6: 
    sec                         ;    set carry to be shifted into result
    rjmp    d16s_3

;----------------------------------------------------------------------
; 
;   by Peter Dannegger 
;     https://www.avrfreaks.net/forum/smallest-and-fastest-binary-bcd-conversion?page=all
;     to base 10
;
; input 16 bit value 0 ... 65535
; output  5 digits (ASCII)
;
; zzzz ( a -- w )
HEADER "utoa", "utoa", F_LEAP 
    NOOP

    movw nos_low, tos_low
    pspull wrk_low, wrk_high
    
itoa:

    ldi tos_low, -1 + '0'
1:  inc tos_low
    subi wrk_low, lo8(10000)    
    sbci wrk_high, hi8(10000)
    brcc 1b
    st    Z+, wrk_low

    ldi tos_low, 10 + '0'
2:  dec tos_low
    subi wrk_low, lo8(-1000)  
    sbci wrk_high, hi8(-1000)
    brcs 2b
    st Z+, wrk_low

    ldi tos_low, -1 + '0'
3:  inc tos_low
    subi wrk_low, lo8(100)   
    sbci wrk_high, hi8(100)
    brcc 3b
    st Z+, wrk_low

    ldi wrk_high, 10 + '0'
4:  dec wrk_high
    subi wrk_low, -10     
    brcs 4b

    subi wrk_low, -'0'
    st Z+, wrk_low

; append \0
    clr wrk_low
    st Z+, wrk_low

    pspush nos_low, nos_high
    POON

/* 
 * Macro to divide a 4-byte value by a 2-byte value yielding a 2-byte 
 * quotient and 2-byte remainder. 
 * 
 * On entry:   _A3.._A0 contains the 4-byte dividend 
 *             _B1.._B0 contains the 2-byte divisor 
 * 
 * On exit:    if there is no overflow 
 *             _A1.._A0 contains the 2-byte quotient 
 *             _A3.._A2 contains the 2-byte remainder 
 * 
 * C-callable: no 
 * 
 * Modifies:   _A3.._A0, _cnt 
 * 
    .macro    div32_16    _A3, _A2, _A1, _A0, _B1, _B0, _cnt 
    ldi     \_cnt, 16 

    cp      \_A2, \_B0 
    cpc     \_A3, \_B1
    brlo    0f
    //overflow, do something intelligent
    ser     \_A1
    ser     \_A0
    rjmp    3f

0: 
    lsl     \_A0 
    rol     \_A1 
    rol     \_A2 
    rol     \_A3 
    brcs    1f 
    cp      \_A2, \_B0 
    cpc     \_A3, \_B1
    brcs    2f 
1: 
    sub     \_A2, \_B0 
    sbc     \_A3, \_B1
    ori     \_A0, 1 
2: 
    dec     \_cnt 
    brne    0b 

3:
    .endm 

*/
