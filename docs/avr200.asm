;**** A P P L I C A T I O N   N O T E   A V R 2 0 0 ************************
;*
;* Title:		Multiply and Divide Routines
;* Version:		1.1
;* Last updated:	97.07.04
;* Target:		AT90Sxxxx (All AVR Devices)
;*
;* Support E-mail:	avr@atmel.com
;* 
;* DESCRIPTION
;* This Application Note lists subroutines for the following
;* Muliply/Divide applications:
;*
;* 8x8 bit unsigned
;* 8x8 bit signed
;* 16x16 bit unsigned
;* 16x16 bit signed
;* 8/8 bit unsigned
;* 8/8 bit signed
;* 16/16 bit unsigned
;* 16/16 bit signed
;*
;* All routines are Code Size optimized implementations
;*
;***************************************************************************

.include "1200def.inc"

	rjmp	RESET	;reset handle


;***************************************************************************
;*
;* "mpy8u" - 8x8 Bit Unsigned Multiplication
;*
;* This subroutine multiplies the two register variables mp8u and mc8u.
;* The result is placed in registers m8uH, m8uL
;*  
;* Number of words	:9 + return
;* Number of cycles	:58 + return
;* Low registers used	:None
;* High registers used  :4 (mp8u,mc8u/m8uL,m8uH,mcnt8u)	
;*
;* Note: Result Low byte and the multiplier share the same register.
;* This causes the multiplier to be overwritten by the result.
;*
;***************************************************************************

;***** Subroutine Register Variables

.def	mc8u	=r16		;multiplicand
.def	mp8u	=r17		;multiplier
.def	m8uL	=r17		;result Low byte
.def	m8uH	=r18		;result High byte
.def	mcnt8u	=r19		;loop counter

;***** Code


mpy8u:	clr	m8uH		;clear result High byte
	ldi	mcnt8u,8	;init loop counter
	lsr	mp8u		;rotate multiplier
	
m8u_1:	brcc	m8u_2		;carry set 
	add 	m8uH,mc8u	;   add multiplicand to result High byte
m8u_2:	ror	m8uH		;rotate right result High byte
	ror	m8uL		;rotate right result L byte and multiplier
	dec	mcnt8u		;decrement loop counter
	brne	m8u_1		;if not done, loop more
	ret




;***************************************************************************
;*
;* "mpy8s" - 8x8 Bit Signed Multiplication
;*
;* This subroutine multiplies signed the two register variables mp8s and 
;* mc8s. The result is placed in registers m8sH, m8sL
;* The routine is an implementation of Booth's algorithm. If all 16 bits
;* in the result are needed, avoid calling the routine with
;* -128 ($80) as multiplicand
;*  
;* Number of words	:10 + return
;* Number of cycles	:73 + return
;* Low registers used	:None
;* High registers used  :4 (mc8s,mp8s/m8sL,m8sH,mcnt8s)	
;*
;***************************************************************************

;***** Subroutine Register Variables

.def	mc8s	=r16		;multiplicand
.def	mp8s	=r17		;multiplier
.def	m8sL	=r17		;result Low byte
.def	m8sH	=r18		;result High byte
.def	mcnt8s	=r19		;loop counter

;***** Code

mpy8s:	sub	m8sH,m8sH	;clear result High byte and carry
	ldi	mcnt8s,8	;init loop counter
m8s_1:	brcc	m8s_2		;if carry (previous bit) set
	add	m8sH,mc8s	;    add multiplicand to result High byte
m8s_2:	sbrc	mp8s,0		;if current bit set
	sub	m8sH,mc8s	;    subtract multiplicand from result High
	asr	m8sH		;shift right result High byte
	ror	m8sL		;shift right result L byte and multiplier
	dec	mcnt8s		;decrement loop counter
	brne	m8s_1		;if not done, loop more
	ret



