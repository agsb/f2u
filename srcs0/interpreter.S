 
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
; minimal interpreter, aka sector forth 
; inside routines, not for user 
; 
;---------------------------------------------------------------------- 
 
/* 
;---------------------------------------------------------------------- 
; 
; ok ( a1 c --- a2 | 0 ) internal 
;   skips chars in address while not equal to c or 0x0 
;   not standart, 0x0 ends buffer, works only in sram 
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
    ; if c 
    cp tos_low, nos_low 
    breq 3f 
    adiw zpm_low, 1 
    rjmp 1b 
2: 
    clr zpm_low 
    clr zpm_high 
3: 
    movw tos_low, zpm_low 
    POON 
 
;---------------------------------------------------------------------- 
; 
; ok ( a1 c --- a2 | 0 ) internal 
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
    ; if c 
    cp tos_low, nos_low 
    brne 3f 
    adiw zpm_low, 1 
    rjmp 1b 
2: 
    clr zpm_low 
    clr zpm_high 
3: 
    movw tos_low, zpm_low 
    POON 
 
;---------------------------------------------------------------------- 
; 
; ok ( a1 a2 u --- ) internal 
;   compare u chars from a1 to a2, 
;   not standart, max 255, no check for overlaps, works only in sram 
; 
HEADER "(same)", "same" 
    NOOP 
    clr tos_high 
    pspull nos_low, nos_high 
    pspull zpm_low, zpm_high 
 
    rspush psp_low, psp_high 
    movw psp_low, nos_low 
10: 
    or tos_low, tos_low 
    breq 20f 
    dec tos_low 
 
    ld wrk_low, Z+ 
    ld wrk_high, Y+ 
    cp wrk_low, wrk_high 
    breq 10b 
 
    clr tos_low 
    rjmp 30f 
20: 
    ser tos_low 
    ser tos_high 
30: 
    POON 
 
*/ 
 
;---------------------------------------------------------------------- 
; 
; ok ( a1 a2 u --- a3 ) internal 
;   copy u chars from a1 into a2, forward copy, a3 = a1+u+1 
;   not standart, max 255, no check for overlaps, works only in sram 
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
    movw tos_low, zpm_low 
    POON 
 
;---------------------------------------------------------------------- 
; 
; ok ( a u --- u ) 
; 
;   refills address till u chars read, u < 256 
;     not standart: 
;     always read from USART 
;     only \n \r \b, all other control turns into space 
;     appends a bl at init and a bl at end 
; 
HEADER "(refill)", "refill" 
    NOOP 
10: 
    ; get buffer pointer 
    pspull zpm_low, zpm_high 
 
    ; keep a spc at start, so every word starts with spc, 
    ; used later to make a counted string 
 
    ; save for BL at end 
    dec tos_low 
 
    ; save for BL at init 
    dec tos_low 
 
    ; place a BL at init 
    ldi wrk_low, 32 
    srsave wrk_low 
 
    ; clear count 
    clr tos_high 
 
    ; clear last char 
    clr wrk_high 
 
;   loop counts from 0 to u 
20: 
    ; end of buffer ? 
    cp tos_low, tos_high 
    brbs BIT_ZERO, 70f 
 
;   getch 
30: 
1: 
    ; waits to receive 
    sbis 0xb, 7 
    rjmp 1b 
 
    ; receive a char 
    in wrk_low, 0xc 
 
    ; no 8bits 
    cpi wrk_low, 128 
    brge 1b 
 
    ; need echo ? 
2: 
    ; wait to send 
    sbis 0x0b, 5 
    rjmp 2b 
 
    ; send a char 
    out 0x0c, wrk_low 
 
; process allowed control 
 
    ; not a control 
    cpi wrk_low, 30 
    brge 60f 
 
40: 
    ; verify CR \r 
    cpi wrk_low, 13 ; CR 
    breq 70f 
 
    ; verify LF \n 
    cpi wrk_low, 10 ; LF 
    breq 70f 
 
44: 
    ; verify BS \b 
    cpi wrk_low, 8 ; BS 
    brne 50f 
 
    ; process BS 
    ; no char ? 
    cp tos_high, tos_high 
    brbs BIT_ZERO, 30b 
 
    ; back one 
    dec tos_high 
    sbiw zpm_low, 1 
    rjmp 30b 
 
50: 
    ; not allow more controls 
    ; magic to 32 
    ldi wrk_low, 32 
 
