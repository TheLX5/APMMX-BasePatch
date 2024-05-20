
;###############################################################

hack_portraits:
        phy 
        php 
        sep #$30
        lda $1E49
        cmp #$04
        beq +
        rep #$20
        lda #$FFFF
        sta !map_portraits_array+$00
        sta !map_portraits_array+$02
        sta !map_portraits_array+$04
        sta !map_portraits_array+$06
        sta !map_portraits_array+$08
        sta !map_portraits_array+$0A
        sta !map_portraits_array+$0C
        sta !map_portraits_array+$0E
        sep #$20
        plp 
        ply
        rtl 
    +
        phb 
        phk 
        plb 
        lda $0B9E
        and #$07
        tax 
        ldy #$80
        sty $2115
        lda !levels_unlocked+1,x
        beq .locked
    .unlocked
        lda !levels_unlocked+1,x
        cmp !map_portraits_array,x
        beq .skip
        sta !map_portraits_array,x
        rep #$20
        phx 
        txa 
        asl 
        tax 
        lda.l .portrait_ptrs,x
        plx 
        bra .shared
    .locked
        cmp !map_portraits_array,x
        beq .skip
        sta !map_portraits_array,x
        rep #$20
        lda.w #.blank_portrait
    .shared 
        pha 
        phx
        txa 
        asl 
        tax 
        lda.l .offsets,x
        pha 
        sta $2116
        ldx #$00
        ldy #$00
    ..loop
        lda ($04,s),y
        sta $2118
        iny #2
        inx 
        cpx #$06
        bne ..loop
        cpy #$47
        bcs ..break
        ldx #$00
        lda $01,s
        clc 
        adc #$0020
        sta $01,s
        sta $2116
        bra ..loop
    ..break
        pla 
        plx 
        pla 
        sep #$20
    .skip
        plb 
        plp 
        ply
        rtl 

    .offsets
        dw $504A    ;# Launch Octopus
        dw $5290    ;# Sting Chameleon
        dw $5104    ;# Armored Armadillo
        dw $5116    ;# Flame Mammoth
        dw $51C4    ;# Storm Eagle
        dw $528A    ;# Spark Mandrill
        dw $51D6    ;# Boomer Kuwanger
        dw $5050    ;# Chill Penguin

    .portrait_ptrs
        dw .launch_octopus_portrait
        dw .sting_chameleon_portrait
        dw .armored_armadillo_portrait
        dw .flame_mammoth_portrait
        dw .storm_eagle_portrait
        dw .spark_mandrill_portrait
        dw .boomer_kuwanger_portrait
        dw .chill_penguin_portrait

    .blank_portrait
        ..row_1
            dw $040F,$040F,$040F,$040F,$040F,$040F
        ..row_2
            dw $040F,$040F,$040F,$040F,$040F,$040F
        ..row_3
            dw $040F,$040F,$040F,$040F,$040F,$040F
        ..row_4
            dw $040F,$040F,$040F,$040F,$040F,$040F
        ..row_5
            dw $040F,$040F,$040F,$040F,$040F,$040F
        ..row_6
            dw $040F,$040F,$040F,$040F,$040F,$040F

    .launch_octopus_portrait
        ..row_1
            dw $040F,$0506,$0507,$0508,$0509,$050A
        ..row_2
            dw $040F,$0516,$0517,$0518,$0519,$051A
        ..row_3
            dw $0525,$0526,$0527,$0528,$0529,$052A
        ..row_4
            dw $0535,$0536,$0537,$0538,$0539,$053A
        ..row_5
            dw $0545,$0546,$0547,$0548,$0549,$054A
        ..row_6
            dw $0555,$0556,$0557,$0558,$0559,$055A
    .sting_chameleon_portrait
        ..row_1
            dw $040F,$11CA,$11CB,$11CC,$11CD,$11CE
        ..row_2
            dw $040F,$11DA,$11DB,$11DC,$11DD,$11DE
        ..row_3
            dw $11CF,$11E0,$11E1,$11E2,$11E3,$11E4
        ..row_4
            dw $11DF,$11F0,$11F1,$11F2,$11F3,$11F4
        ..row_5
            dw $11E5,$11E6,$11E7,$11E8,$11E9,$11EA
        ..row_6
            dw $040F,$11F5,$11F6,$11F7,$040F,$040F
    .armored_armadillo_portrait
        ..row_1
            dw $040F,$0900,$0901,$0902,$0903,$0904
        ..row_2
            dw $040F,$0910,$0911,$0912,$0913,$0914
        ..row_3
            dw $040F,$0920,$0921,$0922,$0923,$0924
        ..row_4
            dw $0905,$0930,$0931,$0932,$0933,$0934
        ..row_5
            dw $0915,$0940,$0941,$0942,$0943,$0944
        ..row_6
            dw $0980,$0950,$0951,$0952,$0953,$0954
    .flame_mammoth_portrait
        ..row_1
            dw $0561,$0562,$0563,$4563,$4562,$4561
        ..row_2
            dw $0571,$0572,$0573,$4573,$4572,$4571
        ..row_3
            dw $0581,$0582,$0583,$4583,$4582,$4581
        ..row_4
            dw $0591,$0592,$0593,$4593,$4592,$4591
        ..row_5
            dw $05A1,$05A2,$05A3,$45A3,$45A2,$45A1
        ..row_6
            dw $05B1,$05B2,$05B3,$45B3,$45B2,$45B1
    .storm_eagle_portrait
        ..row_1
            dw $080F,$0D6A,$0D6B,$0D6C,$0D6D,$080F
        ..row_2
            dw $080F,$0D7A,$0D7B,$0D7C,$0D7D,$080F
        ..row_3
            dw $0D89,$0D8A,$0D8B,$0D8C,$0D8D,$080F
        ..row_4
            dw $0D99,$0D9A,$0D9B,$0D9C,$0D9D,$0D9E
        ..row_5
            dw $0DA9,$0DAA,$0DAB,$0DAC,$0DAD,$0DAE
        ..row_6
            dw $0DB9,$0DBA,$0DBB,$0DBC,$0DBD,$0DBE
    .spark_mandrill_portrait
        ..row_1
            dw $0DC1,$0DC2,$0DC3,$4DC3,$4DC2,$4DC1
        ..row_2
            dw $0DD1,$0DD2,$0DD3,$4DD3,$4DD2,$4DD1
        ..row_3
            dw $0DC4,$0DC5,$0DC6,$4DC6,$4DC5,$4DC4
        ..row_4
            dw $0DD4,$0DD5,$0DD6,$4DD6,$4DD5,$4DD4
        ..row_5
            dw $0DC7,$0DC8,$0DC9,$4DC9,$4DC8,$4DC7
        ..row_6
            dw $0DD7,$0DD8,$0DD9,$4DD9,$4DD8,$4DD7
    .boomer_kuwanger_portrait
        ..row_1
            dw $050B,$050C,$050D,$050E,$050F,$0560
        ..row_2
            dw $051B,$051C,$051D,$051E,$051F,$0570
        ..row_3
            dw $052B,$052C,$052D,$052E,$052F,$040F
        ..row_4
            dw $053B,$053C,$053D,$053E,$053F,$040F
        ..row_5
            dw $054B,$054C,$054D,$054E,$054F,$05A0
        ..row_6
            dw $055B,$055C,$055D,$055E,$055F,$05B0
    .chill_penguin_portrait
        ..row_1
            dw $080F,$0D64,$0D65,$0D66,$0D67,$0D68
        ..row_2
            dw $080F,$0D74,$0D75,$0D76,$0D77,$0D78
        ..row_3
            dw $080F,$0D84,$0D85,$0D86,$0D87,$0D88
        ..row_4
            dw $0D90,$0D94,$0D95,$0D96,$0D97,$0D98
        ..row_5
            dw $0D69,$0DA4,$0DA5,$0DA6,$0DA7,$0DA8
        ..row_6
            dw $0D79,$0DB4,$0DB5,$0DB6,$0DB7,$0DB8
