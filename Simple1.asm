	#include p18f87k22.inc
	
	extern PWM_Setup_B, PWM_dc_B, PWM_rotate_B, PWM_delay_B
	extern PWM_Setup_T, PWM_dc_T, PWM_rotate_T, PWM_delay_T
	extern  ADC_Setup, ADC_Read
	extern LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_clear, LCD_delay_ms
	
acs0    udata_acs   ; named variables in access ram
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
delay_count	res 1   ; reserve one byte for counter in the delay routine
temp_work	res 4	; reserves four byte for temporary work directory
Y_ADC_h		res 4	; reserves four byte for high byte of yellow LED measurement
Y_ADC_l		res 4	; reserves four byte for low byte of yellow LED measurement
G_ADC_h		res 4	; reserves four byte for high byte of green LED measurement
G_ADC_l		res 4	; reserves four byte for low byte of green LED measurement
diff_l		res 4	; reserves four byte for difference in measurements
	
	
main	code
	org 0x0			
	goto	setup
	
	org 0x100			 ;Main code starts here at address 0x100

;~~~~~~~~~Interupt Code~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int_hi	code	0x0008		; high vector, no low vector
	btfss	INTCON,TMR0IF	; check that this is timer0 interrupt
	retfie	FAST		; if not then return
	incf	PWM_dc_B        ; incrementing the duty cycle
	call    PWM_rotate_B	; rotates the motor by new duty cycle
	bcf	INTCON,TMR0IF	; clear interrupt flag	
	retfie	FAST		; fast return from interrupt
	
;~~~~~~~~~~Program Setup~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
setup	
	clrf TRISH
	clrf PORTH  		;setting port H as output for esting
	
	call PWM_Setup_B	;setting up bottom motor	
	call PWM_Setup_T	;setting up top motor
	call ADC_Setup		;settung up the ADC module
	call LCD_Setup		;setting up the LCD module

;~~~~~~~~~~Main Code~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
start	
	movlw	b'10000111'	; Set timer0 to 16-bit, Fosc/4/256
	movwf	T0CON		; = 62.5KHz clock rate, approx 1sec rollover
	bsf	INTCON,TMR0IE	; Enable timer0 interrupt
	bsf	INTCON,GIE	; Enable all interrupts


measure_green
	movf	PWM_dc_T, W	
	movwf	PORTH		;displaying top duty cycle on PORT H
	
	movlw	0x00
	movwf	diff_l		;reset the difference in mesurement to zero

	movlw   0x05	    	; select AN1 for measurement
	movwf   ADCON0	    	; and turn ADC on
	call	ADC_Read
	movff	ADRESH,G_ADC_h	
	movff	ADRESL,G_ADC_l	;save the value of ACD on green LDR
	
measure_yellow	
	movlw   0x09	    	; select AN2 for measurement
	movwf   ADCON0	    	; and turn ADC on
	call	ADC_Read
	movff	ADRESH,Y_ADC_h
	movff	ADRESL,Y_ADC_l	;save the value of ACD on yellow LDR
			
	
	movff	Y_ADC_h,0x15 	;only for testing
	movff	Y_ADC_l,0x17
	movff	G_ADC_h,0x19
	movff	G_ADC_l,0x1B

check_h
	movf	G_ADC_h, W
	cpfseq	Y_ADC_h			;is yellow high equal to green high
	bra	change_h		;if no go to change_h
check_l					;if yes check for low
	movf	G_ADC_l, W		
	cpfsgt	Y_ADC_l			
	call	sub_Y			;if yellow is greater than green substract from yellow and put it in diff_l
	movf	G_ADC_l, W
	cpfslt	Y_ADC_l
	call	sub_G			;if yellow is smaller than green substract from green and put it in diff_l
	
	movlw	0x32			
	cpfslt	diff_l			;is difference less than 25mV?
	call	change_l		;if no go to change l
	goto	measure_green		;if yes repeat


	goto $

;~~~~~~~~~~~~Programms subroutines~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
change_h					;changes the duty cycle according to high green and yellow
	movf	G_ADC_h, W	
	cpfsgt	Y_ADC_h				
	call	dec_dc				;if yellow is greater than green decrement dc
	movf	G_ADC_h, W
	cpfslt	Y_ADC_h
	call	inc_dc				;if yellow is greater than green increment dc
	goto	measure_green			;if equal repeat the measurement


change_l					;changes the duty cycle according to low green and yellow
	movf	G_ADC_l, W
	cpfsgt	Y_ADC_l				
	call	dec_dc				;if yellow is greater than green decrement dc
	cpfslt	Y_ADC_l
	call	inc_dc				;if yellow is smaller than green decrement d
	return
	
sub_Y	movf	G_ADC_l, W			;substracting green from yellow (Y-G)
	subwf	Y_ADC_l, W
	movf	diff_l, W	
	return

sub_G	movf	Y_ADC_l, W			;substracting yellow from green (G-Y)
	subwf	G_ADC_l, W
	movf	diff_l, W	
	return
	
dec_dc						;decrementing the duty cycle or top motor
	decf	PWM_dc_T
	return

inc_dc						;decrementing the duty cycle or top motor
	incf	PWM_dc_T
	return
	
	

delay						;delay if needed
	decfsz	delay_count			; decrement until zero
	bra delay
	return
	
	end
