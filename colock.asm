; STANDARD HEADER FILE
	PROCESSOR	16F876A
;-------------REGISTER FILES 선언-----------
; BANK 0
	INDF		EQU		00H
	TMR0		EQU		01H
	PCL		EQU		02H
	STATUS	EQU   		03H
	FSR    		EQU   		04H   
	PORTA    	EQU  		05H
	PORTB    	EQU   		06H
	PORTC    	EQU   		07H
	EEDATA    	EQU   		08H
	EEADR    	EQU   		09H
	PCLATH    	EQU   		0AH
	INTCON    	EQU   		0BH
; BANK 1
	OPTIONR    	EQU   		81H
	TRISA    	EQU   		85H
	TRISB    	EQU  	 	86H
	TRISC    	EQU   		87H
	EECON1    	EQU   		88H
	EECON2    	EQU   		89H
	ADCON1    	EQU   		9FH
;-------------STATUS BITS 선언-------------
	IRP    		EQU   		7
	RP1    		EQU   		6
	RP0    		EQU   		5
	NOT_TO     	EQU   		4
	NOT_PD     	EQU   		3
	ZF     		EQU   		2 	;ZERO FLAG BIT
	DC     		EQU   		1 	;DIGIT CARRY/BORROW BIT
	CF     		EQU   		0 	;CARRY BORROW FLAG BIT
;-------------INTCON BITS 선언--------------
;-------------OPTION BITS 선언--------------
	W     		EQU   		B'0' 	; W 변수를 0으로 선언
	F     		EQU   		.1   	; F 변수를 1로 선언
;--------------------USER------------------
	DISP1    	EQU    	20H
	DBUF1    	EQU     	21H
	DBUF2    	EQU   		22H
	DISP2    	EQU   		23H
	W_TEMP    	EQU   		24H
	STATUS_TEMP 	EQU   		25H
	HOHO    	EQU   		26H
	MUTEX    	EQU   		27H
	INT_CNT    	EQU   		28H
	D_1SEC    	EQU   		29H
	D_10SEC    	EQU   		30H	
	D_1MIN    	EQU   		31H
	D_10MIN    	EQU   		32H
	SORS    	EQU   		33H
	SORS2    	EQU    	34H
	STOP    	EQU   		35H
	TEMP    	EQU   		36H
	TEMP2    	EQU   		37H
; MAIN PROGRAM
	ORG    	0000   
   	GOTO   	START_UP
   	ORG   		4
;-----------------INT/TIMER-----------------

   	MOVWF   	W_TEMP   
   	SWAPF   	STATUS,W
   	MOVWF   	STATUS_TEMP

   	GOTO   	DISP			; DISPLAY 부 프로그램

BACK   SWAPF   	STATUS_TEMP,W 	; 저장된 내용으로 복원
   	MOVWF   	STATUS
   	SWAPF   	W_TEMP,F
   	SWAPF   	W_TEMP,W
   	BCF   		INTCON,2
  	
	RETFIE

;-------------DISPLAY ROUTINE-------------
DISP
	BTFSS   	HOHO, 1		; 몇 번째 들어왔는지 확인한다
   	GOTO   	HOTEST		; HOHO = 0X
   	BTFSS   	HOHO,0
   	GOTO   	O_MIN			; HOHO = 10
   	GOTO   	T_MIN			; HOHO = 11

HOTEST   					; HOHO = 0X 인 경우
	BTFSS   	HOHO, 0		
   	GOTO   	O_SEC			; HOHO = 00
   	GOTO   	T_SEC			; HOHO = 01
   
T_MIN						; D_10MIN 변수 내용을 7 SEGMENT에 표시       
   	CALL   	ALLOFF			; 7 SEGMENT를 모두 끄고
   	MOVF   	D_10MIN, W   		   
	CALL   	CONV			; 7 SEGMENT 값을 읽어와
   	CALL   	PRINT			; 10MIN을 7SEGMENT에 출력
   	BCF   		PORTA, 3 		; DG1에 출력
   	INCF   		HOHO, F
   	GOTO   	BACK