;***************************************************************************
;*
;* "mpy16u" - 16x16 Bit Unsigned Multiplication
;*
;* This subroutine multiplies the two 16-bit register variables 
;* mp16uH:mp16uL and mc16uH:mc16uL.
;* The result is placed in m16u3:m16u2:m16u1:m16u0.
;*  
;* Number of words	:14 + return
;* Number of cycles	:153 + return
;* Low registers used	:None
;* High registers used  :7 (mp16uL,mp16uH,mc16uL/m16u0,mc16uH/m16u1,m16u2,
;*                          m16u3,mcnt16u)	
;*
;***************************************************************************

;***** Subroutine Register Variables

.def	mc16uL	=r16		;multiplicand low byte
.def	mc16uH	=r17		;multiplicand high byte
.def	mp16uL	=r18		;multiplier low byte
.def	mp16uH	=r19		;multiplier high byte
.def	m16u0	=r18		;result byte 0 (LSB)
.def	m16u1	=r19		;result byte 1
.def	m16u2	=r20		;result byte 2
.def	m16u3	=r21		;result byte 3 (MSB)
.def	mcnt16u	=r22		;loop counter

;***** Code

mpy16u:	clr	m16u3		;clear 2 highest bytes of result
	clr	m16u2
	ldi	mcnt16u,16	;init loop counter
	lsr	mp16uH
	ror	mp16uL

m16u_1:	brcc	noad8		;if bit 0 of multiplier set
	add	m16u2,mc16uL	;add multiplicand Low to byte 2 of res
	adc	m16u3,mc16uH	;add multiplicand high to byte 3 of res
noad8:	ror	m16u3		;shift right result byte 3
	ror	m16u2		;rotate right result byte 2
	ror	m16u1		;rotate result byte 1 and multiplier High
	ror	m16u0		;rotate result byte 0 and multiplier Low
	dec	mcnt16u		;decrement loop counter
	brne	m16u_1		;if not done, loop more
	ret



;***************************************************************************
;*
;* "mpy16s" - 16x16 Bit Signed Multiplication
;*
;* This subroutine multiplies signed the two 16-bit register variables 
;* mp16sH:mp16sL and mc16sH:mc16sL.
;* The result is placed in m16s3:m16s2:m16s1:m16s0.
;* The routine is an implementation of Booth's algorithm. If all 32 bits
;* in the result are needed, avoid calling the routine with
;* -32768 ($8000) as multiplicand
;*  
;* Number of words	:16 + return
;* Number of cycles	:210/226 (Min/Max) + return
;* Low registers used	:None
;* High registers used  :7 (mp16sL,mp16sH,mc16sL/m16s0,mc16sH/m16s1,
;*			    m16s2,m16s3,mcnt16s)	
;*
;***************************************************************************

;***** Subroutine Register Variables

.def	mc16sL	=r16		;multiplicand low byte
.def	mc16sH	=r17		;multiplicand high byte
.def	mp16sL	=r18		;multiplier low byte
.def	mp16sH	=r19		;multiplier high byte
.def	m16s0	=r18		;result byte 0 (LSB)
.def	m16s1	=r19		;result byte 1
.def	m16s2	=r20		;result byte 2
.def	m16s3	=r21		;result byte 3 (MSB)
.def	mcnt16s	=r22		;loop counter

;***** Code
mpy16s:	clr	m16s3		;clear result byte 3
	sub	m16s2,m16s2	;clear result byte 2 and carry
	ldi	mcnt16s,16	;init loop counter
m16s_1:	brcc	m16s_2		;if carry (previous bit) set
	add	m16s2,mc16sL	;    add multiplicand Low to result byte 2
	adc	m16s3,mc16sH	;    add multiplicand High to result byte 3
