	DEVICE	ZXSPECTRUM48

; PCB ReVerSE U8EP3C POST v0.2 (build 20130507)
; IP Core v0.2 (build 20130507)

;-------------------------------------------------------------------------------
; X80CPU ROM
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
; -- x   x   x   x   x   x   x   x  x    x  x  x  x  x  x  x  0	#FE	R/W:b3..0 номер страницы SRAM, подключенной в верхние 32КБ памяти (с адреса #8000)
; -- x   x   x   x   x   x   x   x  x    x  x  x  x  x  x  0  x	#FD	R:	b7..0 версия Soft-Core
; -- x   x   x   x   x   x   x   x  x    x  x  x  x  x  0  x  x	#FB	W:	mult0_data1,	R:	mult0_result(7..0) 	Mult Result = mult_data1*mault_data2
; -- x   x   x   x   x   x   x   x  x    x  x  x  x  0  x  x  x	#F7	W:	mult0_data2,	R:	mult0_result(15..8)
; -- x   x   x   x   x   x   x   x  x    x  x  x  0  x  x  x  x	#EF W/R:uart_data(7..0)
; -- x   x   x   x   x   x   x   x  x    x  x  0  x  x  x  x  x	#DF	R:	b7= uart_tx_busy, b6= CBUS4, b5..2= 1111, b1= uart_rx_error, b0= uart_rx_avail
; -- x   x   x   x   x   x   x   x  x    x  0  x  x  x  x  x  x	#BF W/R:txt0_addr1 мл.адрес начала текстового видео буфера
; -- x   x   x   x   x   x   x   x  x    0  x  x  x  x  x  x  x	#7F W/R:txt0_addr2 ст.адрес начала текстового видео буфера

; -------------------------------------------------------------------------------
; -- Карта памяти T80v3 CPU
; -------------------------------------------------------------------------------
; -- A15 A14 A13
; -- 0   0   x	0000-3FFF (16384) RAM
; -- 0   0   x		      ( 4800) текстовый буфер (символ, цвет, символ...)
; -- 1   x   x	4000-FFFF (49152) пусто

; -- A15 A14 A14 A13 A12 A11 A10 A9 A8 | A7 A6 A5 A4 A3 A2 A1 A0
; -- x   x   x   x   x   x   x   x  x    x  x  x  x  x  x  x  0	#FE	R/W:b3..0 номер страницы SRAM, подключенной в верхние 32КБ памяти (с адреса #8000)
; -- x   x   x   x   x   x   x   x  x    x  x  x  x  x  x  0  x	#FD
; -- x   x   x   x   x   x   x   x  x    x  x  x  x  x  0  x  x	#FB	W:	mult1_data1,	R:	mult1_result(7..0) 	Mult Result = mult_data1*mault_data2
; -- x   x   x   x   x   x   x   x  x    x  x  x  x  0  x  x  x	#F7	W:	mult1_data2,	R:	mult1_result(15..8)
; -- x   x   x   x   x   x   x   x  x    x  x  x  0  x  x  x  x	#EF
; -- x   x   x   x   x   x   x   x  x    x  x  0  x  x  x  x  x	#DF
; -- x   x   x   x   x   x   x   x  x    x  0  x  x  x  x  x  x	#BF W/R:txt1_addr1 мл.адрес начала текстового видео буфера
; -- x   x   x   x   x   x   x   x  x    0  x  x  x  x  x  x  x	#7F W/R:txt1_addr2 ст.адрес начала текстового видео буфера


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
port_page		EQU #fe
port_ver		EQU #fd
port_mult1		EQU #fb
port_mult2		EQU #f7
port_uart_data		EQU #ef
port_uart_status	EQU #df
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
		ld de,str01
		ld hl,BUFFER
		call PrintStr
		
		in a,(port_ver)
		ld hl,BUFFER+56*2
		call ByteToHexStr

		ld de,str14
		ld hl,BUFFER+160*1
		call PrintStr

;--------------------------------------
; Тест памяти
TestSram	ld de,str02
		ld hl,BUFFER+160*3
		call PrintStr

		xor a
		ld hl,BUFFER+160*3+38*2

testSramNext	out (port_page),a
		ld (sram_page),a
		ld (print_addr),hl

		ld hl,#8000
		ld b,h
		ld c,l

		call TestMem
		jr nz,testSramError

		ld hl,(print_addr)
		ld (hl),219
		inc hl
		inc hl
		
		ld a,(sram_page)
		inc a
		cp 16
		jr nz,testSramNext

		ld de,str05		; "OK."
		ld hl,BUFFER+160*3+56*2
		call PrintStr

		jr TestMult