O_MIN   					; D_1MIN 변수 내용을 7 SEGMENT에 표시   
   	CALL    	ALLOFF			; 7 SEGMENT를 모두 끄고
   	MOVF   	D_1MIN, W   		
   	CALL   	CONV			; 7 SEGMENT 값을 읽어와
   	CALL   	PRINT			; 1MIN을 7SEGMENT에 출력
   	BCF   		PORTA, 2 		; DG2에 출력
   	INCF   		HOHO, F
   	GOTO   	BACK
   
T_SEC						; D_10SEC 변수 내용을 7 SEGMENT에 표시         
   	CALL   	ALLOFF			; 7 SEGMENT를 모두 끄고
   	MOVF   	D_10SEC, W   		
   	CALL   	CONV			; 7 SEGMENT 값을 읽어와
   	CALL    	PRINT			; 10SEC을 7 SEGMENT에 출력
   	BCF   		PORTB, 2 		; DG3에 출력
   	INCF   		HOHO, F
   	GOTO   	BACK
   
O_SEC						; D_1SEC 변수 내용을 7 SEGMENT에 표시
   	CALL    	ALLOFF			; 7 SEGMENT를 모두 끄고
   	MOVF   	D_1SEC, W   		
   	CALL   	CONV			; 7 SEGMENT 값을 읽어와
   	CALL   	PRINT			; 1SEC을  7SEGMENT에 출력
   	BCF   		PORTB, 1 		; DG4에 출력
   	INCF   		HOHO, F
   	INCF   		INT_CNT, F		; DG 4개 모두 표시 후 INC_CNT 증가
   	GOTO   	BACK

;-----------------SETTINGS-----------------

START_UP   
   	BSF   		STATUS, RP0		; BANK 1
   	MOVLW   	B'00000010' 		; 2.048msec 
   	MOVWF    	OPTIONR
   	MOVLW   	B'00011000'
   	MOVWF   	TRISC
   	MOVLW   	B'11100000'
   	MOVWF   	TRISA
   	MOVLW   	B'01111000'
   	MOVWF   	TRISB
   	MOVLW   	B'00000111'
   	MOVWF   	ADCON1
   	BCF   		STATUS,RP0 		; BANK 0

   	MOVLW   	B'00000000'		; 변수 초기화
   	MOVWF   	HOHO
   	MOVWF   	INT_CNT
   	MOVWF   	D_10SEC
   	MOVWF   	D_1SEC
   	MOVWF   	D_10MIN
   	MOVWF   	D_1MIN   
   	MOVWF   	SORS
   	MOVWF   	SORS2
 
  	BCF   		PORTB, 7		; LED 끄기
   	GOTO   	ST

;-------------------SUBROUTINE-------------------   

DELAY   					; 5ms DELAY
   	MOVLW   	.125
   	MOVWF   	DBUF1
LOOP1 MOVLW   	.10   
   	MOVWF   	DBUF2
LOOP2	NOP
   	DECFSZ   	DBUF2, F
   	GOTO   	LOOP2
   	DECFSZ   	DBUF1, F
   	GOTO   	LOOP1
   	RETURN


DELAY_1   					; 0.25 sec DELAY
   	MOVLW   	.250
   	MOVWF   	DBUF1
LOOP4	MOVLW   	.250   
   	MOVWF   	DBUF2
LOOP3	NOP
   	DECFSZ   	DBUF2, F
   	GOTO   	LOOP3
   	DECFSZ   	DBUF1, F
   	GOTO   	LOOP4
   	RETURN
   

