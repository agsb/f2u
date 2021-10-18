

  10/06/2021, Still no operational

    The basic functional words are done, as minimal set for parse, find, evaluate, number, create, does;
    
    Controls
    a)  testing top of stack:
      
      *standart implementation for*
      (if ... else ... then ...), forward jumps, (1)
      (begin ... again), inconditional backward jump, (2)
      (begin ... until), conditional backward jump, (2)
      
      *non-standart implementation for*
      (while ... repeat), conditional forward jump and inconditional backward jump, (3)
      (while ... again), maybe ?
      att: *repeat jumps to while*, both independent of begin.
    
    b) testing values on return stack *not for now* 
      why not variables I, J, K ? I dont like using return stack for loops.
      (do ... leave ... loop), counter backward jump, test at loop
      (for ... next), counter backward jump, test at for

  12/05/2021,  Still no operational
  
    Start basic assembler for parse, find, evaluate, number, create, does;
    Defined specific functions for flash memory. All changes at dictionary are done in a buffer sram. 
    Created routines, a *flash* for init the buffer, from flash page of HERE, and a *flush* for copy to flash update
  
  08/04/2021, resumes from 2020
  
    The inner interpreter is done and is very small and effcient;
  
    The primitive words are done, as minimal set from forth plus some extras;
  
    But I'm at easter egg of forth:
      I have sources of words as ": word ~~~ ;" and I need a forth done to compile or
      I have sources of words compiled with some forth and need use same forth engine;
  
    Then sectorforth (https://github.com/cesarblum/sectorforth) comes to simplifly all, and I restart again.
  
    The optiboot v8.0 could do program flash memory, as do_spm, so will use it as boot loader.
  