PROGRAM 		equ 		$10200000
OPERAND 		equ 		$10210000
BUFFER 			equ 		$10220000
STACK 			equ 		$10230000
CR 				equ 		$0D
LF 				equ 		$0A
 org 		OPERAND
PROMPT 			dc.b 		"This program will print out a string in the reverseorder.",CR,LF
 dc.b 		"Enter string to process, followed by :",0
 org 			PROGRAM					
 lea 		STACK,A7 	; initialize stack
 jmp 		start		; move to start ($10200094)
in_string
 move.l 		D1,-(A7)
 move.l 		D2,-(A7)
 move.l 		A1,-(A7)
 move.l 		#0, D2
in_string_loop
 jsr 		in_char
 tst.l D1
 beq 		in_string_loop
 cmp.l 		#CR,D1
 beq.w 		exit_in_string
 cmp.l 		#LF,D1
 beq.w 		exit_in_string
 move.b 		D1,(A1)+
 add.l 		#1, D2
 bra 		in_string_loop
exit_in_string
 tst.l 		D2
 beq 		in_string_loop
 move.b 		#0,(A1)	
 move.l 		(A7)+,A1
 move.l 		(A7)+,D2
 move.l 		(A7)+,D1
 rts		
out_crlf		
 move.l 		D1,-(A7)		
 move 		#CR,D1			
 jsr 		out_char		
 move 		#LF,D1			
 jsr 		out_char		
 move.l 		(A7)+,D1
 rts
out_string
 move.l 		D1,-(A7)
 move.l 		A1,-(A7)
out_next_char
 move.b 		(A1)+,D1
 jsr 		out_char
 tst.b 		D1
 bne 		out_next_char
 move.l 		(A7)+,A1
 move.l 		(A7)+,D1
 rts
out_char
 move.l 		D0,-(A7)
 move.l 		#$0013,D0
 TRAP 		#15
 move.l 		(A7)+,D0
 rts
in_char
 move.l 		D0,-(A7)
 move.l 		#$0010,D0
 TRAP 		#15
 and.l 		#$7F,D1
 bsr 		out_char
 move.l 		(A7)+,D0
 rts
start
 lea 		PROMPT,A1
 bsr.w 		out_string
 bsr.w 		out_crlf
 lea 		BUFFER,A1
 bsr.w 		in_string
 bsr.w 		out_crlf
 move.l 		#BUFFER,A0
bloop1
 tst.b 		(A0)+
 bne 		bloop1
 suba.l 		#1,A0
 movea.l 	#BUFFER+1024,A2
 movea.l		A2,A1
reverse_loop
 move.b		-(A0),(A2)+
 tst.b		(A0)
 bne			reverse_loop
 bsr.w 		out_string
 bsr.w 		out_crlf
 move.l 		#$0000,d0
 TRAP 		#15
end