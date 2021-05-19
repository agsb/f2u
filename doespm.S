; from avr 
; Flash memory read, write, and erase.
.equ    PAGESIZEB = PAGESIZE*2 ;PAGESIZEB is page size in BYTES, not
words
.def    spmcrval = r20
.def    looplo = r22
.def    loophi = r23
; Page Erase
;   ERASE ( a -- )
;   Erase a page of flash memory

    COLON   5,"ERASE"
ERASE:
    movw    zl,tosl
    loadtos
ERASE_1:
    ldi     spmcrval, (1<<PGERS) | (1<<SELFPRGEN)
    rcall   Do_spm

; re-enable the RWW section
    ldi     spmcrval, (1<<RWWSRE) | (1<<SELFPRGEN)
    rjmp    Do_spm

; Page Write
;   WRITE ( ram flash -- )
;   transfer data from RAM to Flash page buffer

    COLON   5,"WRITE"
WRITE:
    movw    zl, tosl
    loadtos
    movw    xl, tosl
    loadtos

WRITE_1:
    ldi     looplo, low(PAGESIZEB) ;init loop variable

Wrloop:
    ld      r0, X+
    ld      r1, X+
    ldi     spmcrval, (1<<SELFPRGEN)
    rcall   Do_spm
    adiw    ZL, 2
    subi    looplo, 2 ;use subi for PAGESIZEB<=256
    brne    Wrloop

; never will work, Z must have the page to write NOT the size of page!

; execute Page Write
    subi    ZL, low(PAGESIZEB) ;restore pointer
    sbci    ZH, high(PAGESIZEB) ;not required for PAGESIZEB<=256
    ldi     spmcrval, (1<<PGWRT) | (1<<SELFPRGEN)
    rcall   Do_spm

; re-enable the RWW section
    ldi     spmcrval, (1<<RWWSRE) | (1<<SELFPRGEN)
    rjmp    Do_spm

; Page Read
;   READ ( flash ram -- )
;   transfer data from Flash to RAM page buffer

    COLON   4,"READ"
READ:
    movw    xl,tosl
    loadtos
    movw    zl,tosl
    loadtos
READ_1:
; read back and check, optional
    ldi     looplo, low(PAGESIZEB) ;init loop variable

Rdloop:
    lpm     r0, Z+
    st      X+, r0
    subi    looplo, 1 ;use subi for PAGESIZEB<=256
    brne    Rdloop
    ret

Do_spm:
; check for previous SPM complete
Wait_spm:
    in     temp1, SPMCSR
    sbrc   temp1, SELFPRGEN
    rjmp   Wait_spm
; SPM timed sequence
    out    SPMCSR, spmcrval
    spm
    ret

/*
5.5.3    Write to Flash

I! is the most interesting command in the flash memory command set, and needs a
more detailed explanation. Its action follows the follow steps:
1. If the flash page addressed by a is in the NEW buffer, go to step 8.
2. If the flash page addressed by a is in the OLD buffer, go to step 7.
3. If the flash page addressed by a is not in either buffer, test the Dirty Bit in OLD
buffer pointer. If the Dirty Bit is not set, go to step 5.
4. OLD buffer is dirty, flush its contents. Continue to step 5.
5. Read the flash memory page pointed to by address a into the OLD buffer.
6. Update OLD buffer pointer with the page address derived from a. Clear the
Dirty Bit in OLD buffer pointer.
7. Switch contents in OLD and NEW, so that the OLD buffer becomes the most
recently accessed buffer.
8. Write data w into NEW buffer to the address corresponding to a, and set the Dirty
Bit in the NEW buffer pointer.

This scheme of data buffering was first used by Chuck Moore in his implementation
of virtual memory to access data stored on magnetic tapes and on magnetic disks.
He divided all external storage media into blocks of 1024 bytes and manage them
with buffers in RAM. His scheme minimized accesses to external media and
achieved execution speed unheard of on computers of the earlier eras.

*/
