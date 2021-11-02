maybeRiscV.md

# RISCV considerations 

Using R32I, 32 bits cell, and same ideias from f2u 
(for atmega8 and exerpts from forth implementations)

Linux free RiscV registers (pointed by LaRs, lbforth)
must be saved by subroutines (calee)
s4 ~X20~ as Ip, return register for BL BR
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

//----------------------------------------------------------------------

.equ FALSE, 0
.equ TRUE, -1
.equ CELL,  4

/*
// as PDP-11, six registers
.equ Ip, s4 //   return register
.equ Rs, s5 //   return stack register
.equ Ps, s6 //   parameter stack register
.equ Tr, s7 //   Top of parameter stack
.equ Nr, s8 //   hold for    
.equ Wr, s9 //   hold for
// using also s10 and s11 temporary
.equ T0, s10
.equ T1, s11
*/

 #define  Ip s4     //   instruction register
 #define  Rs s5     //   return stack register
 #define  Ps s6     //   parameter stack register
 #define  Tr s7     //   Top of parameter stack
 #define  Nr s8     //   hold for
 #define  Wr s9     //   hold for
 #define  T0 s10    //   temporary
 #define  T1 s11    //   temporary

//----------------------------------------------------------------------
// stack macros
//
.macro rspull reg
    lw \reg, 0(Rs)
    addi Rs, Rs, -1*CELL
.endm

.macro rspush reg
    sw \reg, 0(Rs)
    addi Rs, Rs, CELL
.endm

.macro pspull reg
    lw \reg, 0(Ps)
    addi Ps, Ps, -1*CELL
.endm

.macro pspush reg
    sw \reg, 0(Ps)
    addi Ps, Ps, CELL
.endm

.macro jump address
    jal zero, \address
.endm

//----------------------------------------------------------------------
//
// header of word in dictionary
//   byte flags must be 0x80, 0x40, 0x20, 0x10
//   byte size  must be 1 to 15
//   [link][size+flags][name][pad?]
//
//----------------------------------------------------------------------
//
// set start reverse linked list
//
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

//----------------------------------------------------------------------
//
//   forth inner interpreter
//
header "ENDS", "ends"
_ends: 
    .word 0x0

_unnest: // aka do_semis
    rspull Ip

_next: // next
    lw Wr, 0 (Ip)
    addi Ip, Ip, CELL
    beq Wr, zero, _branch

_nest:  // aka do_colon
    rspush Ip
    lw Ip, 0 (Wr)

_link:    
    jal zero, _next

_branch:   
    add Wr, zero, Ip
    addi Ip, Ip, CELL
    jalr zero, Wr, 0

//   [ link,size+flags,name,pad?, 0x0, code, (jal zero, link) ]

//   [ link,size+flags,name,pad?, ref, ..., ref ,_ends]

//----------------------------------------------------------------------
// ( -- 0 )
header "0", "zeru", 
    .word 0x0
    pspush Tr
    add Tr, zero, zero  // li Tr, 0
    jal zero, _link

//----------------------------------------------------------------------
// ( w -- FALSE | TRUE)
header "0=", "zequ"    
    .word 0x0
    beq Tr, zero, _ftrue
_ffalse:
    addi Tr, zero, FALSE  // li Tr, FALSE
    jal zero, _link
_ftrue:
    addi Tr, zero, TRUE   // li Tr, TRUE
    jal zero, _link

//----------------------------------------------------------------------
// ( w a -- )
header "!", "to", 
    .word 0x0
    pspull Nr
    sw Tr, 0 (Nr)
    pspull Tr
    jal zero, _link

//----------------------------------------------------------------------
// ( a -- w )
header "@", "at", 
    .word 0x0
    ld Tr, 0 (Tr)
    jal zero, _link

//----------------------------------------------------------------------
// ( -- rsp )
header "RS@", "RSAT",
    .word 0x0
    pspush Tr
    add Tr, zero, Rs
    jal zero, _link

//----------------------------------------------------------------------
// ( -- psp )
header "PS@", "PSAT",
    .word 0x0
    pspush Tr
    add Tr, zero, Ps
    jal zero, _link

//----------------------------------------------------------------------
// ( u v -- w )
header "NAND", "nand",
    .word 0x0
    pspull Nr
    and Nr, Tr, Nr
    neg Tr, Nr
    jal zero, _link

//----------------------------------------------------------------------
// ( u v -- w )
header "PLUS", "plus",
    .word 0x0
    pspull Nr
    add Tr, Tr, Nr
    jal zero, _link