; process ASCII chars 
60: 
    ; is a spc ? 
    cpi wrk_low, 32 
    brne 62f 
 
    ; highlander it ! 
    ; ( collapse spaces ) 
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
    ; place a BL at end 
    ldi wrk_low, 32 
    srsave wrk_low 
 
    ; save counter 
    mov tos_low, tos_high 
    clr tos_high 
    POON 
 
;---------------------------------------------------------------------- 
; 
; ok ( a c --- a u | 0 ) 
;    find a for c 
;    returns address and u lenght or zero if no c or \0 
;    max lenght is 255 bytes 
; 
HEADER "(parse)", "parse" 
    NOOP 
    ; start at 
    pspull zpm_low, zpm_high 
    ; for \0 check 
    clr tos_high 
    rjmp _tows; 
 
;---------------------------------------------------------------------- 
; 
; ok ( a c --- a u | 0 ) 
;    find a word delimited by c 
;    returns address and u lenght or zero if no c or \0 
;    max lenght is 255 bytes 
; 
HEADER "(word)", "word" 
    NOOP 
    ; start at 
    pspull zpm_low, zpm_high 
    ; for \0 check 
    clr tos_high 
    rjmp _wsto 
 
;---------------------------------------------------------------------- 
; 
;   pass trhu 
; 
_wsto: 
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
 
_tows: 
2: 
    ; keep address 
    movw wrk_low, zpm_low 
 
3: 
    ; scans while not equal delimiter 
    ld nos_low, Z 
    ; if \0 
    cp tos_high, nos_low 
    breq 10f 
    cp tos_low, nos_low 
    breq 4f 
    adiw zpm_low, 1 
    rjmp 3b 
 
_wsat: 
4: 
    ; found 
    sub zpm_low, wrk_low 
    sbc zpm_high, wrk_high 
    pspush wrk_low, wrk_high 
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
;   not official ! (ud1 c-addr1 u1 -- ud2 c-addr2 u2) 
; 
;    ok ( a n -- u2 true | false ) 
;    assumes address n chars 
;    f flag is (Out-of-Range, Not-a-Number, Invalid-Number,) FALSE or TRUE 
;    uses all but X, Y 
;    tos, nos, wrk, Z, _zero_, _work_, r0, r1 
; 
HEADER "(number)", "number" 
    NOOP 
 
    ; tst for c < 1 
 
    clr tos_high 
    cp tos_high, tos_low 
    brlt 10f 
 
    ; not valid size c < 1 
    pspush tos_low, tos_high 
    rjmp 70f 
 
10: 
    ; pull address from 
    pspull zpm_low, zpm_high 
 
    ; keep counter 
    movw nos_low, tos_low 
 
    ; clear result 
    clr tos_low 
    clr tos_high 
 
    ; get actual base 
    lds _work_, BASE+0 
 
20: 
    ; test end of loop 
    cp nos_low, nos_high 
    brne 30f 
    rjmp 80f 
 
30: 
    ; load a char 
    srload wrk_low 
 
    ; allow first char change base 
    tst nos_high 
    brne 40f 
 
    ; goes hexadecimal 
    cpi wrk_low, '$' 
    brne 32f 
    ldi wrk_low, 16 
    mov _work_, wrk_low 
    rjmp 20b 
 
32: 
    ; goes decimal 
    cpi wrk_low, '#' 
    brne 34f 
    ldi wrk_low, 10 
    mov _work_, wrk_low 
    rjmp 20b 
 
34: 
    ; goes binary 
    cpi wrk_low, '%' 
    brne 36f 
    ldi wrk_low, 2 
    mov _work_, wrk_low 
    rjmp 20b 
 
36: 
    ; how do negative ? just two-complement at end 
    cpi wrk_low, '-' 
    brne 38f 
    ldi wrk_high, 1 
    dec nos_high 
    rjmp 20b 
 
38: 
    ; how do positive ? just no two-complement at end 
    cpi wrk_low, '+' 
    brne 40f 
    ldi wrk_high, 0 
    dec nos_high 
    rjmp 20b 
 
38: 
    ; no more bases, no octal, no duodecimal, no hexagesimal 
 
40: 
    ; paranoic test end 
 
    cpi wrk_low, 0 
    breq 80f 
 
    cpi wrk_low, 32 
    breq 80f 
 
    ; mask lowercases 
    cpi wrk_low, 'a' 
    brlt 45f 
    subi wrk_low, 32 
 
