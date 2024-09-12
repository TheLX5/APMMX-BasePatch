pushpc
    org $80EFE9
        jsl password_menu_main
        nop #4
    
    ;# Hijack password menu load
    org $80F05D
        jsl password_menu_load

    ;# Skips cutscenes
    ;org $809C06
    ;    nop #3

    org $809BEE
        db $80

    org $809C1D
        jmp $9C0E

    ;# Allow exiting the intro level
    ;org $009DC8
    ;    lda #$01
    ;    sta $1FD3
    ;    jmp $9DD5

    ;# Instant credits on menu exit
    ;org $809C04
    ;    jmp $9C8F

    ;org $009E36
    ;    jsl stop_timer

    org $80A5C5
        jsl credits_stat_load
        lda #$04
        sta $01
        rts 

    ;# Don't load graphics in credits
    org $80A5BA
        nop #4
    org $80A55A
        jmp $A59C

    org $80A5DB
        jsl credits_stat_main
        rts 

    ;# Skips maverick intros
    org $809589
        jsr $9F0F
        jmp $991B

pullpc

!palette_completed = $3400
!palette_mid = $2C00
!palette_incomplete = $2000
!palette_unused = $2400

macro write_text(line, col, end, color, text)
    table "tables/layer_3_text_<color>.txt",ltr
    dw ($10CA+(<line>*$40)+(<col>*$02))>>1
    dw "<text>"
    dw $FFFE+<end>
endmacro

macro color_picker(color)
    and #$00FF
    clc 
    adc #$0030
    if stringsequal("<color>", "blue")
        ora #$3000
    elseif stringsequal("<color>", "red")
        ora #$2000
    elseif stringsequal("<color>", "green")
        ora #$3400
    elseif stringsequal("<color>", "pink")
        ora #$3800
    elseif stringsequal("<color>", "purple")
        ora #$3C00
    elseif stringsequal("<color>", "yellow")
        ora #$2C00
    elseif stringsequal("<color>", "teal")
        ora #$2800
    elseif stringsequal("<color>", "gray")
        ora #$2400
    elseif stringsequal("<color>", "ram")
        ora $000E
    endif
endmacro

macro write_value(line, col, digits, skip, color, ram)
    lda.w #($10CA+(<line>*$40)+(<col>*$02))>>1
    sta $2116
    lda <ram>
    if <digits> < 3
        and #$00FF
    endif 
    jsl hex_to_dec_super_long
    rep #$20
    if <digits> >= 4
        if <skip> == 1
            lda $0003
            beq ?skip_1000s
        endif
            lda $0003
            %color_picker(<color>)
        ?skip_1000s
            sta $2118
    endif
    if <digits> >= 3
        if <skip> == 1
            lda $0002
            ora $0003
            beq ?skip_100s
        endif
            lda $0002
            %color_picker(<color>)
        ?skip_100s
            sta $2118
    endif
    if <digits> >= 2
        if <skip> == 1
            lda $0001
            ora $0002
            ora $0003
            beq ?skip_10s
        endif
            lda $0001
            %color_picker(<color>)
        ?skip_10s
            sta $2118
    endif
    lda $0000
    %color_picker(<color>)
    sta $2118
endmacro

;##################################################################################################

password_menu_load:
        jsl $828000
        
        jsr .layer_3
        stz $0b9d
    -    
        lda $0b9d
        beq -
        stz $0b9d
    
        stz $4200
        lda #$80
        sta $2100
        phd 
        rep #$20
        lda #$0000
        pha 
        pld 
        sep #$20
        jsr .nmi
        pld 
        
        lda #$81
        sta $4200
        stz $2100

        rtl 

    .nmi
        lda #$80
        sta $2115
        lda.b #password_menu_blank_tilemap>>16
        sta $4314
        rep #$20
        lda #$1801
        sta $4310
        lda.w #password_menu_blank_tilemap
        sta $4312
        lda #$5000
        sta $2116
        lda #$0800
        sta $4315
        ldy #$02
        sty $420B
        sep #$20

        lda.b #progress_menu_default_texts>>16
        sta $08
        rep #$30
        lda.w #progress_menu_default_texts
        jsr load_progress_text

        lda !level_id
        and #$00FF
        asl 
        tax 
        jsr (.levels,x)

        jsr handle_progress_global

        sep #$30
        rts 

    .layer_3
        rep #$20
        ldx #$00
    ..loop
        lda.l password_menu_palette,x
        sta $0300,x
        inx #2
        cpx #$40
        bne ..loop
        sep #$20
        rts 

    .levels
        dw handle_progress_intro
        dw handle_progress_octopus
        dw handle_progress_chameleon
        dw handle_progress_armadillo
        dw handle_progress_mammoth
        dw handle_progress_eagle
        dw handle_progress_mandrill
        dw handle_progress_kuwanger
        dw handle_progress_penguin
        dw handle_progress_fortress_1
        dw handle_progress_fortress_2
        dw handle_progress_fortress_3
        dw handle_progress_fortress_4

password_menu_palette:
        dw $0000,$117D,$087F,$1084
        dw $0000,$739C,$6318,$1084
        dw $0000,$739C,$6BB2,$1084
        dw $0000,$739C,$1B7E,$1084
        dw $0000,$739C,$7F8A,$1084
        ;dw $0000,$739C,$3F4F,$1084
        dw $0000,$5BED,$3720,$1084
        dw $0000,$739C,$6A3D,$1084
        dw $0000,$739C,$725A,$1084

load_progress_text:
        sta $06
        ldy #$0000
    .super_loop
        lda [$06],y
        sta $2116
        iny #2
    .loop
        lda [$06],y
        cmp #$FFFE
        beq .load_next
        cmp #$FFFF
        beq .break
        cmp #$0100
        bcs .regular
        ora $0E
    .regular
        sta $2118
        iny #2
        bra .loop
    .load_next
        iny #2
        bra .super_loop
    .break 
        rts 

