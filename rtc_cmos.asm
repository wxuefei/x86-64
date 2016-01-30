
; Distributed under GPL v1 License
; All Rights Reserved.


init_ps2Mouse:

    align 8
rtc_int:
	pushf
	push	rax rcx rsi rdi

	mov	eax, 0xc
	out	0x70, al
	in	al, 0x71

	add	byte [qword 8], 1

;lea rax, [rsp-40]
;reg rax, 101f
;jmp $

	mov	dword [qword lapic + LAPIC_EOI], 0
	pop	rdi rsi rcx rax
	popf
	iretq

; Check number of times we received periodic interrupt - if update-ended was set (we need this flag).
; If no flag, then enable separate update-ended interrupt (which result in update-ended flag set)
;      to read date/time, which is only safe to read if no update-in-progress happening


; pnp0b00

;===================================================================================================

    align 8
rtc_init:
	push	rax rcx

	; driver needs to tell OS if it is its interrupt arrived for shared int handler

	pushf
	cli

	mov	eax, 0x8b
	out	0x70, al	; select B register, and disable NMI(bit7)
	in	al, 0x71	; read from B

	and	eax, 10001111b
	or	eax, 01000000b	; enable periodic only
	mov	ecx, eax

	mov	eax, 0x8b
	out	0x70, al
	mov	eax, ecx
	out	0x71, al	; write to B

	mov	r8d, 0111b	; 512 times a second  (once per 1.953125 ms)
	call	rtc_setRate

	mov	eax, 0xc
	out	0x70, al
	in	al, 0x71
	popf

	mov	eax, 0xc
	out	0x70, al
	in	al, 0x71

	pop	rcx rax
	ret

;===================================================================================================
; input: r8 = 4bit rate

    align 8
rtc_setRate:
	push	rax rcx
	cmp	r8, 2
	jb	k64err
	and	r8d, 15
	mov	eax, 0x8a
	out	0x70, al
	in	al, 0x71
	and	eax, 0xf0
	or	eax, r8d
	mov	ecx, eax
	mov	eax, 0x8a
	out	0x70, al
	mov	eax, ecx
	out	0x71, al
	pop	rcx rax
	ret

;value	times per second
;----------------------
; 0010b  128
; 0100b  4096
; 0110b  1024
; 1000b  256
; 1010b  64
; 1100b  16
; 1110b  4
; 0001b  256
; 0011b  8192
; 0101b  2048
; 0111b  512
; 1001b  128
; 1011b  32
; 1101b  8
; 1111b  2



; 0xA Status Register A (read/write)
;-------------------------------------------------
;  Bit 7     - (1) time update cycle in progress, data ouputs undefined
;				   (bit 7 is read only)
;  Bit 6,5,4 - 22 stage divider. 010b - 32.768 Khz time base (default)
;  Bit 3-0   - Rate selection bits for interrupt.
;				   0000b - none
;				   0011b - 122 microseconds (minimum)
;				   1111b - 500 milliseconds
;				   0110b - 976.562 microseconds (default)

;0xB Status Register B (read/write)
;-------------------------------------------------
;  Bit 7 - 1 enables cycle update, 0 disables
;  Bit 6 - 1 enables periodic interrupt
;  Bit 5 - 1 enables alarm interrupt
;  Bit 4 - 1 enables update-ended interrupt
;  Bit 3 - 1 enables square wave output
;  Bit 2 - Data Mode - 0: BCD, 1: Binary
;  Bit 1 - 24/12 hour selection - 1 enables 24 hour mode
;  Bit 0 - Daylight Savings Enable - 1 enables

;0xC Status Register C (Read only)
;-------------------------------------------------
;  Bit 7 - Interrupt request flag - 1 when any or all of bits 6-4 are
;			  1 and appropriate enables (Register B) are set to 1. Generates
;			  IRQ 8 when triggered.
;  Bit 6 - Periodic Interrupt flag
;  Bit 5 - Alarm Interrupt flag
;  Bit 4 - Update-Ended Interrupt Flag
;  Bit 3-0 ???
