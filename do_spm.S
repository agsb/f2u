.section .text
.set _pc = .
.org 0xC00

; optiboot do_spm routine uses:
;	r25,r24 as page pointer, r21:r20 as data, r22 as command
;	r31:r30, r1:r0, do_spm internal 
;	not preserved
;
PAGESIZE = SPM_PAGESIZE	; pagesizeb in bytes
;
; copy from flash page into sram buffer:
;	(a -- )

HEADER "(copy_page)", "copy_page"
	NOOP
	pspull ips_low, ips_high
	; save psp 
	rspush psp_low, psp_high
	; define sram buffer
	ldi r26, lo8(SPM_BUFF)
	ldi r27, hi8(SPM_BUFF)
	; define flash origin
	lsl ips_high
	rol ips_low
	; counter
	ldi wrk_low, PAGESIZE
1:
	lpm r0, Z+
	st X+, r0
	dec wrk_low
	brne 1b
;	load psp
	rspull psp_low, psp_high
	POON

; update sram 

HEADER "(fill_buff)", "fill_buff"
	NOOP
	pspull tos_low, tos_high
	pspull wrk_low, wrk_high
    ldi nds_low, 0x01
    rjmp do_exec_spm

HEADER "(erase_page)", "erase_page"
	NOOP
	pspull wrk_low, wrk_high
    ldi nds_low, 0X03
	rjmp exec_spm

HEADER "(write_page)", "write_page"
	NOOP
	pspull wrk_low, wrk_high
    ldi nds_low, 0X05
	rjmp exec_spm

exec_spm:
    clr r21
    clr r20
do_exec_spm:
	rcall do_spm
	POON

; optiboot do_spm
;	flash page in r31:r30,	input from r25:r24
;	data in r1:r0,			input from r21:r20
;	command in r22,			command in r22
; 
do_spm:
 ; does spm
    movw    r30, r24
    movw    r0, r20
    out     0x37, r22   ; 55
    spm

 ; why here :?
    eor     r1, r1

 spm_wait:
 ;   wait till spm done
    in      r0, 0x37    ; 55
    sbrc    r0, 0
    rjmp    spm_wait

 spm_vrfy:
 ;   any ERS/WRT bits, end
    andi    r22, 0x06   ; 6
    breq    spm_end
 ;   data not zero, end
    or      r20, r21
    brne    spm_end

 spm_rww:
 ;   enable rww section
    ldi     r24, 0x11   ; 17
    out     0x37, r24   ; 55
    spm

 spm_end:
    ret

.org _pc

