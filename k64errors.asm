
; Distributed under GPLv1 License  ( www.gnu.org/licenses/old-licenses/gpl-1.0.html )
; All Rights Reserved.


;===================================================================================================
;     error handling for the 64bit long mode	////////////////////////////////////////////////////
;===================================================================================================

	align 8
k64err:

.allocLinAddr:

.timerIn_timerCntNot0:
.timerIn_timerCntNot0_1:
.timerIn_timerCntNot0_2:
.lapT_doubleINT:
.lapT_manyTicks:
.lapT_timerCntNot0:
.lapicT_wakeUpAt_smaller:
	jmp	.unknown


.pf_2nd_PF:
	mov	dword [kernelPanic], 0
	jmp	@f
.pf_notAllocated:
	mov	dword [kernelPanic], 1
	jmp	@f
.pf_noHostPagesMapped:
	mov	dword [kernelPanic], 2
	jmp	@f
.pf_invalid_PML4e:
	mov	dword [kernelPanic], 3
	jmp	@f
.pf_invalid_PDPe:
	mov	dword [kernelPanic], 4
	jmp	@f
.pf_invalid_PDe:
	mov	dword [kernelPanic], 5
	jmp	@f
.pf_paging_addr:
	mov	dword [kernelPanic], 6
	jmp	@f
.pf:
	mov	dword [kernelPanic], 7
	jmp	@f
.unknown:
	mov	dword [kernelPanic], 8
	jmp	@f
.GP:
	mov	dword [kernelPanic], 9
	jmp	@f
.DF:
	mov	dword [kernelPanic], 10
	jmp	@f
.P_0:
	mov	dword [kernelPanic], 11
	jmp	@f
.sharedIntHandler:
	mov	dword [kernelPanic], 12
	jmp	@f
.wrongSharedIntCount:
	mov	dword [kernelPanic], 13
	jmp	@f
.shareIndHandler_largeAddr:
	mov	dword [kernelPanic], 14
	jmp	@f
.RTC:
	mov	dword [kernelPanic], 15
	jmp	@f
.lapT_noThreads:
	mov	dword [kernelPanic], 16
	jmp	@f
.timerIn_manyLapTicks:
	mov	dword [kernelPanic], 17
	jmp	@f
.syscall_invalidNum:
	mov	dword [kernelPanic], 18
	jmp	@f
.syscall_returnedErr:
	mov	dword [kernelPanic], 19
	jmp	@f
.thread_sleep_already:
	mov	dword [kernelPanic], 20
	jmp	@f
.thread_sleep_invalidPrevNext:
	mov	dword [kernelPanic], 21
	jmp	@f
.thrd_sleep_afterINT20:
	mov	dword [kernelPanic], 22
	jmp	@f
.timerIn_min10us:
	mov	dword [kernelPanic], 23
	jmp	@f
.timerIn_max1s:
	mov	dword [kernelPanic], 24
	jmp	@f
.lapT_noThreadSleep:
	mov	dword [kernelPanic], 25
	jmp	@f
.devFind_wrongInput:
	mov	dword [kernelPanic], 26
	jmp	@f
.RTC_init1:
	mov	dword [kernelPanic], 27
	jmp	@f
.RTC_init2:
	mov	dword [kernelPanic], 28
	jmp	@f
.RTC_init3:
	mov	dword [kernelPanic], 29
	jmp	@f
.RTC_init4:
	mov	dword [kernelPanic], 30
	jmp	@f
.devFind_wrongHeader:
	mov	dword [kernelPanic], 31
	jmp	@f
.noIOAPICs:
	mov	dword [kernelPanic], 32
	jmp	@f
.rtcNotPresent:
	mov	dword [kernelPanic], 33
	jmp	@f
.notEnoughDevs:
	mov	dword [kernelPanic], 34
	jmp	@f
.smallDevNum:
	mov	dword [kernelPanic], 35
	jmp	@f
.largeDevNum:
	mov	dword [kernelPanic], 36
	jmp	@f
.invalidDevID:
	mov	dword [kernelPanic], 37
	jmp	@f
.intInst_noIoapInfo:
	mov	dword [kernelPanic], 38
	jmp	@f
.intInst_destIoapInptOutsideMem:
	mov	dword [kernelPanic], 39
	jmp	@f
.intInst_nonShared:
	mov	dword [kernelPanic], 40
	jmp	@f
.intInst_noFreeIDTe:
	mov	dword [kernelPanic], 41
	jmp	@f
.madt:
	mov	dword [kernelPanic], 42
	jmp	@f
