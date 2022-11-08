<< this file is stil a stub >>


# Comparative use of registers, from avr forths

## f2u

  used in forth:
  
    Z(R30, R31) : avr exclusive access flash and sram
    Y(R28, R29) : parameter stack, 18 words deep
    X(R26, R27) : return stack, 18 words deep
    T(R24, R25) : TOS 
    N(R22, R23) : used as NOS, pulled when need
    W(R20, R21) : used as WRK, scratch
  
  used in bios and interrupts:
  
    SP: not used, 18 word deep
    R0, R1 reserved for avr inside routines
    R2, R3 _work_ and _zero_
    R4, R5 _offset_ and _sreg_ 
    R6, R7 clock tick counter in milliseconds
    R16, R17 reserved
  
## flash forth https://flashforth.com/atmega.html

    SP: The return stack pointer
    Y(R28, R29) : The parameter stack pointer
    X(R26, R27), Z(R30, R31): Temporary data and pointers
    R24, R25: Cached TOS value
    R22, R23: Internal flags
    R20, R21: The P register
    R18, R19: The A register
    R0, R1, R16, R17: Temporary data for assembler words.
    R4, R12, R13: CPU load measurement result (optional).
    R14, R15: Millisecond counter.
    R10, R11: Buffered flash page address.
    
## am-forth https://amforth.sourceforge.net/TG/AVR8.html#avr8-register-mappings

    Forth Register 	ATmega Register(s)
    R22:R23 W: Working Register 
    R26:R27 IP: Instruction Pointer	XH:XL
    SPH:SPL RSP: Return Stack Pointer SPH:SPL
    R28:r29 PSP: Parameter Stack Pointer YH:YL 
    R4:R5   UP: User Pointer
    R24:R25 TOS: Top Of Stack 
    R30:R32 X: temporary register ZH:ZL