m16s_2:	sbrc	mp16sL,0	;if current bit set
	sub	m16s2,mc16sL	;    sub multiplicand Low from result byte 2
	sbrc	mp16sL,0	;if current bit set
	sbc	m16s3,mc16sH	;    sub multiplicand High from result byte 3
	asr	m16s3		;shift right result and multiplier
	ror	m16s2
	ror	m16s1
	ror	m16s0
	dec	mcnt16s		;decrement counter
	brne	m16s_1		;if not done, loop more	
	ret



;***************************************************************************
;*
;* "div8u" - 8/8 Bit Unsigned Division
;*
;* This subroutine divides the two register variables "dd8u" (dividend) and 
;* "dv8u" (divisor). The result is placed in "dres8u" and the remainder in
;* "drem8u".
;*  
;* Number of words	:14
;* Number of cycles	:97
;* Low registers used	:1 (drem8u)
;* High registers used  :3 (dres8u/dd8u,dv8u,dcnt8u)
;*
;***************************************************************************

;***** Subroutine Register Variables

.def	drem8u	=r15		;remainder
.def	dres8u	=r16		;result
.def	dd8u	=r16		;dividend
.def	dv8u	=r17		;divisor
.def	dcnt8u	=r18		;loop counter

;***** Code

div8u:	sub	drem8u,drem8u	;clear remainder and carry
	ldi	dcnt8u,9	;init loop counter
d8u_1:	rol	dd8u		;shift left dividend
	dec	dcnt8u		;decrement counter
	brne	d8u_2		;if done
	ret			;    return
d8u_2:	rol	drem8u		;shift dividend into remainder
	sub	drem8u,dv8u	;remainder = remainder - divisor
	brcc	d8u_3		;if result negative
	add	drem8u,dv8u	;    restore remainder
	clc			;    clear carry to be shifted into result
	rjmp	d8u_1		;else
d8u_3:	sec			;    set carry to be shifted into result
	rjmp	d8u_1



;***************************************************************************
;*
;* "div8s" - 8/8 Bit Signed Division
;*
;* This subroutine divides the two register variables "dd8s" (dividend) and 
;* "dv8s" (divisor). The result is placed in "dres8s" and the remainder in
;* "drem8s".
;*  
;* Number of words	:22
;* Number of cycles	:103
;* Low registers used	:2 (d8s,drem8s)
;* High registers used  :3 (dres8s/dd8s,dv8s,dcnt8s)
;*
;***************************************************************************

;***** Subroutine Register Variables

.def	d8s	=r14		;sign register
.def	drem8s	=r15		;remainder
.def	dres8s	=r16		;result
.def	dd8s	=r16		;dividend
.def	dv8s	=r17		;divisor
.def	dcnt8s	=r18		;loop counter

;***** Code

div8s:	mov	d8s,dd8s	;move dividend to sign register
	eor	d8s,dv8s	;xor sign with divisor
	sbrc	dv8s,7		;if MSB of divisor set
	neg	dv8s		;    change sign of divisor
	sbrc	dd8s,7		;if MSB of dividend set
	neg	dd8s		;    change sign of divisor
	sub	drem8s,drem8s	;clear remainder and carry
	ldi	dcnt8s,9	;init loop counter
d8s_1:	rol	dd8s		;shift left dividend
	dec	dcnt8s		;decrement counter
	brne	d8s_2		;if done
	sbrc	d8s,7		;    if MSB of sign register set
	neg	dres8s		;        change sign of result
	ret			;    return
d8s_2:	rol	drem8s		;shift dividend into remainder
	sub	drem8s,dv8s	;remainder = remainder - divisor
	brcc	d8s_3		;if result negative
	add	drem8s,dv8s	;    restore remainder
	clc			;    clear carry to be shifted into result			
	rjmp	d8s_1		;else
d8s_3:	sec			;    set carry to be shifted into result
	rjmp	d8s_1


	
