;
; buttonLight.asm
;
; Created: 10/18/2018 5:22:38 PM
; Author : nevinbonak
;


.org 0x0000
rjmp Init
.org 0x0020
rjmp overflow_handler

Init:
	.def temp = R16
	;to use .delay:
	.def overflows = R17
	.def delayTime = R18
	ldi temp, (1<<CS01) | (1<<CS00)
	out TCCR0B, temp
	ldi temp, 249
	out OCR0A, temp
	ldi temp, 0b0000_0010
	out TCCR0A, temp
	sts TIMSK0, temp
	clr temp
	out TCNT0, temp
	sei
	;other init stuff:
	.def button = R20
	.def tencounter = R21
	.def huncounter = R22
	.def thocounter = R23
	.def onecounter = R25
	.def place = R24
	.def displaycounter = R26
	ldi temp, 0b1111_1111
	out DDRD, temp
	ldi temp, 0b0000_1111
	out DDRB, temp
	ldi temp, 0b0000_0000
	out DDRC, temp
	
	ldi ZL, LOW(segcodes<<1)
	ldi ZH, HIGH(segcodes<<1)
	
	ldi place, 0b1111
	out PORTB, place
	ldi temp, 0b1100_0000
	out PORTD, temp
	
	ldi place, 0b1000
	
	ldi onecounter, 0
	ldi tencounter, 0
	ldi huncounter, 0
	ldi thocounter, 0

	clr temp
	
	


.macro delay
	clr overflows
	ldi delayTime, @0
	sec_count:
		cpse overflows, delayTime
	rjmp sec_count
.endmacro

main:
	//RCALL debounce
	///brcc main
	
	//change this to change the length of the display
	ldi displaycounter, 5
	RCALL display
	inc onecounter

	cpi onecounter, 10
	brge teninc
ten:
	cpi tencounter, 10
	brge huninc
hun:
	cpi huncounter, 10
	brge thoinc

	cpi thocounter, 10
	brge init

	rjmp main

teninc:
	ldi onecounter, 0
	inc tencounter
	rjmp ten

huninc:
	ldi tencounter, 0
	inc huncounter
	rjmp hun

thoinc:
	ldi huncounter, 0
	inc thocounter
	rjmp main

display:
	
	ldi place, 0b1000
	out PORTB, place
	
	add ZL, onecounter
	lpm temp, Z
	sub ZL, onecounter
	
	out PORTD, temp
	
	delay 2

	ldi place, 0b0100
	out PORTB, place

	add ZL, tencounter
	lpm temp, Z
	sub ZL, tencounter

	out PORTD, temp

	delay 2

	ldi place, 0b0010
	out PORTB, place

	add ZL, huncounter
	lpm temp, Z
	sub ZL, huncounter

	out PORTD, temp

	delay 2

	ldi place, 0b0001
	out PORTB, place

	add ZL, thocounter
	lpm temp, Z
	sub ZL, thocounter

	out PORTD, temp

	delay 2

	dec displaycounter
	brne display
	
	ldi place, 0b1111
	out PORTB, place

	ldi temp, 0b1111_1111
	out PORTD, temp
	ret

debounce:
	sec ;set carry
	sbic PINC, PC5
	rjmp bitset
	delay 5
	sbic PINC, PC5
	rjmp bitset
	ret
bitset:
	clc
	ret

	
overflow_handler:
	inc overflows
	reti

.org 0x500
segcodes: .db 0b1100_0000, 0b1111_1001, 0b1010_0100, 0b1011_0000, 0b1001_1001, 0b1001_0010, 0b1000_0010, 0b1111_1000, 0b1000_0000, 0b1001_1000