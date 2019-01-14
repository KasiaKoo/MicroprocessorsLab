	#include p18f87k22.inc
	
	code
	org 0x0
	goto	setup
	
	org 0x100		    ; Main code starts here at address 0x100

	; ******* Programme FLASH read Setup Code ****  
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	goto	start
	; ******* My data and where to put it in RAM *
myTable data	"a","b"	;"This is just some data"
	constant 	myArray=0x400	; Address in RAM for data
	constant 	counter=0x10	; Address of counter variable
	; ******* Main programme *********************
start 	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	.2		; 22 bytes to read
	movwf 	counter		; our counter register
loop 	tblrd*+			; move one byte from PM to TABLAT, increment TBLPRT
	movlw	0x03
	movwf	0x20
	movwf	0x30
	call	delay
	movff	TABLAT, POSTINC0	; move read data from TABLAT to (FSR0), increment FSR0	
	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
	
	
	goto	0x0	

delay	call delay1
	movlw	0x03
	movwf	0x30
	decfsz 0x20
	bra delay
	movlw	0x03
	movwf	0x20
	return

delay1	decfsz 0x30
	bra delay1
	return



	end
