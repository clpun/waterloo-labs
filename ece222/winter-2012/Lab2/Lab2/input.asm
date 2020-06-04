in_string
				move.l  D1,-(A7)
				move.l  D2,-(A7)
				move.l  A1,-(A7)
				move.l  #0, D2
in_string_loop	jsr 	in_char
				tst.l   D1
				beq     in_string_loop
				cmp.l   #CR,D1
				beq.w   exit_in_string
				cmp.l   #LF,D1
				beq.w   exit_in_string
				move.b  D1,(A1)+
				add.l   #1, D2
				bra     in_string_loop
					
exit_in_string	tst.l   D2
				beq     menu
				move.b	#0,(A1)
				
				move.l	(A7)+,A1
				move.l	(A7)+,D2
				move.l	(A7)+,D1
				rts

in_char	; Takes input from user
				move.l  D0,-(A7) 
				move.l  #$0010,d0 
				TRAP    #15 
				and.l   #$7F,d1 
				bsr     out_char
					
				move.l  (A7)+,D0
				rts 