The Code
cfasm ColdFire Assembler version 2.92 (07 Jun 2005)
Copyright (C) 1998-2005 Austex Software. All rights reserved.
Address Opcode Mnuemonics/ Directives
Operands
CPU 5307
include q:\eng\ece\Coldfire\coldfire.asm
* E&CE 222 Lab 1 sample program.
*
* Copyright 1998, University of Waterloo

10200000 					PROGRAM 		equ 		$10200000
10210000 					OPERAND 		equ 		$10210000
10220000 					BUFFER 			equ 		$10220000
10230000 					STACK 			equ 		$10230000
0000000d 					CR 				equ 		$0D
0000000a 					LF 				equ 		$0A
10210000 									org 		OPERAND
10210000 	5468 6973 2070 	PROMPT 			dc.b 		"This program will print out a string in the reverseorder.",CR,LF
			726f 6772 616d
			2077 696c 6c20
			7072 696e 7420
			6f75 7420 6120
			7374 7269 6e67
			2069 6e20 7468
			6520 7265 7665
			7273 6520 6f72
			6465 722e 0d0a
1021003c 	456e 7465 7220 					dc.b 		"Enter string to process, followed by :",0
			7374 7269 6e67
			2074 6f20 7072
			6f63 6573 732c
			2066 6f6c 6c6f
			7765 6420 6279
			203c 456e 7465
			723e 3a00
10200000 	org 			PROGRAM					
* Initilization
10200000 	4ff9 1023 0000 	lea 		STACK,A7 	; initialize stack
10200006 	4ef9 1020 0094 	jmp 		start		; move to start ($10200094)
******************************************************
*
* Subroutines...
*
******************************************************
* Fetch a string until CR or LF and return it in
* NOTE: a null termination is added
* the buffer is provided by A1
* ** Stay in this until at least _1_ character is entered!
* ** This prevents problems with extra CR/LF/Null characters
******************************************************
			in_string
1020000c 	2f01 			move.l 		D1,-(A7)
1020000e 	2f02 			move.l 		D2,-(A7)
10200010 	2f09 			move.l 		A1,-(A7)
10200012 	7400 			move.l 		#0, D2
			in_string_loop
10200014 	4eb9 1020 0082 	jsr 		in_char
1020001a 	4a81 			tst.l D1
1020001c 	67f6 			beq 		in_string_loop
1020001e 	b2bc 0000 000d 	cmp.l 		#CR,D1
10200024 	6700 0012 		beq.w 		exit_in_string
10200028 	b2bc 0000 000a 	cmp.l 		#LF,D1
1020002e 	6700 0008 		beq.w 		exit_in_string
10200032 	12c1 			move.b 		D1,(A1)+
10200034	5282 			add.l 		#1, D2
10200036	60dc			bra 		in_string_loop
			exit_in_string
10200038	4a82			tst.l 		D2
1020003a	67d8			beq 		in_string_loop
1020003c	12bc 0000 		move.b 		#0,(A1)	
10200040	225f 			move.l 		(A7)+,A1
10200042	241f 			move.l 		(A7)+,D2
10200044	221f 			move.l 		(A7)+,D1
10200046	4e75 			rts		
******************************************************
* print CR, LF
******************************************************
			out_crlf		
10200048 	2f01 			move.l 		D1,-(A7)		
1020004a 	323c 000d 		move 		#CR,D1			
1020004e 	4eb9 1020 0078 	jsr 		out_char		
10200054 	323c 000a 		move 		#LF,D1			
10200058 	4eb9 1020 0078 	jsr 		out_char		
1020005e 	221f 			move.l 		(A7)+,D1
10200060 	4e75 			rts
******************************************************
* Put out a string to the terminal
* A1 points to start of string; 0 marks end of string
******************************************************
			out_string
10200062 	2f01 			move.l 		D1,-(A7)
10200064 	2f09 			move.l 		A1,-(A7)
			out_next_char
10200066 	1219 			move.b 		(A1)+,D1
10200068 	4eb9 1020 0078 	jsr 		out_char
1020006e 	4a01 			tst.b 		D1
10200070 	66f4 			bne 		out_next_char
10200072 	225f 			move.l 		(A7)+,A1
10200074 	221f 			move.l 		(A7)+,D1
10200076 	4e75 			rts
******************************************************
* D1 is printed to terminal
******************************************************
			out_char
10200078 	2f00 			move.l 		D0,-(A7)
1020007a 	7013 			move.l 		#$0013,D0
1020007c 	4e4f 			TRAP 		#15
1020007e 	201f 			move.l 		(A7)+,D0
10200080 	4e75 			rts
******************************************************
* D1 is returned from the terminal
******************************************************
			in_char
10200082 	2f00 		 	move.l 		D0,-(A7)
10200084 	7010 			move.l 		#$0010,D0
10200086 	4e4f 			TRAP 		#15
10200088 	c2bc 0000 007f 	and.l 		#$7F,D1
1020008e 	61e8 			bsr 		out_char
10200090 	201f 			move.l 		(A7)+,D0
10200092 	4e75 			rts
******************************************************
*
* End of Subroutines
*
******************************************************
			start
10200094 	43f9 1021 0000 	lea 		PROMPT,A1
1020009a 	6100 ffc6 		bsr.w 		out_string
1020009e 	6100 ffa8 		bsr.w 		out_crlf
* Get input
102000a2 	43f9 1022 0000 	lea 		BUFFER,A1
102000a8 	6100 ff62 		bsr.w 		in_string
102000ac 	6100 ff9a 		bsr.w 		out_crlf
* Scan for end of string.
102000b0 	207c 1022 0000 	move.l 		#BUFFER,A0
			bloop1
102000b6	4a18			tst.b 		(A0)+
102000b8	66fe			bne 		bloop1
102000ba	91fc 0000 0001 	suba.l 		#1,A0
102000c0	247c 1022 0400	movea.l 	#BUFFER+1024,A2
************ Code added **************
			reverse_loop
102000c6	14c9			move.b		A0,(A2)+		; set last letter as first letter of reversed string. 0001 0100 1100 1001
102000c8	5388		 	subq.l 		#1,A0			; look at the next last character. 0101 0011 1000 1000
102000ca	b3c8			cmpa		A0,A1			; compare the operand addresses store in A0 and A1. 1011 0011 1100 1000
102000cc	6efc			bgt		reverse_loop		; continue the loop if the address store in A0 is still greater than the one that is stored in A1. 0110 1110 1111 0100
102000ce	14bc 0000 		move 		#0,(A2)			; change address register to 0 to represent the end. 0001 0100 1011 1100 x0000
102000d2	2249			movea.l		A2,A1			; point the string register (A1) to the beginning of the reversed string. 0010 0010 0100 1001
************ Code added **************
102000d4	6100 ff8c		bsr.w 		out_string
102000d8	6100 ff72		bsr.w 		out_crlf
* Exit
102000dc	203c 0000 0000	move.l 		#$0000,d0
102000e2	4e4f			TRAP 		#15
							end