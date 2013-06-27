;u8 print driver v. 1.02 by shurik-ua
;управляющие коды
;13 (0x0d)				- след строка
;17 (0x11),color	- изменить цвет последующих символов
;23 (0x17),x,y		- изменить позицию на координаты x,y
;24 (0x18),x			- изменить позицию по x
;25 (0x19),y			- изменить позицию по y
;0								- конец строки
;пример -
;	db	23,0,1,17,7,"Z80 instruction exerciser for ",17,$46,"Reverse",17,7," u8 board",13,13,0
;выведет в позиции 0,1 белым "Z80 instruction exerciser for ", затем ярким жёлтым "Reverse",
;и далее белым " u8 board" и сместит позицию печати на 0,3
;
;row - позиция по y до которой будет вертикальный скролл по достижении конца экрана
;

row	=	4

;========================
;clear screen
cls
	ld hl,video_ram
	ld de,video_ram+1
	ld bc,31*160-1
	ld (hl),0
	ldir
	ret

;========================
;print string i: hl - pointer to string zero-terminated
print_str
	ld a,(hl)
	cp 17
	jr z,print_color
	cp 23
	jr z,print_pos_xy
	cp 24
	jr z,print_pos_x
	cp 25
	jr z,print_pos_y
	or a
	ret z
	inc hl
	call print_char
	jr print_str
print_color
	inc hl
	ld a,(hl)
	ld (pr_param+2),a		;color
	inc hl
	jr print_str
print_pos_xy
	inc hl
	ld a,(hl)
	ld (pr_param),a			;x-coord
	inc hl
	ld a,(hl)
	ld (pr_param+1),a		;y-coord
	inc hl
	jr print_str
print_pos_x
	inc hl
	ld a,(hl)
	ld (pr_param),a			;x-coord
	inc hl
	jr print_str
print_pos_y
	inc hl
	ld a,(hl)
	ld (pr_param+1),a		;y-coord
	inc hl
	jr print_str

;========================
;print character i: a - ansi char
print_char
	push hl
	push de
	push bc
	cp 13
	jr z,pchar2
	ld c,a
	ld a,(pr_param+1)
	out (mult2),a
	ld a,160
	out (mult1),a
	in a,(mult2)
	ld h,a
	in a,(mult1)
	ld l,a
	ld de,video_ram
	add hl,de
	ld a,(pr_param)
	sla a
	ld e,a
	ld d,0
	add hl,de
	ld a,(pr_param+2)
	ld (hl),c
	inc hl
	ld (hl),a
	ld a,(pr_param)
	inc a
	cp 80
	jr nz,pchar1
pchar2
	ld a,(pr_param+1)
	inc a
	cp 30
	jr nz,pchar0
	ld de,video_ram+row*160
	ld hl,video_ram+(row+1)*160
	ld bc,(30-row)*160
	ldir
	jr pchar00
pchar0
	ld (pr_param+1),a
pchar00
	xor a
pchar1
	ld (pr_param),a
	pop bc
	pop de
  pop hl
	ret

;========================
;print hexadecimal i: a - 8 bit number
print_hex
	ld b,a
	and $f0
	rrca
	rrca
	rrca
	rrca
	call hex2
	ld a,b
	and $0f
hex2
	cp 10
	jr nc,hex1
	add 48
	jp print_char
hex1
	add 55
	jp print_char

;========================
;print decimal i: l,d,e - 24 bit number , e - low byte
print_dec
	ld ix,dectb_w
	ld b,8
	ld h,0
lp_pdw1
	ld c,"0"-1
lp_pdw2
	inc c
	ld a,e
	sub (ix+0)
	ld e,a
	ld a,d
	sbc (ix+1)
	ld d,a
	ld a,l
	sbc (ix+2)
	ld l,a
	jr nc,lp_pdw2
	ld a,e
	add (ix+0)
	ld e,a
	ld a,d
	adc (ix+1)
	ld d,a
	ld a,l
	adc (ix+2)
	ld l,a
	inc ix
	inc ix
	inc ix
	ld a,h
	or a
	jr nz,prd3
	ld a,c
	cp "0"
	ld a," "
	jr z,prd4
prd3
	ld a,c
	ld h,1
prd4
	call print_char
	djnz lp_pdw1
	ret

dectb_w
	db #80,#96,#98	;10000000 decimal
	db #40,#42,#0f	;1000000
	db #a0,#86,#01	;100000
	db #10,#27,0		;10000
	db #e8,#03,0		;1000
	db 100,0,0			;100
	db 10,0,0				;10
	db 1,0,0				;1

