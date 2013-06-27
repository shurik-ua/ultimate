	DEVICE	ZXSPECTRUM48

; PCB ReVerSE U8EP3C POST v0.2 (build 20130507)
; IP Core v0.2 (build 20130507)

;-------------------------------------------------------------------------------
; T80CPU ROM
;-------------------------------------------------------------------------------


; v0.1.1	2013-05-06	Добавлен Т80CPU, изменения в карте памяти
; v0.1.0	2013-05-04	Первая версия

; -------------------------------------------------------------------------------
; -- Карта памяти X80v1 CPU
; -------------------------------------------------------------------------------
; -- A15 A14 A13
; -- 0   0   x	0000-3FFF (16384) RAM
; -- 0   0   x			  ( 4800) текстовый буфер (символ, цвет, символ...)
; -- 0   1   x	4000-7FFF ( 8192) пусто 
; -- 1   x   x	8000-FFFF (32768) SRAM страница (0..15)

; -- A15 A14 A14 A13 A12 A11 A10 A9 A8 | A7 A6 A5 A4 A3 A2 A1 A0
; -- x   x   x   x   x   x   x   x  x    x  x  x  x  x  x  x  0	#FE	R/W:	b3..0 номер страницы SRAM, подключенной в верхние 32КБ памяти (с адреса #8000)
; -- x   x   x   x   x   x   x   x  x    x  x  x  x  x  x  0  x	#FD	R:	b7..0 версия Soft-Core
; -- x   x   x   x   x   x   x   x  x    x  x  x  x  x  0  x  x	#FB	W:	mult0_data1,	R:	mult0_result(7..0) 	Mult Result = mult_data1*mault_data2
; -- x   x   x   x   x   x   x   x  x    x  x  x  x  0  x  x  x	#F7	W:	mult0_data2,	R:	mult0_result(15..8)
; -- x   x   x   x   x   x   x   x  x    x  x  x  0  x  x  x  x	#EF 	W/R:	uart_data(7..0)
; -- x   x   x   x   x   x   x   x  x    x  x  0  x  x  x  x  x	#DF	R:	b7= uart_tx_busy, b6= CBUS4, b5..2= 1111, b1= uart_rx_error, b0= uart_rx_avail
; -- x   x   x   x   x   x   x   x  x    x  0  x  x  x  x  x  x	#BF	W/R:	txt0_addr1 мл.адрес начала текстового видео буфера
; -- x   x   x   x   x   x   x   x  x    0  x  x  x  x  x  x  x	#7F 	W/R:	txt0_addr2 ст.адрес начала текстового видео буфера

; -------------------------------------------------------------------------------
; -- Карта памяти T80v3 CPU
; -------------------------------------------------------------------------------
; -- A15 A14 A13
; -- 0   0   x	0000-3FFF (16384) RAM
; -- 0   0   x		      ( 4800) текстовый буфер (символ, цвет, символ...)
; -- 1   x   x	4000-FFFF (49152) пусто

; -- A15 A14 A14 A13 A12 A11 A10 A9 A8 | A7 A6 A5 A4 A3 A2 A1 A0
; -- x   x   x   x   x   x   x   x  x    x  x  x  x  x  x  x  0	#FE	R/W:	b7..0 номер страницы SDRAM, подключенной в верхние 32КБ памяти (с адреса #8000)
; -- x   x   x   x   x   x   x   x  x    x  x  x  x  x  x  0  x	#FD 	R/W:	b15..0 номер страницы SDRAM, подключенной в верхние 32КБ памяти (с адреса #8000)
; -- x   x   x   x   x   x   x   x  x    x  x  x  x  x  0  x  x	#FB	W:	mult1_data1,	R:	mult1_result(7..0) 	Mult Result = mult_data1*mault_data2
; -- x   x   x   x   x   x   x   x  x    x  x  x  x  0  x  x  x	#F7	W:	mult1_data2,	R:	mult1_result(15..8)
; -- x   x   x   x   x   x   x   x  x    x  x  x  0  x  x  x  x	#EF
; -- x   x   x   x   x   x   x   x  x    x  x  0  x  x  x  x  x	#DF
; -- x   x   x   x   x   x   x   x  x    x  0  x  x  x  x  x  x	#BF 	W/R:	txt1_addr1 мл.адрес начала текстового видео буфера
; -- x   x   x   x   x   x   x   x  x    0  x  x  x  x  x  x  x	#7F 	W/R:	txt1_addr2 ст.адрес начала текстового видео буфера


BUFFER			EQU #2000	; Адрес начала текстового буфера
VARIABLES		EQU #003a	; Адрес начала переменных

; Переменные
print_color		EQU VARIABLES+0
sram_page		EQU VARIABLES+1
print_addr		EQU VARIABLES+2
dram_page		EQU VARIABLES+4
cnt1			EQU VARIABLES+6
cnt0			EQU VARIABLES+8


; I/O
port_page1		EQU #fe
port_page2		EQU #fd
port_mult1		EQU #fb
port_mult2		EQU #f7
;port_uart_data		EQU #ef
;port_uart_status	EQU #df
port_txt_addr1		EQU #bf
port_txt_addr2		EQU #7f




;--------------------------------------
; Reset
		ORG #0000
StartProg:
		di
		ld a,#00
		out (port_txt_addr1),a
		ld a,#10
		out (port_txt_addr2),a
		jp Test
;--------------------------------------
; INT
		ORG #0038
Int
		reti
;--------------------------------------
; NMI
		ORG #0066
Nmi
		retn
;--------------------------------------
Test
		ld sp,#4000

		call Cls
		
		ld de,str14		;"Processor 2: T80v3 @ 35MHz"
		ld hl,BUFFER+160*2
		call PrintStr