45: 
    ; reduce 
    subi wrk_low, '0' 
 
    ; less than 0 ? 
    cpi wrk_low, 0 
    brlt 70f 
 
    ; less than 9 ? 
    cpi wrk_low, 10 
    brlt 50f 
 
    ; mind the gap 0-9 ~ A-F 
    subi wrk_low, 7 
 
50: 
    ; over base ? 
    cp wrk_low, _work_ 
    brge 70f 
 
; easy way 
; bases 2, 8, 10, 16 
 
    add tos_low, wrk_low 
    adc tos_high, _zero_ 
 
    ; set value 
    movw R0, tos_low 
 
    ; set base 
    cp wrk_low, _work_ 
 
; 2 
_bin_base: 
    lsl R0 
    rol R1 
    cpi wrk_low, 2 
    breq _next_digit 
 
    ; keep for decimal or odds 
    movw tos_low, R0 
 
; 4 
_nib_base: 
    lsl R0 
    rol R1 
    ; cpi wrk_low, 4 
    ; breq _next_digit 
 
; 8 
_oct_base: 
    lsl R0 
    rol R1 
    ; cpi wrk_low, 8 
    ; breq _next_digit 
 
;10 
_dec_base: 
    cpi wrk_low, 10 
    brne _hex_base 
 
    add R0, tos_low 
    adc R1, tos_high 
    rjmp _next_digit 
 
; 16 
_hex_base: 
    lsl R0 
    rol R1 
    cpi wrk_low, 16 
    breq _next_digit 
 
_next_digit: 
; overflow ? 
    brcc _next_digit 
    rjmp 70f 
 
; next digit 
    movw tos_low, R0 
 
60: 
    ; count digits 
    inc nos_high 
 
    ; next digit 
    rjmp 10b 
 
70: 
    ; (Underflow, Overflow, Not_a_Number, Out_of_Range, Invalid_numeric_Argument) 
    clr wrk_low 
    clr wrk_high 
    rjmp 100f 
 
80: 
    ; if positive 
    cpi wrk_high, 0 
    breq 90f 
 
    ; 2's complement 
    com tos_low 
    com tos_high 
    adiw tos_low, 1 
 
    ; underflow 
    brcs 70b 
 
90: 
    ; push result 
    pspush tos_low, tos_high 
 
    ; made true 
    ser wrk_low 
    ser wrk_high 
 
100: 
    ; push digits 
    movw tos_low, wrk_low 
    POON 
 
;---------------------------------------------------------------------- 
; 
; ok find a word in a vocabulary 
;   ( aw u ad -- xt f | a 0 ) 
;    ad link to dictionary 
;    aw address to word 
;    u  length 
;   f is  1 if word is immediate 
;   f is -1 if word is normal 
;   f is  0 if word not found 
;   names are 15 maximum 
; 
;   dictionary is in flash and word is in sram 
; 
HEADER "(find)", "find" 
    NOOP 
 
    ; load address dictionary 
    movw zpm_low, tos_low 
 
    ; load counter 
    pspull tos_low, tos_high 
 
    ; load address word 
    pspull nos_low, nos_high 
 
    ; save stack 
    rspush psp_low, psp_high 
 
    ; save address word 
    rspush nos_low, nos_high 
 
    ; move address to Y ! always check in macros.S 
    movw psp_low, nos_low 
 
    ; prepare loop 
 
    ; save word count 
    mov tos_high, tos_low 
 
    ; push aword for first loop 
    rspush psp_low, psp_high 
 
    ; push alist for first loop 
    rspush zpm_low, zpm_high 
 
10: 
    ; load link 
    rspull zpm_low, zpm_high 
 
    ; load address 
    pmload wrk_low, wrk_high 
 
    ; if null, list ends 
    cp wrk_low, wrk_high 
    brbs BIT_ZERO, 26f 
 
    ; save next link 
    rspush wrk_low, wrk_high 
 
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
    ; verify next chars 
    dec tos_low 
    brbs BIT_ZERO, 20f 
 
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
 
    ; return flags 
    andi wrk_high, F_IMMEDIATE 
    brne 24f 
 
22: 
    ; immediate (1) 
    clr tos_low 
    clr tos_high 
    inc tos_low 
    rjmp 30f 
24: 
    ; common (-1) 
    ser tos_low 
    ser tos_high 
    rjmp 30f 
26: 
    ; not found (0) 
    clr tos_low 
    clr tos_low 