//----------------------------------------------------------------------
// ( u v -- w )
header "MINUS", "minus",
    .word 0x0
    pspull Nr
    sub Tr, Tr, Nr
    jal zero, _link

//----------------------------------------------------------------------
// ( u v -- w )
header "SHR", "shr"
    .word 0x0
    pspull Nr
    srl Tr, Tr, Nr
    jal zero, _link

//----------------------------------------------------------------------
// ( u v -- w )
header "SHL", "shl"
    .word 0x0
    pspull Nr
    sll Tr, Tr, Nr
    jal zero, _link

//----------------------------------------------------------------------
// ( u v -- w )
header "AND", "and"
    .word 0x0
    pspull Nr
    and Tr, Tr, Nr
    jal zero, _link

//----------------------------------------------------------------------
// ( u v -- w )
header "OR", "or"
    .word 0x0
    pspull Nr
    or Tr, Tr, Nr
    jal zero, _link

//----------------------------------------------------------------------
// ( u v -- w )
header "XOR", "xor"
    .word 0x0
    pspull Nr
    xor Tr, Tr, Nr
    jal zero, _link

//----------------------------------------------------------------------
// ( u -- w )
header "INVERT", "invert"
    .word 0x0
    xori Tr, Tr, -1
    jal zero, _link

//----------------------------------------------------------------------
// ( u -- w )
header "NEGATE", "negate"
    .word 0x0
    sub Tr, zero, Tr
    jal zero, _link

//----------------------------------------------------------------------
//   ( -- FALSE)
header "FALSE", "false", 
    .word 0x0
    pspush Tr
_isfalse:
    addi Tr, zero, FALSE  // li Tr, FALSE
    jal zero, _link

//----------------------------------------------------------------------
//   ( -- TRUE)
header "TRUE", "true", 
    .word 0x0
    pspush Tr
_istrue:
    addi Tr, zero, TRUE   // li Tr, TRUE
    jal zero, _link

//----------------------------------------------------------------------
header "<", "lt", 
    .word 0x0
    pspull Nr
    blt Tr, Nr, _istrue
    bge Tr, Nr, _isfalse
    
//----------------------------------------------------------------------
header ">", "gt", 
    .word 0x0
    pspull Nr
    blt Nr, Tr, _istrue
    bge Nr, Tr, _isfalse
    
//----------------------------------------------------------------------
header "=", "eq", 
    .word 0x0
    pspull Nr
    beq Tr, Nr, _istrue
    bne Tr, Nr, _isfalse

//----------------------------------------------------------------------
header "<>", "neq", 
    .word 0x0
    pspull Nr
    bne Tr, Nr, _istrue
    beq Tr, Nr, _isfalse

//----------------------------------------------------------------------
header "1", "one", 
    .word 0x0
    pspush Tr
    addi Tr, zero, 1  // li Tr, 1
    jal zero, _link

//----------------------------------------------------------------------
header "2", "two", 
    .word 0x0
    pspush Tr
    addi Tr, zero, 2  // li Tr, 2
    jal zero, _link

//----------------------------------------------------------------------
header "CELL", "cell", 
    .word 0x0
    pspush Tr
    addi Tr, zero, CELL   // li Tr, CELL
    jal zero, _link

//----------------------------------------------------------------------
header ">R", "tor", 
    .word 0x0
    rspush Tr
    pspull Tr
    jal zero, _link

//----------------------------------------------------------------------
header "R>", "rto", 
    .word 0x0
    pspush Tr
    rspull Tr
    jal zero, _link

//----------------------------------------------------------------------
header "R@", "rat", 
    .word 0x0
    pspush Tr
    lw Tr, 0 (Rs)
    jal zero, _link

//----------------------------------------------------------------------
//   ( rs -- )
header "R!", "rsto", 
    .word 0x0
    add Rs, zero, Tr
    jal zero, _pull
    
//----------------------------------------------------------------------
//   ( ps -- )
header "P!", "psto", 
    .word 0x0
    add Ps, zero, Tr
    jal zero, _pull

//----------------------------------------------------------------------
//   ( w -- )
header "DROP", "drop", 
    .word 0x0
_pull:
    pspull Tr
    jal zero, _link

//----------------------------------------------------------------------
//   ( w -- w w )
header "DUP", "dup", 
    .word 0x0
_push:
    pspush Tr
    jal zero, _link

//----------------------------------------------------------------------
//   ( w v -- v w )
header "SWAP", "swap", 
    .word 0x0
    pspull Nr
_swap:    
    pspush Tr
    mv Tr, Nr
    jal zero, _link

