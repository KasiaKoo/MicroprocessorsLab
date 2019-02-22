    #include p18f87k22.inc
    
    global  PWM_Setup_B, PWM_dc_B, PWM_rotate_B, PWM_delay_B
    extern  flag
acs0    udata_acs   ; named variables in access ram
;~~~~~~~ Counters used in the delay    
cnt_con		res 4   ; reserve 4 bytes for big PWM cycle
cnt_100um	res 4   ; reserve 4 bytes for mid PWM cycle
cnt_10um	res 4   ; reserve 4 bytes for small PWM cycle
cnt_var		res 4   ; reserve 4 bytes for big PWM cycle
cnt_20um	res 4   ; reserve 4 bytes for mid PWM cycle
cnt_4um   	res 4   ; reserve 4 bytes for small PWM cycle

;~~~~~~~ PWM period and duty cycle values
PWM_pr_B	    res 4	; reserve 4 bytes for PWM period remainder
PWM_pr_con_B  res 4	; reserve 4 bytes for PWM period
PWM_dc_B    res 4	; reserve 4 bytes for PWM duty cycle remainder
PWM_dc_con_B  res 4	; reserve 4 bytes for PWM duty cycl
counter	    res	4	; reserve 4 bytes for test routine

  
;................THE PWM FOR SG90 MOTOR..................................................
;Motor's datasheet requires 20 ms period which is not compatible with built in PWM module
;Therefore, we created our own module which takes care of this PWM through the use of delays
;The 20 ms period is split into 0.5 ms constant duty cycle, remainder and 17 ms constant period
;The remainder allows us to control the length of the of the duty cycle by dividing it 
;into period and the duty cycle in the rotation routine
;The remainder is not set exactly for 2.5 ms but with length calculated with oscillopscope
;that takes into account the extra clock cycle used during rotation commands
;the counter controls the number of complete pulses which are sent to the motor before 
;any changes to dc are made
;........................................................................................

PWM	code
 
PWM_Setup_B
	clrf TRISE	    
	clrf PORTE
	clrf LATE	    		; PORTE as PWM motor cycle (as output)
	movlw	0xAA
	movwf	PWM_pr_con_B		; setting PWM period length to 17 ms
	movlw	0x58
	movwf	PWM_pr_B			; setting the Reminder to ~2 ms 
	movlw   0x05
	movwf   PWM_dc_con_B		; setting the minimum duty cycle to 0.5 ms
	movlw	0x04
	movwf	PWM_dc_B      		; setting variable dc so that the motor is comfortable
	movlw	0x0A
	movwf	counter    		;setting the number of pulses send to the motor with one dc
	return                    

	
PWM_rotate_B
	incf	PWM_dc_B        ; incrementing the duty cycle	
rot	movlw	0x00
	movwf	flag
	cpfsgt	counter, BANKED			;checking if counter reached 0
	call	counter_reset			;reset counter if 0
	decf	counter, BANKED			;decrement counter if not 0
	
	bsf	PORTE, 0			;setting the pulse to high on RE4
	movf    PWM_dc_con_B, W
	call    PWM_100um			;implementing constant part of the duty cycle
	movf	PWM_dc_B, W
	call	PWM_delay_B			;implementing the variable part of the duty cycle
	
	bcf	PORTE, 0			;setting the pulse to low on RE4
	movf	PWM_dc_B, W
	subwf	PWM_pr_B, W			;finding how much remainder has to be implemented after this duty cycle
	call	PWM_delay_B			;implementing the remainder
	movf	PWM_pr_con_B, W			
	call	PWM_100um			;implementing the constant part of the period
	movlw	0x00
	cpfsgt	counter				;checks if counter reached 0
	bra	check_dc			;if yes return to the interupt
	bra	rot			;if no repeat the loop

check_dc
	movlw	0x57
	cpfseq	PWM_dc_B			;if no: compare dc_to 87
	return
	;goto final				;if we were working on the timescale of a day, this would be the end of the azimuthal rotation

reset_dc    					;if yes reset the counter
	movlw	0x01
	call	PWM_100um
	movlw	0x04
	movwf	PWM_dc_B
	return
	
final   
	goto $	

counter_reset
	movlw	0x20
	movwf	counter
	return
	
	
;~~~~~~~~The delay used for the duty cycle of the motor~~~~~~~~~~~~~~~~~~~
PWM_delay_B
	movwf	cnt_var   ; counting down from number specified in test routine depending on duty cycle length
Var_d	movlw	0x00
	cpfseq	cnt_var   ; skip next instruction and return if counter has reached 0
	goto	um20_delay  ; delay of 0.1 ms 
	return
	
	
um20_delay
	movlw	0x05
	movwf	cnt_20um
d_20	decf	cnt_20um   ; counting down from 9
	movlw	0x00
	cpfseq	cnt_20um   ; skip next instruction and branch to big cycle if counter has reached 0
	goto	um4_delay
	decf	cnt_var
	bra	Var_d
	
um4_delay	
	movlw	0x10
	movwf	cnt_4um
d_4	decf	cnt_4um   ; counting down from 39
	movlw	0x00
	cpfseq	cnt_4um   ; skip next instruction and branch to mid cycle if counter has reached 0
	bra	d_4
	bra	d_20

	
;~~~~~~~~The delay used for 17 ms of the period for the motor~~~~~~~~~~~~~~~~~~~	
PWM_100um
	movwf	cnt_con   ; counting down from number specified in test routine depending on duty cycle length
Con_d	movlw	0x00
	cpfseq	cnt_con   ; skip next instruction and return if counter has reached 0
	goto	um100_delay   ; delay of 0.1 ms 
	return
	
	
um100_delay
	movlw	0x09
	movwf	cnt_100um
d_100	decf	cnt_100um   ; counting down from 9
	movlw	0x00
	cpfseq	cnt_100um   ; skip next instruction and branch to big cycle if counter has reached 0
	goto	um10_delay
	decf	cnt_con
	bra	Con_d
	
um10_delay	
	movlw	0x27
	movwf	cnt_10um
d_10	decf	cnt_10um   ; counting down from 39
	movlw	0x00
	cpfseq	cnt_10um   ; skip next instruction and branch to mid cycle if counter has reached 0
	bra	d_10
	bra	d_100
	
	end


