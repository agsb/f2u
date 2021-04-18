
;----------------------------------------------------------------------
;
; init instruction pointer and etc
; from avr manual
;
    __SREG__ = 0x3f
    __SP_H__ = 0x3e
    __SP_L__ = 0x3d

;----------------------------------------------------------------------;
; assign stacks address for atmega8
;
    SRAM_END = 0x45F	; SRAM from AVR manual
    SRAM_START = 0x060 	; SRAM from AVR manual
    USER_START = 0x0C0	; still to be fixed at endings

;----------------------------------------------------------------------
; stacks and buffers
;
    SPU_SIZE = 40 ; real Stack Pointer, reserved for interrupts and libraries

;----------------------------------------------------------------------
; default sizes as forth83 (bytes)
;
    PSP_SIZE = 64 ; minimum 32 words
    RSP_SIZE = 48 ; minimum 24 words
    TIB_SIZE = 80 ; minimum 80 bytes
    PAD_SIZE = 84 ; minumum 84 bytes

;----------------------------------------------------------------------
; grows downwards SP = SP - 1
;
    SPP_TOP = SRAM_END 
    RSP_TOP = SPP_TOP - SPU_SIZE
    PSP_TOP = RSP_TOP - RSP_SIZE
	PSP_END = PSP_TOP - PSP_SIZE

;----------------------------------------------------------------------
; grows upwards PT = PT + 1
;
    TIB_TOP = PSP_END - TIB_SIZE

;----------------------------------------------------------------------
; grows upwards PT = PT + 1
;
    PAD_TOP = TIB_TOP - PAD_SIZE

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
; default init cell, in dictionary ????
;
    _INIT = 200

