;=========================================================
; 文件名: INT2-NP.ASM 
; 功能描述: 8259多级中断实验，中断源为主片8259的IRQ6,IRQ7
;           IRQ7每产生一次中断输出显示4个字符7，
;           IRQ6每产生一次中断输出显示3个字符6，
;           观察不保护现场可能的问题。
;           保护现场：在子程序MIR7的第一条指令前加入PUSH DX，最后一条指令前加入 POP　DX。
;=========================================================

SSTACK  SEGMENT STACK
                DW 32 DUP(?)
SSTACK  ENDS

CODE    SEGMENT
                ASSUME CS:CODE
START:  PUSH DS
                MOV AX, 0000H
                MOV DS, AX
                MOV AX, OFFSET MIR7             ;取中断入口地址
                MOV SI, 003CH                   ;中断矢量地址
                MOV [SI], AX                    ;填IRQ7的偏移矢量
                MOV AX, CS                              ;段地址
                MOV SI, 003EH
                MOV [SI], AX                    ;填IRQ7的段地址矢量
                MOV AX, OFFSET MIR6             ;取中断入口地址
                MOV SI, 0038H                   ;中断矢量地址
                MOV [SI], AX                    ;填IRQ6的偏移矢量
                MOV AX, CS                              ;段地址
                MOV SI, 003AH
                MOV [SI], AX                    ;填IRQ6的段地址矢量
                CLI
                POP DS
                ;初始化主片8259
                MOV AL, 11H
                OUT 20H, AL                             ;ICW1
                MOV AL, 08H
                OUT 21H, AL                             ;ICW2
                MOV AL, 04H
                OUT 21H, AL                             ;ICW3
                MOV AL, 01H
                OUT 21H, AL                             ;ICW4           
                MOV AL, 2FH                             ;OCW1
                OUT 21H, AL
                STI
AA1:    NOP
        MOV CX,26
        MOV DL,41H
AA2:     MOV AH,01
        MOV AL,DL
        INT 10H
        CALL DELAY
        INC DL
        loop AA2
                JMP AA1

MIR7   PROC             
                PUSH AX
                MOV CX,4
                MOV DL,61H
                STI
  L7:   NOP
                MOV AX, 0137H
                INT 10H                 ;显示字符7
                MOV AX, 0120H
                INT 10H
        CALL DELAY
                LOOP L7
                MOV AL, 20H
                OUT 20H, AL     
                POP AX                  ;中断结束命令
                IRET
MIR7    ENDP            

MIR6   PROC             
        PUSH CX
                PUSH AX
                STI
        MOV CX,3
   L6:  NOP
                MOV AX, 0136H
                INT 10H                 ;显示字符6
                MOV AX, 0120H
                INT 10H
        CALL DELAY
                LOOP L6
                MOV AL, 20H
                OUT 20H, AL      ;中断结束命令
                POP AX
                POP CX                  
                IRET
MIR6    ENDP                    

DELAY   PROC
        PUSH CX
                MOV CX, 0F000H
AA0:    PUSH AX
                POP  AX
                LOOP AA0
                POP CX
                RET
DELAY   ENDP            
CODE    ENDS
                END  START

