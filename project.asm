ORG 0000H
CLR P2.7 ; port 2.7 will be used for buzzer
MOV R5,#3D ;number of attempts
;--------------------------------
MAIN:
ACALL LCD_INIT ; initialize LCD
MOV DPTR,#INITIAL_MSG ;DPTR point to initial text
ACALL SEND_DAT ;DISPLAY DPTR content on LCD
ACALL DELAY ;GIVE DELAY 
ACALL LINE2 ;MOVE TO LINE 2
ACALL READ_KEYPRESS ;take input from keypad
ACALL DELAY ;give some delay
ACALL CLRSCR ; clear our screen
MOV DPTR, #CHECK_CODE_MSG
ACALL SEND_DAT
ACALL DELAY2
ACALL CHECK_PASSWORD  ;CHECK for correct password
SJMP MAIN 
;---------------------------------
LCD_INIT:MOV DPTR,#MYDATA
C1:CLR A
MOVC A,@A+DPTR
JZ DAT
ACALL COMNWRT
ACALL  DELAY
INC DPTR
SJMP C1
DAT:RET
;---------------------------------
SEND_DAT:  
CLR A
MOVC A,@A+DPTR
JZ AGAIN
ACALL DATAWRT
ACALL DELAY
INC DPTR
SJMP SEND_DAT
AGAIN: RET
;--------------------------------- 
READ_KEYPRESS:
MOV R0,#5D  ; R0 = 5
MOV R1,#160D ; R1= 160
ROTATE:ACALL KEY_SCAN   ;take the input key
MOV @R1,A ;take the key pressed value and store at address of R1 i.e. 160
ACALL DATAWRT ; display the key on LCD
ACALL DELAY2 ; delay
ACALL DELAY2 ;
INC R1
DJNZ R0,ROTATE ;repeat this process for 5 time
RET
;----------------------------------
CHECK_PASSWORD:MOV R0,#5D  ;R0 = 5
MOV R1,#160D ; R1= 160
MOV DPTR,#PASSWORD ;DPTR Point to actual PASSWORD
RPT:CLR A ; A = 0
MOVC A,@A+DPTR ; A = FIRST NUMBER OF THE ACTUAL PASSWORD
XRL A,@R1 ; XOR with the actual password
;if both the numbers are equal then A = 0;
JNZ FAIL ; jump to FAIL where we decide what will happen
INC R1
INC DPTR
DJNZ R0,RPT ;repeat this process for 5 times
ACALL SUCCESS
RET
;-----------------------------------
SUCCESS:ACALL CLRSCR
ACALL DELAY2
MOV DPTR,#TEXT_S1
ACALL SEND_DAT ;display corret password
ACALL DELAY2
ACALL LINE2
MOV DPTR,#TEXT_S2
ACALL SEND_DAT ;display corret password
ACALL DELAY2
CLR P2.3
CLR P2.4 
;ROTATE MOTOR CLOCK WISE TO OPEN DOOR
ACALL DELAY3 ; GIVE SECOND DELAY
ACALL CLRSCR
MOV DPTR, #TEXT_S3
ACALL SEND_DAT
ACALL DELAY2
ACALL DELAY3; GIVE SECOND DELAY
SETB P2.3
CLR P2.5
MOV R5,#3H
RET
;----------------------------
FAIL:ACALL CLRSCR 
MOV DPTR,#TEXT_F1 
ACALL SEND_DAT ;display incorrect text
ACALL DELAY2
ACALL LINE2
MOV DPTR, #TEXT_F2
ACALL SEND_DAT ;display incorrect text
ACALL DELAY2
;MOV A,R5
DJNZ R5,LOOP
ACALL ALERT
LOOP: ACALL ATTEMPT
LJMP MAIN ;go to main funtion
;------------------------------
ATTEMPT: ACALL CLRSCR
MOV DPTR,#ATTEMPT_TEXT
ACALL SEND_DAT
ACALL DELAY2
MOV A,#48D
ADD A,R5
DA A
;MOV A ,R5
ACALL DATAWRT
ACALL DELAY
ACALL DELAY2
ACALL DELAY2 ;
RET
;-------------------------------
ALERT:MOV R2,#10D
ACALL CLRSCR
MOV DPTR, #ALERT_TEXT
ACALL SEND_DAT
ACALL DELAY2
BUZZ:SETB P2.7
ACALL DELAY2
CLR P2.7
ACALL DELAY2
DJNZ R2, BUZZ
MOV R5,#3D
LJMP MAIN
;--------------------------------------------------
;algorithm to check for key scan
KEY_SCAN:MOV P1,#11111111B  ;TAKE INPUT FROM PORT 1
;CHECKING FOR ROW 1 COLUMN 1
CLR P1.0  ;first row checking #11111110
JB P1.4, NEXT1 ;when 1 column is 1 then no button is pressed , check for next column
MOV A,#55D ; if above fails then 7 is pressed , A =7
RET 

NEXT1:JB P1.5,NEXT2 ; ROW 1 COULMN 2
MOV A,#56D ; A = 8
RET

