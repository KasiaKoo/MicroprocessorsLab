	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message, LCD_clear	    ; external LCD subroutines
	extern	LCD_Write_Hex, LCD_delay_ms			    ; external LCD subroutines
	extern  ADC_Setup, ADC_Read		    ; external ADC routines
	
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
delay_count res 1   ; reserve one byte for counter in the delay routine

tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****
myTable data	    "Too Low!\n"	; message, plus carriage return
	constant    myTable_l=.09	; length of data
	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	call	ADC_Setup	; setup ADC
	movlw	0x00
	movwf	TRISD
	movwf	TRISH
	
	goto	start
	
	; ******* Main programme ****************************************
start 	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter		; our counter register
	;call	LCD_clear
	;movlw	0x0B
	;movwf	0x016
	;movlw	0xff
	;movwf	0x012
	;movlw	0x0A
	;movwf	0x014
loop 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
		
	;movlw	myTable_l-1	; output message to LCD (leave out "\n")
	;lfsr	FSR2, myArray
	;call	LCD_Write_Message

	;movlw	myTable_l	; output message to UART
	;lfsr	FSR2, myArray
	;call	UART_Transmit_Message
	
	;call	check
	;goto	$
	
measure_loop
	;call	LCD_delay_ms                                                                                                                      
	;call	LCD_clear
	call	ADC_Read
	;movf	ADRESH,W
	;call	LCD_Write_Hex
	;movf	ADRESL,W
	;call	LCD_Write_Hex
	call	check
	;goto	measure_loop		; goto current line in code
	
check
	call	LCD_delay_ms
	;call	ADC_Read
	movf	ADRESH, W
	;movf	0x014, W
	cpfseq	0x050
	call	compare_H
	call	compare_L
	;bra	check
	goto	measure_loop
	
compare_H
	cpfslt	0x050
	call	CUTOFF
	goto	measure_loop

	; a delay subroutine if you need one, times around loop in delay_count
delay	decfsz	delay_count	; decrement until zero
	bra delay
	return

CUTOFF	
	;call	LCD_clear
	;movlw	.16
	;call	LCD_delay_ms
	movlw	myTable_l-1	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	call	LCD_Write_Message
	;movlw	.16
	;call	delay
	movlw	myTable_l	; output message to UART
	lfsr	FSR2, myArray
	call	UART_Transmit_Message
	goto	measure_loop
	
compare_L
	movf	ADRESL, W
	;movf	0x012, W
	cpfslt	0x052
	call	CUTOFF
	
	end