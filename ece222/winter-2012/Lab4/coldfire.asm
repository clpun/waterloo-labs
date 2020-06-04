**********************************************************************
*   MCF5206 ColdFire Assembly Header File                            *
*   Developed by       : Motorola                                    *
*                        Imaging and Storage Systems Division        *
*                        Austin, TX                                  *
*   Modified by        : E&CE Technical Staff, University of Waterloo*
**********************************************************************



MBASE      EQU      0xF0000000    ; Module Base Address



*Serial Port Registers
UMR10	equ	MBASE+0x1c0	;UART Mode Register 1 (R/W 8 bit)

USR0	equ	MBASE+0x1c4	;UART Status Registers (R 8 bits)
UCR0	equ	MBASE+0x1c8	;UART Command Registers (W 8 bits)
URB0	equ	MBASE+0x1cc	;UART Receiver Buffers (R 8 bits)
UTB0	equ	MBASE+0x1cc	;UART Trasmitter Buffers (W 8 bits)

UIMR0	equ	MBASE+0x1d4	;UART Interrupt Mask Register (R/W 8 bit)

*Parallel Port Registers
PAR	equ	MBASE+0x004	;Pin Assignment Register (R/W 16 bits)
PADDR	equ	MBASE+0x244	;Port A Data Direction Register (R/W 16 bits)
PADAT	equ	MBASE+0x248	;Port A Data Register (R/W 16 bits)

*Timer Register
TMR0	equ	MBASE+0x140	;Timer 0 Mode Register (R/W 16 bits)
TRR0	equ	MBASE+0x144	;Timer 0 Reference Register (R/W 16 bits)
TCR0    equ     MBASE+0x148     ;Timer 0 Capture Register (R 16 bits)
TCN0    equ     MBASE+0x14c     ;Timer 0 Counter (R/W 16 bits)
TER0	equ	MBASE+0x151	;Timer 0 Event Register (R/W 8 bits)

TMR1    equ     MBASE+0x180     ;Timer 1 Mode Register (R/W 16 bits)
TRR1    equ     MBASE+0x184     ;Timer 1 Reference Register (R/W 16 bits)
TCR1    equ     MBASE+0x188     ;Timer 1 Capture Register (R 16 bits)
TCN1    equ     MBASE+0x18c     ;Timer 1 Counter (R/W 16 bits)
TER1    equ     MBASE+0x191	;Timer 1 Event Register (R/W 8 bits)

*Interrupt Registers
IPR     equ     MBASE+0x040     ;Interrupt Pending Register (R 32 bits)
IMR		equ	MBASE+0x044	;Interrupt Mask Regiser (R/W 32 bits)
ICR1	equ	MBASE+0x04d	;Interrupt Control Register for Timer 0 (R/W 8 bits)
ICR2    equ     MBASE+0x04e     ;Interrupt Control Register for Timer 1 (R/W 8 bits)_
ICR4	equ	MBASE+0x050	;Interrupt Control Register for UART 0 (R/W 8 bits)

ISR_base        equ     0x10000000
ISR_lvl_1       equ     ISR_base+100     Lvl 1 interrupt autovector
ISR_lvl_2       equ     ISR_base+104     Lvl 2 interrupt autovector
ISR_lvl_3       equ     ISR_base+108     Lvl 3 interrupt autovector
ISR_lvl_4       equ     ISR_base+112     Lvl 4 interrupt autovector
ISR_lvl_5       equ     ISR_base+116     Lvl 5 interrupt autovector
ISR_lvl_6       equ     ISR_base+120     Lvl 6 interrupt autovector
ISR_lvl_7       equ     ISR_base+124     Lvl 7 interrupt autovector