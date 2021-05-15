/*
;----------------------------------------------------------------------
;	https://www.avrfreaks.net/forum/dis-asm-dirty-math-tricks-adventures-division-ten?page=all
;   8bit / 10 ~~~
;	DIV10: MULI A, 26 ; response in R1
;-----------------------------------;
; RETRO (SYNTHETIC) DIVISION BY 10  ;
; ANSWER IN R1, R0=REM, A:PRESERVED ;
;-----------------------------------;
DIV10:  PUSH B
        LDI  B,26   ;MUL BY 26
        MUL  A,B    ;R1=A/10
        PUSH R1     ;BRUTE-FORCE CALC OF REMAINDER      
        LDI  B,10   ;CALC REM
        MUL  R1,B   ;R0=10xR1(QUOT)
        POP  R1     ;RESTORE QUOT
        SUB  R0,A   ;SUBTRACT REMx10
NODJST: NEG  R0     ;MAKE POSITIVE
         BRPL NONEG ;STILL NEG?
        ADD  R0,B   ;OOPS MAKE 
        DEC  R1     ;ADJUSTMENTS
NONEG:   RET

;----------------------------------------
; 8-bit division by 10 routine.
;
; the input number must be in register "input"
; value/10 is in register "result"
; register temp1 and R1:R0 are clobbered
div10:
	ldi temp1, 205
	mul temp1, input
	lsr R1
	lsr R1
	lsr R1
	mov result, R1
	ret
;----------------------------------------
; 8-bit division by 10 routine.
;
; Input: R0 = dividend.
; Output: R1 = result = dividend/10.
;
; Registers R0 and R16 are clobbered.
; 5 words/10 clocks including RET.
; 
div10:
	ldi	r16,205
	mul	r0,r16
	ldi	r16,32
	mul	r1,r16
	ret 
;----------------------------------------
*/

;----------------------------------------------------------------------
;
; 	great DJB hash, adapted for 16bits
;
; hash = (hash << 5) + str[i]
; for ascii chars in sram, in bytes not cells
; ( a u -- h ) djb hash
.equ djbHASH, 5381
HEADER "HASH", "HASH"
	NOOP
	ldi nds_low, lo8(djbHASH)
	ldi nds_high, hi8(djbHASH)
	pspull wrk_low, wrk_high
	pspull ips_low, ips_high
	; get a char
1:	srload tos_low
	add nds_low, tos_low
	adc nds_high, _zero_
	lsl nds_low
	rol nds_high
	lsl nds_low
	rol nds_high
	lsl nds_low
	rol nds_high
	lsl nds_low
	rol nds_high
	lsl nds_low
	rol nds_high
    ; decrease counter
	sbiw wrk_low, 1
	brge 1b
2:  pspush nds_low, nds_high
	POON

;----------------------------------------------------------------------
;
;	 ©2000-2021 by Gerhard Schmidt,
; 	 http://www.avr-asm-tutorial.net/avr_en/apps/random_tn13/random_calc_tn13.html
;
;    seed ~ 0x02A8
;
;	 also good seeds
;
;    B167 4A3C 9879 B61E 7B26 
;    A858 1F88 50D5 419D 5537
;    0224 0527 5EB6 1E6D BCDC
;    92FF C206 0ECD 9361 2823
;    BE0B B303 6462 0E4C 3D24
;
HEADER "RANDOM", "RANDOM"
	NOOP
;    load seed
    lds wrk_low, SEED
    lds wrk_high, SEED
;    run magics
    eor wrk_low, wrk_high
    swap wrk_low
    add wrk_high, wrk_low
;    save seed
	pspush wrk_low, wrk_high
_seed:
    sts SEED, wrk_low
    sts SEED + 1, wrk_high
    POON

;----------------------------------------------------------------------
;
; sets seed for rand
;
HEADER "RAND", "RAND"
	NOOP
	pspull wrk_low, wrk_high
	rjmp _seed
    
;----------------------------------------------------------------------
;
; 7FFF FFFF FFFF FFFF = 9.223.372.036.854.775.807
;----------------------------------------------------------------------
;
; adapted from AVR-200 
; "mpy16u" "- 16x16 Bit Unsigned Multiplication
;
; ok UM*
HEADER "UM*", "UMUL"
	NOOP
;
;    move operands
;
	pspull tos_low, tos_high	; pull multiplicand
	pspull nds_low, nds_high	; pull multiplier
;
;***** Code
;
mul16u: 
	ldi wrk_low, 16
	mov _work_, wrk_low 	;init loop counter
	sub wrk_low, wrk_low	;clear high result Low byte
    sub wrk_high, wrk_high	;clear high result High byte and carry

	; multiplier shift rigth
    lsr nds_high
    ror nds_low

m16u_1: 
	brcc noad8 				;if carry, bit 0, of multiplier set
    add wrk_low, tos_low 	;add multiplicand Low to byte 2 of res
    adc wrk_high, tos_high 	;add multiplicand high to byte 3 of res

noad8: 
	ror wrk_high 			;shift right result byte 3
    ror wrk_low 			;rotate right result byte 2
    ror nds_high			;rotate result byte 1 and multiplier High
    ror nds_low				;rotate result byte 0 and multiplier Low
    dec _work_ 				;decrement loop counter
    brne m16u_1 			;if not done, loop more

m16ures: 
m16result:	
	pspush wrk_low, wrk_high	; high bytes
    pspush nds_low, nds_high	; low bytes
    POON

