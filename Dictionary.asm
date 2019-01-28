#include p18f87k22.inc
    
    global Dic_Setup, Dic_4to2
    


    
Dic_Setup
    lsfr    FSR0, 0x100		;load address 0x100 into FSR0
    movlw 0x00
    movwf 0x10E
    movlw 0x01
    movwf 0x10D
    movlw 0x10
    movfw 0x10B
    movlw 0x11
    movfw 0x107
    
    
Dic_4to2
    
    addwf INDF0, f
    
    