;***************************************************************************
;*
;* "div16u" - 16/16 Bit Unsigned Division
;*
;* This subroutine divides the two 16-bit numbers 
;* "dd8uH:dd8uL" (dividend) and "dv16uH:dv16uL" (divisor). 
;* The result is placed in "dres16uH:dres16uL" and the remainder in
;* "drem16uH:drem16uL".
;*  
;* Number of words	:19
;* Number of cycles	:235/251 (Min/Max)
;* Low registers used	:2 (drem16uL,drem16uH)
;* High registers used  :5 (dres16uL/dd16uL,dres16uH/dd16uH,dv16uL,dv16uH,
;*			    dcnt16u)
;*
;***************************************************************************

;***** Subroutine Register Variables

.def	drem16uL=r14
.def	drem16uH=r15
.def	dres16uL=r16
.def	dres16uH=r17
.def	dd16uL	=r16
.def	dd16uH	=r17
.def	dv16uL	=r18
.def	dv16uH	=r19
.def	dcnt16u	=r20

;***** Code

div16u:	clr	drem16uL	;clear remainder Low byte
	sub	drem16uH,drem16uH;clear remainder High byte and carry
	ldi	dcnt16u,17	;init loop counter
d16u_1:	rol	dd16uL		;shift left dividend
	rol	dd16uH
	dec	dcnt16u		;decrement counter
	brne	d16u_2		;if done
	ret			;    return
d16u_2:	rol	drem16uL	;shift dividend into remainder
	rol	drem16uH
	sub	drem16uL,dv16uL	;remainder = remainder - divisor
	sbc	drem16uH,dv16uH	;
	brcc	d16u_3		;if result negative
	add	drem16uL,dv16uL	;    restore remainder
	adc	drem16uH,dv16uH
	clc			;    clear carry to be shifted into result
	rjmp	d16u_1		;else
d16u_3:	sec			;    set carry to be shifted into result
	rjmp	d16u_1
	
	

;***************************************************************************
;*
;* "div16s" - 16/16 Bit Signed Division
;*
;* This subroutine divides signed the two 16 bit numbers 
;* "dd16sH:dd16sL" (dividend) and "dv16sH:dv16sL" (divisor). 
;* The result is placed in "dres16sH:dres16sL" and the remainder in
;* "drem16sH:drem16sL".
;*  
;* Number of words	:39
;* Number of cycles	:247/263 (Min/Max)
;* Low registers used	:3 (d16s,drem16sL,drem16sH)
;* High registers used  :7 (dres16sL/dd16sL,dres16sH/dd16sH,dv16sL,dv16sH,
;*			    dcnt16sH)
;*
;***************************************************************************

;***** Subroutine Register Variables

.def	d16s	=r13		;sign register
.def	drem16sL=r14		;remainder low byte		
.def	drem16sH=r15		;remainder high byte
.def	dres16sL=r16		;result low byte
.def	dres16sH=r17		;result high byte
.def	dd16sL	=r16		;dividend low byte
.def	dd16sH	=r17		;dividend high byte
.def	dv16sL	=r18		;divisor low byte
.def	dv16sH	=r19		;divisor high byte
.def	dcnt16s	=r20		;loop counter

;***** Code

div16s:	mov	d16s,dd16sH	;move dividend High to sign register
	eor	d16s,dv16sH	;xor divisor High with sign register
	sbrs	dd16sH,7	;if MSB in dividend set
	rjmp	d16s_1
	com	dd16sH		;    change sign of dividend
	com	dd16sL		
	subi	dd16sL,low(-1)
	sbci	dd16sL,high(-1)
d16s_1:	sbrs	dv16sH,7	;if MSB in divisor set
	rjmp	d16s_2
	com	dv16sH		;    change sign of divisor
	com	dv16sL		
	subi	dv16sL,low(-1)
	sbci	dv16sH,high(-1)
d16s_2:	clr	drem16sL	;clear remainder Low byte
	sub	drem16sH,drem16sH;clear remainder High byte and carry
	ldi	dcnt16s,17	;init loop counter

