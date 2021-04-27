
;----------------------------------------------------------------------
;
;    "div16u" - 16/16 Bit Unsigned Division
;
; ok UM/MOD
LEAF 6, "UM/MOD"
UMBYMOD:
	NOOP
;
;***** Subroutine Register Variables

#define drem16uL r14
#define drem16uH r15
#define dres16uL r16
#define dres16uH r17

#define dd16uL r16
#define dd16uH r17
#define dv16uL r18
#define dv16uH r19

#define dcnt16u r20

;
;    move operands
;
    movw r16, nds_low
    movw r18, tos_low
;
;***** Code

div16u: 
	clr wrk_low ;clear remainder Low byte
    sub wrk_high, wrk_high;clear remainder High byte and carry
    ldi r16,17 ;init loop counter
d16u_1: 
	rol nds_low ;shift left dividend
    rol nds_high
    dec r16 ;decrement counter
    brne d16u_2 ;if done
d16ures:
;
;    move operands
;
    movw nds_low, r16
    movw tos_low, r14
    rjmp CORE

d16u_2: 
	rol wrk_low ;shift dividend into remainder
    rol wrk_high
    sub wrk_low, tos_low ;remainder = remainder - divisor
    sbc wrk_high, tos_high ;
    brcc d16u_3 ;if result negative
    add wrk_low, tos_low ; restore remainder
    adc wrk_high, tos_high
    clc ; clear carry to be shifted into result
    rjmp d16u_1 ;else
d16u_3: sec ; set carry to be shifted into result
    rjmp d16u_1


;----------------------------------------------------------------------
;
;    "div16s" - 16/16 Bit Signed Division
;
; ok /
LEAF 1, "/"
SDIV:
;
;***** Subroutine Register Variables
;

#define drem16sL r14
#define drem16sH r15
#define dres16sL r16
#define dres16sH r17

#define dd16sL r16
#define dd16sH r17
#define dv16sL r18
#define dv16sH r19


#define dcnt16s r20

#define    d16s    r21

;
;    move operands
;
    movw r16, nds_low
    movw r18, tos_low
;
;***** Code
;
div16s: mov    d16s,dd16sH    ;move dividend High to sign register
    eor    d16s,dv16sH    ;xor divisor High with sign register
    sbrs    dd16sH,7    ;if MSB in dividend set
    rjmp    d16s_1
    com    dd16sH    ;    change sign of dividend
    com    dd16sL
    subi    dd16sL,lo8(-1)
    sbci    dd16sL,hi8(-1)
d16s_1: sbrs    dv16sH,7    ;if MSB in divisor set
    rjmp    d16s_2
    com    dv16sH    ;    change sign of divisor
    com    dv16sL
    subi    dv16sL,lo8(-1)
    sbci    dv16sL,hi8(-1)
d16s_2: clr    drem16sL    ;clear remainder Low byte
    sub    drem16sH,drem16sH;clear remainder High byte and carry
    ldi    dcnt16s,17     ;init loop counter

d16s_3: rol    dd16sL    ;shift left dividend
    rol    dd16sH
    dec    dcnt16s    ;decrement counter
    brne    d16s_5    ;if done
    sbrs    d16s,7    ;    if MSB in sign register set
    rjmp    d16s_4
    com    dres16sH    ;    change sign of result
    com    dres16sL
    subi    dres16sL,lo8(-1)
    sbci    dres16sH,hi8(-1)
d16s_4:      ;    return
d16sres:
    movw nds_low, r16
    movw tos_low, r14
    rjmp CORE

d16s_5: rol    drem16sL    ;shift dividend into remainder
    rol    drem16sH
    sub    drem16sL,dv16sL ;remainder = remainder - divisor
    sbc    drem16sH,dv16sH ;
    brcc    d16s_6    ;if result negative
    add    drem16sL,dv16sL ;    restore remainder
    adc    drem16sH,dv16sH
    clc     ;    clear carry to be shifted into result
    rjmp    d16s_3    ;else
d16s_6: sec     ;    set carry to be shifted into result
    rjmp    d16s_3

