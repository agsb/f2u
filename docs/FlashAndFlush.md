FlashAndFlush.md

# Memory Models

*"Do not Speculate"*

Forth born in CPUs with Von Neumann memory paradigm, were instructions and data share same address space and external magnetic devices stores data for permanent read and write cycles. 

Main system routines are stored in Read Only Memory, with reserved address for I/O Mapped Memory, but all Random Access Memory, where Forth lives, can be changed with same CPU instructions.

Modern MCUs uses Harvard memory paradigm, instructions and data do not share continous address, and the program memory is in flash, with about 10.000 cycles of read and write, and static random access memory. 

Those spaces have separated MCUs instructions and processes to be accessed and changed, and this makes a fundamental diference at implementations of Forth.

In AVR MCUs flash memory is erased and writed in pages, with sizes varyng from 32 to 128 words, there is no way to change only one specific word.

Many Forths go around this limitation with schemes of mapping where dictionary is writtren and ping-pong buffers to perform as a transparent, or not, system, some uses explicit sram, eeprom, and flash spaces and leaves for user where and what use.

## how do 

Looking into Forth standarts (79, 83, ANS, 2012, FIG, etc) and implementations, (using mnemonics) there are small lists of 
-  words that changes memory contents as MOVE, FILL; 
- words that changes the dictionary as COMMA (,), CREATE, VARIABLE, CONSTANT, VALUE, DOTSTR (."); 
- words that changes flag bits as IMMEDIATE, COMPILE_ONLY, SMUDGE, TOGGLE; 

All those uses _store_ (!) to move a value into a memory address.

So how _store_ would differentiate a address in flash or sram ?

One simple form is using restrict range of address. In a ATmega8, everthing above 0x460 is flash memory, then if Forth starts at 0x460 in flash, everthing above is dictionary, then both @ and ! must play with address, to resolve if in flash or in sram. This solution maybe not fully portable but works for Atmega8. But is a waste of address.

PS: It also reserves a 1k byte flash for boot routines.

> Still tons of things to play, as buffer for flash pages, incremental flush and flash, etc

# my alternative: 

- _Still not working_

When defining a new word, copy the actual flash page correspondent of DP pointer to sram buffer, start pointers offsets, make the changes into sram buffer and when is full, or at end, flush contents and restart pointers, repeat until done;

When defining words with VARIABLE, CONSTANT, DEFER, IS, TO, ASSIGN, CREATE, \<BUILDS and DOES\> use same aprouch.

# Implementation References

*Do it yourself*

the code field holds "what to do" for the inner interpreter and in classic forth can be one of: 
    
- _nest, push instruction point into return
- _unest, pull instruction point from return
- _exec, jump to next cell 
- _exit, do _unest, do exec
  
- _branch, _zbranch
- _dovar, copy a address in a cell to data, 
- _docon, copy contents of a address in cell to data,
- _dolit, copy next cell to data, advance two cells
- _pushrs, _pullrs, _pushps, _pullps, in return stack or data stack
     
In most forths those are specific inline opcodes 

Since f2u intents a concept of immutable dictionary without inline code, the inner engine only see cells as references with one exception, if a cell reference is 0x0 then next cell is a reference to a leaf, to be executed.

this makes possible no need of CODE in dictionary but costs a comparation and a test at each reference, about 2 cycles in a AVR. the dictionary then is like:
    
a leaf 0x0000, reference for a primitive.
a twig reference, reference, ..., reference, _inner_
yes, _inner_ is a reference to the forth inner engine that does all work,
    
the dictionary order does not matter, but is more easy for future ports that all primitives precede all compounds;

then to port for other MCU or CPU, just rewrote the engine and primitives, change the references of primitives at dictionary and done.
    
      boot+bios+forth+more where 
      boot, setup at boot or reset; 
      bios, routines for input and output devices, 
      forth, code for inner and primitives, 
      more, all forth dictionary immutable.
    

### ; notes

    all internal words defined between parentheses, so user never could use ; 
    the memory model is not unified, separate address for flash and for sdram;
    uses minus one reference execution per each compound word  at cost of a test if NULL

    ??? why all mature forths does inline or code at start of parameters, just for speed ???
