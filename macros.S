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
#define _zero_ r1

; counter for timer0
#define tmr_low r2
#define tmr_high r3

; offset for timer0
#define offs_low r4

; sreg reserved
#define sreg_low r5

; flash buffer ptr
#define buffer	r6
#define counter	r7

; Z instruction pointer for access sram and flash high memory
#define ips_low r30
#define ips_high r31

; Y return stack pointer for access sram
#define rsp_low r28
#define rsp_high r29

; X parameter stack pointer for access sram
#define psp_low r26
#define psp_high r27

; temporary 
#define tmp_low r19
#define tmp_high r18

; second value parameter stack
#define tos_low r20
#define tos_high r21

; fist value parameter stack
#define nds_low r22
#define nds_high r23

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
;    adapted from amforth-6.9
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
    rjmp _exit
.endm

;----------------------------------------------------------------------
;
; start reverse linked list
;
.set _link_, 0x0
;----------------------------------------------------------------------
;
; header of leaf word in dictionary
;
.macro HEADER name, label
hd_\label:
    .p2align 1, 0x00
7:    
    .word _link_
    .set _link_, 7b
    .byte 9f - 8f
8:     
    .ascii "\name"
9:     
    .p2align 1, 0x20
\label:
.endm

;----------------------------------------------------------------------
; little endian !!! AVR
;
;    A    Z (r31:r30) is used as generic address pointer
;    R    Y (r29:r28) is used as return stack pointer    
;    S    X (r27:r26) is used as data/parameter stack pointer
;    W    W (r25:r24) is used as generic work register
;
;----------------------------------------------------------------------
;    push into return stack, increments pointer
.macro rspush low, high 
    st Y+, \low
    st Y+, \high
.endm

;----------------------------------------------------------------------
;    pull from return stack, decrements pointer
.macro rspull low, high
    ld \high, -Y
    ld \low, -Y
.endm

;----------------------------------------------------------------------
;    push into data stack, increments pointer
.macro pspush low, high
    st X+, \low
    st X+, \high
.endm

;----------------------------------------------------------------------
;    pull from data stack, decrements pointer
.macro pspull low, high
    ld \high, -X
    ld \low, -X
.endm

;----------------------------------------------------------------------
;    load from program memory (flash)
;    input address in bytes, output address in bytes   
;    only works with TWO lpm !!!
.macro pmload low, high
    lsl \low
    rol \high
    lpm \low, Z+
    lpm \high, Z+
    ror \high
    ror \low
.endm

;----------------------------------------------------------------------
;    load from static memory (sram), increments pointer
;
.macro srload byte
    ld \byte, Z+
.endm

;----------------------------------------------------------------------
;    save to static memory (sram), increments pointer
;
.macro srsave byte
    st Z+, \byte 
.endm

; all dictionary above $0460 in flash ??
 
;----------------------------------------------------------------------
; also io@
;
.macro peek address, register
    .if (\address < $40)
    in \register, \address
    .else
    lds \register, \address
    .endif
.endm

;----------------------------------------------------------------------
; also io!
;
.macro poke address, register
    .if (\address < $40)
    out \address, \register
    .else
    sts \address, \register
    .endif
.endm

;---------------------------------------------------------------------
; from avr manual
;
    __SREG__ = 0x3f
    __SP_H__ = 0x3e
    __SP_L__ = 0x3d

    SRAM_START = 0x060    ; SRAM from AVR manual
    SRAM_END =   0x45F    ; SRAM from AVR manual
    FLASH_START = 0x000        ; flash start
    FLASH_END    = 0XCFF        ; flash end
    EEPROM_START = 0x000    ; Eeprom start
    EEPROM_END    = 0x200        ; eeprom end

    SPM_PAGESIZE = 64    ; bytes

;----------------------------------------------------------------------
;    sizes
;
; "Column 72 means Continue",
;  71 free for use, 72 always \0
    TIB_SIZE = 72
    PAD_SIZE = 72
; stack 18 words deep
    RSP_SIZE = 36
    PSP_SIZE = 36
; flash page size for Atmega8
    FSH_SIZE = 64

;----------------------------------------------------------------------
;    eeprom used
;
    eeprom = EEPROM_START

    E_turnkey = eeprom + 0
    E_seed = eeprom + 2
    E_here = eeprom + 4
    E_last = eeprom + 6
    E_tosr = eeprom + 8 
    E_tofh = eeprom + 10
    E_toee = eeprom + 12

    
;----------------------------------------------------------------------
;     flags 
;
    F_IMMEDI = 0x80
    F_SMUDGE = 0x40
    F_HIDDEN = 0x20
	
    F_TOMASK = 0xE0
    F_UNMASK = 0x1F
    F_FOUND = 0x01

.ifdef SMALL_NAMES
    F_EXTRA = 0x10
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

	SPM_PAGESIZE = 64		; in bytes