//----------------------------------------------------------------------
//   (w v -- w v w)
header "OVER", "over", 
    .word 0x0
    lw Nr, CELL (Ps)
    jal zero, _swap
    
//----------------------------------------------------------------------
//   (w u v -- u v w)
header "ROT", "rot", 
    .word 0x0
    pspull Wr
    pspull Nr
    pspush Wr
    jal zero, _swap
    
//----------------------------------------------------------------------
//   ( 0 -- 0 ) (w -- w w)
header "?DUP", "zdup", 
    .word 0x0
    beq Tr, zero, 1f
    pspush Tr
1:    
    jal zero, _link

//----------------------------------------------------------------------
// trick, load Ip from next reference pointed by Ip
// that's what does> do
header "JMPL", "jmpl", 
    .word 0x0
    lw Wr, 0(Ip)
_skip:
    add Ip, zero, Wr
    jal zero, _link

//----------------------------------------------------------------------
// trick, load Tos from next reference pointed by Ip
// that's what literal do
header "LITL", "ltil", 
    .word 0x0
    pspush Tr
    lw Tr, 0(Ip)
_skip:
    addi Ip, Ip, CELL
    jal zero, _link

//----------------------------------------------------------------------
// trick, if Tos not zero skip next reference, drop Tos
header "?BRANCH", "zbranch", 
    .word 0x0
    add Wr, zero, Tr
    pspull Tr
    bne Wr, zero, _skip
    jal zero, _branch
    
//----------------------------------------------------------------------
// trick, a follow reference is always offset to branch
header "BRANCH", "branch", 
    .word 0x0
_branch:    
    lw Wr, 0 (Ip)
    add Ip, Ip, Wr
    jal zero, _link

//----------------------------------------------------------------------
// trick, a Tos reference is pushed into return stack
header "EXECUTE", "execute", 
    .word 0x0
    rspush Tr
    jal zero, _pull
    
//  ZZZZ >< ABS ALLIGN 

//----------------------------------------------------------------------
//   ( b a -- ) 
// writes one byte at address
header "C!", "cto", 
    .word 0x0
    pspull Nr
    sb Nr, 0 (Tr)
    jal zero, _pull

//----------------------------------------------------------------------
//   ( a -- b )
// reads one byte from address
header "C@", "cat", 
    .word 0x0
    lb Tr, 0 (Tr)
    jal zero, _link

//----------------------------------------------------------------------
//   ( w a --  )
// reads one byte from address
header "+!", "plusto", 
    .word 0x0
    pspull Nr
    lw Wr, 0 (Tr)
    add Wr, Wr, Nr
    sw Wr, 0 (Tr)
    jal zero, _pull

//----------------------------------------------------------------------
//   ( a1 a2 u --- FALSE | TRUE )
// compare bytes from source++ to destination++, decrease count--
// returns 0 if equal (no differ)
// used most to compare names with less than 16 of length
// 
HEADER "CSAME", "csame"
    .word 0x0
    pspull Nr
    pspull Wr

    add T0, zero, zero
1:
    beq Tr, zero, 2f
    lb T0, 0 (Wr)
    lb T1, 0 (Nr)
    xor T0, T1, T0
    bne T0, zero, 2f

    addi Wr, Wr, 1
    addi Nr, Nr, 1
    subi Tr, Tr, 1
    jal zero, 1b
2:
    // results
    add Tr, zero, T0
    jal zero, _link
    
//----------------------------------------------------------------------
//   ( a1 a2 u --- )
// move bytes from source++ to destination++, decrease count--
// returns 0 if equal (no differ)
//
HEADER "CMOVE", "cmove"
    .word 0x0
    pspull Nr
    pspull Wr
1:
    beq Tr, zero, 2f
    lb T0, 0(Wr)
    sb T0, 0(Nr)
    addi Wr, Wr, 1
    addi Nr, Nr, 1
    subi Tr, Tr, 1
    jal zero, 1b
2:
    jal zero, drop

//----------------------------------------------------------------------
//   ( a1 a2 u --- )
// move bytes from source-- to destination--, decrease count--
// offsets calculated inside
// returns 0 if equal (no differ)
//
HEADER "BMOVE", "bmove"
    .word 0x0
    pspull Nr
    pspull Wr

// do offsets    
    addi Nr, Nr, Tr
    addi Wr, Wr, Tr
1:
    beq Tr, zero, 2f
    lb T0, 0(Wr)
    sb T0, 0(Nr)
    subi Wr, Wr, 1
    subi Nr, Nr, 1
    subi Tr, Tr, 1
    jal zero, 1b
2:
    jal zero, drop
    