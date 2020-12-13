;**************************************************************************************************************
;AUTHOR   : SAEED DESOUKY
;LANGUAGE : ASSEMBLY 
;VERSION  : V01                                           
;**************************************************************************************************************


;**************************************************************************************************************
;                                           GLOBAL BARIABLES  
;**************************************************************************************************************

Stack_Size      		     EQU     0x00000400 
Heap_Size       		     EQU     0x00000400
Variable_RAM1   		     EQU     0x20001000  
REVERCE_BYTE_ORDER_64_BIT_VARIABLE   EQU     0x2000101A     ;location into the ram to stor the new value of the vaiable after reversing it 

;**************************************************************************************************************
;                                           SECTIONS 
;**************************************************************************************************************
        
        AREA    STACK, NOINIT, READWRITE, ALIGN=3             
Stack_Mem       
        SPACE   Stack_Size
__initial_sp

        AREA    RESET, DATA, READONLY,ALIGN=3 
        DCD     __initial_sp
        DCD     Main     
			
;**************************************************************************************************************
;                                           FUNCTIONS 
;**************************************************************************************************************

;CALL DELAY FUUNCTION 
		AREA    CALL_DELAY_FUNCTION, CODE, READONLY
				push	{lr}	;push the last value of the LR into the stack 	
				BL 		MY_DELAY_FUNCTION
				;this solution is optimized more than the second solution becuse it uses less execution cycles
				pop 	{pc}	;pop PC to get back to the last exexution tin main thi 
				;another solution remove the ; from the 2 lines below 
				;pop{lr}
				;BX lr  

;DELAY FUUNCTION 
		AREA    MY_DELAY_FUNCTION, CODE, READONLY 
				PUSH {R0}	   ; push R0 to the stack 
LOOP			   ; Loop label
	CMP R0, #0         ; CMP(compare) this instruction compares the content of register to specified value 
	BLE ENDLOOP        ; will get out of  the loop if the condition i>0 is false 
	SUB R0, R0, #1     ; similar to i--
	B LOOP             ; back to the begining of the loop to repeat 
ENDLOOP
	POP{R0}		   ;pop R0 from the stack 
	BX LR              ;after executing the loop it jumps back to the linker register 
END

