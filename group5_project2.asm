		ORG 00H				;Start program at location 0H
		
USERNAME:	MOV 50H,#'T'			;Store the username
		MOV 51H,#'O'
		MOV 52H,#'M'
		MOV 53H,#'A'
		MOV 54H,#'T'
		MOV 55H,#'O'
		MOV 56H,#'2'
		MOV 57H,#'4'
		MOV 58H,#'5'
		
PASSWORD:	MOV 70H,#'P'			;Store the password
		MOV 71H,#'O'
		MOV 72H,#'T'
		MOV 73H,#'A'
		MOV 74H,#'T'
		MOV 75H,#'O'
		MOV 76H,#'3'
		MOV 77H,#'6'
		MOV 78H,#'9'
		
BEGIN:		MOV R5,#0H			;Set as 0 to take username input. Further explanation later.
		MOV R6,#9H			;Number of characters used in username
		MOV R7,#9H			;Number of characters used in password
		
DISPLAY1:	ACALL DISPLAYRST		;Call subroutine to refresh the display for new message
		MOV A,#'E'			;Display the character 'E'
		ACALL DATAWRT			;Call subroutine for displaying data
		ACALL DELAY			;Small delay
		MOV A,#'n'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'t'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'e'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'r'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#' '
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'U'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'s'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'e'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'r'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'n'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'a'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'m'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'e'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#':'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#0C0H			;Put the display cursor at the start of the second line
		ACALL COMNWRT			;Call subroutine for command
		ACALL DELAY
		
KEYPAD:		MOV P2,#0FFH			;Make P2 as input port
		MOV R0,#50H			;Beginning of stored username
		MOV R1,#70H			;Beginning of stored password
K1:		MOV P0,#0H			;Ground all rows at once
		MOV A,P2			;Read all column values
		ANL A,#00111111B		;Mask unused bits
		CJNE A,#00111111B,K1		;Check till all keys released
K2:		ACALL DELAY
		MOV A,P2			;See if any key is pressed
		ANL A,#00111111B
		CJNE A,#00111111B,OVER		;Move forward if key is pressed
		SJMP K2				;Repeat loop if key is not pressed
OVER:		ACALL DELAY			;Debounce time for key press
		MOV A,P2			;Check key closure
		ANL A,#00111111B
		CJNE A,#00111111B,OVER1		;Find row if key is pressed
		SJMP K2		
OVER1:		MOV P0,#11111110B		;Ground row 0
		MOV A,P2
		ANL A,#00111111B
		CJNE A,#00111111B,ROW_0		;If row 0 is the right row, they won't be equal so move to next step
		MOV P0,#11111101B
		MOV A,P2
		ANL A,#00111111B
		CJNE A,#00111111B,ROW_1
		MOV P0,#11111011B
		MOV A,P2
		ANL A,#00111111B
		CJNE A,#00111111B,ROW_2
		MOV P0,#11110111B
		MOV A,P2
		ANL A,#00111111B
		CJNE A,#00111111B,ROW_3
		MOV P0,#11101111B
		MOV A,P2
		ANL A,#00111111B
		CJNE A,#00111111B,ROW_4
		MOV P0,#11011111B
		MOV A,P2
		ANL A,#00111111B
		CJNE A,#00111111B,ROW_5
		LJMP K2				;Jump back if there is a false input
		
ROW_0:		MOV DPTR,#KCODE0		;Set DPTR at the start of row 0 character lookup table
		SJMP FIND			;Jump to FIND subroutine to find the column again
ROW_1:		MOV DPTR,#KCODE1
		SJMP FIND
ROW_2:		MOV DPTR,#KCODE2
		SJMP FIND
ROW_3:		MOV DPTR,#KCODE3
		SJMP FIND
ROW_4:		MOV DPTR,#KCODE4
		SJMP FIND
ROW_5:		MOV DPTR,#KCODE5
		SJMP FIND
		
FIND:		RRC A				;Check if CY = 0
		JNC MATCH			;Go to the next step to get ASCII code if CY = 0
		INC DPTR			;Point to next column address
		SJMP FIND			;Repeat loop

MATCH:		CLR A				;Set A = 0
		MOVC A,@A+DPTR			;Get the ASCII code from lookup table
		CJNE R5,#0H,PASS		;If R5 = 0, the username is matched. Otherwise password is matched