CONV   					; 7 SEGMENT LOOKUPTABLE
   	ANDLW   	0FH
   	ADDWF   	PCL, F
   
	RETLW   	B'11111100' 		; 0
   	RETLW   	B'01100000' 		; 1
   	RETLW   	B'11001110' 		; 2
   	RETLW   	B'11101010' 		; 3
   	RETLW   	B'01110010' 		; 4
   	RETLW   	B'10111010' 		; 5
   	RETLW   	B'10111110' 		; 6
   	RETLW   	B'11110000' 		; 7
   	RETLW   	B'11111110' 		; 8
   	RETLW   	B'11111010' 		; 9
   	RETLW   	B'00000010' 		; -
   	RETLW   	B'11111100' 		; 0
   	RETLW   	B'11111100' 		; 0
   	RETLW   	B'11111100' 		; 0
   	RETLW   	B'11111100' 		; 0
   	RETLW   	B'11111100' 		; 0
   	RETLW   	B'11111100' 		; 0


ALLOFF						; 7SEGMENT 모두 끄기
   	BCF   		PORTC, 7      		   
   	BCF   		PORTC, 6
   	BCF   		PORTC, 5
   	BCF   		PORTC, 2
   	BCF   		PORTC, 1
   	BCF   		PORTC, 0
   	BCF   		PORTA, 0
   	BCF   		PORTA, 1
   	BSF   		PORTA, 3      		; DG 선택 초기화
  	BSF   		PORTA, 2
   	BSF   		PORTB, 2
   	BSF   		PORTB, 1   
   	RETURN


PRINT   					; W REG에 있는 값 7 SEGMENT에 출력
   	MOVWF   	TEMP
   	MOVLW   	B'11100000'
   	MOVWF   	PORTC
   	MOVF      	TEMP, W
   	ANDWF   	PORTC, F
   	MOVLW   	B'00011100'
   	MOVWF   	TEMP2
   	MOVF      	TEMP, W
   	ANDWF   	TEMP2, F
   	RRF      	TEMP2
   	RRF      	TEMP2
   	MOVF      	TEMP2, W
   	IORWF      	PORTC, F
   	MOVLW   	B'00000011'
   	MOVWF   	TEMP2
   	MOVF      	TEMP, W
   	ANDWF   	TEMP2, W
   	IORWF      	PORTA, F 
   	RETURN
   
TIMERMODE				 	; TIMER 초기화
   	CALL   	O_SEC_RESET
   	CALL   	T_SEC_RESET
   	RETURN

O_SEC_RESET					; 1SEC 초기화
   	MOVLW   	.9
   	MOVWF   	D_1SEC
   	RETURN

T_SEC_RESET					; 10SEC 초기화
   	MOVLW   	.5
   	MOVWF   	D_10SEC
   	RETURN


MANDOO   					; 10분마다 10MIN 감소하고 1MIN 증가
	DECF   	D_10MIN
   	MOVLW   	.9
   	MOVWF   	D_1MIN
   	RETURN

;---------------MAINPROGRAM---------------
  
ST   	BSF   		INTCON, 5 		; TIMER INTERRUPT ENABLE
   	BSF   		INTCON, 7 		; GOLBAL INTERRUPT ENABLE


DEFAULT   
   	BTFSS   	PORTB, 4     		; 스위치 2확인 후 눌러졌으면 스탑워치 테스트
   	GOTO   	SWT
   	BTFSS   	PORTB, 5 		; 스위치 3확인 후 눌러졌으면 타이머 테스트
   	GOTO   	TMT
   	CLRF   	INT_CNT 		
   	GOTO   	DEFAULT

SWT						; 스탑워치 테스트
   	BTFSS   	PORTB, 5   		; 스위치 3확인  
   	GOTO   	MUTE   		; 스위치 2,3 둘다 눌렀으면 MUTE
   	CALL   	DELAY_1		; 약간의 지연 후에도
   	BTFSS   	PORTB,	4   		; 스위치2가 눌러져 있다면 
   	GOTO   	STOPWATCH		; 스탑워치 시작
   	GOTO   	DEFAULT		; 그렇지 않다면 돌아가서 다시 확인


