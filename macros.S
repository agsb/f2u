;----------------------------------------------------------------------
;
;    MUST use gnu cpp 
;    use with .S (upper S) or
;    use with -x assembler-with-cpp
;
; can't use alias 
;----------------------------------------------------------------------
;
; r1:r0 reserved and used in self instructions, as spm, mul, des etc
;

; reserved fo interrupt timer0 
	; counter for timer0
#define tmr_low r2
#define tmr_high r3
	; offset for timer0
#define offs_low r4
	; sreg reserved
#define sreg_low r5

; generic use
#define _work_ r6
#define _zero_ r7

; Z instruction pointer for access sram and flash high memory
#define ips_low r30
#define ips_high r31

; Y return stack pointer for access sram
#define rsp_low r28
#define rsp_high r29

; X parameter stack pointer for access sram
#define psp_low r26
#define psp_high r27

; work register
#define wrk_low r24
#define wrk_high r25

; fist value parameter stack
#define nds_low r22
#define nds_high r23

; second value parameter stack
#define tos_low r20
#define tos_high r21

;----------------------------------------------------------------------
;
; version information
;
.equ version, 0x0100

;----------------------------------------------------------------------
;
;    adapted from amforth-6.9
;
.macro STRINGS string
;    .word DOSLIT
    .byte 8f - 7f
7:  .ascii "\string"
8:  .balign 2
.endm

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
;
;   all stacks grows downwards.
;
;----------------------------------------------------------------------
;    push into return stack, 
.macro rspush low, high 
    st -Y, \low
    st -Y, \high
.endm

;----------------------------------------------------------------------
;    pull from return stack, 
.macro rspull low, high
    ld \high, Y+
    ld \low, Y+
.endm

;----------------------------------------------------------------------
;    push into data stack, 
.macro pspush low, high
    st -X, \low
    st -X, \high
.endm

;----------------------------------------------------------------------
;    pull from data stack, 
.macro pspull low, high
    ld \high, X+
    ld \low, X+
.endm

;----------------------------------------------------------------------
;    load from program memory (flash)
;    input address in bytes, output address in bytes   
;    only works with TWO lpm !!!
.macro pmload low, high
    lsl ips_low
    rol ips_high
    lpm \low, Z+
    lpm \high, Z+
    ror ips_high
    ror ips_low
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

;----------------------------------------------------------------------
;    sizes
;
; "Column 72 means Continue", 72 always \0
    TIB_SIZE = 72

; small collate for numbers and words
    PIC_SIZE = 16

; stacks 18 words deep
    STACK_SIZE = 36

;----------------------------------------------------------------------
;    eeprom used
;
    eeprom = 0x00
    e_void = eeprom + 0
    e_turn = eeprom + 2
    e_seed = eeprom + 4
    e_here = eeprom + 6
    e_last = eeprom + 8
    e_sram = eeprom + 10 ; as a stack
    e_erom = eeprom + 12 ; as a stack 
    
;----------------------------------------------------------------------
;    flags 
;
; IMMEDIATE, COMPILE, HIDEN, TOGGLE
;
    F_IMMEDIATE = 0x80
    F_COMPILE_ONLY = 0x40
    F_HIDDEN = 0x20
    F_TOGGLE = 0x10
   
    F_TOMASK = 0xF0
    F_UNMASK = 0x0F
    F_FOUND =  0x01

; STATES

    S_POSTONE = 2
    S_COMPILE = 1
    S_EXECUTE = 0

/*       

    default state is executing
    while defining a new word, state is compiling
    while state is compiling 
    the immediate flag decides if execute or compile
    but to force compiling next word, then state


       common   immediate
    S_EXECUTE   execute   execute
    S_COMPILE   compile   execute
    S_POSTONE   compile compile

    prefer

    S_DECIDES   flag immediate decides
    S_COMPILE   always compile next word
    S_EXECUTE   always execute next word   

*/
;---------------------------------------------------------------------
; default base
;
    BASE_DEFAULT = 16

;---------------------------------------------------------------------
; default cell size
;
    CELL_SIZE = 2

;---------------------------------------------------------------------
;    status register 

    NO_ERROR = 0
    INVALID_MEMORY = -9
    OVERFLOW = -11
    WRITE_TO_READ_ONLY = -20
    NOT_A_NUMBER = -24

;---------------------------------------------------------------------
; Flow Control
 XON_   =   0x11
 XOFF_  =   0x13

 CR_    =   0x0d
 LF_    =   0x0a
 BS_    =   0x08
 TAB_   =   0x09
 BL_   =   0x20
 ESC_   =   0x1B

;---------------------------------------------------------------------
; from avr manual
;
    __SREG__ = 0x3f
    __SP_H__ = 0x3e
    __SP_L__ = 0x3d

/* SPMCR */
#define SPMCR  0x37
#define SPMIE   7
#define RWWSB   6
/* bit 5 reserved */
#define RWWSRE  4
#define BLBSET  3
#define PGWRT   2
#define PGERS   1
#define SPMEN   0


    BIT_CARRY = 0
    BIT_ZERO = 1

    SRAM_START = 0x060  ; SRAM from AVR manual
    SRAM_END = 0x45F    ; SRAM from AVR manual
    RAMEND = SRAM_END

    FLASH_RWW = 0x0000
    FLASH_NRWW = 0x1800 
    FLASH_END = 0x1FFF 

    FLASH_STOP = FLASH_NRWW

    SPM_PAGESIZE = 64    
	E2PAGESIZE = 4

#define EEEND 0x1FF
#define FLASHEND 0x1FFF

    pagesize = (SPM_PAGESIZE - 1)
    pagemask = (~pagesize)
   


/* Constants */
#define SPM_PAGESIZE 64
#define RAMSTART         (0x60)
#define RAMEND           0x45F
#define XRAMEND          RAMEND
#define E2END            0x1FF
#define E2PAGESIZE   4
#define FLASHEND         0x1FFF



