MemoryModel.md


** this file is a stub **

# Memory Layout 

For the AVR Atmega328, by Harvard architeture, memory is separed in 1024 bytes eeprom, 2024 bytes static ram, 8192 words flash. Consider a byte is 8 bits and a word is 16 bits. A cell is a 16 bits word.

1. Static ram layout
    
- 0x000 to 0x01f  registers r0 to r31

- 0x020 to 0x05f  i/o memory mapped

- 0x060 to 0x0FF  extra i/o mapped

- 0x100 to 0x8FF  free ram

2. Flash memory layout

- 0x000 to 0x3fff 256 program memory, as pages of 64 bytes, 
    
- 0x000 to 0x3dff RWWM read, erase, write flash memory
    
- 0x3e00 to 0x3fff NRWW read only boot area, where optiboot resides

3. Optiboot 

    0x3e00 optiboot main, handles boot and flash updates
    
    0x3fb0 do_spm routine for runtime update flash memory
    
# Memory Model

## the sram are mapped as:

grows upwards:

0x060   start of non volatile, cells that need be periodic saved to eeprom
       
        VOID,   ever zero
        SEED,   seed for pseudo random
        TURN,   routine to run after boot
        REST,   routine to run before reset
        LIST,   reference to last word in flash dictionary
        LAST,   next free cell in flash dicitionary (forward)
        HEAP,   next free cell in static ram (backward)
        KEEP,   next free cell in eeprom (forward)

0x070   start of volatiles

        STAT,   hold state of interpreter
        BASE,   hold radix for numbers
        PAGE,   hold page flash
        TOIN,   offser in TIB
        
        TIB0,   start of TIB terminal input buffer, 72 bytes
        
        RS0,     top of forth return stack, 36 bytes, 18 celld, backwards
        PS0,     top of forth data stack, 36, 18 cells, backwards
        SP0,     top of system stack, 36, 18 cells, backwards
        
        CURS,   cursor forward in sram

note: system stack is for extra libraries, not for forth
Use of memory

There no way to run forth in sram only, then the dictionary goes to flash
and values and variables goes to sram.

For easy, any reference less than SRAM_END are mapped in sram else in flash.

So, the bios (basic input output system) follow avr interrupt table, 
and forth core start at address of sram_end plus one. 

The gap between bios_end and forth_ini, could be used to expand bios
routines and store default messages.

4. Buffers, reserved for Forth

TIB     terminal input buffer, 72 bytes

TIB is less than Forth standart, but as "column 72 is continue", is enough;

5. Constants, inline

SP0     top of mcu stack reserved

PS0     top of forth parameter stack

RS0     top of forth return stack

TIB0    top of terminal input buffer

DP0     next cell at flash memory

UP0     next cell at static memory

EP0     next cell at eeprom

BASE0   default base radix (10)

SPZ     size of stack (18 cells)

PSZ     size of stack (18 cells)

RSZ     size of stack (18 cells)

TIBZ    size of TIB (72 bytes)

VERS    version (2 bytes) from 0.00.00 to 6.55.36 as release.version.revision

6. Flags defined, inline

CELL_SIZE   size of a cell in bytes, 2

WORD_SIE    size of maximum word, 15

F_IMMEDIATE     flag for immediate words, 0x80

F_COMPILE       flag for compile only words, 0x40

F_HIDDEN        flag for temporary hidden word, 0x20

F_GLOBBER       reserved, 0x10

TRUE    -1

FALSE    0

7. Ascii control, inline

very minimal edit, 
    
    assuming all edition is done by terminal program at host

    all extras are ignored,  

    all are translated to uppercase.

BS      0x08    \b, ^H

LF      0x0A    \n, ^J

CR      0X0D    \r, ^M

BL      0x30    whitespace

XON     0x11    ^Q

XOFF    0x13    ^S