TMT						; 타이머 테스트
   	BTFSS   	PORTB, 4		; 스위치3 확인
   	GOTO   	MUTE   		; 스위치 2,3 둘다 눌렀으면 MUTE 
   	CALL   	DELAY_1		; 약간의 지연 후에도
   	BTFSS   	PORTB, 5   		; 스위치3이 눌러져 있다면
   	GOTO   	TIMER			; 타이머 시작
   	GOTO   	DEFAULT		; 그렇지 않다면 돌아가서 다시 확인


;----------------STOPWATCH----------------   
   
STOPWATCH
   	MOVLW   	.0			; 변수 초기화
   	MOVWF   	D_10MIN
   	MOVWF   	D_1MIN
   	MOVWF   	D_10SEC
   	MOVWF   	D_1SEC
   	MOVWF   	INT_CNT

GOGOGO   
   	BTFSS   	PORTB, 4  		; 스위치2 눌러졌으면 
   	GOTO   	SWRESET 		; 스탑워치 리셋으로 분기
   	BTFSS   	PORTB, 5 		; 스위치3 눌러졌으면  
   	GOTO   	RAMEN   		; RAMEN으로 분기
   	GOTO   	M_LOOP		; 모두 아니면 M_LOOP로 분기

RAMEN						; START/STOP 변수 관리
   	BTFSS   	PORTB, 4  		; 스위치 2,3이 눌러졌으면 
   	GOTO   	DEFAULT		; DEFAULT로 분기
   	CALL   	DELAY_1		; 약간의 지연 후
      	BTFSS   	PORTB, 5 		; 스위치3 눌러졌으면
   	INCF   		SORS			; START/STOP 변수 증가
   	GOTO   	M_LOOP		; 그렇지 않으면 증가하지 않고 M_LOOP로

M_LOOP
   	BTFSS   	SORS, 0   		; START/STOP 변수 확인 후
   	GOTO    	STOPWATCH 		; 짝수(STOP)이면 각 SEGMENT를 증가하지 않고 되돌아간다
						; 홀수(START)인 경우 각 SEGMENT 증가   
   	MOVLW   	.122 			; 122 * 4 * 2.048ms ≒ 1s
   	SUBWF   	INT_CNT, W
   	BTFSS   	STATUS, ZF
   	GOTO   	GOGOGO

; 1초마다 들어오는 부분
   	CLRF   	INT_CNT 		; 다음 1초를 기다리기 위한 초기화
   	INCF   		D_1SEC 		; 1초 단위 변수 증가
   	MOVLW   	.10
   	SUBWF   	D_1SEC, W
   	BTFSS   	STATUS, ZF
   	GOTO   	GOGOGO

; 10초마다 들어오는 부분
   	CLRF   	D_1SEC 		; 다음 10초를 기다리기 위한 초기화
   	INCF   		D_10SEC 		; 10초단위 변수 증가
   	MOVLW   	.6
   	SUBWF   	D_10SEC, W
   	BTFSS   	STATUS, ZF
   	GOTO   	GOGOGO
    
 ; 1분마다 들어오는 부분
    	CLRF   	D_1SEC			; 다음 1분을 기다리기 위한 초기화
    	CLRF   	D_10SEC 		
    	INCF   		D_1MIN
    	MOVLW   	.10
    	SUBWF   	D_1MIN, W
    	BTFSS    	STATUS, ZF
    	GOTO   	GOGOGO
 
 ; 10분마다 들어오는 부분
    	CLRF   	D_1SEC			; 다음 10분을 기다리기 위한 초기화
    	CLRF   	D_10SEC
    	CLRF   	D_1MIN
    	INCF   		D_10MIN
    	MOVLW   	.10
    	SUBWF   	D_10MIN, W
    	BTFSC   	STATUS, ZF		; 100분인지 확인해서
    	GOTO    	SWRESET		; 100분이면 리샛
    	GOTO   	GOGOGO
 
  
