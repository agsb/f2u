	.file	"optiboot_flash.c"
__SP_H__ = 0x3e
__SP_L__ = 0x3d
__SREG__ = 0x3f
__tmp_reg__ = 0
__zero_reg__ = 1
.global	optiboot_version
	.section	.version,"a",@progbits
	.type	optiboot_version, @object
	.size	optiboot_version, 2
optiboot_version:
	.word	1792
	.section	.init8,"ax",@progbits
.global	pre_main
	.type	pre_main, @function
pre_main:
/* prologue: naked */
/* frame size = 0 */
/* stack size = 0 */
.L__stack_usage = 0
/* #APP */
 ;  461 "optiboot_flash.c" 1
	 rjmp 1f
 rjmp do_spm
1:

 ;  0 "" 2
/* #NOAPP */
	nop
/* epilogue start */
	.size	pre_main, .-pre_main
	.section	.init9,"ax",@progbits
.global	main
	.type	main, @function
main:
	in r28,__SP_L__
	in r29,__SP_H__
	sbiw r28,7
	out __SP_H__,r29
	out __SP_L__,r28
/* prologue: function */
/* frame size = 7 */
/* stack size = 7 */
.L__stack_usage = 7
/* #APP */
 ;  494 "optiboot_flash.c" 1
	clr __zero_reg__
 ;  0 "" 2
/* #NOAPP */
	ldi r24,lo8(84)
	ldi r25,0
	movw r30,r24
	ld r24,Z
	std Y+3,r24
	ldi r24,lo8(97)
	ldi r25,0
	ldi r18,lo8(-128)
	movw r30,r24
	st Z,r18
	ldi r24,lo8(97)
	ldi r25,0
	movw r30,r24
	st Z,__zero_reg__
	ldd r24,Y+3
	tst r24
	breq .L3
	ldd r24,Y+3
	mov r24,r24
	ldi r25,0
	andi r24,10
	clr r25
	sbiw r24,2
	breq .L3
	ldd r24,Y+3
	mov r24,r24
	ldi r25,0
	andi r24,2
	clr r25
	or r24,r25
	breq .L4
	ldi r24,lo8(84)
	ldi r25,0
	ldi r18,lo8(-9)
	movw r30,r24
	st Z,r18
.L4:
	ldd r24,Y+3
/* #APP */
 ;  558 "optiboot_flash.c" 1
	mov r2, r24

 ;  0 "" 2
/* #NOAPP */
	ldi r24,0
	call watchdogConfig
/* #APP */
 ;  564 "optiboot_flash.c" 1
	rjmp optiboot_version+2

 ;  0 "" 2
/* #NOAPP */
.L3:
	ldi r24,lo8(-127)
	ldi r25,0
	ldi r18,lo8(5)
	movw r30,r24
	st Z,r18
	ldi r24,lo8(-64)
	ldi r25,0
	ldi r18,lo8(2)
	movw r30,r24
	st Z,r18
	ldi r24,lo8(-63)
	ldi r25,0
	ldi r18,lo8(24)
	movw r30,r24
	st Z,r18
	ldi r24,lo8(-60)
	ldi r25,0
	ldi r18,lo8(16)
	movw r30,r24
	st Z,r18
	ldi r24,lo8(-62)
	ldi r25,0
	ldi r18,lo8(6)
	movw r30,r24
	st Z,r18
	ldi r24,lo8(14)
	call watchdogConfig
	ldi r24,lo8(36)
	ldi r25,0
	ldi r18,lo8(36)
	ldi r19,0
	movw r30,r18
	ld r18,Z
	ori r18,lo8(32)
	movw r30,r24
	st Z,r18
	ldi r24,lo8(4)
	call flash_led
.L19:
	call getch
	std Y+3,r24
	ldd r24,Y+3
	cpi r24,lo8(65)
	brne .L5
	call getch
	std Y+4,r24
	call verifySpace
	ldd r24,Y+4
	cpi r24,lo8(-126)
	brne .L6
	ldi r24,0
	ldi r25,lo8(7)
	call putch
	rjmp .L9
.L6:
	ldd r24,Y+4
	cpi r24,lo8(-127)
	brne .L8
	ldi r24,0
	ldi r25,lo8(7)
	mov r24,r25
	clr r25
	call putch
	rjmp .L9
.L8:
	ldi r24,lo8(3)
	call putch
	rjmp .L9
.L5:
	ldd r24,Y+3
	cpi r24,lo8(66)
	brne .L10
	ldi r24,lo8(20)
	call getNch
	rjmp .L9
