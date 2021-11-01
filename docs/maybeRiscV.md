maybeRiscV.md

# RISCV considerations 

Using R32I, 32 bits cell, and same ideias from f2u 
(for atmega8 and exerpts from forth implementations)

Linux free RiscV registers (pointed by LaRs, lbforth)
must be saved by subroutines (calee)
s4 ~X20~ as Ir, return register for BL BR
s5 ~X21~ as Sr, parameter stack pointer
s6 ~X22~ as Rr, return stack pointer
s7 ~X23~ as Tr, Tos work register
s8 ~X24~ as Nr, temporary scratch register
s9 ~X25~ as Wr, temporary scratch register

https://github.com/riscv-non-isa/riscv-asm-manual/blame/master/riscv-asm.md

The following example shows how to load an absolute address:

    lui  a0, %hi(msg + 1)
    addi a0, a0, %lo(msg + 1)
```

;----------------------------------------------------------------------

.equ FALSE, 0
.equ TRUE, -1
.equ CELL,  4

.equ Ir, x20
.equ Rs, x21
.equ Ps, x22
.equ Tr, x23
.equ Nr, x24
.equ Wr, x25

;----------------------------------------------------------------------
; stack macros
;
.macro rspull reg
    lw \reg, 0(Rs)
    subi Rs, Rs, CELL
.endm

.macro rspush reg
    st \reg, 0(Rs)
    addi Rs, Rs, CELL
.endm

.macro pspull reg
    lw \reg, 0(Ps)
    subi Ps, Ps, CELL
.endm

.macro pspull reg
    lw \reg, 0(Ps)
    subi Ps, Ps, CELL
.endm

.macro jump address
    jal X0, \address
.endm

;----------------------------------------------------------------------
;
; header of word in dictionary
;   byte flags must be 0x80, 0x40, 0x20, 0x10
;   byte size  must be 1 to 15
;   [link][size+flags][name][pad?]
;
;----------------------------------------------------------------------
;
; set start reverse linked list
;
.set _link_, 0x0

.macro header name, label, flags=0x0
is_\label:
    .p2align 1, 0x00
1:
    .word _link_
    .set _link_, 1b
    .byte (3f - 2f) + \flags
2:
    .ascii "\name"
3:
    .p2align 1, 0x20
\label:
.endm

;----------------------------------------------------------------------
;
;   forth inner interpreter
;
header "ENDS", "ends"
_ends: 
    .word 0X0

_exit: ; semis
    rspull Wr

_next: ; next
    lw Ir, 0 (Wr)
    addi Wr, Wr, CELL
    beq Ir, X0, _branch

_enter:
    rspush Wr
    lw Wr, 0 (Ir)
    jal X0, _next

_branch:   
    addi Ir, Wr, CELL
    jalr X0, Wr, 0

_link:
    addi Wr, Ir, 0
    jal X0, _next

;   [ link,size+flags,name,pad?, 0X0, code, (jal X0, link) ]

;   [ link,size+flags,name,pad?, ref, ..., ref ,_ends]

;----------------------------------------------------------------------
; ( -- 0 )
header "0", "zero", 
    .word 0x0
    pspush Tr
    addi Tr, X0, 0  ; li Tr, 0
    jal X0, _link

;----------------------------------------------------------------------
; ( w -- FALSE | TRUE)
header "0=", "zequ"    
    .word 0x0
    beq Tr, X0, _ftrue
_ffalse:
    addi Tr, X0, FALSE  ; li Tr, FALSE
    jal X0, _link
_ftrue:
    addi Tr, X0, TRUE   ; li Tr, TRUE
    jal X0, _link

;----------------------------------------------------------------------
; ( w a -- )
header "!", "to", 
    .word 0x0
    pspull Nr
    st Tr, 0 (Nr)
    pspull Tr
    jal X0, _link

;----------------------------------------------------------------------
; ( a -- w )
header "@", "at", 
    .word 0x0
    ld Tr, 0 (Tr)
    jal X0, _link

;----------------------------------------------------------------------
; ( -- rsp )
header "RS@", "RSAT",
    .word 0x0
    pspush Tr
    add Tr, X0, Rs
    jal X0, _link

;----------------------------------------------------------------------
; ( -- psp )
header "PS@", "PSAT",
    .word 0x0
    pspush Tr
    add Tr, X0, Ps
    jal X0, _link

;----------------------------------------------------------------------
; ( u v -- w )
header "NAND", "nand",
    .word 0x0
    pspull Nr
    and Nr, Nr, Tr
    neg Tr, Nr
    jal X0, _link

;----------------------------------------------------------------------
; ( u v -- w )
header "PLUS", "plus",
    .word 0x0
    pspull Nr
    add Tr, Tr, Nr
    jal X0, _link

;----------------------------------------------------------------------
; ( u v -- w )
header "MINUS", "minus",
    .word 0x0
    pspull Nr
    sub Tr, Tr, Nr
    jal X0, _link

;----------------------------------------------------------------------
; ( u v -- w )
header "SHR", "shr"
    .word 0x0
    pspull Nr
    srl Tr, Tr, Nr
    jal X0, _link

;----------------------------------------------------------------------
; ( u v -- w )
header "SHL", "shl"
    .word 0x0
    pspull Nr
    sll Tr, Tr, Nr
    jal X0, _link

;----------------------------------------------------------------------
; ( u v -- w )
header "AND", "and"
    .word 0x0
    pspull Nr
    and Tr, Tr, Nr
    jal X0, _link

;----------------------------------------------------------------------
; ( u v -- w )
header "OR", "or"
    .word 0x0
    pspull Nr
    or Tr, Tr, Nr
    jal X0, _link

;----------------------------------------------------------------------
; ( u v -- w )
header "XOR", "xor"
    .word 0x0
    pspull Nr
    xor Tr, Tr, Nr
    jal X0, _link

;----------------------------------------------------------------------
; ( u -- w )
header "INVERT", "invert"
    .word 0x0
    not Tr, Tr
    jal X0, _link

;----------------------------------------------------------------------
; ( u -- w )
header "NEGATE", "negate"
    .word 0x0
    sub Tr, X0, Tr
    jal X0, _link

;----------------------------------------------------------------------
;   ( -- FALSE)
header "FALSE", "false", 
    .word 0x0
    pspush Tr
_isfalse:
    addi Tr, X0, FALSE  ; li Tr, FALSE
    jal X0, _link

;----------------------------------------------------------------------
;   ( -- TRUE)
header "TRUE", "true", 
    .word 0x0
    pspush Tr
_istrue:
    addi Tr, X0, TRUE   ; li Tr, TRUE
    jal X0, _link

;----------------------------------------------------------------------
header "<", "lt", 
    .word 0x0
    pspull Nr
    blt Tr, Nr, _istrue
    bge Tr, Nr, _isfalse
    
;----------------------------------------------------------------------
header ">", "gt", 
    .word 0x0
    pspull Nr
    blt Nr, Tr, _istrue
    bge Nr, Tr, _isfalse
    
;----------------------------------------------------------------------
header "=", "eq", 
    .word 0x0
    pspull Nr
    beq Tr, Nr, _istrue
    bne Tr, Nr, _isfalse

;----------------------------------------------------------------------
header "<>", "neq", 
    .word 0x0
    pspull Nr
    bne Tr, Nr, _istrue
    beq Tr, Nr, _isfalse

;----------------------------------------------------------------------
header "1", "one", 
    .word 0x0
    pspush Tr
    addi Tr, X0, 1  ; li Tr, 1
    jal X0, _link

;----------------------------------------------------------------------
header "2", "two", 
    .word 0x0
    pspush Tr
    addi Tr, X0, 2  ; li Tr, 2
    jal X0, _link

;----------------------------------------------------------------------
header "CELL", "cell", 
    .word 0x0
    pspush Tr
    addi Tr, X0, CELL   ; li Tr, CELL
    jal X0, _link

;----------------------------------------------------------------------
header ">R", "tor", 
    .word 0x0
    rspush Tr
    pspull Tr
    jal X0, _link

;----------------------------------------------------------------------
header "R>", "rto", 
    .word 0x0
    pspush Tr
    rspull Tr
    jal X0, _link

;----------------------------------------------------------------------
header "R@", "rat", 
    .word 0x0
    pspush Tr
    lw Tr, 0 (Rs)
    jal X0, _link

;----------------------------------------------------------------------
;   ( rs -- )
header "R!", "rsto", 
    .word 0x0
    add Rs, X0, Tr
    jal X0, _drop
    
;----------------------------------------------------------------------
;   ( ps -- )
header "P!", "psto", 
    .word 0x0
    add Ps, X0, Tr
    jal X0, _drop

;----------------------------------------------------------------------
;   ( w -- )
header "DROP", "drop", 
    .word 0x0
_drop:
    pspull Tr
    jal X0, _link

;----------------------------------------------------------------------
;   ( w -- w w )
header "DUP", "dup", 
    .word 0x0
_push:
    pspush Tr
    jal X0, _link

;----------------------------------------------------------------------
;   ( w v -- v w )
header "SWAP", "swap", 
    .word 0x0
    pspull Nr
_swap:    
    pspush Tr
    mv Tr, Nr
    jal X0, _link

;----------------------------------------------------------------------
;   (w v -- w v w)
header "OVER", "over", 
    .word 0x0
    lw Nr, CELL (Ps)
    jal X0, _swap
    
;----------------------------------------------------------------------
;   (w u v -- u v w)
header "ROT", "rot", 
    .word 0x0
    pspull Wr
    pspull Nr
    pspush Wr
    jal X0, _swap
    
;----------------------------------------------------------------------
;   ( 0 -- 0 ) (w -- w w)
header "?DUP", "zdup", 
    .word 0x0
    beq Tr, X0, 1f
    pspush Tr
1:    
    jal X0, _link

;----------------------------------------------------------------------
; trick, load Tos from next reference
header "LITL", "ltil", 
    .word 0x0
    pspush Tr
    lw Tr, 0(Ir)
_skip:
    addi Ir, Ir, CELL
    jal X0, _link

;----------------------------------------------------------------------
; trick, if Tos not zero skip next reference, drop Tos
header "?BRANCH", "zbranch", 
    .word 0x0
    add Wr, X0, Tr
    pspull Tr
    bne Wr, X0, _skip
    jal X0, _branch
    
;----------------------------------------------------------------------
; trick, a follow reference is always offset to branch
header "BRANCH", "branch", 
    .word 0x0
_branch:    
    lw Wr, 0 (Ir)
    add Ir, Ir, Wr
    jal X0, _link

;----------------------------------------------------------------------
; trick, a Tos reference is pushed into return stack
header "EXECUTE", "execute", 
    .word 0x0
    rspush Tr
    jal X0, _drop
    
;  ZZZZ >< ABS ALLIGN 

;----------------------------------------------------------------------
;   ( b a -- ) 
; writes one byte at address
header "C!", "cto", 
    .word 0x0
    pspull Nr
    sb Nr, 0 (Tr)
    jal X0, _drop

;----------------------------------------------------------------------
;   ( a -- b )
; reads one byte from address
header "C@", "cat", 
    .word 0x0
    lb Tr, 0 (Tr)
    jal X0, _link

;----------------------------------------------------------------------
;   ( a1 a2 u --- FALSE | TRUE )
; compare bytes from source++ to destination++, decrease count--
; returns 0 if equal (no differ)
; zzzzzzz
HEADER "CSAME", "csame"
    .word 0x0
    pspull Nr
    pspull Wr

; save return
    rspush Ir
1:
    beq Tr, X0, 3f
    lb Tr, 0(Wr)
    lb Ir, 0(Nr)
    xor Tr, Tr, Ir
    bne Tr, X0, 3f

    addi Wr, Wr, 1
    addi Nr, Nr, 1
    subi Tr, Tr, 1
    jal X0, 1b
2:
    or Tr, Tr, Tr
    rspull Ir
    jal X0, _link
    
;----------------------------------------------------------------------
;   ( a1 a2 u --- )
; move bytes from source++ to destination++, decrease count--
; returns 0 if equal (no differ)
;
HEADER "CMOVE", "cmove"
    .word 0x0
    pspull Nr
    pspull Wr
    
; save return
    rspush Ir
1:
    beq Tr, X0, 2f
    lb Ir, 0(Wr)
    sb Ir, 0(Nr)
    addi Wr, Wr, 1
    addi Nr, Nr, 1
    subi Tr, Tr, 1
    jal X0, 1b
2:
; load return
    rspull Ir   
    jal X0, drop

;----------------------------------------------------------------------
;   ( a1 a2 u --- )
; move bytes from source-- to destination--, decrease count--
; offsets calculated inside
; returns 0 if equal (no differ)
;
HEADER "BMOVE", "bmove"
    .word 0x0
    pspull Nr
    pspull Wr

; save return
    rspush Ir

; do offsets    
    addi Nr, Nr, Tr
    addi Wr, Wr, Tr

1:
    beq Tr, X0, 2f
    lb Ir, 0(Wr)
    sb Ir, 0(Nr)
    subi Wr, Wr, 1
    subi Nr, Nr, 1
    subi Tr, Tr, 1
    jal X0, 1b
2:
; load return
    rspull Ir   
    jal X0, drop
    