progress_menu_default_texts:
        %write_text($00,$04,0,"blue","Stage Progress")
        %write_text($03,$00,0,"yellow","Checks:")
        %write_text($04,$00,0,"yellow","Heart Tank:")
        %write_text($04,$10,0,"gray","N/A")
        %write_text($05,$00,0,"yellow","Sub Tank:")
        %write_text($05,$10,0,"gray","N/A")
        %write_text($06,$00,0,"yellow","Capsule:")
        %write_text($06,$10,0,"gray","N/A")
        %write_text($07,$00,0,"yellow","Pickups:")
        %write_text($07,$10,0,"gray","N/A")
        %write_text($09,$00,0,"blue","Stage Time:")
        %write_text($09,$0C,0,"gray","000:00:00")

        %write_text($0B,$04,0,"blue","Total Progress")
        %write_text($0D,$00,0,"yellow","Checks:")
        %write_text($0E,$00,0,"yellow","M. Medals:")
        %write_text($0F,$00,0,"yellow","Weapons")
        %write_text($10,$00,0,"yellow","Heart Tanks:")
        %write_text($11,$00,0,"yellow","Sub Tanks:")
        %write_text($12,$00,0,"yellow","Upgrades:")

        %write_text($14,$00,0,"blue","Total Time:")
        %write_text($14,$0C,1,"gray","000:00:00")

;##################################################################################################

global_text_write:
    .heart_tank
        sta $00
        lda !heart_tank_collected
        and $00
        beq ..not_collected
    ..collected
        lda.w #global_texts_heart_tank_yes
        jmp load_progress_text
    ..not_collected
        lda.w #global_texts_heart_tank_no
        jmp load_progress_text
        
    .sub_tank
        sta $00
        lda !upgrades_collected
        and $00
        beq ..not_collected
    ..collected
        lda.w #global_texts_sub_tank_yes
        jmp load_progress_text
    ..not_collected
        lda.w #global_texts_sub_tank_no
        jmp load_progress_text

    .upgrade_capsule
        sta $00
        lda !upgrades_collected
        and $00
    .hadouken_capsule
        beq ..not_collected
    ..collected
        lda.w #global_texts_capsule_yes
        jmp load_progress_text
    ..not_collected
        lda.w #global_texts_capsule_no
        jmp load_progress_text

        
global_texts:
    .heart_tank
        ..yes
            %write_text($04,$0D,1,"green","Collected")
        ..no
            %write_text($04,$0C,1,"red","Uncollected")

    .sub_tank
        ..yes
            %write_text($05,$0D,1,"green","Collected")
        ..no
            %write_text($05,$0C,1,"red","Uncollected")
    
    .capsule
        ..yes
            %write_text($06,$0D,1,"green","Collected")
        ..no
            %write_text($06,$0C,1,"red","Uncollected")

;##################################################################################################

handle_progress_intro:
        lda.w #.stage_name
        jsr load_progress_text
        
    .count_locations
        ldy #$0000
        lda !bosses_defeated+$1C
        and #$00FF
        beq $01
        iny 
        lda !bosses_defeated+$1D
        and #$00FF
        beq $01
        iny 
    
        lda.w #!palette_completed
        sta $0E
        cpy #$0002
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.check_count
        jsr load_progress_text
        %write_value($03, $10, 1, 1, "ram", $0C)

        lda setting_pickupsanity_configuration
        and #$00FF
        bne .count_pickupsanity
        rts 
    .count_pickupsanity
        ldy #$0000
        ldx #$0000
    ..loop
        lda !pickup_array+$00,x
        and #$00FF
        beq $01
        iny 
        inx 
        cpx #$0002
        bne ..loop

        lda.w #!palette_completed
        sta $0E
        cpy #$0002
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.pickup_count
        jsr load_progress_text
        %write_value($07, $10, 1, 1, "ram", $0C)
        rts 
        
    .stage_name
        %write_text($01,$00,1,"purple","        Intro         ")
    .check_count
        %write_text($03,$11,1,"ram","/2")
    .pickup_count
        %write_text($07,$11,1,"ram","/2")

;##################################################################################################

handle_progress_octopus:
        lda.w #.stage_name
        jsr load_progress_text

        lda #$0080
        jsr global_text_write_heart_tank

    .count_locations
        ldy #$0000
        lda !bosses_defeated+$03
        and #$00FF
        beq $01
        iny 
        lda !bosses_defeated+$18
        and #$00FF
        beq $01
        iny 
        lda !bosses_defeated+$19
        and #$00FF
        beq $01
        iny 
        lda !bosses_defeated+$1A
        and #$00FF
        beq $01
        iny 
        lda !bosses_defeated+$1B
        and #$00FF
        beq $01
        iny 
        lda !heart_tank_collected
        and #$0080
        beq $01
        iny 
    
        lda.w #!palette_completed
        sta $0E
        cpy #$0006
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.check_count
        jsr load_progress_text
        %write_value($03, $10, 1, 1, "ram", $0C)

        lda setting_pickupsanity_configuration
        and #$00FF
        bne .count_pickupsanity
        rts 
    .count_pickupsanity
        ldy #$0000
        lda !pickup_array+$02
        and #$00FF
        beq $01
        iny 

        lda.w #!palette_completed
        sta $0E
        cpy #$0001
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.pickup_count
        jsr load_progress_text
        %write_value($07, $10, 1, 1, "ram", $0C)
        rts 
        
    .stage_name
        %write_text($01,$00,1,"purple","    Launch Octopus    ")
    .check_count
        %write_text($03,$11,1,"ram","/6")
    .pickup_count
        %write_text($07,$11,1,"ram","/1")

;##################################################################################################

