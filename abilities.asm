

pushpc
    org $81876D
        jml better_walljump
pullpc

better_walljump:
        lda.l setting_abilities
        and #$0001
        beq .original
        lda $37
        bmi .held
    .not_held
        lda #$0178
        bra .return
    .held
        lda !upgrades
        and #$0008
        beq .original
    .return_wall
        ldx #$10
        stx $55
        lda #$0375
    .return
        jml $81877F

    .original
        lda #$0178
        ldx $56
        beq .return
        ldx $6C
        bne .return
        bra .return_wall

pushpc
    org $8195FD
        jsl grounded_held_dash_1
        nop 
    org $81961C
        jml grounded_held_dash_2
pullpc 

grounded_held_dash_1:
        lda.l setting_abilities
        and #$0004
        beq .not_held
        lda !upgrades
        and #$0008
        beq .not_held
        lda $37
        bmi .held
    .not_held
        lda #$0178
        sta $5C
        rtl 
    .held
        lda #$0375
        sta $5C
        rtl 

grounded_held_dash_2:
        lda.l setting_abilities
        and #$0004
        beq .not_held
        lda !upgrades
        and #$0008
        beq .not_held
        lda $37
        bmi .held
    .not_held
        lda $1A
        bpl $03
        eor #$FFFF
        inc
        jml $819624
    .held
        lda #$0375
        jml $819624

    

;####################################################################

pushpc
    org $81A0DB
        jsl on_hadouken_cast
    org $81A0EC
        nop #6      ; remove hp requirement
pullpc

on_hadouken_cast:
        lda #$18        ; forces helmet on
        sta $0BBE
        stz $03
        stz $7F
        rtl 

;####################################################################

pushpc
    org $81829C
        ldx $02
        jmp (new_movement_pointers,x)
        jsl code_AFFBCE
        rts 
        jsl code_AFFC79
        rts 

    ;# removes first leg requirement
    ;org $819712
    ;    nop #7

    ;# more dash related edits
    org $81976D
        jsl code_AFFBB2
        rts 
    org $819789
        jsl code_AFFB38
        rts

    ;# more dash, graphical?
    org $81F0EB
        jsl code_AFFC71
    org $81F108
        cmp $FFFD,x
    org $848FF6
        ;jsl code_AFFB00
        ;nop #5

    ;# moved pointers
    org $81FF70
        new_movement_pointers:
            dw $82E9,$8398,$8403,$8481
            dw $851D,$85F6,$8A45,$8651
            dw $870E,$8834,$8904,$8B31
            dw $8B43,$8BA7,$8B44,$8B4D
            dw $89A0,$89F0,$8D29,$8D69
            dw $8DAB,$8DE1,$8E75,$8E86
            dw $8F41,$917C,$91DD,$923F
            dw $92E9,$930E,$8F29,$8F4E
            dw $8FB4,$900D,$9051,$8B4D
            dw $82A1,$82A6


    ;# long range calls
    org $81FFD0
        code_819592:
            jsr $9588
            rtl 
        code_8193B2:
            jsr $93A8
            rtl 
        code_819D24:
            jsr $9D1A
            rtl 
        code_819C70:
            jsr $9C66
            rtl 
        code_819540:
            jsr $9536
            rtl 
        code_81956A:
            jsr $9560
            rtl 

    ;# something at 848FF6

    org $86DC64
        dw $FFFF

    org $86FFFA
        db $00,$01,$01,$0E,$14,$48
pullpc

code_AFFBCE:
        ldx $03
        bne .skip_physics
        inc $03
        lda #$FF
        sta $1D
        stz $75
        lda #$08
        jsl $8088CD
        jsl code_819592
        lda #$13
        clc 
        adc $6F
        jsl $848F07
        lda #$10
        sta $55
        sta $52
        rep #$20
        lda #$0375
        sta $5C
        bit $68
        bvs +
        eor #$FFFF
        inc
    +   
        sta $1A
        lda #$BB38
        sta $20
        lda #$A597
        sta $31
        sep #$20
    .skip_physics
        lda $5E
        bit $04
        beq +
        stz $2F
    +   
        lda $59
        bne +
        lda $3B
        bit #$40
        beq ++
    +   
        lda #$13
        jsl code_8193B2
    ++  
        lda #$01
        bit $69
        bvs +
    +   
        inc 
        bit $5E
        bne +
        jsl code_819D24
        bne ++
    +   
    -   
        jml code_AFFC62

    ++  
        jsl $82823E
        dec $52
        bmi -
        bit $0F
        bvc +
        lda #$02
        jsl code_819C70
    +   
        lda #$35
        jsl code_819540
        rtl 

