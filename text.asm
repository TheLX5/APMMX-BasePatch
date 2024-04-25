; text routine starts at 8089E1

;# Start up text
org $869277
    mod_string:
        .header
            db $13      ; Character count
            db $20      ; YXPCCCTT
            dw $0986    ; Tilemap destination
        .text
            db "MMX ARCHIPELAGO MOD"
    version_string:
        .header
            db $09      ; Character count
            db $20      ; YXPCCCTT
            dw $09C6    ; Tilemap destination
        .text
            db "Version: "
    version_num_string:
        .header
            db $05      ; Character count
            db $34      ; YXPCCCTT
            dw $09CF    ; Tilemap destination
        .text
            db "0.1.4"
            
    made_by_string:
        .header
            db $08      ; Character count
            db $20      ; YXPCCCTT
            dw $0A06    ; Tilemap destination
        .text
            db "Made by "
    
    yop_string:
        .header
            db $03      ; Character count
            db $3C      ; YXPCCCTT
            dw $0A0E    ; Tilemap destination
        .text
            db "lx5"
        
        db $00
warnpc $8692CB


;# Main menu, game start selected
org $869349
    game_start_string_1:
        .header
            db $0B      ; Character count
            db $24      ; YXPCCCTT
            dw $0A8A    ; Tilemap destination
        .text
            db "INTRO STAGE"
    password_string_1:
        .header
            db $0C      ; Character count
            db $20      ; YXPCCCTT
            dw $0ACA    ; Tilemap destination
        .text
            db "STAGE SELECT"
    option_string_1:
        .header
            db $07      ; Character count
            db $20      ; YXPCCCTT
            dw $0B0A    ; Tilemap destination
        .text
            db "OPTIONS"
    
    db $00
    print pc
warnpc $869374


;# Main menu, password selected
org $869375
    game_start_string_2:
        .header
            db $0B      ; Character count
            db $20      ; YXPCCCTT
            dw $0A8A    ; Tilemap destination
        .text
            db "INTRO STAGE"
    password_string_2:
        .header
            db $0C      ; Character count
            db $24      ; YXPCCCTT
            dw $0ACA    ; Tilemap destination
        .text
            db "STAGE SELECT"
    option_string_2:
        .header
            db $07      ; Character count
            db $20      ; YXPCCCTT
            dw $0B0A    ; Tilemap destination
        .text
            db "OPTIONS"
    
    db $00
warnpc $8693A0

;# Main menu, option selected
org $8693A1
    game_start_string_3:
        .header
            db $0B      ; Character count
            db $20      ; YXPCCCTT
            dw $0A8A    ; Tilemap destination
        .text
            db "INTRO STAGE"
    password_string_3:
        .header
            db $0C      ; Character count
            db $20      ; YXPCCCTT
            dw $0ACA    ; Tilemap destination
        .text
            db "STAGE SELECT"
    option_string_3:
        .header
            db $07      ; Character count
            db $24      ; YXPCCCTT
            dw $0B0A    ; Tilemap destination
        .text
            db "OPTIONS"
    
    db $00
warnpc $8693CC
