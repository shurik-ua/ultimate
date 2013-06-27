	output rom1.bin

	display "Size of ROM is: ",/a,endpp

	MACRO PORG addr
		IF $ < addr
		BLOCK addr-$
		ENDIF
		ORG addr
	ENDM

endprog			=	$4000
video_ram		=	$2800
vr					=	video_ram / 2
page_port		= $fe
config			= $fd
mult1				= $fb
mult2				= $f7
vaddr_low		=	$bf
vaddr_high	=	$7f

	PORG	0
	jp	reset

	PORG $38
	reti

pr_param
	ds 3

	PORG $66
	retn

	PORG $f3	;dont touch this offset (under any circumstances)
zexall

	include "zexall_core.asm"

	include "print_u8.asm"

reset
	di
	ld	sp,video_ram-2
	ld a,low vr
	out (vaddr_low),a
	ld a,high vr
	out (vaddr_high),a
	call cls
	ld hl,str1
	call print_str
	call zexall

endpp
	jp endpp

str1
	db 23,40,2,17,$47,"CPU2 T80 v249 @ 100MHz",17,7,13,13,24,40,0


msg2
	db	13,24,40,"Tests complete",0
okmsg
	db	17,4," OK",17,7,13,24,40,0
ermsg1
	db	13,24,40,17,2,"CRC: ",17,7,0
ermsg2
	db	",expected: ",0
crlf
	db	13,24,40,0

	block endprog-$