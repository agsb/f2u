
Simple Assembly Code Example for a Boot Loader
;-the routine writes one page of data from RAM to Flash
; the first data location in RAM is pointed to by the Y pointer
; the first data location in Flash is pointed to by the Z-pointer
;-error handling is not included
;-the routine must be placed inside the boot space
; (at least the Do_spm sub routine). Only code inside NRWW section can
; be read during self-programming (page erase and page write).
;-registers used: r0, r1, temp1 (r16), temp2 (r17), looplo (r24),
; loophi (r25), spmcrval (r20)
; storing and restoring of registers is not included in the routine
; register usage can be optimized at the expense of code size
;-It is assumed that either the interrupt table is moved to the Boot
; loader section or that the interrupts are disabled.
.equ PAGESIZEB = PAGESIZE*2 ;PAGESIZEB is page size in BYTES, not words
.org SMALLBOOTSTART
Write_page:
; Page Erase
ldi spmcrval, (1<<PGERS) | (1<<SPMEN)
rcall Do_spm
; re-enable the RWW section
ldi spmcrval, (1<<RWWSRE) | (1<<SPMEN)
rcall Do_spm
; transfer data from RAM to Flash page buffer
ldi looplo, low(PAGESIZEB) ;init loop variable
ldi loophi, high(PAGESIZEB) ;not required for PAGESIZEB<=256
Wrloop:
ld r0, Y+
ld r1, Y+
ldi spmcrval, (1<<SPMEN)
rcall Do_spm
adiw ZH:ZL, 2
sbiw loophi:looplo, 2 ;use subi for PAGESIZEB<=256
brne Wrloop
; execute Page Write
AVR 8-Bit Microcontroller
BTLDR - Boot Loader Support – Read-While-Wri...
© 2017 Microchip Technology Inc. Datasheet Complete 40001974A-page 282
subi ZL, low(PAGESIZEB) ;restore pointer
sbci ZH, high(PAGESIZEB) ;not required for PAGESIZEB<=256
ldi spmcrval, (1<<PGWRT) | (1<<SPMEN)
rcall Do_spm
; re-enable the RWW section
ldi spmcrval, (1<<RWWSRE) | (1<<SPMEN)
rcall Do_spm
; read back and check, optional
ldi looplo, low(PAGESIZEB) ;init loop variable
ldi loophi, high(PAGESIZEB) ;not required for PAGESIZEB<=256
subi YL, low(PAGESIZEB) ;restore pointer
sbci YH, high(PAGESIZEB)
Rdloop:
lpm r0, Z+
ld r1, Y+
cpse r0, r1
rjmp Error
sbiw loophi:looplo, 1 ;use subi for PAGESIZEB<=256
brne Rdloop
; return to RWW section
; verify that RWW section is safe to read
Return:
in temp1, SPMCR
sbrs temp1, RWWSB ; If RWWSB is set, the RWW section is not ready yet
ret
; re-enable the RWW section
ldi spmcrval, (1<<RWWSRE) | (1<<SPMEN)
rcall Do_spm
rjmp Return
Do_spm:
; check for previous SPM complete
Wait_spm:
in temp1, SPMCR
sbrc temp1, SPMEN
AVR 8-Bit Microcontroller
BTLDR - Boot Loader Support – Read-While-Wri...
© 2017 Microchip Technology Inc. Datasheet Complete 40001974A-page 283
rjmp Wait_spm
; input: spmcrval determines SPM action
; disable interrupts if enabled, store status
in temp2, SREG
cli
; check that no EEPROM write access is present
Wait_ee:
sbic EECR, EEWE
rjmp Wait_ee
; SPM timed sequence
out SPMCR, spmcrval
spm
; restore SREG (to enable interrupts if originally enabled)
out SREG, temp2
ret
