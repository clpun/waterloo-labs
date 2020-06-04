out_crlf ; go to newline subroutine
				move.l   D1,-(A7)
				move     #CR,D1
				jsr      out_char 
				move     #LF,D1 
				jsr      out_char 
				move.l   (A7)+,D1 
				rts 
					
out_string ; output all the characters
				move.l  D1,-(A7) 
				move.l	A1,-(A7) 
out_next_char
				move.b   (A1)+,D1 
				jsr      out_char 
				tst.b    D1 
				bne      out_next_char 
				move.l   (A7)+,A1 					
				move.l   (A7)+,D1 
				rts
					
out_char ; display a character onto monitor
				move.l  D0,-(A7)
				move.l  #$0013,d0 
				TRAP    #15
				move.l  (A7)+,D0 
				rts