30: 
    ; drops references 
    rspull wrk_low, wrk_high 
    rspull wrk_low, wrk_high 
 
    ; copy wt 
    rspull wrk_low, wrk_high 
 
    cpi tos_low, 0 
    brbs BIT_ZERO, 40f 
 
    ; copy (xt) 
    movw wrk_low, zpm_low 
 
40: 
    ; restore psp 
    rspull psp_low, psp_high 
 
    ; push result address 
    pspush wrk_low, wrk_high 
 
    ; save results 
    POON 
 
;********************************************************************** 
; 
; almost forth94 
; 
;---------------------------------------------------------------------- 
 
 
;---------------------------------------------------------------------- 
; 
; ok MOVE (a1 a2 u -- ) 
; 
HEADER "MOVE", "MOVE", 
1:  .word ZDUP, ZBRANCH, 2f
    .word ONEMINUS, TOR
    .word OVER, AT, OVER, TO
    .word ONEPLUS, SWAP, ONEPLUS, SWAP
    .word BRANCH, 1b
2:  .word DROP, DROP, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok FILL (a u c -- ) 
; 
HEADER "FILL", "FILL", 
    .word SWAP, TOR, SWAP
1:  .word RTO, ZDUP, ZBRANCH, 2f
    .word ONEMINUS, TOR
    .word OVER, OVER, TO, ONEPLUS 
    .word BRANCH, 1b 
2:  .word DROP, DROP, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is \] to compile 
; 
HEADER "]", "RBRAC", 
    .word ONE, STATE, TO, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is \[ to interpret 
; 
HEADER "[", "LBRAC", F_IMMEDIATE 
    .word ZERO, STATE, TO, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is TOGGLE ( a f -- ) 
; 
HEADER "TOGGLE", "TOGGLE", 
    .word OVER, AT, XOR, SWAP, TO, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is >NFA ( a f -- ) 
; from link to c_name 
; 
HEADER ">NFA", "TONFA", 
    .word CELL, PLUS, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is >CFA ( a f -- ) 
; from link to code 
HEADER ">CFA", "TOCFA", 
    .word CELL, PLUS, DUP, AT, F_UNMASK, AND, PLUS, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is HIDDEN 
; 
HEADER "HIDDEN", "HIDDEN", 
    .word LATEST, TONFA, F_HIDDEN, TOGGLE, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is IMMEDIATE 
; 
HEADER "IMMEDIATE", "IMMEDIATE", 
    .word LATEST, TONFA, F_IMMEDIATE, TOGGLE, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is COMP_ONLY 
; 
HEADER "COMPILE_ONLY", "COMPILE_ONLY", 
    .word LATEST, TONFA, F_COMPILE, TOGGLE, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is HANDLER 
; 
HEADER "HANDLER", "HANDLER", 
    .word LIT, HANDLERS, ENDS 
 
HANDLERS:   .word 0     ; hold for catch//throw 
 
;---------------------------------------------------------------------- 
; 
; is CATCH 
; 
HEADER "CATCH", "CATCH", 
    .word PSAT, TOR, HANDLER, AT, TOR, RSAT, HANDLER, TO 
    .word EXEC, RTO, HANDLER, TO, RTO, DROP, LIT, 0 
    .word ENDS 
 
;---------------------------------------------------------------------- 
; 
; is THROW 
; 
HEADER "THROW", "THROW", 
    .word ZDUP, ZBRANCH, 1f 
    .word HANDLER, AT, RSTO, RTO, HANDLER, TO 
    .word RTO, SWAP, TOR, PSTO, DROP, RTO 
1:  .word ENDS 
 
;---------------------------------------------------------------------- 
; 
; is SPACE ( -- )
; 
HEADER "SPACE", "SPACE" 
    .word BL, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is SPACES ( n -- )
; 
HEADER "SPACES", "SPACES" 
1:  .word ZDUP, ZBRANCH, 2f
    .word SPACE, ONEMINUS, BRANCH, 1b
2:  .word ENDS 
 
;---------------------------------------------------------------------- 
; 
; is THROW 
; 
HEADER "ABORT", "ABORT" 
    .word LIT, -1, THROW, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is ACCEPT is a refill with edit capabilities 
; 
HEADER "ACCEPT", "ACCEPT", 
    .word ZZZZ, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is 
; 
HEADER "OVERT", "OVERT", 
    ;.word LATEST, AT, CURRENT, AT, TO, ENDS 
    .word ZZZZ, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is 
; 
HEADER ":", "COLON", F_IMMEDIATE 
    .word CREATE, RBRAC, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is 
; 
HEADER ";", "SEMMI", 
    .word EXIT, LBRAC, OVERT, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is SOURCE 
;   place terminal buffer address and length in stack 
; 
HEADER "SOURCE", "SOURCE", 
    .word LIT, TIB0, LIT, TIB_SIZE 
;   no standart: also place a \0 at end :) 
    .word OVER, OVER, PLUS, LIT, ZERO, SWAP, TO, ONE, MINUS 
    .word ENDS 
 
