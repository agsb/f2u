;----------------------------------------------------------------------
;
;    MUST use gnu cpp 
;    use with .S (upper S) or
;    use with -x assembler-with-cpp
;
; can't use alias 
;----------------------------------------------------------------------

; generic use
#define _work_ r0

; always zero
#define _zero_ r1

; counter for timer0
#define tmr_low r2
#define tmr_high r2

; offset for timer0
#define offs_low r4

; sreg reserved
#define sreg_low r5

; Z instruction pointer for access sram and flash high memory
#define ips_low r30
#define ips_high r31

; Y return stack pointer for access sram
#define rsp_low r28
#define rsp_high r29

; X parameter stack pointer for access sram
#define psp_low r26
#define psp_high r27

; second value parameter stack
#define nds_low r20
#define nds_high r21

; fist value parameter stack
#define tos_low r22
#define tos_high r23

; work register
#define wrk_low r24
#define wrk_high r25

;----------------------------------------------------------------------
;
; version information
;
.equ version, 0x0100


;----------------------------------------------------------------------
;
;	adapted from amforth-6.9
;
;.macro STRINGS string
;    .word DOSLIT
;    .byte 8f - 7f
;7:  .ascii "\string"
;8:  .balign 2
;.endm

;----------------------------------------------------------------------
;
; all leaf must start with NOOP and end with POON
;
.macro NOOP
	nop
.endm

.macro POON
	rjmp _EXIT
.endm

;----------------------------------------------------------------------
;
; start reverse linked list
;
.set _link_ , 0x0
;----------------------------------------------------------------------
;
; header of leaf word in dictionary
;
.macro HEADER name label
hd_\label:
	.p2align 1,0x00
7:	
	.word _link_
	.set _link_, 7b
	.byte 9f - 8f
8: 	
	.ascii "\name"
9: 	
	.p2align 1,0x20
\label:
.endm

;----------------------------------------------------------------------
; little endian !!! AVR
;
;	A	Z (r31:r30) is used as generic address pointer
;	R	Y (r29:r28) is used as return stack pointer	
;	S	X (r27:r26) is used as data/parameter stack pointer
;	W	W (r25:r24) is used as generic work register
;
;----------------------------------------------------------------------
;	push into return stack, increments pointer
.macro rspush low , high
    st Y+ , \low
    st Y+ , \high
.endm

;----------------------------------------------------------------------
;	pull from return stack, decrements pointer
.macro rspull low , high
    ld \high , -Y
    ld \low  , -Y
.endm

;----------------------------------------------------------------------
;	push into data stack, increments pointer
.macro pspush low , high
    st X+ , \low
    st X+ , \high
.endm

;----------------------------------------------------------------------
;	pull from data stack, decrements pointer
.macro pspull low , high
    ld \high , -X
    ld \low  , -X
.endm

;----------------------------------------------------------------------
;	load from program memory (flash), increments pointer
.macro pmload low , high
    lpm \low  , Z+
    lpm \high , Z+
.endm

;----------------------------------------------------------------------
;	load from static memory (sram), increments pointer
.macro srload byte
    ld \byte  , Z+
.endm

;----------------------------------------------------------------------
;	save to static memory (sram), increments pointer
.macro srsave byte
    st Z+, \byte 
.endm

;----------------------------------------------------------------------
; unused
;	load from memory, increments pointer
.macro mmload byte
     ; all dictionary above $0460 in flash
100: 
	movw wrk_low, ips_low
    subi wrk_low, $60
    sbic wrk_high, $04
    brge 104f
	; read from sram
102: 
	ld \byte, Z+
    rjmp 106f
  	; read from flash
104: 
	lpm \byte, Z+
106:
.endm
 
;----------------------------------------------------------------------
; unused
;	save into memory, increments pointer
.macro mmsave byte
     ; all dictionary above $0460 in flash
100: 
	movw wrk_low, ips_low
    subi wrk_low, $60
    sbic wrk_high, $04
    brge 104f
	; save into sram
102: 
	st Z+, \byte
    rjmp 106f
  	; save into flash
104:
	.error "trying write into flash" 
	nop ; spm is complex, dont works in bytes
106:
.endm
 
;----------------------------------------------------------------------
; also io@
.macro peek byte , address
    .if (\address < $40)
    in \byte , \address
    .else
    lds \byte , \address
    .endif
.endm

;----------------------------------------------------------------------
; also io!
.macro poke byte , address
    .if (\address < $40)
    out \address, \byte
    .else
    sts \address, \byte
    .endif
.endm

;----------------------------------------------------------------------
;	sizes
;
; "Column 72 means Continue"
	TIB_SIZE = 73
	PAD_SIZE = 73
; stack 20 words deep
	RSP_SIZE = 40
	PSP_SIZE = 40

;----------------------------------------------------------------------
; 	flags 
;
    F_IMMEDIATE = 0x80
    F_COMPILE = 0x40
    F_HIDDEN = 0x20
	F_TOMASK = 0xE0
	F_UNMASK = 0x1F
	F_FOUND = 0x01

.ifdef SMALL_NAMES
	F_EXTRA	= 0x10
    F_TOMASK = 0xF0
    F_UNMASK = 0x0F
.endif

	F_COMPILE = 1
	F_INTERPE = 0

;---------------------------------------------------------------------
; default base
;
    BASE_DEFAULT = 10

;---------------------------------------------------------------------
; default cell size
;
    CELL_SIZE = 2

;---------------------------------------------------------------------
;    status register ZERO bit

    BIT_CARRY = 0
    BIT_ZERO = 1

;---------------------------------------------------------------------
; from avr manual
;
    __SREG__ = 0x3f
    __SP_H__ = 0x3e
    __SP_L__ = 0x3d

    SRAM_END =   0x45F    ; SRAM from AVR manual
    SRAM_START = 0x060    ; SRAM from AVR manual



