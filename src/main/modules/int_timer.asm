;************************************************
; File to edit each time a task is added
;************************************************

int_timer:
    pusha
    push ds
    push es

    mov ax, 0x0010
    mov ds, ax
    mov es, ax

    ; refresh interrupt count
    inc dword [TIMER_COUNT]

    ; clear the interrupt flag
    outp 0x20, 0x20

    ;******************
    ; switch the task
    ;******************
    str ax                      ; ax = tr // current task register
    cmp ax, SS_TASK_0           ; case (SS_TASK_0)
    je .11L                     ; { // (ax == SS_TASK_0)
    cmp ax, SS_TASK_1           ; case (SS_TASK_1)
    je .12L                     ; {
    cmp ax, SS_TASK_2           ; case (SS_TASK_2)
    je .13L                     ; {
    cmp ax, SS_TASK_3
    je  .14L
    cmp ax, SS_TASK_4
    je  .15L
    cmp ax, SS_TASK_5
    je  .16L
    jmp SS_TASK_0:0             ; // switching task0
    jmp .10E                    ; break
.11L:
    jmp SS_TASK_1:0             ; // switching task1
    jmp .10E                    ; break
.12L:
    jmp SS_TASK_2:0
    jmp .10E
.13L:
    jmp SS_TASK_3:0
    jmp .10E
.14L:
    jmp SS_TASK_4:0
    jmp .10E
.15L:
    jmp SS_TASK_5:0
    jmp .10E
.16L:
    jmp SS_TASK_6:0
    jmp .10E
.10E:

    pop es
    pop ds
    popa

    iret
ALIGN 4, db 0
TIMER_COUNT: dd 0
