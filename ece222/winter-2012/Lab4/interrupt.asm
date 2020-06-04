**************************************************************************************************
* Interrupt Service Routine for keyboard
* D1 contains the key pressed
* KEY_READY contains the flag to indicate whether a character is ready. (0x72 means yes, 0x00 means no.)
* Note: 72 is my birthday. 
**************************************************************************************************
KEYBOARD_ISR
	clr.l		D1
	move.b		URB0,D1	; record key press into D1
 	and.l 		#$7F,D1
	lea			KEY_READY,A1	; set KEY_READY flag to be 0x72 to indicate completion of keyboard ISR
	move.l		#$72,(A1)
	rte ; rte instead of rts since this is an exception. 

**************************************************************************************************
* Interrupt Service Routine for timer
* This ISR will be called every 1 second
* Increment every 1 second(called every 1 second)
**************************************************************************************************

TIMER_ISR
	move.l		A1,-(A7)
	move.l		A2,-(A7)
	move.l		D2,-(A7)
	move.l		D3,-(A7)
	move.l		D4,-(A7)
	move.l		D5,-(A7)
	move.l		D6,-(A7)

	clr.l		D2	; make sure that bit1 of TER0 is set to 1 so that all interrupts are cleared. 
	move.b		#$02,D2
	move.b		D2,TER0
	clr.l		D2
	
* Move seconds into D4 in binary
	movea.l		#SECONDS,A1
	bsr			DEC2BIN	; ascii to binary conversion
	move.l		D3,D4	; D4 now contains the binary representation of seconds
	
* Move minutes into D5 in binary
	movea.l		#MINUTES,A1
	bsr			DEC2BIN ; ascii to binary conversion
	move.l		D3,D5	; D5 now contains the binary representation of minutes
	
* Move hours into D6 in binary
	movea.l		#HOURS,A1
	bsr			DEC2BIN	; ascii to binary conversion
	move.l		D3,D6	; D6 now contains the binary representation of hours
	
* Increment 1 second by adding 1 to D4
	add.l		#01,D4		; Add 1 to seconds
	bsr			ROLLOVER_CHECK; check if seconds is 60. To be added...
	
* Store the ascii version of hours back to HOURS
	bsr			BIN2DEC
	cmp.l		#09,D6		; prepend 0 if time value is 0 to 9. (so 9 will display as 09)
	bgt			HOURS_READY
	move.b		#$30,(A1)+
HOURS_READY
	movea.l		#BUFFER+1024,A2
	move.l		(A2),D2
	move.l		D2,(A1)		; HOURS now contains updated hours in ASCII
	  
* Store the ascii version of minutes back to MINUTES
	movea.l		#MINUTES,A1
	move.l		D5,D6
	bsr			BIN2DEC
	cmp.l		#09,D6		; prepend 0 if time value is 0 to 9. (so 9 will display as 09)
	bgt			MINUTES_READY
	move.b		#$30,(A1)+
MINUTES_READY
	movea.l		#BUFFER+1024,A2
	move.l		(A2),D2
	move.l		D2,(A1)		; HOURS now contains updated hours in ASCII
	
* Store the ascii version of seconds back to SECONDS
	movea.l		#SECONDS,A1
	move.l		D4,D6
	bsr			BIN2DEC
	cmp.l		#09,D6		; prepend 0 if time value is 0 to 9. (so 9 will display as 09)
	bgt			SECONDS_READY
	move.b		#$30,(A1)+
SECONDS_READY
	movea.l		#BUFFER+1024,A2
	move.l		(A2),D2
	move.l		D2,(A1)		; HOURS now contains updated hours in ASCII
	
	lea			TIMER_UPDATED,A1	; set TIMER flag to be 0x72 to indicate completion of timer ISR
	move.l		#$72,(A1)
	
	move.l		(A7)+,D6
	move.l		(A7)+,D5
	move.l		(A7)+,D4
	move.l		(A7)+,D3
	move.l		(A7)+,D2
	move.l		(A7)+,A2
	move.l		(A7)+,A1
	rte
	
ROLLOVER_CHECK
	cmp.l		#060,D4
	blt			NO_FIXING
	move.l		#0,D4	; set seconds to 0
	add.l		#01,D5	; increment minutes by 1
	cmp.l		#060,D5
	blt			NO_FIXING
	move.l		#0,D5	; set minutes to 0
	add.l		#01,D6	; increment hours by 1
	cmp.l		#012,D6
	blt			NO_FIXING
	move.l		#0,D6	; set hours to 0
NO_FIXING		rts