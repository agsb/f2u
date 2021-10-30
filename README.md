# f2u

718525ae-a057-11eb-a679-ebc1ee2a486b Sun, 18 Apr 2021 12:04:59 -0300

# *"To master riding bicycles you have do ride bicycles"*

## This is still just a "brainstorm", really is a documentation of changes. 
---
# Table of Contents
* [Introduction]
* [Size or Speed]
* [Details]

This is a evolution from what I learning with u2forth, ATMEGA8, gcc assembler and forth implementations as 328eforth, eforth, amforth, avr-forth, gforth, flashforth, punyforth, etc 

Some special insights from jonasforth (https://rwmj.wordpress.com/2010/08/07/jonesforth-git-repository/ https://github.com/nornagon/jonesforth), sectorforth (https://github.com/cesarblum/sectorforth), and lbforth (https://github.com/larsbrinkhoff/lbForth/)


(I need to learn how to use and format with .md)

https://github.com/matiassingers/awesome-readme

https://silentlad.com/how-to-write-beautiful-and-meaningful-readme.md

# Introduction

*In the chat session Chuck was asked, "How did you come to the conclusion that Forth was too complex, and that sourceless programming was your next move?" His reply was, "Maybe by reading the Forth Standard." [Moore, 2002] <http://www.ultratechnology.com/levels.htm>*

Forth is language based in thread code, with a dictionary of words as named routines and two stacks for arguments in a forever read–eval–print-loop.

The dictionary is a linked list of words, each with name and code. It have two types of words, those called primitives, ad leaves, which are coded in specific CPU or MCU instructions, and those called compounds, ad twigs, which are sequences with references to words.
 
*"A most important aspect of FORTH is its ability to define new words. New definitions and code are devised continously. Likewise, new constants or variables are created.", Rather, Moore, Hollis, https://library.nrao.edu/public/memos/comp/CDIR_17.pdf*

I want a forth with:

- a minimal inner interpreter and primitives words (clock, uart, interrupts, stacks, math, moves) dependent of a MCU family;

- all compound words independent of any specific MCU family, without any assembler specifc code inline, like a imutable list with rellocable references.

The dictionary then will a unique linked list composed by  a) a link for previous word's link, b) a byte with size of name plus flags, c) a sequence of characters of name and d) a sequence of, or references or assembler code.

The word names are full preserved, not hashed, not lowered, for trace back compound words, word by word.
# Size or Speed

*"Keep it Simple"*

Most of Forth implementations goes "runnig for speed" for timming applications or simply to be "the most faster than", but when memory space is the critical limit most of design decisions must take another path.

A MCU 32 bits, as ARM Cortex-M4 STM32L4+ with 2048k bytes flash and 640k bytes sram, really have 512k flash mcu words and 160k mcu words sram. Sure, that is much more than enough to run Forth.

But my choice for design is a small AVR Atmega8, a complete RISC MCU with harvard memory architeture, 4k words (16-bits) program flash memory, 1k bytes (8-bits) static ram memory, 512 bytes of EEPROM,  memory-mapped I/O, one UART, one SPI, one I2C, with 32 (R0 to R31) 8 bits registers, with some that could be used as eight (R16 to R31) 16 bits registers. 
## A challenge.

There are many low cost MCU with far more resources and pleny of SRAM and flash. Why use an old MCU for hosting Forth ?

Most to refine language paradigms and understood manage memory, RAM and FLASH, and how forth works inside, looking from behind the stacks.

Many challenges to resolve, how make a minimal bios, what basic word must set, how update flash memory, how access internal resources, etc. Learn from previous many implementations of Forth and adapt to survive.

For comparation, in 1979, the Von Newman architeture PDP-11, Programmed Data Processor, was also eight 16-bit registers, (including one stack pointer R6, and one program counter R7), memory mapped devices,but with unifed memory addressing. <http://bitsavers.trailing-edge.com/pdf/dec/pdp11/handbooks/PDP11_Handbook1979.pdf>.

The PDP-11 had successful implementations of Forth, by Charles H. Moore reported in 1974, <https://library.nrao.edu/public/memos/comp/CDIR_17.pdf>, and a Fig-Forth by Johm S. James in 1980.

In back 1968, Charles H. Moore creates Forth in a IBM-1130, <https://github.com/monsonite/1968-FORTH>,"The IBM 1130 was a fairly simple 16-bit computer, with a load-store architecture, a single accumulator and three index registers X1, X2, X3, stored at locations 01, 02, 03 in the core memory." <https://github.com/monsonite/1968-FORTH>

There are also Forth implementations for many AVR RISCs, mostly for the larger ones like Amforth, Avrforth, CamelForth, Eforth, Flashforth. Studying these codes, as references for models and styles, has been an excellent learning experience for comparing solutions and techniques. 

## Forth

amForth: Matthias Trute - http://amforth.sourceforge.net/

FlashForth: Mikael Nordman - http://flashforth.sourceforge.net/

CamelForth: Brad Rodriguez - http://www.camelforth.com

avrforth: Daniel Kruszyna - http://krue.net/avrforth/

Fig-Forth: John S. James - http://www.forth.org/fig-forth/fig-forth_PDP-11.pdf


## Licensing:

GNU Public License v2 (GPL)