;REVERCE BYTE ORDER FUUNCTION
		AREA    REVERCE_BYTE_ORDER_64_BIT_FUNCTION, CODE, READONLY
				LDR R0, =Variable_64      		     ;pointer to the variable that user enered 
				LDR R6, =REVERCE_BYTE_ORDER_64_BIT_VARIABLE  ;location into the ram to stor the new value of the vaiable after reversing it 
				LDR R1, [R0, #4]            		     ;load upper  part of the variable
				LDR R2, [R0]	 	   		     ;load lower  part of the variable 
				REV R3, R1				     ;1-revers the byte order in the upper part      0x21654327
				AND R3, #0x000000FF		             ;2-and the previous operation to get first byte 0x00000027
				MOV R4, R2				     ;0xFDA3210E
				BFI R4, R3, #0, #8	                     ;3-insert the last byte of the upper nibble to the first byte in the low inbble 0xFDA32127
				AND R2, R2, #0x000000FF	                     ;1-get the first byte of the low nibble by anding with the musk R5 = 0x0000000E
				MOV R5, R1				     ;0x27654321
				BFI R5, R2, #24, #8		             ;0x0E654321
				STR R4, [R6]			             ;0xFDA32127 lower
				STR R5, [R6, #4]		             ;0x0E654321 upper 							
				BX  LR

        	AREA    |.text|, CODE, READONLY, ALIGN=8 


;**************************************************************************************************************
;                                        MAIN FUNCTION 
;**************************************************************************************************************


	
Main    

		;**************************************************************************************************************
		;                                           NOTES 
		;**************************************************************************************************************
		 
		;to make a constant variable  variable name DCD value that will take four bytes 
		;STR Rx, [Ry] store the value in registerX in a memory location(address) who is value is registerY
		;REV reverse byte order 
		;REV16  reverse byte order in each half word
		;BFI this instruction used to insert a bit or even a bute or more  Note this instruction needs too registers 		
		;BFI (Bit Field Insert) =>BFI  Rd, Rs, #the bit to start from, #the width or the number of bits you want to take from the specifid start
		;Rd the destination register to store  data in , Rs the register you want to take data from it 
		;BFI this instruction used to clear a bit Note this instruction need only a register  
		;SUBS (subtraction with sufyx s) this instaction set the flag Z in the status register when it arrive to zero  
		
		;**************************************************************************************************************
		
		;**************************************************************************************************************
		;                                           Questiuon 1
		;**************************************************************************************************************
		;write values 100 and 0x1FFFFFF into registers R0 and R1
		push    {R0,R1}					; push R0 and R1 to the stack to perform operations on it 
        	MOV     R0, #100	                        ; write constant value in R0 R0 = 100
       		MOV     R1, #0x1FFFFFFF                         ; write constant value in R0 R0 = 0x1FFFFFFF
		pop     {R0,R1}
		;**************************************************************************************************************
		
		;**************************************************************************************************************
		;                                           Questiuon 2
		;**************************************************************************************************************
		;load from RAM memory with location 0x20001000 four bytes into register R1
		;we load the address we want into a general prupose register we choose R3 now R3 = 0x20001000
	    	LDR     R3, =Variable_RAM1              ;load the address which we want to access in RAM into R3
		;we made this step just to test by storing a value in the location the we loaded it again if you want use it remove ; from the next line 
		;STR     R0, [R3]		        ; we make this for testing we put a value in the specific location of the ram to make sure we correctly accesed it
		;we loaded the value from the location 0x20001000
		LDR     R1, [R3]                        ; the default value in this location 0x00000000 
		;**************************************************************************************************************
		
		;**************************************************************************************************************
		;                                           Questiuon 3
		;**************************************************************************************************************
		;write 0xFF value (one byte length) to RAM memory location 0x20001000
		;Writting the desired value into register R2 now R2 = 0xFF 
		MOV     R2, #0xFF
		;now store the in R2 in the memory location 0x20001000
		;note the suffyx B in STRB used to store a byte 
		STRB    R2, [R3]
		;we made this for testing to check if the data is actually stored in the location ox20001000 
		;we copied the data in register R1 
		;to use it remove ; from next line 
		;LDRB    R1, [R3]
		;************************************************************************************************************** 
		
		;**************************************************************************************************************
		;                                           Questiuon 4
		;**************************************************************************************************************
        	;set and clear single bit at position 25 of variable (variable address 0x20001000).
		;i have provided you to solutions for this task
		;First Solution 
		;in this method we use masking to set or clear a bit as you know 0 OR 1 = 1 , 0 AND 1 = 0 
		;SET BIT 
		;we use this mask 000000100000000000 to set bit number 25 with content of register R2 
		ORR 	R2,#0x2000000    ;set bit number 25 R2 OR 0x2000000 = 0x020000FF
		STR 	R2, [R3]         ;we store the new value at the specific address  
		LDR 	R1, [R3]         ; we loadded it just to make sure its succesfully loaded
		;CLEAR BIT
		;we use this mask 11111101111111111 to clear bit number 25 with content of register R2 
		AND 	R2,#0xF0FFFFFF   ;clear bit number 25  R2 AND 0xF0FFFFFF = 0x000000FF
		STR 	R2, [R3]         ;we store the new value at the specific address  
		LDR 	R1, [R3]         ; we loadded it just to make sure its succesfully loaded
		
		;Second Solution 
		;to use this solution remove the ; from the lines blewo 
		;we use those two instructions BFI (Bit Filed Insert), BFC (Bit Filed clear) to know about them read the not section above the page 
		;MOV 	R4, #1	         ;put 1 in register R4 because we will need it for the next instruction R4 = 1 
		;BFI 	R2, R4, #25 ,#1  ;this instruction take the stord value from register R4 and put it in bit 25 and #1 indicates we will take one bit width and store the value in R2
		;STR 	R2, [R3]         ;we store the new value at the specific address  
		;LDR 	R1, [R3]         ; we loadded it just to make sure its succesfully loaded
		;CLEAR BIT 
		;BFC 	R2, #25 ,#1      ;this instruction clears bit 25  #1 indicates we will take one bit width
		;STR 	R2, [R3]         ;we store the new value at the specific address  
		;LDR 	R1, [R3]         ; we loadded it just to make sure its succesfully loaded
		
		;************************************************************************************************************** 

		;**************************************************************************************************************
		;                                           Questiuon 5
		;**************************************************************************************************************
		;decrement register for 10 times until zero (use SUBS instruction)
		MOV 	R5,#2 ;put value of 10 in register R5 to decrement it 10 times  
;this the for loop body 
FOR_LOOP			   ; Loop label
	CMP R5, #0                 ; CMP(compare) this instruction compares the content of register to specified value 
	BLE END_FOR_LOOP           ; will get out of  the loop if the condition i>0 is false 
	SUBS R5, R5, #1 	   ; similar to i--
	B FOR_LOOP         	   ; back to the begining of the loop to repeat 
END_FOR_LOOP
		
		;************************************************************************************************************** 
		
		;**************************************************************************************************************
		;                                           Questiuon 6
		;**************************************************************************************************************
		;read both stack registers (msp, psp) into r0 and r1 registers
		;MRS specific instruction to read from processor registers and store their value in general purpose register
		push    {R0,R1}			
		MRS 	R0, MSP			 
		MRS 	R1, PSP
		pop     {R0,R1}
		;************************************************************************************************************** 

		;**************************************************************************************************************
		;                                           Questiuon 7
		;**************************************************************************************************************
		;read programa counter(pc) to r0 register
		MOV     R0, PC  
		;************************************************************************************************************** 

		;**************************************************************************************************************
		;                                           Questiuon 8
		;**************************************************************************************************************
		;create simple delay function (pass variable into r0 how much to delay) 
		;put the value of delay you want to pass to the function (note delay is in millisecond)
		MOV R0, #2  
		BL  MY_DELAY_FUNCTION 		; call Delay Function 
		;**************************************************************************************************************

		;**************************************************************************************************************
		;                                           Questiuon 9
		;**************************************************************************************************************
		;Create function wich call delay function (also pass R0 as variable for delay) 
		;put the value of delay you want to pass to the function (note delay is in millisecond)
		MOV R0, #2
		BL CALL_DELAY_FUNCTION 		; function that calls Delay Function 
		;**************************************************************************************************************

		;**************************************************************************************************************
		;                                           Questiuon 10
		;**************************************************************************************************************
		;multiply r0 register by 3 ussing single ADD instruction (use barrel shifter).
		;barrel shifter technique 
		;it shifts the register to the left 1 time (one shifting to the lift is multiplying  the number by two)
		;then add the register ti itself again after sifting it 
		;so that is the same as we multiply by 3 
		ADD     R0, R0,R0, LSL #1
		;**************************************************************************************************************
	
		;**************************************************************************************************************
		;                                           Questiuon 11
		;**************************************************************************************************************
		;reverse all bits for register r0
		;RBIT (Rotate Bit) is a specific instruction rotates all the bits 
		RBIT    R0, R0
		;**************************************************************************************************************

		;**************************************************************************************************************
		;                                           Questiuon 12
		;**************************************************************************************************************
		;create function: reverser byte order for long long variable (64 bits length)
Variable_64        DCQ     0x27654321FDA3210E		    ;your 64 bit variable you want to reverse its byte order 
		BL REVERCE_BYTE_ORDER_64_BIT_FUNCTION	    ;call the function 
		LDR R2, [R6, #4]                            ;load upper  part of the variable
		LDR R3, [R6]			            ;load lower  part of the variable 
		;**************************************************************************************************************

		; Infinite LOOP 
        B       .
	END