d16s_3:	rol	dd16sL		;shift left dividend
	rol	dd16sH
	dec	dcnt16s		;decrement counter
	brne	d16s_5		;if done
	sbrs	d16s,7		;    if MSB in sign register set
	rjmp	d16s_4
	com	dres16sH	;        change sign of result
	com	dres16sL
	subi	dres16sL,low(-1)
	sbci	dres16sH,high(-1)
d16s_4:	ret			;    return
d16s_5:	rol	drem16sL	;shift dividend into remainder
	rol	drem16sH
	sub	drem16sL,dv16sL	;remainder = remainder - divisor
	sbc	drem16sH,dv16sH	;
	brcc	d16s_6		;if result negative
	add	drem16sL,dv16sL	;    restore remainder
	adc	drem16sH,dv16sH
	clc			;    clear carry to be shifted into result
	rjmp	d16s_3		;else
d16s_6:	sec			;    set carry to be shifted into result
	rjmp	d16s_3



;****************************************************************************
;*
;* Test Program
;*
;* This program calls all the subroutines as an example of usage and to 
;* verify correct verification.
;*
;****************************************************************************

;***** Main Program Register variables

.def	temp	=r16		;temporary storage variable

;***** Code
RESET:
;---------------------------------------------------------------
;Include these lines for devices with SRAM
;	ldi	temp,low(RAMEND)
;	out	SPL,temp	
;	ldi	temp,high(RAMEND)
;	out	SPH,temp	;init Stack Pointer
;---------------------------------------------------------------

;***** Multiply Two Unsigned 8-Bit Numbers (250 * 4)

	ldi	mc8u,250
	ldi	mp8u,4
	rcall	mpy8u		;result: m8uH:m8uL = $03e8 (1000)

;***** Multiply Two Signed 8-Bit Numbers (-99 * 88)
	ldi	mc8s,-99
	ldi	mp8s,88
	rcall	mpy8s		;result: m8sH:m8sL = $ddf8 (-8712)

;***** Multiply Two Unsigned 16-Bit Numbers (5050 * 10,000)
	ldi	mc16uL,low(5050)
	ldi	mc16uH,high(5050)
	ldi	mp16uL,low(10000)
	ldi	mp16uH,high(10000)
	rcall	mpy16u		;result: m16u3:m16u2:m16u1:m16u0
				;=030291a0 (50,500,000)
	
;***** Multiply Two Signed 16-Bit Numbers (-12345*(-4321))
	ldi	mc16sL,low(-12345)
	ldi	mc16sH,high(-12345)
	ldi	mp16sL,low(-4321)
	ldi	mp16sH,high(-4321)
	rcall	mpy16s		;result: m16s3:m16s2:m16s1:m16s0
				;=$032df219 (53,342,745)

;***** Divide Two Unsigned 8-Bit Numbers (100/3)
	ldi	dd8u,100
	ldi	dv8u,3
	rcall	div8u		;result: 	$21 (33)
				;remainder:	$01 (1)

;***** Divide Two Signed 8-Bit Numbers (-110/-11)
	ldi	dd8s,-110
	ldi	dv8s,-11
	rcall	div8s		;result:	$0a (10)
				;remainder	$00 (0)


;***** Divide Two Unsigned 16-Bit Numbers (50,000/60,000)
	ldi	dd16uL,low(50000)
	ldi	dd16uH,high(50000)
	ldi	dv16uL,low(60000)
	ldi	dv16uH,high(60000)
	rcall	div16u		;result:	$0000 (0)
				;remainder:	$c350 (50,000)


;***** Divide Two Signed 16-Bit Numbers (-22,222/10)
	ldi	dd16sL,low(-22222)
	ldi	dd16sH,high(-22222)
	ldi	dv16sL,low(10)
	ldi	dv16sH,high(10)
	rcall	div16s		;result:	$f752 (-2222)
				;remainder:	$0002 (2)

forever:rjmp	forever


