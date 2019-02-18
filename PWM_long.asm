    #include p18f87k22.inc
    
    global  PWM_Setup, PWM_dc, PWM_test_routine, PWM_cycle_big2
    
acs0    udata_acs   ; named variables in access ram
PWM_cnt_l   res 1   ; reserve 1 byte for variable PWM_cnt_l
PWM_cnt_h   res 1   ; reserve 1 byte for variable PWM_cnt_h
   
PWM_cnt_b   res	4   ; reserve 4 bytes for big PWM cycle
PWM_cnt_m   res	4   ; reserve 4 bytes for mid PWM cycle
PWM_cnt_s   res	4   ; reserve 4 bytes for small PWM cycle
PWM_cnt_b2   res	4   ; reserve 4 bytes for big PWM cycle
PWM_cnt_m2   res	4   ; reserve 4 bytes for mid PWM cycle
PWM_cnt_s2   res	4   ; reserve 4 bytes for small PWM cycle

PWM_pr	    res 4   ; reserve 4 bytes for PWM period
PWM_pr_con  res 4
PWM_dc	    res 4   ; reserve 4 bytes for PWM duty cycle
PWM_dc_con  res 4
counter	    res	4   ; reserve 4 bytes for test routine
work	    res	4

PWM_counter res 2   ; reserve 2 bytes
  

PWM	code
 
PWM_Setup
	clrf TRISE	    
	clrf PORTE
	clrf LATE	    ; PORTE as PWM motor cycle
	movlw	0xAA
	movwf	PWM_pr_con	    ; setting PWM period length to 20 ms
	movlw	0x58
	movwf	PWM_pr
	movlw   0x05
	movwf   PWM_counter
	movlw   0x05
	movwf   PWM_dc_con
	movlw	0x04
	movwf	PWM_dc      ; setting minimum duty cycle length to 1 ms
	movlw	0x20
	movwf	counter    
	return                    

	
PWM_test_routine
	movlw	0x00
	cpfsgt	counter
	call	counter_reset
	decf	counter
	movlw	0xFF
	movwf	PORTE
	movf    PWM_dc_con, W
	call    PWM_cycle_big
	movf	PWM_dc, W
	call	PWM_cycle_big2
	movlw	0x00
	movwf	PORTE
	movf	PWM_dc, W
	subwf	PWM_pr, W
	call	PWM_cycle_big2
	movf	PWM_pr_con, W
	call	PWM_cycle_big
	movlw	0x00
	cpfsgt	counter
	return
	;incf	PWM_dc
	;movlw	0x57
	cpfseq	PWM_dc
	bra	PWM_test_routine

reset_dc    
	movlw	0x04
	movwf	PWM_dc
	bra	PWM_test_routine
	
counter_reset
	movlw	0x20
	movwf	counter
	return
	
	
;~~~~~~~~The delay used for the duty cycle of the motor~~~~~~~~~~~~~~~~~~~
PWM_cycle_big2
	movwf	PWM_cnt_b2   ; counting down from number specified in test routine depending on duty cycle length
big2	movlw	0x00
	cpfseq	PWM_cnt_b2   ; skip next instruction and return if counter has reached 0
	goto	PWM_mid2   ; delay of 0.1 ms 
	return
	
	
PWM_mid2
	movlw	0x05
	movwf	PWM_cnt_m2
mid2	decf	PWM_cnt_m2   ; counting down from 9
	movlw	0x00
	cpfseq	PWM_cnt_m2   ; skip next instruction and branch to big cycle if counter has reached 0
	goto	PWM_small2
	decf	PWM_cnt_b2
	bra	big2
	
PWM_small2	
	movlw	0x10
	movwf	PWM_cnt_s2
small2	decf	PWM_cnt_s2   ; counting down from 39
	movlw	0x00
	cpfseq	PWM_cnt_s2   ; skip next instruction and branch to mid cycle if counter has reached 0
	bra	small2
	bra	mid2

	
;~~~~~~~~The delay used for 17 ms of the period for the motor~~~~~~~~~~~~~~~~~~~	
PWM_cycle_big
	movwf	PWM_cnt_b   ; counting down from number specified in test routine depending on duty cycle length
big	movlw	0x00
	cpfseq	PWM_cnt_b   ; skip next instruction and return if counter has reached 0
	goto	PWM_mid   ; delay of 0.1 ms 
	return
	
	
PWM_mid
	movlw	0x09
	movwf	PWM_cnt_m
mid	decf	PWM_cnt_m   ; counting down from 9
	movlw	0x00
	cpfseq	PWM_cnt_m   ; skip next instruction and branch to big cycle if counter has reached 0
	goto	PWM_small
	decf	PWM_cnt_b
	bra	big
	
PWM_small	
	movlw	0x27
	movwf	PWM_cnt_s
small	decf	PWM_cnt_s   ; counting down from 39
	movlw	0x00
	cpfseq	PWM_cnt_s   ; skip next instruction and branch to mid cycle if counter has reached 0
	bra	small
	bra	mid
	
	end


