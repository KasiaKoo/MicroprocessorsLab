#include p18f87k22.inc
    
    global Dic_Setup, Dic_4to2, Dic_Hex, Dic_HextoText
    

Dictrionary code
    
Dic_Setup
    lfsr FSR0, 0x100		;load address 0x100 into FSR0
    banksel 0x100
    movlw b'00'
    movwf 0x10E, BANKED
    movlw b'01'
    movwf 0x10D, BANKED
    movlw b'10'
    movwf 0x10B, BANKED
    movlw b'11'
    movwf 0x107, BANKED
    lfsr FSR1, 0x120
    movlw '1'
    movwf 0x120, BANKED
    movlw '2'
    movwf 0x121, BANKED
    movlw '3'
    movwf 0x122, BANKED
    movlw 'F'
    movwf 0x123, BANKED
    movlw '4'
    movwf 0x124, BANKED
    movlw '5'
    movwf 0x125, BANKED
    movlw '6'
    movwf 0x126, BANKED
    movlw 'E'
    movwf 0x127, BANKED
    movlw '7'
    movwf 0x128, BANKED
    movlw '8'
    movwf 0x129, BANKED
    movlw '9'
    movwf 0x12A, BANKED
    movlw 'D'
    movwf 0x12B, BANKED
    movlw 'A'
    movwf 0x12C, BANKED
    movlw '0'
    movwf 0x12D, BANKED
    movlw 'B'
    movwf 0x12E, BANKED
    movlw 'C'
    movwf 0x12F, BANKED
    return
    
    
Dic_4to2
    movf PLUSW0, W
    return
    
Dic_Hex
    rlncf 0x05
    rlncf 0x05
    movf  0x05, W
    iorwf 0x06	    ;in W we have the hex we want
    return
    
Dic_HextoText
    movf PLUSW1, W
    return
   
    end

