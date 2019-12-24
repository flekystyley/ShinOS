    ;;**********************************
    ;; BPB(BIOS Parameter Block)
    ;;**********************************

    ;;******************************************************
    ;; 0x00007c00 = 0x00007dff : Read Boot Sector Address.
    ;; don't access address
    ;;******************************************************

    ;; Initial Program Load Addr
    ORG     0x7c00

    ;; FAT 12 Format Floppy Disk
    JMP     entry
    DB      0x90                ; BS_jmpBoot

    DB      "SHINIPL"           ; BS_jmpBoot
    DW      512                 ; BPB_BytsPerSec // sector size
    DB      1                   ; BPB_SecPerClus // alocation unit size(minimum 1 byte).
    DW      1                   ; BPB_RsvdSecCnt // reserve sector count
    DB      2                   ; BPB_NumFATs    // FAt count
    DW      224                 ; BPB_RootEntCnt // Root Dir Count
    DW      2880                ; BPB_TotSec16   // All Volume Sector
    DB      0xf0                ; BPB_Media      // Media Type
    DW      9                   ; BPB_FATSz16    // 1 FAT Sector count
    DW      18                  ; BPB_SecPerTrk  // Track Sector Count
    DW      2                   ; BPB_NumHeads   // Head Count
    DD      0                   ; BPB_HiddSec    // Physics Sector
    DD      2880                ; BPB_TotSec     // New 32bit Fields

    ;; Setting fields starting from offset 36
    DB      0x00                ; BS_DrvNum
    DB      0x00                ; BS_Reserved1
    DB      0x29                ; BS_BootSig

    DD      0xffffffff          ; Volume Serial Number
    DB      "Shin-OS   "        ; DiskName
    DB      "FAT12   "          ; Format Name
    RESB    18                  ; For now, leave open 18byte

;; Reset Register Value
entry:
    MOV     AX, 0
    MOV     SS, AX
    MOV     SP, 0x7c00
    MOV     DS, AX

    ;; load disk
    MOV     AX, 0x0820
    MOV     ES, AX
    MOV     CH, 0
    MOV     DH, 0
    MOV     CL, 2

    ;;*********************************************
    ;; **0x13(BIOS System Call)
    ;; - http://stanislavs.org/helppc/int_13.html
    ;;**********************************************
    MOV     AH, 0x02
    MOV     AL, 1
    MOV     BX, 0
    MOV     DL, 0x00
    INT     0x13
    JC      error

fin:
    HLT
    JMP     fin

error:
    MOV     SI, msg

putloop:
    MOV     AL, [SI]
    ADD     SI, 1
    CMP     AL, 0
    JE      fin
    MOV     AH, 0x0e
    MOV     BX, 15
    INT     0x10                ; interrupt BIOS
    JMP     putloop

msg:
    DB      0x0a, 0x0a
    DB      "Hi My Firends"
    DB      0x0a
    DB      0

    ;;  0x7cc-0x7dfe fill with 0
    RESB    0x7dfe-0x7c00-($-$$)

    DB      0x55, 0xaa