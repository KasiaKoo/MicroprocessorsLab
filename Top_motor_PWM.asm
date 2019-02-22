    #include p18f87k22.inc
    
    global PWM_Setup_T, PWM_dc_T, PWM_rotate_T, PWM_delay_T
    
bnk0    udata	0x100   ; named variables in Bank 1 
;~~~~~~~ Counters used in delays
cnt_con	    res	4   	; reserve 4 bytes for big PWM cycle
cnt_100um   res	4   	; reserve 4 bytes for mid PWM cycle
cnt_10um    res	4   	; reserve 4 bytes for small PWM cycle
cnt_var     res 4   	; reserve 4 bytes for big PWM cycle
cnt_20um    res	4   	; reserve 4 bytes for mid PWM cycle
cnt_4um     res	4   	; reserve 4 bytes for small PWM cycle

;~~~~~~~ PWM period and duty cycle values
PWM_pr	    res 4   ; reserve 4 bytes for PWM period remainder
PWM_dc_T    res 4   ; reserve 4 bytes for PWM duty cycle remainder
counter	    res	4   ; reserve 4 bytes for test routine

PWM_dc_con  res 4   ; reserve 4 bytes for PWM period
PWM_pr_con  res 4   ; reserve 4 bytes for PWM duty cycle
  
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

;~~~~~~ Top Moto PWM setup ~~~~~~~~~~~~~~~~~~~~~~~

PWM_Setup_T
	movlw	0xB4
	movwf	PWM_pr_con, BANKED		; setting PWM constant period length to 17 ms
	movlw   0x05
	movwf   PWM_dc_con, BANKED		; setting the minimum duty cycle to 0.5 ms
	movlw	0x2F
	movwf	PWM_pr, BANKED			; setting the Reminder to ~2 ms 

	movlw	0x08
	movwf	PWM_dc_T, BANKED		; setting variable dc so that the motor is comfortable
	movlw	0x05
	movwf	counter, BANKED    		;controls the speed of the rotation
	return                    

;~~~~~~ Top Moto PWM setup ~~~~~~~~~~~~~~~~~~~~~~~

PWM_rotate_T
						 
	movlw	0x00
	cpfsgt	counter, BANKED			;checking if counter reached 0
	call	counter_reset			;reset counter if 0
	decf	counter, BANKED			;decrement counter if not 0
	
	bsf	PORTE, 4			;setting the pulse to high on RE4
	movf    PWM_dc_con, W, BANKED		
	call    PWM_100um			;implementing constant part of the duty cycle
	movf	PWM_dc_T, W, BANKED
	call	PWM_delay_T, BANKED		;implementing the variable part of the duty cycle
	
	bcf	PORTE, 4			;setting the pulse to low on RE4
	movf	PWM_dc_T, W, BANKED
	subwf	PWM_pr, W, BANKED		;finding how much remainder has to be implemented after this duty cycle
	call	PWM_delay_T			;implementing the remainder
	movf	PWM_pr_con, W, BANKED
	call	PWM_100um			;implementing the constant part of the period
	
	movlw	0x00				
	cpfsgt	counter, BANKED			;checking if the counter is zero
	return					;if yes return from the routine
	bra	PWM_rotate_T			;i no repeat the routine

	
counter_reset
	movlw	0x20
	movwf	counter, BANKED
	return
	
	
;~~~~~~~~The delay used for the duty cycle of the motor~~~~~~~~~~~~~~~~~~~
PWM_delay_T
	movwf	cnt_var, BANKED   ; counting down from number specified in rotate depending on duty cycle length
Var_d	movlw	0x00
	cpfseq	cnt_var, BANKED   ; skip next instruction and return if counter has reached 0
	goto	um20_delay   ; delay of 0.1 ms 
	return
	
	
um20_delay
	movlw	0x05
	movwf	cnt_20um, BANKED
d_20	decf	cnt_20um, BANKED   ; counting down from 9
	movlw	0x00
	cpfseq	cnt_20um, BANKED   ; skip next instruction and branch to big cycle if counter has reached 0
	goto	um4_delay
	decf	cnt_var, BANKED
	bra	Var_d
	
um4_delay	
	movlw	0x10
	movwf	cnt_4um, BANKED
d_4	decf	cnt_4um, BANKED   ; counting down from 39
	movlw	0x00
	cpfseq	cnt_4um, BANKED   ; skip next instruction and branch to mid cycle if counter has reached 0
	bra	d_4
	bra	d_20

	
;~~~~~~~~The delay used for 17 ms of the period for the motor~~~~~~~~~~~~~~~~~~~	
PWM_100um
	movwf	cnt_con , BANKED  ; counting down from number specified in rotate
Con_d	movlw	0x00
	cpfseq	cnt_con, BANKED   ; skip next instruction and return if counter has reached 0
	goto	um100_delay  ; delay of 0.1 ms 
	return
	
	
um100_delay
	movlw	0x09
	movwf	cnt_100um, BANKED
d_100	decf	cnt_100um, BANKED   ; counting down from 9
	movlw	0x00
	cpfseq	cnt_100um, BANKED   ; skip next instruction and branch to big cycle if counter has reached 0
	goto	um10_delay
	decf	cnt_con, BANKED
	bra	Con_d
	
um10_delay	
	movlw	0x27
	movwf	cnt_10um, BANKED
d_10	decf	cnt_10um, BANKED   ; counting down from 39
	movlw	0x00
	cpfseq	cnt_10um, BANKED   ; skip next instruction and branch to mid cycle if counter has reached 0
	bra	d_10
	bra	d_100
	
	end





