Minimal.md

# Minimal, a essay

In back 1968, Charles H. Moore, create a Forth language for a IBM-1130.

"The IBM 1130 was a fairly simple 16-bit computer, with a load-store architecture, a single accumulator and three index registers X1, X2, X3, stored at locations 01, 02, 03 in the core memory." <https://github.com/monsonite/1968-FORTH>

What could be a minimal cpu ?

    Suppose a processor with a address and data bus of same quantity of (16) bits. Three generic latches as registers W, T, N.
    
    A addresss memory bus port A, a data memory bus port D, and let D holds the contents of memory pointed by address in A. 
    
    All registers and ports are only accessed by register W for copy values from and into.
    
    Lets reserve seven memory address called by  Z, I, P, S, R, U, V.
    
    Let register T also serves as minimal aritimetc and logic register and memory Z always be zero, 
    
    Let memory U is a input uart port, memory V is a output uart port.

Some ideas of http://blog.jeff.over.bz/assembly/compilers/jit/2017/01/15/x86-assembler.html
# 1. Operations:

| MNEMO | CODE | DOES | explain |
|-------|------|------|---------|
| _; moves into W_ |
| noop   | 0x00  | movw W, W  | move w into w |
| mvwt   | 0x01  | movw W, T  | move t into w |
| mvwn   | 0x02  | movw W, N  | move b into w |
| mvwd   | 0x03  | movw W, D  | move from memory |
| _; moves from W_ |
| mvaw   | 0x04  | movw A, W | move w into A |
| mvtw   | 0x05  | movw T, W | move w into t |
| mvnw   | 0x06  | movw N, W | move w into n |
| mvdw   | 0x07  | movw D, W | move into memory |
| _; unary in T_ |
| tstz   | 0x08  | test T, 0 | test if t equal 0 |
| mvtz   | 0X09  | movi T, 0 | move 0 into t |
| inct   | 0x0A  | T++       | increase t |
| dect   | 0x0B  | T--       | decrease t |
| _; binary in T using W_ |
| natw   | 0x0C  | nand T, W | t = t nand w |
| sums   | 0x0D  | sums T, W | t = t + w |
| _; other_ |
| mvwi   | 0x0E  | movi w, val | move value into w |
| halt   | 0x0F  | halt | halt |

_Still no jump operation_

_Still no shift right operation_

_All logic using NAND_

# 2. Macros :
## 2.1 basics

    _load : ; (load D into w)
        mvaw 
        mvwd 

    _hold :
        mvwt
        mvnm

    _save : ; (save t to w to D)
        mvaw
        _hold

    _incM :  ; increase value at memory 
        _load
        mvtw
        inct
        _hold
        
    _decM :  ; decrease value at memory 
        _load
        mvtw
        inct
        _hold

## 2. As Branch and Link:

    _loadP :
        mvwi P
        _load
        
    _saveP :
        mvwi P
        _save

    _loadI :
        mvwi I
        _load

    _saveI :
        mvwi I
        _save

    ; branch and link variants

    BL :    ; move ([P] + 1) into [I]
        _loadP
        mvtw
        inct    ; many as sizeof word in bytes 
        inct
        _saveI

    BR :    ; move [I] into [P]
        _loadI
        mvtw
        _saveP

    BX:     ; move ([P] + 1) into [I] and old [I] into [P]
        _loadI
        mvnw
        BL
        mvwn
        _saveP

## 3. Parameter and Return Stacks

    pull :  ; uses A as stack pointer
        incm
        _load
        
    push :  ; uses A as stack pointer
        decm
        _save
    
    pushR :
        mvwi R
        _pull

    pullR :
        mvwi R
        _push

    pushS :
        mvwi S
        _push

    pullS :
        mvwi S
        _pull

## 4. Forth's primitives

    >R :    ;  S> to >R
        _pullS
        mvtw       
        _pushR

    R> :    ; R> to >S
        _pullR
        mvtw
        _pushS

    @R :
        mvwi R
        _load

    @S :
        mvwi S    
        _load

    @ : ( a -- w )
        _pullS
        _load

    ! : (  w a -- )
        _pullS
        mvnw
        _pullS 
        mvtw
        mvwn
        _save

    nand : ( w2 w1 -- w1 nand w2)
        _pullS
        mvtw
        _pullS
        natw
        _pushS

    2* : (w -- w + w )
        _pullS
        mvtw
        sums
        _saveS    
        
    + : ( w2 w1 -- w1 + w2 )
        _pullS
        mvtw
        _pullS
        sums 
        _saveS

    +! : ( u w -- ) 
        _pullS
        mvnw
        _load
        mvtw
        _pullS
        sums
        mvnw
        _save

    drop :
        _pullS

    dup :
        _pullS
        mvtw
        _pushS
        _pushS

    swap :
        >R
        _pullS
        mvnw
        R>
        mvwn
        mvtw
        _pushS

    over :
        >R
        _pullS
        mvnw
        mvtw
        _pushS
        R>
        mvwn
        mvtw
        _pushS

    rot :
        >R
        swap
        R>
        swap

    zero:
        mvtz
        _pushS
    
    one:
        mvtz
        inct
        _pushS
    
    two:
        mvtz
        inct
        inct
        _pushS

    false:
        zero
    
    true:
        zero
        nand

    invert :
        _pullS
        mvtw
        natw
        _pushS

    or : 
        invert
        swap
        invert
        nand    
    
    and:
        nand
        invert

    negate:
        invert
        one
        +

    - :
        negate
        +


