#include p18f87k22.inc

    global  Keypad_Setup, Column, Row, Read_Keypad_H, LCD_delay_ms
    extern  Dic_Setup, Dic_4to2, Dic_Hex, Dic_HextoText
    
acs0    udata_acs   ; named variables in access ram
LCD_cnt_l   res 1   ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h   res 1   ; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms  res 1   ; reserve 1 byte for ms counter
LCD_tmp	    res 1   ; reserve 1 byte for temporary use
LCD_counter res 1   ; reserve 1 byte for counting through nessage

	constant    LCD_E=5	; LCD enable bit
    	constant    LCD_RS=4	; LCD register select bit


Keypad code
    
Keypad_Setup
	banksel PADCFG1
	bsf PADCFG1, REPU, BANKED	;set pull ups to on for PORTE
	movlb 0x00
	clrf LATE			;writing 0s to the LATE register
	movlw 0x00
	movwf TRISH			;setting PORTH to output
	movwf PORTH
	;movlw 0x55
	;movwf PORTH
	movlw 0x00
	movwf 0x11, ACCESS
	;goto Keypad_Setup
	return
	
Column
	movlw 0x0F
	movwf TRISE, ACCESS			;setting 4-7 as outputs and 0-3 as inputs
	;movlw 0xFF
	;movwf 0x30
	call LCD_delay_ms
	return
	
Row
	movlw 0xF0
	movwf TRISE, ACCESS			;reversing inputs and outputs
	;movlw 0xFF
	;movwf 0x30
	call LCD_delay_ms
	;cpfseq 
	return
	
Read_Keypad_H
	call Column
	movf PORTE, W
	call Dic_4to2
	movwf 0x05
	call Row
	movf PORTE, W
	movwf 0x08
	rrncf 0x08
	rrncf 0x08
	rrncf 0x08
	rrncf 0x08
	movf 0x08, W
	call Dic_4to2
	movwf 0x06
	call Dic_Hex
	;movf 0x06, W
	call Dic_HextoText
	movwf 0x11
	movff 0x11, PORTH
	;movff PORTE, 0x05
	;call Row
	;movff PORTE, 
	;movf 0x07, W
	;addwf 0x05, W
	;movwf  0x11
	;movff 0x11, PORTH
	call Column
	return

delay	decfsz	0x30	; decrement until zero
	bra delay
	return

LCD_delay_ms		    ; delay given in ms in W
	movwf	LCD_cnt_ms
lcdlp2	movlw	.250	    ; 1 ms delay
	call	LCD_delay_x4us	
	decfsz	LCD_cnt_ms
	bra	lcdlp2
	return
    
LCD_delay_x4us		    ; delay given in chunks of 4 microsecond in W
	movwf	LCD_cnt_l   ; now need to multiply by 16
	swapf   LCD_cnt_l,F ; swap nibbles
	movlw	0x0f	    
	andwf	LCD_cnt_l,W ; move low nibble to W
	movwf	LCD_cnt_h   ; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	LCD_cnt_l,F ; keep high nibble in LCD_cnt_l
	call	LCD_delay
	return

LCD_delay			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lcdlp1	decf 	LCD_cnt_l,F	; no carry when 0x00 -> 0xff
	subwfb 	LCD_cnt_h,F	; no carry when 0x00 -> 0xff
	bc 	lcdlp1		; carry, then loop again
	return			; carry reset so return
	

	end
