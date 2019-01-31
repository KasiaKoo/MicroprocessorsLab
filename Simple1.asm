	#include p18f87k22.inc

	extern  Keypad_Setup, Column, Row, Read_Keypad_H  ;external Keypad subroutines
	extern  Dic_Setup, Dic_4to2, Dic_Hex, Dic_HextoText
	

rst	code	0    ; reset vector
	goto	setup


main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	call    Keypad_Setup	; setupp Keypad
	call	Dic_Setup
	movlw 0x0F
	movwf 0x021
	call Column

	goto	start
	
	; ******* Main programme ****************************************
start 	;movlw 0x10
	;movwf PORTE
	;call Row
	
loop	movlw 0x05
	movwf 0x030
	movff PORTE, 0x023
	movf 0x023, W
	cpfsgt	0x021
	bra loop
	call delay
	movff PORTE, 0x025
	movf 0x025, W
	cpfseq	0x023
	bra loop
	cpfsgt	0x021
	bra loop
	call Read_Keypad_H

	goto	$		; goto current line in code (stay at this line forever)

delay	decfsz	0x30	; decrement until zero
	bra delay
	return
	
	end
