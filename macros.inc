;----------------------------------------------------------------------
;
;    MUST use gnu cpp 
;    use with .S (upper S) or
;    use with -x assembler-with-cpp
;
;----------------------------------------------------------------------
; generic use
#define    _work_    r0    
; .set _work_ , r0    

; always zero
#define    _zero_    r1    
; .set _zero_ , r1

; Z instruction pointer for access sram and flash high memory
#define    ip_low    r30    
;.set    ipl,    r30

#define    ip_high    r31    
;.set    iph,    r31

; Y return stack pointer for access sram
#define    rsp_low    r28    
;.set    rspl,    r28

#define    rsp_high    r29    
;.set    rsph,    r29

; X parameter stack pointer for access sram
#define    psp_low    r26    
;.set    pspl,    r26

#define    psp_high    r27    
;.set    psph,    r27

; work registers
#define    wrk_low    r24    
;.set    wl,    r24

#define    wrk_high    r25    
;.set    wh,    r25

; second value parameter stack
#define    nds_low    r22    
;.set    nl,    r22

#define    nds_high    r23    
;.set    nh, r23

; fist value parameter stack
#define    tos_low    r20    
;.set    tl,    r20

#define    tos_high    r21    
;.set    th,    r21

;----------------------------------------------------------------------
;
; version information
;----------------------------------------------------------------------
;
; version information
;
.equ version, 0x0100

;----------------------------------------------------------------------
;
; start reverse linked list
;
.set _LINK , 0x0
.set _THIS , 0x0

;----------------------------------------------------------------------
;
; header of leaf word in dictionary
; must start with nop, nop
; must end with RJMP NOOP
;
.macro LEAF size , name
.set _THIS, .
.word _LINK
.set _LINK, _THIS 
.byte \size
.ascii "\name"
;was odd, so we need to pad it
.if ! ( \size & 1 ) 
.byte 0x20
.endif
.balign 2
.endm

;----------------------------------------------------------------------
;
; all leaf must start with NOOP and end with POON
;
.macro NOOP
	nop
	nop
.endm

.macro POON
	rjmp _EXIT
.endm

;----------------------------------------------------------------------
;
; header of twig word in dictionary
; hold a list of reference address
; must end with reference to NOOP
;
.macro TWIG size , name
.set _THIS, .
.word _LINK
.set _LINK, _THIS 
.byte \size
.ascii "\name"
;was odd, so we need to pad it
.if ! ( \size & 1 ) 
.byte 0x20
.endif
.balign 2
.endm

;----------------------------------------------------------------------
; little endian !!! AVR

;----------------------------------------------------------------------
.macro rspush low , high
    st -Y , \high
    st -Y , \low
.endm

;----------------------------------------------------------------------
.macro rspull low , high
    ld \low  , Y+
    ld \high , Y+
.endm

;----------------------------------------------------------------------
.macro pspush low , high
    st -X , \high
    st -X , \low
.endm

;----------------------------------------------------------------------
.macro pspull low , high
    ld \low  , X+
    ld \high , X+
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
    out \byte , \address
    .else
    sts \byte , \address
    .endif
.endm



