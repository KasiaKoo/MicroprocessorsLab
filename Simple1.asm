	#include p18f87k22.inc

	extern  Keypad_Setup, Con1, Con2, Read_Keypad   ;external Keypad subroutines
	

rst	code	0    ; reset vector
	goto	setup


main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call    Keypad_Setup	; setupp Keypad
	goto	start
	
	; ******* Main programme ****************************************
start 	;movlw 0x10
	;movwf PORTE
	call Con1
	;call Read_Keypad
	
	goto	$		; goto current line in code (stay at this line forever)
	
	end