handle_progress_penguin:
        lda.w #.stage_name
        jsr load_progress_text

        lda #$0001
        jsr global_text_write_heart_tank
        lda #$0008
        jsr global_text_write_upgrade_capsule

    .count_locations
        ldy #$0000
        lda !bosses_defeated+$01
        and #$00FF
        beq $01
        iny 
        lda !heart_tank_collected
        and #$0001
        beq $01
        iny 
        lda !upgrades_collected
        and #$0008
        beq $01
        iny 
    
        lda.w #!palette_completed
        sta $0E
        cpy #$0003
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.check_count
        jsr load_progress_text
        %write_value($03, $10, 1, 1, "ram", $0C)

        lda setting_pickupsanity_configuration
        and #$00FF
        bne .count_pickupsanity
        rts 
    .count_pickupsanity
        ldy #$0000
        lda !pickup_array+$12
        and #$00FF
        beq $01
        iny 

        lda.w #!palette_completed
        sta $0E
        cpy #$0001
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.pickup_count
        jsr load_progress_text
        %write_value($07, $10, 1, 1, "ram", $0C)
        rts 
        
    .stage_name
        %write_text($01,$00,1,"purple","    Chill  Penguin    ")
    .check_count
        %write_text($03,$11,1,"ram","/3")
    .pickup_count
        %write_text($07,$11,1,"ram","/1")

;##################################################################################################

handle_progress_armadillo:
        lda.w #.stage_name
        jsr load_progress_text

        lda #$0002
        jsr global_text_write_heart_tank
        lda #$0020
        jsr global_text_write_sub_tank
        lda !hadouken_collected
        and #$00FF
        jsr global_text_write_hadouken_capsule

    .count_locations
        ldy #$0000
        lda !bosses_defeated+$00
        and #$00FF
        beq $01
        iny 
        lda !bosses_defeated+$15
        and #$00FF
        beq $01
        iny 
        lda !bosses_defeated+$16
        and #$00FF
        beq $01
        iny 
        lda !hadouken_collected
        and #$00FF
        beq $01
        iny 
        lda !heart_tank_collected
        and #$0002
        beq $01
        iny 
        lda !upgrades_collected
        and #$0020
        beq $01
        iny 
    
        lda.w #!palette_completed
        sta $0E
        cpy #$0006
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.check_count
        jsr load_progress_text
        %write_value($03, $10, 1, 1, "ram", $0C)

        lda setting_pickupsanity_configuration
        and #$00FF
        bne .count_pickupsanity
        rts 
    .count_pickupsanity
        ldy #$0000
        ldx #$0000
    ..loop
        lda !pickup_array+$05,x
        and #$00FF
        beq $01
        iny 
        inx 
        cpx #$0003
        bne ..loop

        lda.w #!palette_completed
        sta $0E
        cpy #$0003
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.pickup_count
        jsr load_progress_text
        %write_value($07, $10, 1, 1, "ram", $0C)
        rts 
        
    .stage_name
        %write_text($01,$00,1,"purple","  Armored  Armadillo  ")
    .check_count
        %write_text($03,$11,1,"ram","/6")
    .pickup_count
        %write_text($07,$11,1,"ram","/3")

;##################################################################################################

handle_progress_eagle:
        lda.w #.stage_name
        jsr load_progress_text

        lda #$0004
        jsr global_text_write_heart_tank
        lda #$0010
        jsr global_text_write_sub_tank
        lda #$0001
        jsr global_text_write_upgrade_capsule

    .count_locations
        ldy #$0000
        lda !bosses_defeated+$06
        and #$00FF
        beq $01
        iny 
        lda !heart_tank_collected
        and #$0004
        beq $01
        iny 
        lda !upgrades_collected
        and #$0001
        beq $01
        iny 
        lda !upgrades_collected
        and #$0010
        beq $01
        iny 
    
        lda.w #!palette_completed
        sta $0E
        cpy #$0004
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.check_count
        jsr load_progress_text
        %write_value($03, $10, 1, 1, "ram", $0C)

        lda setting_pickupsanity_configuration
        and #$00FF
        bne .count_pickupsanity
        rts 
    .count_pickupsanity
        ldy #$0000
        ldx #$0000
    ..loop
        lda !pickup_array+$0B,x
        and #$00FF
        beq $01
        iny 
        inx 
        cpx #$0005
        bne ..loop
        lda !pickup_array+$1B
        and #$00FF
        beq $01
        iny 

        lda.w #!palette_completed
        sta $0E
        cpy #$0006
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.pickup_count
        jsr load_progress_text
        %write_value($07, $10, 1, 1, "ram", $0C)
        rts 
        
    .stage_name
        %write_text($01,$00,1,"purple","     Storm  Eagle     ")
    .check_count
        %write_text($03,$11,1,"ram","/4")
    .pickup_count
        %write_text($07,$11,1,"ram","/6")

;##################################################################################################

handle_progress_mandrill:
        lda.w #.stage_name
        jsr load_progress_text

        lda #$0040
        jsr global_text_write_heart_tank
        lda #$0040
        jsr global_text_write_sub_tank

    .count_locations
        ldy #$0000
        lda !bosses_defeated+$02
        and #$00FF
        beq $01
        iny 
        lda !bosses_defeated+$17
        and #$00FF
        beq $01
        iny 
        lda !heart_tank_collected
        and #$0040
        beq $01
        iny 
        lda !upgrades_collected
        and #$0040
        beq $01
        iny 
    
        lda.w #!palette_completed
        sta $0E
        cpy #$0004
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.check_count
        jsr load_progress_text
        %write_value($03, $10, 1, 1, "ram", $0C)
        rts 
        
    .stage_name
        %write_text($01,$00,1,"purple","    Spark Mandrill    ")
    .check_count
        %write_text($03,$11,1,"ram","/4")

;##################################################################################################

handle_progress_chameleon:
        lda.w #.stage_name
        jsr load_progress_text

        lda #$0008
        jsr global_text_write_heart_tank
        lda #$0004
        jsr global_text_write_upgrade_capsule

    .count_locations
        ldy #$0000
        lda !bosses_defeated+$05
        and #$00FF
        beq $01
        iny 
        lda !heart_tank_collected
        and #$0008
        beq $01
        iny 
        lda !upgrades_collected
        and #$0004
        beq $01
        iny 
    
        lda.w #!palette_completed
        sta $0E
        cpy #$0003
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.check_count
        jsr load_progress_text
        %write_value($03, $10, 1, 1, "ram", $0C)

        lda setting_pickupsanity_configuration
        and #$00FF
        bne .count_pickupsanity
        rts 
    .count_pickupsanity
        ldy #$0000
        lda !pickup_array+$03
        and #$00FF
        beq $01
        iny 
        lda !pickup_array+$04
        and #$00FF
        beq $01
        iny 

        lda.w #!palette_completed
        sta $0E
        cpy #$0002
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.pickup_count
        jsr load_progress_text
        %write_value($07, $10, 1, 1, "ram", $0C)
        rts 
        
    .stage_name
        %write_text($01,$00,1,"purple","   Sting  Chameleon   ")
    .check_count
        %write_text($03,$11,1,"ram","/3")
    .pickup_count
        %write_text($07,$11,1,"ram","/2")

;##################################################################################################

handle_progress_mammoth:
        lda.w #.stage_name
        jsr load_progress_text

        lda #$0010
        jsr global_text_write_heart_tank
        lda #$0080
        jsr global_text_write_sub_tank
        lda #$0002
        jsr global_text_write_upgrade_capsule

    .count_locations
        ldy #$0000
        lda !bosses_defeated+$07
        and #$00FF
        beq $01
        iny 
        lda !heart_tank_collected
        and #$0010
        beq $01
        iny 
        lda !upgrades_collected
        and #$0080
        beq $01
        iny 
        lda !upgrades_collected
        and #$0002
        beq $01
        iny 
    
        lda.w #!palette_completed
        sta $0E
        cpy #$0004
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.check_count
        jsr load_progress_text
        %write_value($03, $10, 1, 1, "ram", $0C)

        lda setting_pickupsanity_configuration
        and #$00FF
        bne .count_pickupsanity
        rts 
    .count_pickupsanity
        ldy #$0000
        ldx #$0000
    ..loop
        lda !pickup_array+$08,x
        and #$00FF
        beq $01
        iny 
        inx 
        cpx #$0003
        bne ..loop

        lda.w #!palette_completed
        sta $0E
        cpy #$0003
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.pickup_count
        jsr load_progress_text
        %write_value($07, $10, 1, 1, "ram", $0C)
        rts 
        
    .stage_name
        %write_text($01,$00,1,"purple","    Flame  Mammoth    ")
    .check_count
        %write_text($03,$11,1,"ram","/4")
    .pickup_count
        %write_text($07,$11,1,"ram","/3")

;##################################################################################################

handle_progress_kuwanger:
        lda.w #.stage_name
        jsr load_progress_text

        lda #$0020
        jsr global_text_write_heart_tank

    .count_locations
        ldy #$0000
        lda !bosses_defeated+$04
        and #$00FF
        beq $01
        iny 
        lda !heart_tank_collected
        and #$0020
        beq $01
        iny 

        lda.w #!palette_completed
        sta $0E
        cpy #$0002
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.check_count
        jsr load_progress_text
        %write_value($03, $10, 1, 1, "ram", $0C)
        rts 
        
    .stage_name
        %write_text($01,$00,1,"purple","   Boomer  Kuwanger   ")
    .check_count
        %write_text($03,$11,1,"ram","/2")

;##################################################################################################

handle_progress_fortress_1:
        lda.w #.stage_name
        jsr load_progress_text

    .count_locations
        ldy #$0000
        lda !bosses_defeated+$08
        and #$00FF
        beq $01
        iny 
        lda !bosses_defeated+$09
        and #$00FF
        beq $01
        iny 
        lda !bosses_defeated+$0A
        and #$00FF
        beq $01
        iny 

        lda.w #!palette_completed
        sta $0E
        cpy #$0003
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.check_count
        jsr load_progress_text
        %write_value($03, $10, 1, 1, "ram", $0C)
        rts 
        
    .stage_name
        %write_text($01,$00,1,"purple","  Sigma's Fortress #1 ")
    .check_count
        %write_text($03,$11,1,"ram","/3")

;##################################################################################################

handle_progress_fortress_2:
        lda.w #.stage_name
        jsr load_progress_text

    .count_locations
        ldy #$0000
        lda !bosses_defeated+$0B
        and #$00FF
        beq $01
        iny 
        lda !bosses_defeated+$0C
        and #$00FF
        beq $01
        iny 
        lda !bosses_defeated+$0D
        and #$00FF
        beq $01
        iny 

        lda.w #!palette_completed
        sta $0E
        cpy #$0003
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.check_count
        jsr load_progress_text
        %write_value($03, $10, 1, 1, "ram", $0C)
        rts 
        
    .stage_name
        %write_text($01,$00,1,"purple","  Sigma's Fortress #2 ")
    .check_count
        %write_text($03,$11,1,"ram","/3")

;##################################################################################################

handle_progress_fortress_3:
        lda.w #.stage_name
        jsr load_progress_text

    .count_locations
        ldy #$0000
        lda !bosses_defeated+$0E
        and #$00FF
        beq $01
        iny 
        lda !bosses_defeated+$0F
        and #$00FF
        beq $01
        iny 
        lda !bosses_defeated+$10
        and #$00FF
        beq $01
        iny 
        lda !bosses_defeated+$11
        and #$00FF
        beq $01
        iny 
        lda !bosses_defeated+$12
        and #$00FF
        beq $01
        iny 
        lda !bosses_defeated+$1E
        and #$00FF
        beq $01
        iny 

        lda.w #!palette_completed
        sta $0E
        cpy #$0006
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.check_count
        jsr load_progress_text
        %write_value($03, $10, 1, 1, "ram", $0C)

        lda setting_pickupsanity_configuration
        and #$00FF
        bne .count_pickupsanity
        rts 
    .count_pickupsanity
        ldy #$0000
        ldx #$0000
    ..loop
        lda !pickup_array+$13,x
        and #$00FF
        beq $01
        iny 
        inx 
        cpx #$0008
        bne ..loop

        lda.w #!palette_completed
        sta $0E
        cpy #$0008
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.pickup_count
        jsr load_progress_text
        %write_value($07, $10, 1, 1, "ram", $0C)
        rts 
        
    .stage_name
        %write_text($01,$00,1,"purple","  Sigma's Fortress #3 ")
    .check_count
        %write_text($03,$11,1,"ram","/6")
    .pickup_count
        %write_text($07,$11,1,"ram","/8")

;##################################################################################################

handle_progress_fortress_4:
        lda.w #.stage_name
        jsr load_progress_text

    .count_locations
        ldy #$0000
        lda !bosses_defeated+$13
        and #$00FF
        beq $01
        iny 

        lda.w #!palette_completed
        sta $0E
        cpy #$0001
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.check_count
        jsr load_progress_text
        %write_value($03, $10, 1, 1, "ram", $0C)
        rts 
        
    .stage_name
        %write_text($01,$00,1,"purple","  Sigma's Fortress #4 ")
    .check_count
        %write_text($03,$11,1,"ram","/1")

;##################################################################################################

handle_progress_global:
    .count_all
        stz $0A
        ldy #$0000
        jsr .count_bosses
        jsr .count_collected_heart_tanks
        jsr .count_collected_upgrades

        lda.l setting_pickupsanity_configuration
        and #$00FF
        beq ..skip
        jsr .count_collected_pickups
    ..skip

        lda.w #!palette_unused
        sta $0E
        tya 
        sta $0C
        %write_value($0D, $0F, 2, 1, "ram", $0C)
        %write_value($0D, $12, 2, 1, "ram", $0A)
        lda.w #.total_check_count
        jsr load_progress_text

    .count_medals
        jsr .count_obtained_medals
        
        lda.l setting_sigma_medal_count
        and #$00FF
        sta $00
        lda.w #!palette_unused
        sta $0E
        lda.l setting_sigma_configuration
        and #$0001
        beq ..write 
        lda.w #!palette_completed
        sta $0E
        cpy $00
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.total_medal_count
        jsr load_progress_text
        %write_value($0E, $10, 1, 1, "ram", $0C)

    .count_weapons
        jsr .count_obtained_weapons
        
        lda.l setting_sigma_weapon_count
        and #$00FF
        sta $00
        lda.w #!palette_unused
        sta $0E
        lda.l setting_sigma_configuration
        and #$0002
        beq ..write 
        lda.w #!palette_completed
        sta $0E
        cpy $00
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        tya 
        sta $0C
        lda.w #.total_weapon_count
        jsr load_progress_text
        %write_value($0F, $10, 1, 1, "ram", $0C)


    .count_total_heart_tanks
        jsr .count_obtained_heart_tanks

        lda.l setting_sigma_heart_tank_count
        and #$00FF
        sta $00
        lda.w #!palette_unused
        sta $0E
        lda.l setting_sigma_configuration
        and #$0008
        beq ..write 
        lda.w #!palette_completed
        sta $0E
        cpy $00
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.total_heart_tank_count
        jsr load_progress_text
        %write_value($10, $10, 1, 1, "ram", $0C)

    .count_total_sub_tanks
        jsr .count_obtained_sub_tanks

        lda.l setting_sigma_sub_tank_count
        and #$00FF
        sta $00
        lda.w #!palette_unused
        sta $0E
        lda.l setting_sigma_configuration
        and #$0010
        beq ..write 
        lda.w #!palette_completed
        sta $0E
        cpy $00
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.total_sub_tank_count
        jsr load_progress_text
        %write_value($11, $10, 1, 1, "ram", $0C)

    .count_total_upgrades
        jsr .count_obtained_upgrades

        lda.l setting_sigma_armor_count
        and #$00FF
        sta $00
        lda.w #!palette_unused
        sta $0E
        lda.l setting_sigma_configuration
        and #$0004
        beq ..write 
        lda.w #!palette_completed
        sta $0E
        cpy $00
        bcs ..write
        lda.w #!palette_incomplete
        sta $0E
    ..write
        tya 
        sta $0C
        lda.w #.total_upgrade_count
        jsr load_progress_text
        %write_value($12, $10, 1, 1, "ram", $0C)
        %write_value($12, $12, 1, 1, "ram", $0A)

    .handle_stage_timer
        sep #$20
        lda !level_timer_fractions
        sta $4202
        lda.b #100
        sta $4203
        jsr wait_for_calc
        rep #$20
        lda $4216
        sta $4204
        sep #$20
        lda.b #60
        sta $4206
        jsr wait_for_calc
        nop #2
        rep #$20
        ldy $4214
        lda $4216
        cmp.w #30
        bcc ..no_round
    ..round
        iny  
    ..no_round
        tya 
        sta $0C
        %write_value($09, $13, 2, 0, "gray", $0C)
        %write_value($09, $10, 2, 0, "gray", !level_timer_seconds)
        %write_value($09, $0C, 3, 1, "gray", !level_timer_minutes)

    .handle_global_timer
        sep #$20
        lda !global_timer_fractions
        sta $4202
        lda.b #100
        sta $4203
        jsr wait_for_calc
        rep #$20
        lda $4216
        sta $4204
        sep #$20
        lda.b #60
        sta $4206
        jsr wait_for_calc
        nop #2
        rep #$20
        ldy $4214
        lda $4216
        cmp.w #30
        bcc ..no_round
    ..round
        iny  
    ..no_round
        tya 
        sta $0C
        %write_value($14, $13, 2, 0, "gray", $0C)
        %write_value($14, $10, 2, 0, "gray", !global_timer_seconds)
        %write_value($14, $0C, 3, 1, "gray", !global_timer_minutes)
        rts 
        
        
    .total_check_count
        %write_text($0D,$11,1,"ram","/")
    .total_medal_count
        %write_text($0E,$11,1,"ram","/8")
    .total_weapon_count
        %write_text($0F,$11,1,"ram","/8")
    .total_heart_tank_count
        %write_text($10,$11,1,"ram","/8")
    .total_sub_tank_count
        %write_text($11,$11,1,"ram","/4")
    .total_upgrade_count
        %write_text($12,$11,1,"ram","/")

    .bit_field
        dw $0001,$0002,$0004,$0008,$0010,$0020,$0040,$0080

    .count_collected_pickups
        ldx #$0000
    ..loop
        inc $0A
        lda !pickup_array+$00,x
        and #$00FF
        beq $01
        iny 
        inx 
        cpx #$001B
        bne ..loop
        dec $0A
        dec $0A
        rts 

    .count_collected_heart_tanks
        ldx #$0000
    ..loop
        inc $0A
        lda !heart_tank_collected
        and.l .bit_field,x
        beq $01
        iny 
        inx #2
        cpx #$0008
        bne ..loop
        rts 

    .count_collected_upgrades
        ldx #$0000
    ..loop
        inc $0A
        lda !upgrades_collected
        and.l .bit_field,x
        beq $01
        iny 
        inx #2
        cpx #$0010
        bne ..loop
        rts 

    .count_obtained_heart_tanks
        stz $0A
        ldy #$0000
        ldx #$0000
    ..loop
        inc $0A
        lda !heart_tanks
        and.l .bit_field,x
        beq $01
        iny 
        inx #2
        cpx #$0010
        bne ..loop
        rts 

    .count_obtained_upgrades
        stz $0A
        ldy #$0000
        ldx #$0000
    ..loop_1
        inc $0A
        lda !upgrades
        and.l .bit_field,x
        beq $01
        iny 
        inx #2
        cpx #$0008
        bne ..loop_1
        lda setting_jammed_buster_configuration
        and #$00FF
        beq +
        inc $0A
        lda !unlocked_charge
        and #$00FF
        beq $01
        iny 
    +   
        lda setting_abilities
        and #$0002
        beq +
        inc $0A
        lda !unlocked_air_dash
        and #$00FF
        beq $01
        iny 
    +   
        rts 

    .count_obtained_sub_tanks
        stz $0A
        ldy #$0000
        ldx #$0008
    ..loop
        inc $0A
        lda !upgrades
        and.l .bit_field,x
        beq $01
        iny 
        inx #2
        cpx #$0010
        bne ..loop
        rts 
    
    .count_obtained_weapons
        stz $0A
        ldy #$0000
        ldx #$0000
    ..loop
        lda !weapons,x
        and #$0040
        beq $01
        iny
        inx #2
        cpx #$0010
        bne ..loop
        rts 

    .count_obtained_medals
        ldy #$0000
        ldx #$0000
    ..loop
        lda !bosses_defeated+$00,x
        and #$00FF
        beq $01
        iny 
        inx 
        cpx #$0008
        bne ..loop
        rts 

    .count_bosses
        ldx #$0000
    ..loop
        inc $0A
        lda !bosses_defeated+$00,x
        and #$00FF
        beq $01
        iny 
        inx 
        cpx #$001F
        bne ..loop
        dec $0A
        rts 

wait_for_calc:
        rts 

;##################################################################################################

password_menu_main:
    .fraction
        ldx !direct_dma_queue_index
        lda #$80
        sta.w direct_dma_queue.vmain,x
        lda #$04
        sta.w direct_dma_queue.size,x

        lda !global_timer_fractions
        sta $4202
        lda.b #100
        sta $4203
        jsr wait_for_calc
        rep #$20
        lda $4216
        sta $4204
        sep #$20
        lda.b #60
        sta $4206
        jsr wait_for_calc
        nop #2
        ldy $4214
        lda $4216
        cmp #$30
        bcc ..no_round
    ..round
        iny  
    ..no_round
        rep #$20
        lda.w #$15F0>>1
        sta.w direct_dma_queue.destination,x
        tya 
        jsl hex_to_dec_super_long
        lda $0001
        clc 
        adc #$30
        sta.w direct_dma_queue.data,x
        lda #$24
        sta.w direct_dma_queue.data+$01,x
        lda $0000
        clc 
        adc #$30
        sta.w direct_dma_queue.data+$02,x
        lda #$24
        sta.w direct_dma_queue.data+$03,x
        txa 
        clc 
        adc #$08
        sta !direct_dma_queue_index

    .seconds
        ldx !direct_dma_queue_index
        lda #$80
        sta.w direct_dma_queue.vmain,x
        lda #$04
        sta.w direct_dma_queue.size,x
        rep #$20
        lda.w #$15EA>>1
        sta.w direct_dma_queue.destination,x
        lda !global_timer_seconds
        and #$00FF
        jsl hex_to_dec_super_long
        lda $0001
        clc 
        adc #$30
        sta.w direct_dma_queue.data,x
        lda #$24
        sta.w direct_dma_queue.data+$01,x
        lda $0000
        clc 
        adc #$30
        sta.w direct_dma_queue.data+$02,x
        lda #$24
        sta.w direct_dma_queue.data+$03,x
        txa 
        clc 
        adc #$08
        sta !direct_dma_queue_index

    .minutes
        ldx !direct_dma_queue_index
        lda #$80
        sta.w direct_dma_queue.vmain,x
        lda #$06
        sta.w direct_dma_queue.size,x
        rep #$20
        lda.w #$15E2>>1
        sta.w direct_dma_queue.destination,x
        lda !global_timer_minutes
        and #$0FFF
        jsl hex_to_dec_super_long
        lda $0002
        beq +
        clc 
        adc #$30
    +   
        sta.w direct_dma_queue.data,x
        lda #$24
        sta.w direct_dma_queue.data+$01,x

        lda $0001
        ora $0002
        beq +
        lda $0001
        clc 
        adc #$30
    +   
        sta.w direct_dma_queue.data+$02,x
        lda #$24
        sta.w direct_dma_queue.data+$03,x

        lda $0000
        clc 
        adc #$30
        sta.w direct_dma_queue.data+$04,x
        lda #$24
        sta.w direct_dma_queue.data+$05,x
        txa 
        clc 
        adc #$0A
        sta !direct_dma_queue_index
        rtl 

;##################################################################################################

credits_stat_load:
        lda #$01
        sta $00A1
        jsr .layer_3

        stz $0b9d
    -    
        lda $0b9d
        beq -
        stz $0b9d
    
        stz $4200
        lda #$80
        sta $2100
    
        phd 
        rep #$20
        lda #$0000
        pha 
        pld 
        sep #$20
        jsr .nmi
        pld 

        lda #$81
        sta $4200
        stz $2100

        rtl 

    .nmi
        lda #$80
        sta $2115
        lda.b #final_menu_default_texts>>16
        sta $08
        rep #$30
        lda.w #final_menu_default_texts
        jsr load_progress_text

        jsr handle_progress_final

        sep #$30
        rts 

!final_special_palette = $3C00
!final_silver_palette = $2400
!final_golden_palette = $2800
!final_bronze_palette = $3800

    .palette
        dw $0000,$117D,$087F,$1084
        dw $0000,$739C,$6318,$1084
        dw $0000,$0F3E,$01D6,$1084
        dw $0000,$739C,$1B7E,$1084
        dw $0000,$739C,$7F8A,$1084
        dw $0000,$5BED,$3720,$1084
        dw $0000,$42DF,$2597,$1084
        dw $0000,$739C,$725A,$1084

    .layer_3
        rep #$20
        ldx #$00
    ..loop
        lda.l .palette,x
        sta $0300,x
        inx #2
        cpx #$40
        bne ..loop
        sep #$20
        rts 

final_menu_default_texts:
        %write_text($00,$06,0,"blue","GAME CLEAR!")
        %write_text($02,$03,0,"blue","MMX1  Archipelago")
        %write_text($03,$08,0,"purple","v1.4.0")
        %write_text($05,$06,0,"blue","Final Stats")
        %write_text($07,$00,0,"yellow","Checks:")
        %write_text($08,$00,0,"yellow","M. Medals:")
        %write_text($09,$00,0,"yellow","Weapons:")
        %write_text($0A,$00,0,"yellow","Heart Tanks:")
        %write_text($0B,$00,0,"yellow","Sub Tanks:")
        %write_text($0C,$00,0,"yellow","Upgrades:")

        %write_text($0E,$00,0,"yellow","Deaths:")
        %write_text($0F,$00,0,"yellow","DMG Taken:")
        %write_text($10,$00,0,"yellow","DMG Dealt:")

        %write_text($12,$00,0,"blue","Clear Time:")

        %write_text($14,$02,1,"blue","Thanks for playing!")
        
credits_stat_main:
        rtl 


handle_progress_final:
    .count_all
        stz $0A
        ldy #$0000
        jsr handle_progress_global_count_bosses
        jsr handle_progress_global_count_collected_heart_tanks
        jsr handle_progress_global_count_collected_upgrades

        lda.l setting_pickupsanity_configuration
        and #$00FF
        beq ..skip
        jsr handle_progress_global_count_collected_pickups
    ..skip

        lda $0A
        pha 
        lda.w #!final_special_palette
        sta $0E
        cpy.w #25
        bcc ..write
        lda.w #!final_golden_palette
        sta $0E
        cpy $0A
        beq ..write
        lda.w #!final_silver_palette
        sta $0E
        lda $01,s
        lsr 
        sta $01,s
        tya 
        cmp $01,s
        bcs ..write
        lda.w #!final_bronze_palette
        sta $0E
    ..write
        tya 
        sta $0C
        pla 

        %write_value($07, $0F, 2, 1, "ram", $0C)
        %write_value($07, $12, 2, 1, "ram", $0A)
        lda.w #.total_check_count
        jsr load_progress_text

    .count_medals
        ldy #$0000
        jsr handle_progress_global_count_obtained_medals
        
        lda.w #!final_special_palette
        sta $0E
        cpy #$0000
        beq ..incomplete
        lda.w #!final_golden_palette
        sta $0E
        cpy #$0008
        bcs ..incomplete
        lda.w #!final_silver_palette
        sta $0E
        cpy #$0005
        bcs ..incomplete
        lda.w #!final_bronze_palette
        sta $0E
    ..incomplete
        tya 
        sta $0C
        lda.w #.total_medal_count
        jsr load_progress_text
        %write_value($08, $10, 1, 1, "ram", $0C)

    .count_weapons
        ldy #$0000
        jsr handle_progress_global_count_obtained_weapons

        lda.w #!final_special_palette
        sta $0E
        cpy #$0000
        beq ..incomplete
        lda.w #!final_golden_palette
        sta $0E
        cpy #$0008
        beq ..incomplete
        lda.w #!final_silver_palette
        sta $0E
        cpy #$0005
        bcs ..incomplete
        lda.w #!final_bronze_palette
        sta $0E
    ..incomplete
        tya 
        sta $0C
        lda.w #.total_weapon_count
        jsr load_progress_text
        %write_value($09, $10, 1, 1, "ram", $0C)


    .count_total_heart_tanks
        ldy #$0000
        jsr handle_progress_global_count_obtained_heart_tanks

        lda.w #!final_special_palette
        sta $0E
        cpy #$0000
        beq ..incomplete
        lda.w #!final_golden_palette
        sta $0E
        cpy #$0008
        bcs ..incomplete
        lda.w #!final_silver_palette
        sta $0E
        cpy #$0005
        bcs ..incomplete
        lda.w #!final_bronze_palette
        sta $0E
    ..incomplete
        tya 
        sta $0C
        lda.w #.total_heart_tank_count
        jsr load_progress_text
        %write_value($0A, $10, 1, 1, "ram", $0C)

    .count_total_sub_tanks
        ldy #$0000
        jsr handle_progress_global_count_obtained_sub_tanks

        lda.w #!final_special_palette
        sta $0E
        cpy #$0000
        beq ..incomplete
        lda.w #!final_golden_palette
        sta $0E
        cpy #$0004
        bcs ..incomplete
        lda.w #!final_silver_palette
        sta $0E
        cpy #$0002
        bcs ..incomplete
        lda.w #!final_bronze_palette
        sta $0E
    ..incomplete
        tya 
        sta $0C
        lda.w #.total_sub_tank_count
        jsr load_progress_text
        %write_value($0B, $10, 1, 1, "ram", $0C)

    .count_total_upgrades
        ldy #$0000
        jsr handle_progress_global_count_obtained_upgrades

        lda.w #!final_special_palette
        sta $0E
        cpy #$0000
        beq ..incomplete
        lda.w #!final_golden_palette
        sta $0E
        cpy #$0004
        bcs ..incomplete
        lda.w #!final_silver_palette
        sta $0E
        cpy #$0002
        bcs ..incomplete
        lda.w #!final_bronze_palette
        sta $0E
    ..incomplete
        tya 
        sta $0C
        lda.w #.total_capsule_count
        jsr load_progress_text
        %write_value($0C, $10, 1, 1, "ram", $0C)
        %write_value($0C, $12, 1, 1, "ram", $0A)

    .handle_deaths
        lda !total_deaths
        sta $0C
        tay 
        lda.w #!final_special_palette
        sta $0E
        cpy #$0000
        beq ..incomplete
        lda.w #!final_golden_palette
        sta $0E
        cpy #$0001
        beq ..incomplete
        lda.w #!final_bronze_palette
        sta $0E
        cpy #$0005
        bcs ..incomplete
        lda.w #!final_silver_palette
        sta $0E
    ..incomplete
        %write_value($0E, $0F, 4, 1, "ram", $0C)
        
    .handle_dmg_taken
        lda !total_damage_taken
        sta $0C
        tay 
        lda.w #!final_special_palette
        sta $0E
        cpy.w #32
        bcc ..incomplete
        lda.w #!final_golden_palette
        sta $0E
        cpy.w #250
        bcc ..incomplete
        lda.w #!final_silver_palette
        sta $0E
        cpy.w #500
        bcc ..incomplete
        lda.w #!final_bronze_palette
        sta $0E
    ..incomplete
        %write_value($0F, $0F, 4, 1, "ram", $0C)

    .handle_dmg_dealt
        lda !total_damage_dealt
        sta $0C
        tay 
        lda.w #!final_special_palette
        sta $0E
        cpy.w #9999
        bcs ..incomplete
        lda.w #!final_golden_palette
        sta $0E
        cpy.w #7000
        bcs ..incomplete
        lda.w #!final_silver_palette
        sta $0E
        cpy.w #3500
        bcs ..incomplete
        lda.w #!final_bronze_palette
        sta $0E
    ..incomplete
        %write_value($10, $0F, 4, 1, "ram", $0C)

    .handle_timer
        sep #$20
        lda !level_timer_fractions
        sta $4202
        lda.b #100
        sta $4203
        jsr wait_for_calc
        rep #$20
        lda $4216
        sta $4204
        sep #$20
        lda.b #60
        sta $4206
        jsr wait_for_calc
        nop #2
        rep #$20
        ldy $4214
        lda $4216
        cmp.w #30
        bcc ..no_round
    ..round
        iny  
    ..no_round
        tya 
        sta $0C

    ..compute_targets
        lda.w #25
        sta $00
        lda.w #40
        sta $02
        lda.w #70
        sta $04

        lda.l setting_pickupsanity_configuration
        and #$00FF
        beq ...no_pickupsanity
        lda $00
        clc 
        adc.w #3
        sta $00
        lda $02
        clc 
        adc.w #5
        sta $02
        lda $04
        clc 
        adc.w #10
        sta $04
    ...no_pickupsanity
        lda.l setting_boss_weakness_strictness
        and #$00FF
        cmp #$0002
        bcc ...not_strict
        lda $00
        clc 
        adc.w #4
        sta $00
        lda $02
        clc 
        adc.w #5
        sta $02
        lda $04
        clc 
        adc.w #10
        sta $04
    ...not_strict
        lda.l setting_boss_weakness_rando
        and #$00FF
        beq ..no_weakness_rando
        lda $00
        clc 
        adc.w #3
        sta $00
        lda $02
        clc 
        adc.w #5
        sta $02
        lda $04
        clc 
        adc.w #5
        sta $04
    ..no_weakness_rando
    
        lda.w #!final_special_palette
        sta $0E
        lda !level_timer_minutes
        tay 
        cpy $00
        bcc ..write
        lda.w #!final_golden_palette
        sta $0E
        cpy $02
        bcc ..write
        lda.w #!final_silver_palette
        sta $0E
        cpy $04
        bcc ..write
        lda.w #!final_bronze_palette
        sta $0E
    ..write
        lda.w #.total_timer
        jsr load_progress_text
        %write_value($12, $13, 2, 0, "ram", $0C)
        %write_value($12, $10, 2, 0, "ram", !level_timer_seconds)
        %write_value($12, $0C, 3, 1, "ram", !level_timer_minutes)

        rts 
        
    .total_timer
        %write_text($12,$0C,1,"ram","---:--:--")
    .total_check_count
        %write_text($07,$11,1,"ram","/")
    .total_medal_count
        %write_text($08,$11,1,"ram","/8")
    .total_weapon_count
        %write_text($09,$11,1,"ram","/8")
    .total_heart_tank_count
        %write_text($0A,$11,1,"ram","/8")
    .total_sub_tank_count
        %write_text($0B,$11,1,"ram","/4")
    .total_capsule_count
        %write_text($0C,$11,1,"ram","/5")
