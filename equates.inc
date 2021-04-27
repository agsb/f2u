
;----------------------------------------------------------------------
;
; init instruction pointer and etc
; from avr manual
;
    __SREG__ = 0x3f
    __SP_H__ = 0x3e
    __SP_L__ = 0x3d

;----------------------------------------------------------------------;
	;TCCR0	= 0x33
	;TCNT0	= 0x32
	;TIMSK	= 0x39

;----------------------------------------------------------------------;
; assign stacks address for atmega8
;
    SRAM_END =   0x45F	; SRAM from AVR manual
    SRAM_START = 0x060 	; SRAM from AVR manual
    USER_START = 0x0C0	; still to be fixed at endings

;----------------------------------------------------------------------
; stacks and buffers
;
    SPU_SIZE = PAD_SIZE; real Stack Pointer, reserved for interrupts and libraries

;----------------------------------------------------------------------
; default sizes in bytes and forth83 specs in bytes
;
    PSP_SIZE = 40 ; 20 cells, minimum 32 words
    RSP_SIZE = 40 ; 20 cells, minimum 24 words
    TIB_SIZE = 80 ; minimum 80 bytes
    PAD_SIZE = 80 ; minumum 84 bytes

; PAD will share SPU space

;----------------------------------------------------------------------
; real stack grows downwards: push is SP = SP - 1, pull is SP = SP + 1
; forth all grows upwards
    SPU_TOP = SRAM_END 
    PAD_TOP = SPU_TOP - PAD_SIZE
	TIB_TOP = PAD_TOP - TIB_SIZE
	PSP_TOP = TIP_TOP - PSP_SIZE
	RSP_END = PSP_TOP - RSP_SIZE
;----------------------------------------------------------------------
; at last 256 SRAM bytes, rests 16 words for exclusive variables


;----------------------------------------------------------------------
; flags for words
;
    F_IMMEDIATE = 0x080
    F_COMPILE = 0x040
    F_HIDDEN = 0x020

    F_MASKZ = 0x01F
    F_MASKO = 0x0E0

;---------------------------------------------------------------------
; default base
;
    BASEE = 16

;---------------------------------------------------------------------
; default cell size
;
    CELL_SIZE = 2

;---------------------------------------------------------------------
;	status register ZERO bit  

	BIT_ZERO = 1

;---------------------------------------------------------------------
; default init cell, in dictionary ????
;
    _INIT = 200

