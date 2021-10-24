Minimal.md

# Minimal

what could be a minimal cpu ?

Suppose a address and data bus of same quantity of bits 
A register W, a register T, a register N, A addresss memory bus port M, a data memory bus port D
Reserved memory address I, P, S, R, N

operations:

    moves into w
    0x00    movw w, w
    0x01    movw w, t
    0x02    movw w, n
    0x03    movw w, [A]
    
    moves from w
    0x04    movw A, w
    0x05    movw t, w
    0x06    movw n, w
    0x07    movw [A], w
    
    unary in t
    0x08    tst t, 0
    0X09    movi t, 0
    0x0A    t++
    0x0B    t--

    binary in t, w
    0x0C    nand t, w
    0x0D    sums t, w

    complementary 
    0x0E    movi w, value
    0x0F    halt

load :
    movw A, w
    movw w, [A]
    
save :
    movw A, w 
    movw w, t
    movw [A], w 

incM :
    load
    movw t, w
    t++
    save
    
decM :
    load
    movw t, w
    t--
    save
    
pull :
    incm
    load
    
push :
    decm
    save
    
Forth

    >R :
        movi w, S
        pull
        movw t, w
        
        movi w, R
        push

    R> :
        movi w, R
        pull
        movw t, w
        movi w, S
        push

    @R :
        movi w, R
        load

    @S :
        movi w, S    
        load

    @ : ( a -- w )
        movi w, S
        pull
        load

    ! : (  w a -- )
        movi w, S
        pull
        movw n, w
        movi w, S
        pull 
        movw t, w
        movw w, n
        save

    2* : (w -- w+w )
        movi w, S
        pull
        movw t, w
        sums t, w
        movi w, S
        save


    + : ( u v -- u + v )
        movi w, S
        pull
        movw t, w
        movi w, S
        pull
        sums t, w
        movi w, S
        save

    +! :
        movi w, S
        pull
        movi t, w
        movi w, S
        pull
        load
        sums
        movi w, S
        push

    S! :
    
    S@ :
