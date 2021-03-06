;************************************************
; initialize paging
;************************************************
;---------------------------------------
;          |____________|
; 0010_5000|       (4K) | directory table
;          =            =
;          |____________|
; 0010_6000|       (4K) | page table
;          =            =
;          |____________|
; 0010_7000|       (4K) | page fault
;          =            =
;          |____________|
;          |            |
;
;************************************************
init_page:
    pusha

    ;******************************
    ; create page transfer table
    ;******************************
    cdecl    page_set_4m, CR3_BASE
    cdecl    page_set_4m, CR3_TASK_4
    cdecl    page_set_4m, CR3_TASK_5
    cdecl    page_set_4m, CR3_TASK_6

    ;******************************
    ; create page transfer table
    ;******************************
    mov	[0x0010_6000 + 0x107 * 4], dword 0

    ;******************************
    ; configure transfer address
    ;******************************
    mov	[0x0020_1000 + 0x107 * 4], dword PARAM_TASK_4 + 7
    mov	[0x0020_3000 + 0x107 * 4], dword PARAM_TASK_5 + 7
    mov	[0x0020_5000 + 0x107 * 4], dword PARAM_TASK_6 + 7

    ;***************************
    ; configure drawing param
    ;***************************
    cdecl    memcpy, PARAM_TASK_4, DRAW_PARAM.t4, rose_size
    cdecl    memcpy, PARAM_TASK_5, DRAW_PARAM.t5, rose_size
    cdecl    memcpy, PARAM_TASK_6, DRAW_PARAM.t6, rose_size

    popa

    ret

;*********************************
; create page directory function
;*********************************
page_set_4m:
    ;***********************************************
    ; ebp + 0 | ebp(base value)
    ; ebp + 4 | eip(return value)
    ; ebp + 8 | start page table memory position
    ;***********************************************
    push	ebp
    mov	ebp, esp

    pusha

    ;****************************
    ; create page directory(p=0)
    ;****************************
    cld
    mov	edi, [ebp + 8]      ; edi = page directory head addr
    mov	eax, 0x00000000     ; eax = 0
    mov	ecx, 1024           ; ecx = 1024
    rep     stosd               ; while (count--) *dst++

    ;************************
    ; select head entry
    ;************************
    mov	eax, edi            ; eax = edi(page directory head addr)
    and	eax, ~0x0000_0FFF   ; eax &= ~0FFF // physics addr
    or      eax, 7              ; eax |= 7 // allow Read & Write
    mov	[edi - (1024 * 4)], eax ; select head entry

    ;************************
    ; configure page table
    ;************************
    mov	eax, 0x00000007     ; select physics address & allow RW(7)
    mov	ecx, 1024           ; count = 1024

.10L:
    stosd                       ; *dst++
    add	eax, 0x00001000     ; adr += 0x1000 // (4K = 4*1024 = 4096 = 0x1000)
    loop	.10L                ; // while(--count(ecx register))

    popa

    mov	esp, ebp
    pop	ebp

    ret