;		jp TestRTC
;--------------------------------------
; Тест памяти
;--------------------------------------
TestDram	ld de,str03
		ld hl,BUFFER+160*5
		call PrintStr

		ld de,#0000
		ld hl,BUFFER+160*5+38*2

testDramNext	ld a,e
		out (port_page1),a
		ld a,d
		out (port_page2),a
		ld (dram_page),de
		ld (print_addr),hl

		ld hl,#8000
		ld b,h
		ld c,l
		call TestMem
		jr nz,testDramError

		ld hl,(print_addr)
		ld (hl),219
		inc hl
		inc hl
		
		ld de,(dram_page)
		inc de
		ld a,d
		cp #04
		jr nc,testDramNext

		ld de,str05		; "OK."
		ld hl,BUFFER+160*5+56*2
		call PrintStr

		jr TestRTC		
;--------------------------------------
testDramError	ld d,a
		push de
		push hl

		ld de,str15		; "Error."
		ld hl,BUFFER+160*5+56*2
		call PrintStr

		ld de,str04		; "ERROR:"
		ld hl,BUFFER+160*5
		call PrintStr

		pop de
		ld bc,(dram_page)
		srl b
		rr c
		rl d
		rrc d

		ld a,b
		ld hl,BUFFER+160*6+15*2
		call ByteToHexStr
		ld a,c
		call ByteToHexStr
		ld a,d
		call ByteToHexStr
		ld a,e
		call ByteToHexStr
		
		pop de
		ld a,d
		ld hl,BUFFER+160*6+32*2
		call ByteToBitStr
		ld a,e
		ld hl,BUFFER+160*6+48*2
		call ByteToBitStr
;--------------------------------------
TestRTC
		ld hl,#0000
		ld (cnt1),hl
		ld (cnt0),hl
	
		ld de,str18
		ld hl,BUFFER+160*2+65*2
		call PrintStr
testRtc1
		ld hl,BUFFER+160*2+72*2
		call Count
		jr testRtc1

;======================================	









;--------------------------------------
; Очистка текстового видео буфера	
;--------------------------------------
Cls		ld de,#0000
		ld bc,#0960
		ld hl,BUFFER
cls1		ld (hl),e
		inc hl
		ld (hl),d
		inc hl
		dec bc
		ld a,c
		or b
		jr nz,cls1
		ret

;--------------------------------------
; Печать
;--------------------------------------
PrintStr	ld a,(print_color)
printStr2	ld c,a
printStr3	ld a,(de)
		or a
		ret z
		inc de
		cp #01
		jr z,printStr1
		ld (hl),a
		inc hl
		ld (hl),c
		inc hl
		jr printStr3
printStr1	ld a,(de)
		ld (print_color),a
		inc de
		jr printStr2
	
;--------------------------------------
; Тест памяти	
;--------------------------------------
TestMem		xor a
		ld (hl),a
		ld e,(hl)
		cp e
		ret nz
		cpl
		ld (hl),a
		ld e,(hl)
		cp e
		ret nz
		ld a,%01010101
		ld (hl),a
		ld e,(hl)
		cp e
		ret nz
		cpl
		ld (hl),a
		ld e,(hl)
		cp e
		ret nz
testMemNext	inc hl
		dec bc
		ld a,b
		or c
		jr nz,TestMem
		ret

;--------------------------------------
; Byte to BIN string
;--------------------------------------
; A  = byte
; HL = buffer (8 bytes)
ByteToBitStr	ld b,8
byteToBitStr2	rlca
		jr nc,byteToBitStr1
		ld (hl),#31
		inc hl
		inc hl
		djnz byteToBitStr2
		ret
byteToBitStr1	ld (hl),#30
		inc hl
		inc hl
		djnz byteToBitStr2
		ret

;--------------------------------------
; Byte to HEX string
;--------------------------------------
; A  = byte
; HL = buffer
ByteToHexStr	ld b,a
		rrca
		rrca
		rrca
		rrca
		and #0f
		add a,#90
		daa
		adc a,#40
		daa
		ld (hl),a
		inc hl
		inc hl
		ld a,b
		and #0f
		add a,#90
		daa
		adc a,#40
		daa
		ld (hl),a
		inc hl
		inc hl
		ret

;--------------------------------------
; Счетчик (демонстрация скорости счета)
;--------------------------------------
; HL = buffer
Count
		ld a,(cnt1+1)
		call ByteToHexStr
		ld a,(cnt1)
		call ByteToHexStr
		ld a,(cnt0+1)
		call ByteToHexStr
		ld a,(cnt0)
		call ByteToHexStr

		ld de,#0001
		ld hl,(cnt0)
		add hl,de
		ld (cnt0),hl
		ld e,#00
		ld hl,(cnt1)
		adc hl,de
		ld (cnt1),hl
		ret


; цвет
; b2..0 = ink
; b5..3 = paper
; b6	= bright
; b7	= -

;				 00000000001111111111222222222233333333334444444444555555555566666666667777777777	
;				 01234567890123456789012345678901234567890123456789012345678901234567890123456789
str03		db 1,%00000111,	"Test SDRAM (MT48LC32M8A2TG-75)  32MB [",177,177,177,177,177,177,177,177,177,177,177,177,177,177,177,177,"]",0
str04		db 1,%01000010,	"ERROR: Address 00000000h (Write 00000000b, Read 00000000b)",0
str05		db 1,%00000100,	"OK",0
str14		db 1,%00000111,	"Processor 2: T80v3 @ 100MHz",0
str15		db 1,%01000010, "ERROR",0
str18		db 1,%00000101, "Count:         ",0

	savebin "rom1.bin",StartProg, 16384