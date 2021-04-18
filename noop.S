
NOOP:
	nop
	nop
EXIT:
	ld r31, Y+
	ld r30, Y+
THIS:
	ld r25, Z+
	ld r24, Z+
EXEC:
	mov r0, r25
	or  r0, r24
	brne ENTER
	ijmp
ENTER:
	st -Y, r30
	st -Y, r31
NEXT:
	movw r30, r24
	rjmp THIS
 