;---------------------------------------------------------------------- 
; 
; is SOURCE 
;   place terminal buffer address and length in stack 
; 
HEADER "SOURCE+", "SOURCEPLUS", 
    .word SOURCE, DROP, TOIN, PLUS, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is  REFILL ( -- a n ), toin = 0 
; 
HEADER "REFILL", "REFILL", 
    .word SOURCE, refill, ZERO, TOIN, TO, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is PARSE ( "<chars>ccc" c -- a n ) 
;   no counted-string 
; 
HEADER "PARSE", "PARSE" 
    .word SOURCEPLUS, SWAP 
    .word parse, ZDUP, ZBRANCH, 2f 
    .word DUP, TOIN, PLUSTO, ENDS 
2:  .word REFILL, BRANCH, PARSE ; perfect loop 
 
;---------------------------------------------------------------------- 
; 
; is PAREN ( "<chars>ccc" c -- ) also comments
; 
HEADER "(", "PAREN" 
    .word LIT, ')', PARSE, DROP, DROP, ENDS ; F_IMMEDIATE 

;---------------------------------------------------------------------- 
; 
; is DOTPAREN .( "<chars>ccc" c -- a n ) also types
;   not standart, no multi-task support
;
HEADER ".(", "DOTPAREN" 
    .word LIT, ')', PARSE, ENDS ;

;---------------------------------------------------------------------- 
; 
; is SQUOTE S\" ( "<chars>ccc" c -- a n )
;   not standart, no multi-task support
;
HEADER "S\"", "SQUOTE" 
    .word LIT, '\"', PARSE, ENDS ;

;---------------------------------------------------------------------- 
; 
; is DOTQUOTE .\" ( "<chars>ccc" c -- a n )
;   not standart, no multi-task support
;
HEADER ".\"", "DOTQUOTE" 
    .word SQUOTE, TYPE, ENDS ;

;---------------------------------------------------------------------- 
;---------------------------------------------------------------------- 
; 
; is  PARSE-NAME ( "ccc<chars>ccc" c -- a n ), toin = 0 
;   no counted-string 
; 
HEADER "PARSE-NAME", "PARSEN", 
    .word SOURCEPLUS, SWAP 
    .word word, ZDUP, ZBRANCH, 2f 
    .word DUP, TOIN, PLUSTO, ENDS 
2:  .word REFILL, BRANCH, PARSEN  ; perfect loop 
 
;---------------------------------------------------------------------- 
; 
; is FIND-NAME ( a n -- a 0 | xt -1 | xt 1 ) 
;   no counted-string 
;   no vocabularies 
; 
HEADER "FIND-NAME", "FINDN", 
    .word LATEST, AT, find, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is FIND ( "ccc<chars>ccc" -- a 0 | xt -1 | xt 1 ) 
; 
HEADER "FIND", "FIND", 
    .word PARSEN, FINDN
    .word ZBRANCH, ABORT 
    .word DROP, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is  NONAME ( "" ), toin = 0 
; 
HEADER "NONAME", "NONAME", 
    .word ZZZZ, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is CREATE ( "ccc<str>ccc" -- xt ) 
; parse next word and compile a header 
; 
HEADER "CREATE", "CREATE", 
    .word PARSEN, LIT, UH0 
    .word DUP, LATEST, AT, SWAP, TO, CELLPLUS 
    .word OVER, OVER, TO, ONEPLUS, SWAP, DUP 
    .word TOR, copy, RTO 
    .word DUP, ONE, AND, ZEQU, ZBRANCH, 2f 
    .word DUP, BL, SWAP, TO, ONE, PLUS 
2:  .word ENDS 
 
;---------------------------------------------------------------------- 
; zzzz
;
; is DOES ( xt -- ) 
; 
HEADER "DOES", "DOES", 
    .word LIT, BRANCH, COMMA, HERE, COMMA, ENDS 