USER:		MOV B,@R0			;Move the first character of stored username to B
		CJNE A,B,SKIP			;Compare pressed key with the stored key. Jump if not same
		INC R0				;Go to next stored character
		ACALL DATAWRT
		DJNZ R6,REPEAT			;Repeat key pressing and checking loop
		LJMP DISPLAY2			;Display the second message
PASS:		MOV B,@R1			;Move the first character of stored password to B
		CJNE A,B,SKIP
		INC R1
		MOV A,#'*'			;Show '*' instead of actual password character for security
		ACALL DATAWRT
		DJNZ R7,REPEAT
		LJMP DISPLAY3			;Display the third message
REPEAT:		LJMP K1				;Check for key press again
SKIP:		ACALL ERROR			;Show error message if key doesn't match
		LJMP BEGIN			;Start from the very beginning due to wrong username or password

DISPLAY2:	MOV R5,#1H			;R5 = 0 for password checking step
		ACALL DISPLAYRST
		MOV A,#'E'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'n'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'t'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'e'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'r'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#' '
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'P'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'a'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'s'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'s'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'w'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'o'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'r'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'d'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#':'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#0C0H
		ACALL COMNWRT
		ACALL DELAY
		LJMP K1				;Check for key press
		
DISPLAY3:	ACALL DISPLAYRST
		MOV A,#'C'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'o'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'n'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'g'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'r'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'a'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'t'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'u'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'l'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'a'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'t'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'i'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'o'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'n'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'s'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'!'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#0C0H
		ACALL COMNWRT
		ACALL DELAY
		MOV A,#'W'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'e'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'l'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'c'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'o'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'m'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'e'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#' '
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'t'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'o'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#' '
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'X'
		ACALL DATAWRT
		ACALL DELAY
		
AGAIN: 		SJMP AGAIN			;Stop program here and keep displaying the welcome message
		
ERROR:		ACALL DISPLAYRST		;Error message
		MOV A,#'S'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'o'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'r'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'r'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'y'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'!'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#0C0H
		ACALL COMNWRT
		ACALL DELAY
		MOV A,#'T'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'r'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'y'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#' '
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'A'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'g'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'a'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'i'
		ACALL DATAWRT
		ACALL DELAY
		MOV A,#'n'
		ACALL DATAWRT
		ACALL DELAY			;Long delay
		ACALL DELAY
		ACALL DELAY
		ACALL DELAY
		ACALL DELAY
		RET
				
COMNWRT:	MOV P1,A			;Subroutine for giving command information to LCD
		CLR P3.0
		CLR P3.1
		SETB P3.2
		ACALL DELAY
		CLR P3.2
		RET
		
DATAWRT:	MOV P1,A			;Subroutine for giving data information to LCD
		SETB P3.0
		CLR P3.1
		SETB P3.2
		ACALL DELAY
		CLR P3.2
		RET
		
DISPLAYRST:	MOV A,#38H			;Initialize LCD
		ACALL COMNWRT
		ACALL DELAY
		MOV A,#0EH			;Display on, cursor on
		ACALL COMNWRT
		ACALL DELAY
		MOV A,#01H			;Clear LCD
		ACALL COMNWRT
		ACALL DELAY
		MOV A,#06H			;Shift cursor right
		ACALL COMNWRT
		ACALL DELAY
		MOV A,#80H			;Put the display cursor at the start of the first line
		ACALL COMNWRT
		ACALL DELAY
		RET
		
DELAY: 		MOV R3,#50			;Delay subroutine
HERE2: 		MOV R4,#255
HERE: 		DJNZ R4,HERE
		DJNZ R3,HERE2
		RET

		ORG 600H			;Location for lookup table
KCODE0:		DB 'A','B','C','D','E','F'	;Lookup table for row 0 characters
KCODE1:		DB 'G','H','I','J','K','L'	;Lookup table for row 1 characters
KCODE2:		DB 'M','N','O','P','Q','R'	;Lookup table for row 2 characters
KCODE3:		DB 'S','T','U','V','W','X'	;Lookup table for row 3 characters
KCODE4:		DB 'Y','Z','0','1','2','3'	;Lookup table for row 4 characters
KCODE5:		DB '4','5','6','7','8','9'	;Lookup table for row 5 characters
		END				;End of the entire program