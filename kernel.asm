!to "kernel.bin", plain
screen_control_reg_1 = $d011
screen_control_reg_2 = $d016
screen_ram = $0400

PRA = $dc00
DDRA = $dc02

PRB = $dc01
DDRB = $dc03

* = $e000
sei

!zone vic_init
; set border color
lda #14
sta $d020
; set background color
lda #6
sta $d021
; set font
lda #$15
sta $d018

; clear screen
lda #' '
!for i, 0, 999 {
	sta screen_ram + i
}

; set vic to text mode (and more?)
; should probably figure out why we're doing this
lda #$1b
sta screen_control_reg_1
lda #$c8
sta screen_control_reg_2

!zone IO_init
; setup io dirs
lda #%11111111 ; out
sta DDRA
lda #%00000000 ; in
sta DDRB

!zone main
print_loop
	; write hex to screen
	lda hex_h, x
	sta screen_ram + 0
	lda hex_l, x
	sta screen_ram + 1

-	jsr check_key ; wait for key press
	cmp #$ff
	beq -

-	jsr check_key ; wait for key release
	cmp #$ff
	bne -

	inx

	jmp print_loop

check_key
	lda #$00
	sta PRA
	lda PRB
	rts

; hex conversion table
hex_h = *
!for i, 0, 255 {
	!if i / 16 < 10 {
		!byte '0' + i / 16
	} else {
		!byte 1 + i / 16 - 10
	}
}
hex_l = *
!for i, 0, 255 {
	!if i % 16 < 10 {
		!byte '0' + i % 16
	} else {
		!byte 1 + i % 16 - 10
	}
}

; set reset vector
* = $fffc
!hex 00 e0

; pad file
!align $2000, 0