.fadt:
	mov	dword [kernelPanic], 43
	jmp	@f
.handlerPresent:
	mov	dword [kernelPanic], 44
	jmp	@f
.notMasked:
	mov	dword [kernelPanic], 45
	jmp	@f
.intInst_nonSharedP:
	mov	dword [kernelPanic], 46
	jmp	@f
.maxThread1:
	mov	dword [kernelPanic], 47
	jmp	@f
@@:
	;cli
	;mov	 eax, -1
	;mov	 cr8, rax
	lea	rsp, [interrupt_stack]
	sub	rsp, 128

	cmp	dword [qword vbeLfb_ptr + rmData], 0
	jz	.textMode

;---------------------------------------------------------------------------------------------------
.graphicsMode:

	mov	word [qword txtVidCursor + rmData], 10

	mov	r8, cr2
	mov	r9, rsp
	mov	r12d, 16
	call	regToAsciiHex

	lea	r8, [rsp + 16]
	lea	rax, [text1]
	mov	word  [r8], 10
	mov	word  [r8 + 2], 70
	mov	word  [r8 + 4], 16
	mov	word  [r8 + 6], 0 ;font id
	mov	dword [r8 + 8], 0xff ;color
	mov	word  [r8 + 12], 0
	mov	qword [r8 + 14], rsp
	mov	r9, screen
	call	txtOut_noClip

	mov	edi, [kernelPanic]
	lea	rsi, [k64err_messages]
	movzx	edi, word [rsi + rdi*2]
	lea	rsi, [k64err_messages.0]
	add	rdi, rsi

	mov	rsi, rdi
	mov	ecx, k64err_messages_len
	xor	eax, eax
	repne	scasb
	sub	rdi, rsi
	mov	ecx, 65535
	cmp	rdi, rcx
	cmova	edi, ecx

	mov	r8, rsp
	lea	rax, [text1]
	mov	word  [r8], 140
	mov	word  [r8 + 2], 70
	mov	word  [r8 + 4], di
	mov	word  [r8 + 6], 0 ;font id
	mov	dword [r8 + 8], 0xff ;color
	mov	word  [r8 + 12], 0
	mov	qword [r8 + 14], rsi;rax ;text ptr
	mov	r9, screen
	call	txtOut_noClip

	cli
	jmp	$;.graphicsMode



;---------------------------------------------------------------------------------------------------
.panic:
	mov	rax, 'X 6 4 P '
	mov	[qword 120+txtVidMem], rax
	mov	rax, 'A N I C '
	mov	[qword 128+txtVidMem], rax
	jmp	.panic

;---------------------------------------------------------------------------------------------------
.textMode:
	lea	rax, [kernelPanic]
	mov	eax, [rax]
	cmp	eax, 1
	jb	.0
	jz	.1
	cmp	eax, 3
	jb	.2
	jz	.3
	cmp	eax, 5
	jb	.4
	jz	.5
	cmp	eax, 7
	jb	.6
	jz	.7
	cmp	eax, 9
	jb	.8
	jz	.9
	cmp	eax, 11
	jb	.10
	jz	.11
	cmp	eax, 13
	jb	.12
	jz	.13
	cmp	eax, 15
	jb	.14
	jz	.15
	cmp	eax, 17
	jb	.16
	jz	.17
	cmp	eax, 19
	jb	.18
	jz	.19
	cmp	eax, 21
	jb	.20
	jz	.21
	cmp	eax, 23
	jb	.22
	jz	.23
	cmp	eax, 25
	jb	.24
	jz	.25
	cmp	eax, 27
	jb	.26
	jz	.27
	cmp	eax, 29
	jb	.28
	jz	.29
	cmp	eax, 31
	jb	.30
	jz	.31
	cmp	eax, 33
	jb	.32
	jz	.33
	cmp	eax, 35
	jb	.34
	jz	.35
	cmp	eax, 37
	jb	.36
	jz	.37
	cmp	eax, 39
	jb	.38
	jz	.39
	cmp	eax, 41
	jb	.40
	jz	.41
	cmp	eax, 43
	jb	.42
	jz	.43
	cmp	eax, 45
	jb	.44
	jz	.45
	cmp	eax, 47
	jb	.46
	jz	.47
	cmp	eax, 49
	jb	.48
	jz	.49
	cmp	eax, 51
	jb	.50
	jz	.51
	cmp	eax, 53
	jb	.52
	jz	.53
	jmp	.err