NEXT2: JB P1.6,NEXT3 ; ROW 1 COLUMN 3
MOV A,#57D ; A=9 		  
RET

NEXT3: JB P1.7,NEXT4 ; ROW 1 COLUMN 4
MOV A,#47D  ; A=/ DIVIDE
RET

NEXT4:SETB P1.0 ; ROW 1 IS RESET
CLR P1.1 ;CHECK FOR ROW 2
JB P1.4, NEXT5 ; ROW 2 COLUMN 1
MOV A,#52D ; A = 4
RET

NEXT5:JB P1.5,NEXT6 ; ROW 2 COLUMN 2
MOV A,#53D	;A = 5
RET

NEXT6: JB P1.6,NEXT7 ; ROW 2 COLUMN 3
MOV A,#54D ;A = 6
RET

NEXT7: JB P1.7,NEXT8 ; ROW 2 COLUMN 4
MOV A,#42D ; A = * 
RET

NEXT8:SETB P1.1 ;ROW IS RESET
CLR P1.2 ; CHECK FOR ROW 3
JB P1.4, NEXT9 ; ROW 3 COLUMN 1
MOV A,#49D  ;A = 1
RET

NEXT9:JB P1.5,NEXT10 ; ROW 3 COLUMN 2
MOV A,#50D ;A =2 
RET

NEXT10: JB P1.6,NEXT11 ; ROW 3 COLUMN 3
MOV A,#51D ;A = 3
RET

NEXT11: JB P1.7,NEXT12 ; ROW 3 COLUMN 4
MOV A,#45D ;A = -
RET

NEXT12:SETB P1.2 ; ROW 3 IS RESET
CLR P1.3 ; CHECK FOR ROW 4
JB P1.4, NEXT13 ; ROW 4 COLUMN 1
MOV A,#67D ; A = C
RET

NEXT13:JB P1.5,NEXT14; ROW 4 COLUMN 2
MOV A,#48D ; A = 0
RET

NEXT14: JB P1.6,NEXT15 ; ROW 4 COLUMN 3
MOV A,#61D	 ; A = '='
RET

NEXT15: JB P1.7,NEXT16; ROW 4 COLUMN 4
MOV A,#43D ; A = +
RET
NEXT16:LJMP KEY_SCAN ; again check for keys
;!!!!!!!!!!!!!!!!!!!!!!!!!!CHECK FOR SJMP OPTION
;-----------------------------------------------

COMNWRT:MOV P3,A
CLR P2.0 ; R/s = 0
CLR P2.1 ;R/w =0
SETB P2.2 ;high
ACALL DELAY ; delay
CLR P2.2 ;low
RET

DATAWRT: MOV P3,A
SETB P2.0
CLR P2.1
SETB P2.2
ACALL DELAY
CLR P2.2
RET
;-------------------------------------------------
LINE2: MOV A,#0C0H
ACALL COMNWRT
RET

;---------------------------------
DELAY: MOV R3,#65
HERE2: MOV R4,#255
HERE: DJNZ R4,HERE
DJNZ R3,HERE2
RET

DELAY2:	MOV R3,#250D
         MOV TMOD,#01
BACK2:   MOV TH0,#0FCH 
        MOV TL0,#018H 
        SETB TR0 
HERE5:  JNB TF0,HERE5
        CLR TR0 
        CLR TF0 
        DJNZ R3,BACK2
        RET   

DELAY3:MOV TMOD,#10H ;Timer 1, mod 1
MOV R3,#60 ;cnter for multiple delay
AGAIN1: MOV TL1,#08H ;TL1=08,low byte of timer
MOV TH1,#01H ;TH1=01,high byte
SETB TR1 ;Start timer 1
BACK: JNB TF1,BACK ;until timer rolls over
CLR TR1 ;Stop the timer 1
CLR TF1 ;clear Timer 1 flag
DJNZ R3,AGAIN1 ;if R3 not zero then 
;reload time

;-----------------------------------------
CLRSCR: MOV A,#01H
ACALL COMNWRT
RET
;----------------------------------------
ORG 500H
MYDATA: DB 38H,0EH,01,06,80H,0; 
;initializer 5 X 7 MATRIX lcd
;display on cursor blinking
;clear the display screen
;cursor shift --> towards right
;start from the first line
INITIAL_MSG:   DB "ENTER 5-DIG.CODE",0
CHECK_CODE_MSG:  DB "CHECKING CODE...",0	
PASSWORD:DB 49D,50D,51D,52D,53D,0  ;PASSWORD = 1 2 3 4 5
TEXT_F1: DB "WRONG CODE",0
TEXT_F2: DB "ACCESS DENIED",0
TEXT_S1: DB "ACCESS GRANTED",0
TEXT_S2: DB "OPENING DOOR",0
TEXT_S3: DB "CLOSING DOOR", 0
ALERT_TEXT: DB "INTRUDER ALERT !",0
ATTEMPT_TEXT: DB "ATTEMPTS LEFT:0",0
ATTEMPT_VALUE: DB 53D,54D,55D
END