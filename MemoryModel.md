MemoryModel.md

# Memory Layout 

For the AVR Atmega8, by Harvard architeture, memory is separed in 512 bytes eeprom, 1024 bytes static ram, 4096 words flash. Consider a byte as 8 bits and a word as 16 bits. A cell is a 16 bits word.

1. Static ram layout
    
    0x000 to 0x01f  registers r0 to r31
    
    0x020 to 0x05f  i/o memory mapped
    
    0x060 to 0x45f  free ram

2. Flash memory layout

    0x000 to 0x1fff 128 program memory, as pages of 64 bytes

# Memory Model

the sram are mapped as:

    grows downwards:

    0x060   forth variables, 12 cells

    0x078   start of terminal input buffer, 72 bytes

    0x0C0   start of scratch pad buffer, 32 cells
    
    0x100   start of user ram, 740 bytes

    0x3e3   start of hold buffer, 16 bytes

    grows upwards:

    0x3f3   start stacks area

    0x417   top of parameter stack, 36, 18 cells

    0x43b   top of return stack, 36, 18 cells

    0x45f   top of stack pointer, 36, 18 cells

note: last stack is for extra libraries, not for forth    

## Use of memory

### 1. Buffers, reserved for Forth

    TIB     terminal input buffer, 72 bytes
    
    PAD     scratch pad , 64 bytes
    
    HLD     reserved for numeric convertion, 16 bytes

    Notes:
    
    TIB is less than Forth standart, but as "column 72 is continue", is enough;
    
    PAD is for buffer compile words and flush to flash
    
    HLD if for use in numeric format

### 2. Variables non volatile, cells that need be periodic saved to eeprom

    void    always zero, 2 bytes
    
    turn    routine to run after boot, 2 bytes
    
    latest  last entry in dictionary, 2 bytes
    
    seed    seed for ramdom routine, 2 bytes
    
    dp      next free cell in flash memory, 2 bytes
    
    up      next free cell in sram memory, 2 bytes
    
    ep      next free cell in eeprom, 2 bytes

    last    next free cell at flash, for flush

    temp    temporary use

### 3. variables volatiles, use as half cells

    state   state of interpreter, 1 byte
    
    base    numeric radix, 1 byte
    
    tibc    cursor in TIB as offset, 1 byte, also >IN
    
    hldc    cursor in HLD as offset, 1 byte
    
    padc    cursor in PAD as offset, 1 byte
    
    fmpg    page of flash memory to update, 1 byte

### 4. Stacks

    SP      reserved for mcu stack, 36 bytes
    
    PS      parameter stack, 36 bytes
    
    RS      return stack, 36 bytes

### 5. Constants, inline

    SP0     top of mcu stack reserved

    PS0     top of forth parameter stack

    RS0     top of forth return stack
    
    TIB0    top of terminal input buffer
    
    PAD0    top of scratch pad buffer
    
    HLD0    top of numeric format buffer
    
    DP0     next cell at flash memory
    
    UP0     next cell at static memory
    
    EP0     next cell at eeprom
    
    BASE0   default base radix (10)
    
    SPZ     size of stack (18 cells)
    
    PSZ     size of stack (18 cells)
    
    RSZ     size of stack (18 cells)
    
    TIBZ    size of TIB (72 bytes)
    
    PADZ    size of PAD (64 bytes)
    
    HLDZ    size of HLD (16 bytes)
    
    VERS    version (2 bytes) from 0.00.00 to 6.55.36 as release.version.revision

### 6. Flags defined, inline

    CELLZ   size of a cell in bytes, 2
    
    WORDZ   size of maxim word, 15

    F_IMMEDIATE     flag for immediate words, 0x80
    
    F_COMPILE_ONLY  flag for compile only words, 0x40
    
    F_HIDDEN        flag for temporary hidden word, 0x20
    
    F_GLOBBER       reserved, 0x10

    TRUE    -1

    FALSE    0

### 7. Ascii control, inline

    NIL     0x00    \0, ^@

    ETX     0x03    ^C

    EOT     0x04    ^D
    
    BELL    0x07    \a, ^G

    BS      0x08    \b, ^H

    TAB     0x09    \t, ^I

    LF      0x0A    \n, ^J

    VT      0x0B    \v, ^K

    FF      0x0C    \f, ^L

    CR      0X0D    \r, ^M

    XON     0x11    ^Q

    XOFF    0x13    ^S

    CAN     0x18    ^X

    ESC     0x1B    \e, ^[

    SPC     0x30    whitespace