SWRESET					; 스탑워치 초기화   
	BTFSS   	PORTB,	5 		; 스위치 2,3이 눌러졌으면 
   	GOTO   	DEFAULT		; 디폴트로 분기
   	MOVLW   	B'00000000'		; 변수 초기화
  	MOVWF   	HOHO
   	MOVWF   	INT_CNT
   	MOVWF   	D_10SEC
   	MOVWF   	D_1SEC
   	MOVWF   	D_10MIN
   	MOVWF   	D_1MIN	
   	MOVWF   	SORS
   	GOTO   	STOPWATCH    	; 리셋만 누른 경우 다시 스탑워치로 

;---------------TIMER/ALRAM---------------

TIMER   
   	MOVLW   	.0			; 변수 초기화
   	MOVWF   	D_10MIN
   	MOVWF   	D_1MIN
   	MOVWF   	D_10SEC
   	MOVWF   	D_1SEC
   	MOVWF   	INT_CNT

GOGOGO2   
   	BTFSS   	PORTB, 4  		; 스위치2 눌러졌으면
   	GOTO   	SETTIME		; 시간 설졍
   	BTFSS   	PORTB, 5 		; 스위치3 눌러졌으면 
   	GOTO   	JUMBO			; JUMBO로 분기
   	GOTO   	MM_LOOP		; 모두 아니면 MM_LOOP로 분기
   
JUMBO						; START/STOP 설정
   	BTFSS   	PORTB, 4  		; 스위치 2,3이 눌러졌으면 
   	GOTO   	DEFAULT		; DEFAULT로 분기
   	CALL   	DELAY_1		; 약간의 지연 후
   	BTFSS   	PORTB, 5    		; 스위치3 눌러졌으면 
   	INCF   		SORS2			; START/STOP 변수 증가

MM_LOOP					; interrupt가 들어온 횟수 확인 (시간 계수) 
   	BTFSS   	SORS2, 0 		; START/STOP 변수 확인 후
   	GOTO    	GOGOGO2 		; 짝수(STOP)이면 각 7SEGMENT를 증가하지 않고 되돌아간다 
						; 홀수(START)이면 각 7SEGMENT 증가 
   
 ;---------------시간 종료 확인---------------
    	MOVLW   	.0
   	SUBWF   	D_10MIN, W
   	BTFSS   	STATUS, ZF
   	GOTO   	GOGOGO3   
   	MOVLW   	.0
   	SUBWF   	D_1MIN, W
   	BTFSS   	STATUS, ZF
   	GOTO    	GOGOGO3
   	MOVLW   	.0
   	SUBWF   	D_10SEC, W
   	BTFSS   	STATUS, ZF
   	GOTO   	GOGOGO3
   	MOVLW   	.0
   	SUBWF   	D_1SEC, W
   	BTFSS   	STATUS, ZF
   	GOTO   	GOGOGO3
   	GOTO    	RINGMYBELL;		; 모두 0이면 알람을 울리고 그렇지 않으면 아무 일도 하지 않고 넘어감
;-------------------------------------------
         
GOGOGO3          
   	BTFSS   	PORTB, 5 		; 동작 중 스위치3이 눌러졌으면 
   	GOTO   	GOGOGO2		; 각 SEGMENT층가하지 않고 되돌아간다(STOP)	

   	MOVLW   	.122			; 시간계수(1s) 확인
   	SUBWF   	INT_CNT, W
   	BTFSS   	STATUS, ZF
   	GOTO   	GOGOGO2

; 1초마다 들어오는 부분 
	CLRF   	INT_CNT 		; 다음 1초를 기다리기 위한 초기화
   	DECF   	D_1SEC 		; 1초 단위 변수 감소
   	MOVLW   	0FFH
   	SUBWF   	D_1SEC, W
   	BTFSS   	STATUS, ZF
   	GOTO   	MM_LOOP