code_AFFC62:
        sep #$30
        lda $5E
        bit #$04
        bne +
        lda #$4A
        sta $02
        stz $03
        rtl 
    +   
        sep #$30
        lda #$20
        sta $02
        stz $03
        rtl 

code_AFFC71:
        sta $16
        ldx $0B
        lda $FFFA,x
        rtl 

code_AFFC79:
        ldx $03
        bne +
        inc $03
        rep #$20
        lda #$A552
        sta $20
        stz $1A
        stz $1C
        sep #$20
        stz $1F
        lda #$40
        sta $1E
        lda #$08
        sta $4E
        lda #$16
        clc 
        adc $6F
        jsl $848F07
    +   
        lda $59
        bne +
        lda $3B
        bit #$40
        beq ++
    +   
        lda #$16
        jsl code_8193B2
    ++  
        dec $4E
        bne +
    -   
        stz $4F
        lda #$04
        tsb $87
        sep #$30
        lda #$08
        sta $02
        stz $03
        lda #$08
        sta $2F
        rtl 
    +   
        lda $37
        bit #$03
        bne -
        jsl $828174
        lda #$16
        jsl code_81956A
        rtl 

code_AFFBB2:
        LDA $02
        BEQ label_2FFBC5
        CMP #$02
        BEQ label_2FFBC5
        CMP #$04
        BEQ label_2FFBC5
        CMP #$0A
        BEQ label_2FFBC5

label_2FFBC2:
        LDA #$01
        RTL

label_2FFBC5:
        JSL $8499AF
        BCS label_2FFBC2
        LDA #$00
        RTL

code_AFFB38:
        lda !upgrades 
        and #$08
        beq label_2FFB76
        LDA $1F23
        BNE label_2FFB76
        LDA $3A
        BIT #$80
        BEQ label_2FFB76
        LDA $02
        CMP #$02
        BEQ label_2FFB55
        CMP #$08
        BEQ label_2FFB55
        CMP #$10
        BEQ label_2FFB55
        CMP #$12
        BNE label_2FFB64
label_2FFB55:
        LDA $2C
        BMI label_2FFB5F
        JSL $849A24
        BCC label_2FFB64
label_2FFB5F:
        LDA #$0A
        STA $56
        RTL

label_2FFB64:
        JSL label_2FFBB2
        BNE label_2FFB77
        LDA #$40
        TSB $7E
        SEP #$30
        LDA #$14
        STA $02
        STZ $03

label_2FFB76:
        RTL

label_2FFB77:
        lda !unlocked_air_dash
        beq label_2FFB76
        JSL label_2FFB8A
        BNE label_2FFB76
        LDA #$40
        TSB $7E
        SEP #$30
        LDA #$48
        STA $02
        STZ $03
        RTL

label_2FFB8A:
        lda !unlocked_air_dash
        beq label_2FFB9B
        LDA $02
        CMP #$06
        BEQ label_2FFB9E
        CMP #$08
        BEQ label_2FFB9E

label_2FFB9B:
        LDA #$01
        RTL

label_2FFB9E:
        REP #$20
        LDA $5C
        CMP #$0375
        SEP #$20
        BEQ label_2FFB9B
        JSL $8499AF
        BCS label_2FFB9B
        LDA #$00
        RTL

label_2FFBB2:
        LDA $02
        BEQ label_2FFBC5_1
        CMP #$02
        BEQ label_2FFBC5_1
        CMP #$04
        BEQ label_2FFBC5_1
        CMP #$0A
        BEQ label_2FFBC5_1
        LDA #$01
        RTL
    label_2FFBC5_1:
        jmp label_2FFBC5