.L10:
	ldd r24,Y+3
	cpi r24,lo8(69)
	brne .L11
	ldi r24,lo8(5)
	call getNch
	rjmp .L9
.L11:
	ldd r24,Y+3
	cpi r24,lo8(85)
	brne .L12
	call getch
	mov r14,r24
	call getch
	mov r15,r24
	movw r24,r14
	lsl r24
	rol r25
	movw r14,r24
	call verifySpace
	rjmp .L9
.L12:
	ldd r24,Y+3
	cpi r24,lo8(86)
	brne .L13
	ldi r24,lo8(4)
	call getNch
	ldi r24,0
	call putch
	rjmp .L9
.L13:
	ldd r24,Y+3
	cpi r24,lo8(100)
	brne .L14
	call getch
	call getch
	mov r13,r24
	std Y+5,r13
	call getch
	std Y+6,r24
	lds r24,buff
	lds r25,buff+1
	std Y+2,r25
	std Y+1,r24
.L15:
	ldd r16,Y+1
	ldd r17,Y+2
	movw r24,r16
	adiw r24,1
	std Y+2,r25
	std Y+1,r24
	call getch
	movw r30,r16
	st Z,r24
	dec r13
	tst r13
	brne .L15
	call verifySpace
	ldd r19,Y+6
	lds r24,buff
	lds r25,buff+1
	ldd r18,Y+5
	movw r20,r14
	movw r22,r24
	mov r24,r19
	call writebuffer
	rjmp .L9
.L14:
	ldd r24,Y+3
	cpi r24,lo8(116)
	brne .L16
	call getch
	call getch
	mov r13,r24
	call getch
	std Y+7,r24
	call verifySpace
	mov r20,r13
	movw r22,r14
	ldd r24,Y+7
	call read_mem
	rjmp .L9
.L16:
	ldd r24,Y+3
	cpi r24,lo8(117)
	brne .L17
	call verifySpace
	ldi r24,lo8(30)
	call putch
	ldi r24,lo8(-107)
	call putch
	ldi r24,lo8(20)
	call putch
	rjmp .L9
.L17:
	ldd r24,Y+3
	cpi r24,lo8(81)
	brne .L18
	ldi r24,lo8(8)
	call watchdogConfig
	call verifySpace
	rjmp .L9
.L18:
	call verifySpace
.L9:
	ldi r24,lo8(16)
	call putch
	rjmp .L19
	.size	main, .-main
	.data
	.type	buff, @object
	.size	buff, 2
buff:
	.word	256
	.text
.global	putch
	.type	putch, @function
putch:
	push r28
	push r29
	push __zero_reg__
	in r28,__SP_L__
	in r29,__SP_H__
/* prologue: function */
/* frame size = 1 */
/* stack size = 3 */
.L__stack_usage = 3
	std Y+1,r24
	nop
.L21:
	ldi r24,lo8(-64)
	ldi r25,0
	movw r30,r24
	ld r24,Z
	mov r24,r24
	ldi r25,0
	andi r24,32
	clr r25
	or r24,r25
	breq .L21
	ldi r24,lo8(-58)
	ldi r25,0
	ldd r18,Y+1
	movw r30,r24
	st Z,r18
	nop
/* epilogue start */
	pop __tmp_reg__
	pop r29
	pop r28
	ret
	.size	putch, .-putch
.global	getch
	.type	getch, @function
getch:
	push r28
	push r29
	push __zero_reg__
	in r28,__SP_L__
	in r29,__SP_H__
/* prologue: function */
/* frame size = 1 */
/* stack size = 3 */
.L__stack_usage = 3
	nop
.L23:
	ldi r24,lo8(-64)
	ldi r25,0
	movw r30,r24
	ld r24,Z
	tst r24
	brge .L23
	ldi r24,lo8(-64)
	ldi r25,0
	movw r30,r24
	ld r24,Z
	mov r24,r24
	ldi r25,0
	andi r24,16
	clr r25
	or r24,r25
	brne .L24
	call watchdogReset
.L24:
	ldi r24,lo8(-58)
	ldi r25,0
	movw r30,r24
	ld r24,Z
	std Y+1,r24
	ldd r24,Y+1
/* epilogue start */
	pop __tmp_reg__
	pop r29
	pop r28
	ret
	.size	getch, .-getch
	.type	getNch, @function
getNch:
	push r28
	push r29
	push __zero_reg__
	in r28,__SP_L__
	in r29,__SP_H__
/* prologue: function */
/* frame size = 1 */
/* stack size = 3 */
.L__stack_usage = 3
	std Y+1,r24
