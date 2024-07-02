'
' *** CSR_EX.BAS - CSRLIN function programming example
'
' Move cursor to center of screen, then print message.
' Cursor returned to center of screen.
   LOCATE 12,40
   CALL MsgNoMove("A message not to be missed.",9,35)
   INPUT "Enter anything to end: ",A$

' Print a message without disturbing current
' cursor position.
SUB MsgNoMove (Msg$,Row%,Col%) STATIC

   ' Save the current line.
   CurRow%=CSRLIN
   ' Save the current column.
   CurCol%=POS(0)
   ' Print the message at the given position.
   LOCATE Row%,Col% : PRINT Msg$;
   ' Move the cursor back to original position.
   LOCATE CurRow%, CurCol%

END SUB
