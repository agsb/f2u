Details.md

# Specifics

## For ATmega8 MCU,  UPDATE: ATmega328

- a using Opitboot for flashing and boot;
- a internal clock of 8.00 MHz or external 7.68 MHz;
- a uart at 9600, 8-N-1, asynchronous, maybe 19200;
- a timer at 1ms with 16 bits counter  ~ 65 s;
- a watch dog at ~ 2.0 s;
- a pseudo 16bit random generator; 
- a adapted djb hash generator for 16bits;
- all 8bits and 16bits math from AVR200 manual;
    
> need explain update/flush flash memory using a sram buffer

## For Forth,

- all dictionary in flash;
- all forth constants in flash;
- all values and variables in sram;
- eeprom preserves some variables and constants;
- a cell is 16 bits;
- little endian, low byte at low address;
- a char is ASCII 7 bits, one byte at SRAM, one cell at stacks.
- _maximum word lenght is 15_;
- four bits flags (SPECIAL, IMMEDIATE, COMPILE_ONLY, HIDDEN/SMUDGE) per word;
- _word names are padded with space (0x20)_
- numbers are signed two-complement;
- all stacks are 18 words (cells);
- _TIB, terminal input buffer is 72 bytes_;
- flash page buffer syncronous in sram;
- PAD, offset is 36 bytes (2*16+4);
- _all buffers ends in \0;
- one interrupt is timer0;
- still interrupts can't be nested, SREG breaks;
  
## Forth non conforming,

- SMUGDE or HIDDEN bit not used, dictionary only have complete words.
- SPECIAL marks a byte as size and flags;
- LEAP marks a pure assembler chain routine with no calls or jumps.
- primitive (Leaf) routine does not do any calls. 
- compound (Twig) routines could do any calls.
- FOR NEXT counts downwards until 0, easy ever;
- no bounds check, none.
- compare bytes: COMPARE return FALSE or TRUE, only;
- copy bytes : copy bytes, forward until counter is zero
- skip bytes : compare bytes, if equal then increments else return
- scan bytes : compare bytes, if not equal then increments else return
- word names lenght can be 1 to 15, padded with space (0x20);


## Details on Atmega*8
    
- All references are done using of indirect LD and ST with Z, Y, X, 16 bits registers;   
- All primitive words finish with a rjmp _link, so the (inner + primitives) must be less than +2k words;
- The address pointer is Z (r31:r30) for lpm/spm (flash), lds (sram), sts (sram) instructions

- The parameter stack pointer is Y (r28:r29) for forth return stack;
- The return stack pointer is X (r26:r27) for forth data stack;
- A TOS, top on parameter stack is T (r24:r25) for forth as acumulator register;
- A NOS, work register, pull next on parameter stack, is N (r22:r23);
- A WRK, work register, generic auxiliary parameter,  is W (r20:r21);

The TOS is really a Acumulator, as in most CPUs, Z is a Address register, 
    Y and X are stack pointers, WRK and NOS are general registers.

## Registers Use

- reserved r0:r1, used as generic scratch for internal routines (mul, div, etc)
- reserved r2, as generic _SREG_ 
- reserved r3, as timer0 offset delay
- registers r4:r5 reserved for keep 1ms clock ticks counter
- reserved r6 as always _zero_, keep by timer0 interrupt ;)
- register r7 as always _work_, scratch

- registers r8::r19 are free

## Details

- Not using of SP intructions (pop, push, call, ret), leaving those for external extensions and libraries;
- Only using IJMP to primitives else use indirect push and pull for references address;
- Using a optiboot routine to do flush of flash memory update

## Memory Use

ATmega8:

for a 512 boot:

- flash memory from $000 to $FFF ($0000 to $1FFF bytes), splits in read-write flash RWW($000 to $BFF) and no-read-rwrite flash NRWW($C00 to $FFF).

- sram memory from $060 to $45F (1024 bytes)

ATmega328:
        
for a 512 boot:
        
- flash memory from $0000 to $3FFF ($0000 to $3FFF bytes), splits in read-write flash RWW($000 to $3DFF) and no-read-rwrite flash NRWW($3E00 to $3FFF).

- sram memory from $100 to $8FF (2048 bytes)

## ISO Standarts

References:

- ISO/IEC 646, ISO 7-bit coded character set for information interchange.

- ANSI X3.215-1994, Technical Committee X3J14.

- ISO/IEC 9899, language C standart, http://www.open-std.org/jtc1/sc22/wg14/www/docs/n1256.pdf. ;0 Joke ;)

## Bootstrap fuses

from https://www.engbedded.com/conffuse/

BOOTRST, Flash boot size=256 words Boot address= $0F00

EESAVE, preserve eeprom

SPIEN, serial program downloading SPI enable

SUT_CKSEL, Int Osc, 8MHz; startup time 6CK + 64ms

BODEN, Brown-out detector VCC=2,7V

high 0xD4, low  0xA4 (0xA0 for external clock, 16Mhz)

AVRDUDE:

-U hfuse:w:0xd4:m -U lfuse:w:0xa4:m