.0:	; #PF: happened while #PF handler was executing
	mov	dword [qword 22+txtVidMem], (0x4f shl 24) + (0x4f  shl 8) + '2' + ('n' shl 16)
	mov	dword [qword 26+txtVidMem], (0x4f shl 24) + (0x4f  shl 8) + 'd' + ('!' shl 16)
	reg	rbp, 10cf
	jmp	.err

.1:	; #PF: PG_ALLOC bit is not set
	mov	dword [qword 22+txtVidMem], (0x4f shl 24) + (0x4f  shl 8) + 'A' + ('L' shl 16)
	mov	dword [qword 26+txtVidMem], (0x4f shl 24) + (0x4f  shl 8) + 'O' + ('C' shl 16)
	jmp	.err

.2:	; #PF: bitmask in "PF_pages" is empty (all 8 bits set)
	mov	dword [qword 22+txtVidMem], (0x4f shl 24) + (0x4f  shl 8) + '-' + ('H' shl 16)
	mov	dword [qword 26+txtVidMem], (0x4f shl 24) + (0x4f  shl 8) + 's' + ('T' shl 16)
	jmp	.err

.3:	; #PF: no PageDirectoryPointer (512GB chunk)
	mov	dword [qword 22+txtVidMem], (0x4f shl 24) + (0x4f  shl 8) + 'P' + ('M' shl 16)
	mov	dword [qword 26+txtVidMem], (0x4f shl 24) + (0x4f  shl 8) + 'L' + ('e' shl 16)
	jmp	.err

.4:	; #PF: no PageDirectory (1GB chunk)
	mov	dword [qword 22+txtVidMem], (0x4f shl 24) + (0x4f  shl 8) + 'P' + ('D' shl 16)
	mov	dword [qword 26+txtVidMem], (0x4f shl 24) + (0x4f  shl 8) + 'P' + ('e' shl 16)
	jmp	.err

.5:	; #PF: no PageTable (2MB chunk)
	mov	dword [qword 22+txtVidMem], (0x4f shl 24) + (0x4f  shl 8) + 'P' + ('D' shl 16)
	mov	dword [qword 26+txtVidMem], (0x4f shl 24) + (0x4f  shl 8) + 'e' + (' ' shl 16)
	jmp	.err
.6:
.7:

.8:	; unknown kernel panic
	mov	dword [qword 22+txtVidMem], (0x4f shl 24) + (0x4f  shl 8) + ' ' + ('?' shl 16)
	mov	dword [qword 26+txtVidMem], (0x4f shl 24) + (0x4f  shl 8) + ' ' + (' ' shl 16)
	jmp	.err

