Minimal.md

# Minimal

what could be a minimal cpu ?

Suppose a address and data bus of same quantity of bits 
A register W, a register T, A addresss memory bus port M, a data memory bus port D
Reserved memory address I, P, S, R, N

operations:
    noop
    move value to W 
    
    copy W to A 
    copy D to W 
    copy W to D

    copy W to T
    copy T to W

    Nand T to W 
    Sum  T ro W 

    W++
    W--
    W==

load:
    copy W to A 
    copy D to W 

save:
    copy W to A 
    copy T to W 
    copy W to D 

pull:
    load
    W++ 
    copy W to D
    load

push:
    load 
    W--
    copy W to D 
    save

P++:
    copy 'P' to W 
    pull
    // W contains (P), 
    
Spull:
    copy 'S' to W 
    pull

Spush:
    copy 'S' to W
    push

Rpull:
    copy 'R' to W 
    pull

Rpush:
    copy 'R' to W
    push

T2N:
    copy T to W
    copy W to N 

N2T:
    copy N to W 
    copy W to T 

NAND:
    Spull
    copy W to T
    Spull
    W nand T
    Spush
    
SUMS:
    Spull
    copy W to T
    Spull
    W sums T
    Spush
    
R2S:
    Rpull
    copy W to T 
    Spush
    
S2R:
    Spull 
    copy T to W 
    Rpush 
    
P++:
