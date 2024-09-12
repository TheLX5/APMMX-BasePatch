
;##########################################################

!map_mode = $1E4B

draw_stage_select:
    .game 
        jsr count_total_medals
        jsr portrait_drawing
        jsr map_clear_tilemaps

        lda !selected_level
        beq ..nope
        cmp #$0A
        bcs ..nope
        dec 
        asl
        tax  
        jsr (..ptrs,x)
        jsr draw_map_strings
    ..nope
        rts 

    ..ptrs
        dw ..launch_octopus
        dw ..sting_chameleon
        dw ..armored_armadillo
        dw ..flame_mammoth
        dw ..storm_eagle
        dw ..spark_mandrill
        dw ..boomer_kuwanger
        dw ..chill_penguin
        dw ..sigma

    ..launch_octopus
    ..sting_chameleon
    ..armored_armadillo
    ..flame_mammoth
    ..storm_eagle
    ..spark_mandrill
    ..boomer_kuwanger
    ..chill_penguin
        jsr process_checkpoint_controls
        jsr write_checkpoints
        rts 

    ..sigma
        jsr process_checkpoint_controls
        jsr write_checkpoints

        lda $00AC
        and #$20
        beq ...no_change
        lda #$2C
        jsl play_sfx
        inc !fortress_progress
        lda !fortress_progress
        cmp !fortress_backup
        bcc ...no_change
        stz !fortress_progress
    ...no_change

        phb 
        phk 
        plb 
        rep #$20
        ldy #$00
        ldx #$16
    ...loop_text
        lda.w ...text,y
        cmp #$FFFF
        beq ...done_text
        sta !bottom_text_tilemap,x
        inx #2
        iny #2
        bra ...loop_text
    ...done_text
        lda !fortress_progress
        and #$00FF
        asl 
        tay 
        lda.w ...progress,y
        sta !bottom_text_tilemap+2,x
        sep #$20
        plb 
        rts 

    ...text
        dw $3446,$346F,$3472,$3474,$3472,$3465,$3473,$3473
        dw $FFFF

    ...progress
        dw $3431,$3432,$3433,$3434,$3435


;############################

process_checkpoint_controls:
    .process_right
        lda $00AB
        and #$10
        beq ..no_change
        lda #$2C
        jsl play_sfx
        lda !current_checkpoint
        inc 
        sta !current_checkpoint
        bra .adjust
    ..no_change

    .process_left
        lda $00AB
        and #$20
        beq ..no_change
        lda #$2C
        jsl play_sfx
        lda !current_checkpoint
        beq ..no_change
        dec  
        sta !current_checkpoint
    ..no_change

    .adjust
        lda !selected_level
        cmp #$09
        bne ..normal_stage
        clc 
        adc !fortress_progress
    ..normal_stage
        tax 
        lda !upgrades
        and #$01
        beq ..no_helmet
    ..has_helmet
        lda !current_checkpoint
    ..compute_limit
        cmp.l .limit_per_level,x
        bcc ..no_adjust
        lda.l .limit_per_level,x
    ..no_adjust 
        and #$7F
        sta !current_checkpoint
        rts 
    ..force
        lda #$00
        bra ..no_adjust
    ..no_helmet
        lda !current_checkpoint
        cmp !checkpoints_reached,x
        bcc ..compute_limit
        lda !checkpoints_reached,x
        bra ..compute_limit
    
    .limit_per_level
        db $00  ; Intro
        db $02  ; Launch Octopus
        db $02  ; Sting Chameleon
        db $02  ; Armored Armadillo
        db $02  ; Flame Mammoth
        db $02  ; Storm Eagle
        db $02  ; Spark Mandrill
        db $02  ; Boomer Kuwanger
        db $02  ; Chill Penguin
        db $04  ; Sigma's Fortress 1
        db $03  ; Sigma's Fortress 2
        db $05  ; Sigma's Fortress 3
        db $00  ; Sigma's Fortress 4



;############################

map_clear_tilemaps:
        ldx #$00
        rep #$20
        lda #$2000
    .loop
        sta !top_text_tilemap,x
        sta !bottom_text_tilemap,x
        inx #2
        cpx #$40
        bne .loop
        sep #$20
        rts 
      
;############################

write_checkpoints:
        phb 
        phk 
        plb 
        rep #$20
        ldy #$00
        ldx #$14
    .loop_text
        lda.w .text,y
        cmp #$FFFF
        beq .done_text
        sta !top_text_tilemap,x
        inx #2
        iny #2
        bra .loop_text
    .done_text
        inx #2
        lda !current_checkpoint
        and #$007F
        asl 
        tay 
        lda.w .progress,y
        sta !top_text_tilemap,x
        sep #$20
        plb 
    .skip
        rts 

    .text
        dw $3443,$3468,$3465,$3463,$346B,$3470,$346F,$3469,$346E,$3474
        dw $FFFF

    .progress
        dw $3431,$3432,$3433,$3434,$3435,$3436,$3437,$3438
        dw $3439,$343A,$343B,$343C,$343D,$343E,$343F,$3430

;############################################

draw_map_strings:
        lda !indirect_dma_queue_index
        tax 
        lda #$80
        sta.w indirect_dma_queue.vmain,x
        sta.w indirect_dma_queue.vmain+$08,x
        lda.b #!top_text_tilemap>>16
        sta.w indirect_dma_queue.source+$02,x
        sta.w indirect_dma_queue.source+$08+$02,x
        rep #$20
        lda.w #!top_text_tilemap
        sta.w indirect_dma_queue.source,x
        lda.w #!bottom_text_tilemap
        sta.w indirect_dma_queue.source+$08,x
        lda #$0800
        sta.w indirect_dma_queue.destination,x
        lda #$0B60
        sta.w indirect_dma_queue.destination+$08,x
        lda #$0040
        sta.w indirect_dma_queue.size,x
        sta.w indirect_dma_queue.size+$08,x
        sep #$20
        txa 
        clc 
        adc #$10
        sta !indirect_dma_queue_index
        rts 

;###################################


count_total_medals:
        phx 
        php 
        sep #$30
        phb 
        lda #$7F
        pha 
        plb
        lda #$00
        ldx #$0E
    .loop
        bit.w !levels_completed,x
        bvc $01
        inc 
        dex #2
        bpl .loop
        sta.w !medal_count
        plb 
        plp 
        plx 
        rts


;###############################################################

portrait_drawing:
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
        rts 
    +
        phb 
        phk 
        plb 
        lda $0B9E
        and #$07
        tax 
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
        txa 
        asl 
        tax 
        lda.l .offsets,x
        pha 
        ldy #$05
    .loop
        ldx !indirect_dma_queue_index
        lda $01,s
        sta.w indirect_dma_queue.destination,x
        lda $03,s
        sta.w indirect_dma_queue.source,x
        lda #$000C
        sta.w indirect_dma_queue.size,x
        sep #$20
        lda #$80
        sta.w indirect_dma_queue.vmain,x
        lda.b #portrait_drawing>>16
        sta.w indirect_dma_queue.source+$02,x
        txa 
        clc 
        adc #$08
        sta !indirect_dma_queue_index
        dey 
        bmi .end
        rep #$20
        lda $03,s
        clc 
        adc #$000C
        sta $03,s
        lda $01,s
        clc 
        adc #$0020
        sta $01,s
        bra .loop
    .end
        pla 
        pla 
        pla 
        pla 
    .skip
        plb 
        rts 

        
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
