    #include p18f87k22.inc
    
    ;global  PWM_Setup
    
 

PWM	code
 
PWM_Setup

;******** Setting the PWM Period and Duty Cycle **********
    movlw	0xFF
    movwf	PR2		    ;Set the PWM period by writing to the PR2 register
    					;PR2 is in ACCESS
    movlw	0x55
    movwf	CCPR4L		    ;Set the Duty Cycle 
    					;CCPR4L is in ACCESS

;******** Setting CCP4 pin as output (RG3) ****************    
    ;clrf	TRISG			;setting port G as output
    movlw	b'11110111'
    movwf	TRISG, ACCESS		;setting RG3 as output	
    clrf	LATG, ACCESS		;Clear PORT G outputs
    
;******** Timer2 Configurations **************************
    bsf		T2CON, 2			;enabling Timer2
    bsf		T2CON, 1
    bsf		T2CON, 0			;setting the prescaler to 16 (PWM frequen
    						;Timer2 is b'xxxxx111'

    bsf		CCP4CON, 2	    
    bsf		CCP4CON, 3			;Configuring CCP4 to PWM Mode b'xx11xx'
        
    ;movlw	b'01'
    ;movwf	TMR2		    ;Seting the Time PreScale
    ;bsf	T2CON,0
    return
    
    end