; 10초마다 들어오는 부분
   	CALL   	O_SEC_RESET  		; 다음 10초를 기다리기 위한 초기화
   	DECF   	D_10SEC 		; 10초 단위 변수 감소
   	MOVLW   	0FFH
   	SUBWF   	D_10SEC, W
   	BTFSS   	STATUS, ZF
   	GOTO   	MM_LOOP
    
 ; 1분마다 들어오는 부분
    	CALL   	TIMERMODE 		; 다음 1분을 기다리기 위한 초기화
    	DECF   	D_1MIN			; 1분 단위 변수 감소
    	MOVLW   	0FFH
   	SUBWF   	D_1MIN,W
   	BTFSS   	STATUS, ZF
    	GOTO   	MM_LOOP
 
 ; 10분마다 들어오는 부분
    	CALL    	TIMERMODE 		; 다음 10분을 기다리기 위한 초기화
   	DECF   	D_10MIN		; 10분 단위 변수 감소
    	GOTO   	MM_LOOP
   

SETTIME					; 시간 설정 (1분 단위 면경) 
   	BTFSS   	PORTB, 5 		; 스위치 2,3이 눌러졌으면
   	GOTO  	 	DEFAULT		; DEFAULT로 분기
   	CALL   	DELAY_1		; 약간의 지연 후
   	CALL   	TIMERMODE		; 타이머 초기화
   	INCF   		D_1MIN			; 1분씩 증가
   	MOVLW   	.10
   	SUBWF   	D_1MIN, W     		; 10분이면 D_10MIN 증가
   	BTFSS   	STATUS, ZF
   	GOTO   	GOGOGO2
   	CLRF   	D_1MIN
   	INCF   		D_10MIN
   	MOVLW   	.10      		; 100분이상 이면 D_1MIN, D_10MIN 초기화
   	SUBWF   	D_10MIN,W
   	BTFSS   	STATUS,ZF			
   	GOTO    	GOGOGO2
   	CLRF   	D_1MIN
   	CLRF   	D_10MIN
   	GOTO   	GOGOGO2   
   

RINGMYBELL					; 알람 기능
   	BTFSC   	MUTEX, 0 		; MUTEX변수 확인후   
   	GOTO    	SWINGMYBABY		; 홀수(무음)이면 SWINGMYBABY로 분기

   	BCF   		PORTA, 4		; 짝수(유음)이면 알람
   	CALL   	DELAY_1
   	BSF   		PORTA, 4
   	CALL   	DELAY_1   
   	BCF   		PORTA, 4
   	CALL   	DELAY_1
   	BSF   		PORTA, 4
   	CALL   	DELAY_1 
   	BCF   		PORTA, 4
   	CALL   	DELAY_1
   	BSF   		PORTA, 4
   	GOTO   	DEFAULT		; 알람 후 DEFAULT로 

SWINGMYBABY 					; 무음 모드
   	MOVLW   	.10			; 각 SEGMENT에 ‘-’ 출력
   	MOVWF   	D_10MIN
   	MOVWF   	D_1MIN
   	MOVWF   	D_10SEC
   	MOVWF   	D_1SEC
   	GOTO   	DEFAULT		; 알람 후 DEFAULT로

;------------------MUTE--------------------   

MUTE  	 					; 무음/유음 설정
	INCF   		MUTEX, F 		; MUTEX변수 증가
   	BTFSC   	MUTEX, 0		; MUTEX변수 확인 후 
   	GOTO   	SILENT  		; 홀수 일 때 무음모드
      	BCF   		PORTA,4		; 짝수라면 유음모드
   	CALL   	DELAY_1
   	BSF   		PORTA,4
   	GOTO   	DEFAULT   		; 부저 울린 후 DEFAULT
   
SILENT 					; 무음 모드  
	MOVLW   	.10			; 각 SEGMENT에 ‘-’표시
   	MOVWF   	D_10MIN
   	MOVWF   	D_1MIN
   	MOVWF   	D_10SEC
   	MOVWF   	D_1SEC
   	GOTO   	DEFAULT

END