;---------------------------------------------------------------------- 
; 
; is DOES> ( xt -- ) 
; 
HEADER "DOES>", "DOESTO", F_IMMEDIATE 
    .word LIT, BRANCH, COMMA, HERE, COMMA, ENDS 

;---------------------------------------------------------------------- 
; 
; is CONSTANT ( "ccc<caddr>ccc" w -- ) 
; constants go to eeprom
; EP points next word free
; 
 HEADER "CONSTANT", "CONSTANT", 
    .word CREATE, EPP, AT
    .word DUP, TOR, TOE, RTO
    .word DUP, CELL, PLUS, EPP, TO
    .word COMMA, DOESTO, ENDS 
    
;---------------------------------------------------------------------- 
; 
; is VARIABLE ( "ccc<caddr>ccc"  -- ) 
; variables go to high adress sram
; UP maps next word free
HEADER "VARIABLE", "VARIABLE", 
    .word CREATE, UPP, AT
    .word DUP, TOR, TO, RTO
    .word DUP, CELL, MINUS, UPP, TO
    .word COMMA, DOESTO, ENDS 
    
;---------------------------------------------------------------------- 
; 
; is TICK ( "ccc<caddr>ccc" -- xt | 0 ) 
; 
HEADER "'", "TICK", 
    .word FINDN, DUP, ZEQU, ZBRANCH, 2f 
    .word SWAP 
2:  .word DROP, ENDS 
 
;---------------------------------------------------------------------- 
; 
; ok unconditional compile next word 
;   no check if 0x0 zzzz 
; 
HEADER "POSTPONE", "POSTPONE", F_IMMEDIATE, 
    .word TICK, COMMA, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is 
; 
HEADER "COMPXT", "COMPXT", F_IMMEDIATE 
    .word LIT, LIT, COMMA, COMMA, ENDS 
 
;---------------------------------------------------------------------- 
; 
; is  NUMBN ( a n -- w true | a n false ) 
; 
HEADER "NUMBN", "NUMBN", 
    .word OVER, OVER, number 
    .word ZBRANCH, 2f 
    .word TOR, DROP, DROP, RTO, FTRUE, BRANCH, 4f 
2:  .word FFALSE 
4:  .word ENDS 
 
;---------------------------------------------------------------------- 
; 
; is  NONEN ( a n -- ) 
; 
HEADER "NONEN", "NONEN", 
    .word CR, TYPE, LIT, notoky, LIT, 4, TYPE, ENDS 

;---------------------------------------------------------------------- 
; 
; is 
; 
HEADER "EVAL", "EVAL", 
    .word PARSEN
100:
    ; is a word 
    .word FINDN, ZBRANCH, 200f
    ; is -1 normal 1 immediate 
    .word ONEMINUS, ZEQU, ZBRANCH, 120f 
    .word STATE, AT, ZBRANCH, 120f
110:
    .word COMMA, BRANCH, EVAL 
120:
    .word EXEC, BRANCH, EVAL 
    
    ; is a number ? 
200: .word NUMBN, ZBRANCH, 300f 
    .word STATE, AT, ZBRANCH, EVAL 
    .word LIT, LIT, COMMA, COMMA
    .word BRANCH, EVAL 
300: 
    ; not okey
    .word NONEN, BRANCH, EVAL 
 400:
    .word ENDS
;---------------------------------------------------------------------- 
; 
; is 
; 
HEADER "QUIT", "QUIT", 
1: 
    .word LBRAC 
    .word RS0, RSTO 
    .word REFILL 
2: 
    .word EVAL, CATCH 
    .word DUP, LIT, 0, EQUAL, ZBRANCH, 3f 
    .word STATE, AT, ZEQU, ZBRANCH, 5f 
    .word LIT, prompt, LIT, 4, TYPE, BRANCH, 5f 
    .word CR, BRANCH, 2b 
3: 
    .word DUP, LIT, -1, EQUAL, ZBRANCH, 4f 
    .word LIT, abort, LIT, 8, TYPE, BRANCH, 5f 
4: 
    .word DUP, LIT, -2, EQUAL, ZBRANCH, 5f 
    .word LIT, exception, LIT, 12, TYPE, DOT, BRANCH, 5f 
5: 
    .word CR, BRANCH, 2b 
    .word ENDS 
 
;---------------------------------------------------------------------- 
; 
; is 
; 
