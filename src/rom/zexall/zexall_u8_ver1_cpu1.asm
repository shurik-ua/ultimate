	output rom0.bin

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
	ld a,low video_ram / 2
	out (vaddr_low),a
	ld a,high video_ram / 2
	out (vaddr_high),a
	call cls
	ld hl,str1
	call print_str
	ld hl,str2
	call print_str
	ld hl,str3
	call print_str
	call zexall

endpp
	jp endpp

;	 	  00000000001111111111222222222233333333334444444444555555555566666666667777777777
; 		01234567890123456789012345678901234567890123456789012345678901234567890123456789

str1
	db 17,%01111000,23,0,0
	db "                         Z80 INSTRUCTION EXERCISER v 1.2                        ",0
str2
	db 17,%00000111,"ported to ",17,$46,"ReVerSE U8EP3C DevBoard",17,7," by ",17,$47,"MVV & Shurik-ua ",13,0
str3
	db 17,$47,"CPU1 NextZ80 v101 @ 50MHz",17,7,13,13,0

msg2
	db	13,"Tests complete",0
okmsg
	db	17,4," OK",17,7,13,0
ermsg1
	db	13,17,2,"CRC: ",17,7,0
ermsg2
	db	",expected: ",0
crlf
	db	13,0

	block endprog-$