.9:	; #GP
	mov	dword [qword 120+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('G' shl 16)
	mov	dword [qword 124+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + 'P' + ('_' shl 16)
	jmp	.err

.10:	; #DF
	mov	dword [qword 120+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('D' shl 16)
	mov	dword [qword 124+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + 'F' + ('_' shl 16)
	jmp	.err

.11:	; #PF, Present bit must be 0 in a PTe
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + 'P' + ('F' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('0' shl 16)
	jmp	.err
.12:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '1' + ('2' shl 16)
	jmp	.err
.13:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '1' + ('3' shl 16)
	jmp	.err
.14:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '1' + ('4' shl 16)
	jmp	.err
.15:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '1' + ('5' shl 16)
	jmp	.err
.16:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '1' + ('6' shl 16)
	jmp	.err
.17:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '1' + ('7' shl 16)
	jmp	.err
.18:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '1' + ('8' shl 16)
	jmp	.err
.19:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '1' + ('9' shl 16)
	jmp	.err
.20:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '2' + ('0' shl 16)
	jmp	.err
.21:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '2' + ('1' shl 16)
	jmp	.err
.22:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '2' + ('2' shl 16)
	jmp	.err
.23:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '2' + ('3' shl 16)
	jmp	.err
.24:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '2' + ('4' shl 16)
	jmp	.err
.25:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '2' + ('5' shl 16)
	jmp	.err
.26:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '2' + ('6' shl 16)
	jmp	.err
.27:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '2' + ('7' shl 16)
	jmp	.err
.28:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '2' + ('8' shl 16)
	jmp	.err
.29:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '2' + ('9' shl 16)
	jmp	.err
.30:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '3' + ('0' shl 16)
	jmp	.err
.31:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '3' + ('1' shl 16)
	jmp	.err
.32:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '3' + ('2' shl 16)
	jmp	.err
.33:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '3' + ('3' shl 16)
	jmp	.err
.34:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '3' + ('4' shl 16)
	jmp	.err
.35:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '3' + ('5' shl 16)
	jmp	.err
.36:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '3' + ('6' shl 16)
	jmp	.err
.37:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '3' + ('7' shl 16)
	jmp	.err
.38:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '3' + ('8' shl 16)
	jmp	.err
.39:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '3' + ('9' shl 16)
	jmp	.err
.40:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '4' + ('0' shl 16)
	jmp	.err
.41:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '4' + ('1' shl 16)
	jmp	.err
.42:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '4' + ('2' shl 16)
	jmp	.err
.43:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '4' + ('3' shl 16)
	jmp	.err
.44:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '4' + ('4' shl 16)
	jmp	.err
.45:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '4' + ('5' shl 16)
	jmp	.err
.46:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '4' + ('6' shl 16)
	jmp	.err
.47:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '4' + ('7' shl 16)
	jmp	.err
.48:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '4' + ('8' shl 16)
	jmp	.err
.49:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '4' + ('9' shl 16)
	jmp	.err
.50:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '5' + ('0' shl 16)
	jmp	.err
.51:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '5' + ('1' shl 16)
	jmp	.err
.52:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '5' + ('2' shl 16)
	jmp	.err
.53:
	mov	dword [qword 22+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '_' + ('_' shl 16)
	mov	dword [qword 26+txtVidMem], (0xcf shl 24) + (0xcf  shl 8) + '5' + ('3' shl 16)
	jmp	.err
.err:
	;mov	 esi, [qword reg32.cursor]
	;mov	 dword [qword reg32.cursor], 42
	;mov	 rbp, cr2
	;reg	 rbp, 104f
	;mov	 rbp, rsp
	;reg	 rbp, 104f
	;mov	 [qword reg32.cursor], esi

	cli
	jmp	$



;============================================================================ for debugging ========
reg64_2:
	pushfq
	cli
	push	rdx rbx rax rdi rsi rbp rcx
	mov	rcx, rsp
	sub	rsp, 128
	movdqu	[rsp], xmm0
	movdqu	[rsp + 16], xmm1
	movdqu	[rsp + 32], xmm2
	movdqu	[rsp + 48], xmm3
	movdqu	[rsp + 64], xmm4
	movdqu	[rsp + 80], xmm5
	movdqu	[rsp + 96], xmm6
	movdqu	[rsp + 112], xmm7
	push	rcx

	mov	r8, [rcx + 8*9]

	sub	rsp, 64
	mov	r9, rsp
	mov	r12d, 16
	call	regToAsciiHex

	movzx	eax, word [qword txtVidCursor + rmData]
	add	word [qword txtVidCursor + rmData], 16*7+4

	lea	r8, [rsp + 16]
	mov	word  [r8], ax
	mov	word  [r8 + 2], 120
	mov	word  [r8 + 4], 16
	mov	word  [r8 + 6], 0 ;font id
	mov	dword [r8 + 8], 0xff ;color
	mov	word  [r8 + 12], 0
	mov	qword [r8 + 14], rsp
	mov	r9, screen
	call	txtOut_noClip

	add	rsp, 64

	movdqu	xmm0, [rsp + 8]
	movdqu	xmm1, [rsp + 16 + 8]
	movdqu	xmm2, [rsp + 32 + 8]
	movdqu	xmm3, [rsp + 48 + 8]
	movdqu	xmm4, [rsp + 64 + 8]
	movdqu	xmm5, [rsp + 80 + 8]
	movdqu	xmm6, [rsp + 96 + 8]
	movdqu	xmm7, [rsp + 112 + 8]
	pop	rcx
	mov	rsp, rcx
	pop	rcx rbp rsi rdi rax rbx rdx
	popfq
	ret 8


;============================================================================ for debugging ========
reg64:
	pushfq
	push	rdx rbx rax rdi
	cli

	mov	ebx, [rsp + 56]
	mov	edx, 16
	mov	ah, bl
	shr	ebx, 8
	cmp	ebx, edx
	cmova	ebx, edx
	lea	edi, [rbx*2 + 2]
	lock
	xadd	word [qword txtVidCursor + rmData], di
	mov	rdx, [rsp + 48]
	lea	edi, [edi + ebx*2 - 2]
	add	edi, txtVidMem
	std
.loop:
	mov	al, dl
	and	al, 15
	cmp	al, 10
	jb	@f
	add	al, 7
@@:	add	al, 48
	stosw
	ror	rdx, 4
	dec	ebx
	jnz	.loop

	pop	rdi rax rbx rdx
	popfq
	ret 16