.L27:
	call getch
	ldd r24,Y+1
	subi r24,lo8(-(-1))
	std Y+1,r24
	ldd r24,Y+1
	tst r24
	brne .L27
	call verifySpace
	nop
/* epilogue start */
	pop __tmp_reg__
	pop r29
	pop r28
	ret
	.size	getNch, .-getNch
.global	verifySpace
	.type	verifySpace, @function
verifySpace:
	push r28
	push r29
	in r28,__SP_L__
	in r29,__SP_H__
/* prologue: function */
/* frame size = 0 */
/* stack size = 2 */
.L__stack_usage = 2
	call getch
	cpi r24,lo8(32)
	breq .L29
	ldi r24,lo8(8)
	call watchdogConfig
.L30:
	rjmp .L30
.L29:
	ldi r24,lo8(20)
	call putch
	nop
/* epilogue start */
	pop r29
	pop r28
	ret
	.size	verifySpace, .-verifySpace
	.type	flash_led, @function
flash_led:
	push r28
	push r29
	push __zero_reg__
	in r28,__SP_L__
	in r29,__SP_H__
/* prologue: function */
/* frame size = 1 */
/* stack size = 3 */
.L__stack_usage = 3
	std Y+1,r24
.L35:
	ldi r24,lo8(-124)
	ldi r25,0
	ldi r18,lo8(48)
	ldi r19,lo8(-4)
	movw r30,r24
	std Z+1,r19
	st Z,r18
	ldi r24,lo8(54)
	ldi r25,0
	ldi r18,lo8(1)
	movw r30,r24
	st Z,r18
	nop
.L32:
	ldi r24,lo8(54)
	ldi r25,0
	movw r30,r24
	ld r24,Z
	mov r24,r24
	ldi r25,0
	andi r24,1
	clr r25
	or r24,r25
	breq .L32
	ldi r24,lo8(35)
	ldi r25,0
	ldi r18,lo8(35)
	ldi r19,0
	movw r30,r18
	ld r18,Z
	ori r18,lo8(32)
	movw r30,r24
	st Z,r18
	call watchdogReset
	ldi r24,lo8(-64)
	ldi r25,0
	movw r30,r24
	ld r24,Z
	tst r24
	brlt .L36
	ldd r24,Y+1
	subi r24,lo8(-(-1))
	std Y+1,r24
	ldd r24,Y+1
	tst r24
	brne .L35
	rjmp .L34
.L36:
	nop
.L34:
	nop
/* epilogue start */
	pop __tmp_reg__
	pop r29
	pop r28
	ret
	.size	flash_led, .-flash_led
	.type	watchdogReset, @function
watchdogReset:
	push r28
	push r29
	in r28,__SP_L__
	in r29,__SP_H__
/* prologue: function */
/* frame size = 0 */
/* stack size = 2 */
.L__stack_usage = 2
/* #APP */
 ;  986 "optiboot_flash.c" 1
	wdr

 ;  0 "" 2
/* #NOAPP */
	nop
/* epilogue start */
	pop r29
	pop r28
	ret
	.size	watchdogReset, .-watchdogReset
.global	watchdogConfig
	.type	watchdogConfig, @function
watchdogConfig:
	push r28
	push r29
	push __zero_reg__
	in r28,__SP_L__
	in r29,__SP_H__
/* prologue: function */
/* frame size = 1 */
/* stack size = 3 */
.L__stack_usage = 3
	std Y+1,r24
	ldi r24,lo8(96)
	ldi r25,0
	ldi r18,lo8(24)
	movw r30,r24
	st Z,r18
	ldi r24,lo8(96)
	ldi r25,0
	ldd r18,Y+1
	movw r30,r24
	st Z,r18
	nop
/* epilogue start */
	pop __tmp_reg__
	pop r29
	pop r28
	ret
	.size	watchdogConfig, .-watchdogConfig
	.type	writebuffer, @function
writebuffer:
	push r28
	push r29
	in r28,__SP_L__
	in r29,__SP_H__
	sbiw r28,8
	in __tmp_reg__,__SREG__
	cli
	out __SP_H__,r29
	out __SREG__,__tmp_reg__
	out __SP_L__,r28
/* prologue: function */
/* frame size = 8 */
/* stack size = 10 */
.L__stack_usage = 10
	std Y+3,r24
	std Y+5,r23
	std Y+4,r22
	std Y+7,r21
	std Y+6,r20
	std Y+8,r18
	ldd r24,Y+3
	mov __tmp_reg__,r24
	lsl r0
	sbc r25,r25
	cpi r24,69
	cpc r25,__zero_reg__
	brne .L43