;----------------------------------------------------------------------
;
;* "mpy16s" - 16x16 Bit Signed Multiplication
; ok *
LEAF 1, "*"
SMUL:
;***** Subroutine Register Variables

#define mc16sL r16
#define mc16sH r17     
#define mp16sL r18     
#define mp16sH r19     

#define m16s0 r18    
#define m16s1 r19    
#define m16s2 r20     
#define m16s3 r21    

#define mcnt16s r22     

;
;    move operands
;
    movw r16, nds_low
    movw r18, tos_low
;
;***** Code
mpy16s: 
	clr  m16s3     		   	;clear result byte 3
    sub  m16s2, m16s2    	;clear result byte 2 and carry
    ldi  mcnt16s, 16     	;init loop counter
m16s_1: 
	brcc m16s_2    ;if carry (previous bit) set
    add  m16s2, mc16sL    ;    add multiplicand Low to result byte 2
    adc  m16s3, mc16sH    ;    add multiplicand High to result byte 3
m16s_2: 
	sbrc mp16sL, 0      	;if current bit set
    sub  m16s2,mc16sL     ;    sub multiplicand Low from result byte 2
    sbrc mp16sL, 0        ;if current bit set
    sbc  m16s3,mc16sH     ;    sub multiplicand High from result byte 3
    asr  m16s3            ;shift right result and multiplier
    ror  m16s2
    ror  m16s1
    ror  m16s0
    dec  mcnt16s    		;decrement counter
    brne m16s_1    		;if not done, loop more
m16sres:
    mov nds_low, r16
    rjmp CORE

;----------------------------------------------------------------------
;
; "mpy16u" - 16x16 Bit Unsigned Multiplication
;
; ok UM*
LEAF 3, "UM*"
UMUL:
;
;***** Subroutine Register Variables

#define mc16uL r16
#define mc16uH r17
#define mp16uL r18
#define mp16uH r19

#define m16u0 r18     
#define m16u1 r19     
#define m16u2 r20     
#define m16u3 r21     

#define mcnt16u r22     

;
;    move operands
;
    movw r16, nds_low
    movw r18, tos_low
;
;***** Code
;
mpy16u: clr wrk_high ;clear 2 highest bytes of result
    clr wrk_low
    ldi r16,16 ;init loop counter
    lsr tos_high
    ror tos_low

m16u_1: brcc noad8 ;if bit 0 of multiplier set
    add wrk_low,nds_low ;add multiplicand Low to byte 2 of res
    adc wrk_high,nds_high ;add multiplicand high to byte 3 of res
noad8: ror wrk_high ;shift right result byte 3
    ror wrk_low ;rotate right result byte 2
    ror r19 ;rotate result byte 1 and multiplier High
    ror r18 ;rotate result byte 0 and multiplier Low
    dec r16 ;decrement loop counter
    brne m16u_1 ;if not done, loop more
m16ures:
;
;    move operands
;
    movw nds_low, r18
    rjmp CORE

;----------------------------------------------------------------------

;----------------------------------------------------------------------
;*************************************************************************
;*     *
;*      Convert unsigned 16 bit to 5 digit ASCII    *
;*     *
;*    Author: Peter Dannegger     *
;*     *
;*************************************************************************
; https://www.avrfreaks.net/forum/smallest-and-fastest-binary-bcd-conversion?page=all
;
;
;input: R17, R16 = 16 bit value 0 ... 65535
;output: R20, R19, R18, R17, R16 = 5 digits (ASCII)
;cycle: 20 ... 170
;

bin16_ascii:

    ldi    r20, -1 + '0'
_bcd1:  inc    r20
    subi    r16, lo8(10000)    
    sbci    r17, hi8(10000)
    brcc    _bcd1

    ldi    r19, 10 + '0'
_bcd2:  dec    r19
    subi    r16, lo8(-1000)  
    sbci    r17, hi8(-1000)
    brcs    _bcd2

    ldi    r18, -1 + '0'
_bcd3:  inc    r18
    subi    r16, lo8(100)   
    sbci    r17, hi8(100)
    brcc    _bcd3

    ldi    r17, 10 + '0'
_bcd4:  dec    r17
    subi    r16, -10     
    brcs    _bcd4

    subi    r16, -'0'
    ret