;--------------------------------------
testSramError	ld d,a
		push de
		push hl

		ld de,str15		; "Error."
		ld hl,BUFFER+160*3+56*2
		call PrintStr

		ld de,str04		; "ERROR:"
		ld hl,BUFFER+160*4
		call PrintStr

		pop de
		ld a,(sram_page)
		rrca
		rrca
		ld c,a
		and %00111111
		ld hl,BUFFER+160*4+15*2
		call ByteToHexStr
		ld a,c
		and %11000000
		ld c,a
		ld a,d
		and %00111111
		or c
		call ByteToHexStr
		ld a,e
		call ByteToHexStr
		
		pop de
		ld a,d
		ld hl,BUFFER+160*4+32*2
		call ByteToBitStr
		ld a,e
		ld hl,BUFFER+160*4+48*2
		call ByteToBitStr
;--------------------------------------
TestMult
		ld a,#ff		
		out (port_mult1),a
		ld a,#fe
		out (port_mult2),a
		ld de,str16
		ld hl,BUFFER+160*8
		call PrintStr
		
		in a,(port_mult2)
		ld hl,BUFFER+160*8+20*2
		call ByteToHexStr
		in a,(port_mult1)
		ld hl,BUFFER+160*8+22*2
		call ByteToHexStr
;--------------------------------------
TestUART
		ld de,str08			; "Test USB-UART (FT232R):"
		ld hl,BUFFER+160*9
		call PrintStr

		LD HL,str_test1
		call TxStr
		
		ld de,str17			; "No Conect"
		jr c,testUart1
		ld de,str05			; "OK"
testUart1
		ld hl,BUFFER+160*9+24*2
		call PrintStr

;--------------------------------------
TestRTC
		ld hl,#0000
		ld (cnt1),hl
		ld (cnt0),hl
	
		ld de,str18
		ld hl,BUFFER+160*1+65*2
		call PrintStr
testRtc1
		ld hl,BUFFER+160*1+72*2
		call Count
		jr testRtc1

		halt

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
; UART 
;--------------------------------------
; Ports:
; DATA		W/R
; STATUS	R: bit7=uart_tx_busy, bit6=CBUS4, bit1=uart_rx_error, bit1=uart_rx_avail

; HL=STRING, #00 = END STRING

txIf		rlca
		ret c		; FT232R NO CONNECT TO HOST!
TxStr		in a,(port_uart_status)
		rlca
		jr c,txIf	; CY=1 :BUFFER FULL, WAIT...
		ld a,(hl)
		or a
		ret z		; Z=0 :END STRING
		inc hl
		out (port_uart_data),a
		jr TxStr

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
str01		db 1,%00111000,	"                      REVERSE U8EP3C DEVBOARD TEST v0.2.00                      ",0
str02		db 1,%00000111,	"Test SRAM (CY7C1049DV33-10ZSX) 512KB [",177,177,177,177,177,177,177,177,177,177,177,177,177,177,177,177,"]",0
;str03		db 1,%00000111,	"Test SDRAM (MT48LC32M8A2TG-75)  32MB [0123456789ABCDEF]",0
str04		db 1,%01000010,	"ERROR: Address 00000000h (Write 00000000b, Read 00000000b)",0
str05		db 1,%00000100,	"OK",0
str06		db 1,%00000111,	"Test RTC (PCF8583):",0
str07		db 1,%00000111,	"Test FLASH (M25P40):",0
str08		db 1,%00000111,	"Test USB-UART (FT232R):",0
str09		db 1,%00000111,	"Test SD/MMC:",0
str10		db 1,%00000111,	"Test PS/2 Mouse:",0
str11		db 1,%00000111,	"Test PS/2 Keyboard:",0
str12		db 1,%00000111,	"Test Audio Codec (VS1053B):",0
str13		db 1,%00000110,	"Passed",0
str14		db 1,%00000111,	"Processor 1: NextZ80v1 @ 40MHz",0
str15		db 1,%01000010, "ERROR",0
str16		db 1,%00000111, "Test Mult (FEh*FFh)=    h",0
str17		db 1,%01000110, "No Conect To Host",0
str18		db 1,%00000101, "Count:         ",0


str_test1	db #0D,#0A
		db #0D,#0A,"PCB U8EP3C"
		db #0D,#0A,"POST version 0.2 (build 20130507)",0


	savebin "rom0.bin",StartProg, 16384