.L41:
	rjmp .L41
.L43:
	ldd r24,Y+6
	ldd r25,Y+7
	std Y+2,r25
	std Y+1,r24
	ldd r24,Y+6
	ldd r25,Y+7
	ldi r20,0
	ldi r21,0
	ldi r22,lo8(3)
	call do_spm
.L42:
	ldd r24,Y+4
	ldd r25,Y+5
	movw r18,r24
	subi r18,-2
	sbci r19,-1
	std Y+5,r19
	std Y+4,r18
	movw r30,r24
	ld r18,Z
	ldd r19,Z+1
	ldd r24,Y+1
	ldd r25,Y+2
	movw r20,r18
	ldi r22,lo8(1)
	call do_spm
	ldd r24,Y+1
	ldd r25,Y+2
	adiw r24,2
	std Y+2,r25
	std Y+1,r24
	ldd r24,Y+8
	subi r24,lo8(-(-2))
	std Y+8,r24
	ldd r24,Y+8
	tst r24
	brne .L42
	ldd r24,Y+6
	ldd r25,Y+7
	ldi r20,0
	ldi r21,0
	ldi r22,lo8(5)
	call do_spm
	nop
	nop
/* epilogue start */
	adiw r28,8
	in __tmp_reg__,__SREG__
	cli
	out __SP_H__,r29
	out __SREG__,__tmp_reg__
	out __SP_L__,r28
	pop r29
	pop r28
	ret
	.size	writebuffer, .-writebuffer
	.type	read_mem, @function
read_mem:
	push r28
	push r29
	rcall .
	rcall .
	push __zero_reg__
	in r28,__SP_L__
	in r29,__SP_H__
/* prologue: function */
/* frame size = 5 */
/* stack size = 7 */
.L__stack_usage = 7
	std Y+2,r24
	std Y+4,r23
	std Y+3,r22
	std Y+5,r20
.L45:
	ldd r24,Y+3
	ldd r25,Y+4
	movw r30,r24
/* #APP */
 ;  1087 "optiboot_flash.c" 1
	lpm r18,Z+

 ;  0 "" 2
/* #NOAPP */
	movw r24,r30
	std Y+1,r18
	std Y+4,r25
	std Y+3,r24
	ldd r24,Y+1
	call putch
	ldd r24,Y+5
	subi r24,lo8(-(-1))
	std Y+5,r24
	ldd r24,Y+5
	tst r24
	brne .L45
	nop
	nop
/* epilogue start */
	pop __tmp_reg__
	pop __tmp_reg__
	pop __tmp_reg__
	pop __tmp_reg__
	pop __tmp_reg__
	pop r29
	pop r28
	ret
	.size	read_mem, .-read_mem
	.type	do_spm, @function
do_spm:
	push r28
	push r29
	rcall .
	rcall .
	push __zero_reg__
	in r28,__SP_L__
	in r29,__SP_H__
/* prologue: function */
/* frame size = 5 */
/* stack size = 7 */
.L__stack_usage = 7
	std Y+2,r25
	std Y+1,r24
	std Y+3,r22
	std Y+5,r21
	std Y+4,r20
	ldd r20,Y+3
	ldd r24,Y+1
	ldd r25,Y+2
	ldd r18,Y+4
	ldd r19,Y+5
	movw r30,r24
/* #APP */
 ;  1128 "optiboot_flash.c" 1
	    movw  r0, r18
   out 55, r20
   spm
   clr  r1

 ;  0 "" 2
/* #NOAPP */
.L47:
	ldi r24,lo8(87)
	ldi r25,0
	movw r30,r24
	ld r24,Z
	mov r24,r24
	ldi r25,0
	andi r24,1
	clr r25
	or r24,r25
	brne .L47
	ldd r24,Y+3
	mov r24,r24
	ldi r25,0
	andi r24,6
	clr r25
	or r24,r25
	breq .L49
	ldd r24,Y+4
	ldd r25,Y+5
	or r24,r25
	brne .L49
	ldi r24,lo8(17)
/* #APP */
 ;  1155 "optiboot_flash.c" 1
	out 55, r24
	spm
	
 ;  0 "" 2
/* #NOAPP */
.L49:
	nop
/* epilogue start */
	pop __tmp_reg__
	pop __tmp_reg__
	pop __tmp_reg__
	pop __tmp_reg__
	pop __tmp_reg__
	pop r29
	pop r28
	ret
	.size	do_spm, .-do_spm
	.ident	"GCC: (GNU) 5.4.0"
.global __do_copy_data