;----------------------------------------------------------------------
;
; 	adapted from AVR-200 
;   "div16u" "- 16/16 Bit Unsigned Division
;
; ok UM/MOD
HEADER "UM/MOD", "UMBYMOD"
	NOOP
;
;    move operands
;
	pspull tos_low, tos_high	; pull divisor
	pspull nds_low, nds_high	; pull dividend
;
;***** Code

div16u: 
	ldi wrk_low, 17
	mov _work_, wrk_low 	;init loop counter
	sub wrk_low, wrk_low	;clear remainder Low byte
    sub wrk_high, wrk_high	;clear remainder High byte and carry

d16u_1: 
	rol nds_low 			;shift left dividend
    rol nds_high
    dec _work_ 				;decrement counter
    breq d16ures 			;if done

d16u_2: 
	rol wrk_low 			;shift dividend into remainder
    rol wrk_high
    sub wrk_low, tos_low 	;remainder = remainder - divisor
    sbc wrk_high, tos_high 	;
    brcc d16u_3 			;if result negative
    add wrk_low, tos_low 	; restore remainder
    adc wrk_high, tos_high
    clc 					; clear carry to be shifted into result
    rjmp d16u_1 			;else
d16u_3: 
	sec 			 		; set carry to be shifted into result
    rjmp d16u_1

d16ures:
	rjmp m16result

;----------------------------------------------------------------------
;
; 	adapted from AVR-200 
; 	"mpy16s" "- 16x16 Bit Signed Multiplication
; ok *
HEADER "*", "SMUL"
	NOOP
;
;***** Code
;
;    move operands
;
    pspull tos_low, tos_high        ; pull multiplicand
    pspull nds_low, nds_high        ; pull multiplier
;
;***** Code
mpy16s: 
    ldi wrk_low, 16
    mov _work_, wrk_low     ;init loop counter
    sub wrk_low, wrk_low    ;clear high result Low byte
    sub wrk_high, wrk_high  ;clear high result High byte and carry

m16s_1: 
	brcc m16s_2    			;if carry (previous bit) set
    add  wrk_low, tos_low   ;    add multiplicand Low to result byte 2
    adc  wrk_high, tos_high ;    add multiplicand High to result byte 3
m16s_2: 
	sbrc nds_low, 0      	;if current bit set
    sub  wrk_low, tos_low   ;    sub multiplicand Low from result byte 2
    sbrc nds_low, 0        	;if current bit set
    sbc  wrk_high, tos_high ;    sub multiplicand High from result byte 3
    asr  wrk_high           ;shift right result and multiplier
    ror  wrk_low
    ror  nds_high
    ror  nds_low
    dec  _work_	    		;decrement counter
    brne m16s_1				;if not done, loop more

m16sres:
	rjmp m16result

;----------------------------------------------------------------------
;
; 	adapted from AVR-200 
;   "div16s" "- 16/16 Bit Signed Division
;
; ok /
HEADER "/", "SDIV"
	NOOP
;
;***** Subroutine Register Variables
;
;    move operands
;
    pspull tos_low, tos_high        ; pull divisor
    pspull nds_low, nds_high        ; pull dividend
;
;***** Code
;
div16s: 
	mov    _work_, nds_high   ;move dividend High to sign register
    eor    _work_, tos_high   ;xor divisor High with sign register
	bst _work_, 7	  		  ;save it, but could be BST

d16s_0:
    sbrs   nds_high, 7  		;if MSB in dividend set
    rjmp   d16s_1
    
	com    nds_high    		;    change sign of dividend
    com    nds_low
    subi   nds_low, lo8(-1)
    sbci   nds_low, hi8(-1)

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
	rol    nds_low    ;shift left dividend
    rol    nds_high
    dec    _work_     ;decrement counter
    brne    d16s_5    ;if done

	bld _work_, 7	  	 ;save it, but could be BST
    sbrs    _work_, 7    ;    if MSB in sign register set
    rjmp    d16sres
    com    nds_high      ;    change sign of result
    com    nds_low
    subi   nds_low,lo8(-1)
    sbci   nds_high,hi8(-1)

d16sres:
	rjmp m16result

d16s_5: 
	rol    wrk_low    ;shift dividend into remainder
    rol    wrk_high
    sub    wrk_low, tos_low ;remainder = remainder - divisor
    sbc    wrk_high, tos_high ;
    brcc    d16s_6    ;if result negative

    add    wrk_low, tos_low ;    restore remainder
    adc    wrk_high, tos_high
    clc     ;    clear carry to be shifted into result
    rjmp    d16s_3    ;else
d16s_6: 
	sec     ;    set carry to be shifted into result
    rjmp    d16s_3

;----------------------------------------------------------------------
; 
;   by Peter Dannegger 
; 	https://www.avrfreaks.net/forum/smallest-and-fastest-binary-bcd-conversion?page=all
;
; input 16 bit value 0 ... 65535
; output  5 digits (ASCII)
;
HEADER "utoa", "utoa" 
	NOOP

	ldi ips_low, lo8(PAD)
	ldi ips_high, hi8(PAD)
	movw nds_low, ips_low
	pspull wrk_low, wrk_high
	
itoa:

    ldi tos_low, -1 + '0'
1:  inc tos_low
    subi wrk_low, lo8(10000)    
    sbci wrk_high, hi8(10000)
    brcc 1b
	st	Z+, wrk_low

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

	pspush nds_low, nds_high
	POON

