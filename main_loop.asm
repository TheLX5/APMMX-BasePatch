main_loop:
        lda $00D1
        beq .reset
        cmp #$02
        bne .return
    .playable
        ldx $00D2
        cpx #$08
        bcs .return
        jsr (.game_ptrs,x)
    .return
        inc $0B9B
        ldx #$00
        rtl 
    .reset
        lda #$00
        sta !recv_index
        bra .return

    .game_ptrs
        dw map
        dw level_intro
        dw level
        dw credits

;########################################################################################

level_intro:
        rts 

;########################################################################################

credits:
        rts

;########################################################################################

map:
        lda !current_checkpoint
        and #$7F
        sta !current_checkpoint
        lda #$00
        sta !receiving_item
        jsr playback_sfx
        jsr calculate_fortress_access
        jsr draw_stage_select
        rts 

;########################################################################################

level:
        jsr unlock_sigma_fortress
        jsr handle_heart_tank_upgrade
        jsr handle_hp_refill
        jsr handle_weapon_refill
        jsr give_1up
        jsr fix_softlock
        jsr playback_sfx
        rts 

;##########################################################

unlock_sigma_fortress:
        lda.l setting_sigma_configuration
        bne .check_medals
        rts 

    .check_medals
        lda #$00
        pha 
        lda.l setting_sigma_configuration
        and #$01
        beq ..force
        jsr .count_medals
        beq ..skip
    ..force
        lda $01,s
        inc 
        sta $01,s
    ..skip

    .check_weapons
        lda.l setting_sigma_configuration
        and #$02
        beq ..force
        jsr .count_weapons
        beq ..skip
    ..force
        lda $01,s
        inc 
        sta $01,s
    ..skip

    .check_armor_upgrades
        lda.l setting_sigma_configuration
        and #$04
        beq ..force
        jsr .count_armor_upgrades
        beq ..skip
    ..force
        lda $01,s
        inc 
        sta $01,s
    ..skip

    .check_heart_tanks
        lda.l setting_sigma_configuration
        and #$08
        beq ..force
        jsr .count_heart_tanks
        beq ..skip
    ..force
        lda $01,s
        inc 
        sta $01,s
    ..skip

    .check_sub_tanks
        lda.l setting_sigma_configuration
        and #$10
        beq ..force
        jsr .count_sub_tanks
        beq ..skip
    ..force
        lda $01,s
        inc 
        sta $01,s
    ..skip
    
    .unlock_check
        pla 
        cmp #$05
        bcc .disable
    .enable
        lda #$00
        sta.l !sigma_access
        lda #$01
        sta.l !levels_unlocked+$09
        rts 
    .disable
        lda #$FF
        sta.l !sigma_access
        lda #$00
        sta.l !levels_unlocked+$09
        rts

;############################

    .count_medals
        phb 
        pea $7F7F
        plb 
        plb 
        lda #$00
        ldx #$0E
    ..loop
        bit.w !levels_completed,x
        bvc $01
        inc 
        dex #2
        bpl ..loop
        plb
        cmp.l setting_sigma_medal_count
        bcs ..enable
        lda #$00
        rts 
    ..enable 
        lda #$01
        rts


;############################


    .count_weapons
        lda #$00
        ldx #$0E
    ..loop
        bit.w !weapons,x
        bvc $01
        inc 
        dex #2
        bpl ..loop
        cmp.l setting_sigma_weapon_count
        bcs ..enable
        lda #$00
        rts 
    ..enable 
        lda #$01
        rts


;############################


    .count_armor_upgrades
        lda !upgrades
        and #$0F
        pha 
        ldy #$00
        ldx #$07
    ..loop
        lda $01,s
        and.l .bit_check,x
        beq $01
        iny 
        dex 
        bpl ..loop
        pla 
        tya 
        cmp.l setting_sigma_armor_count
        bcs ..enable
        lda #$00
        rts 
    ..enable 
        lda #$01
        rts


;############################

        
    .count_heart_tanks
        ldy #$00
        ldx #$07
    ..loop
        lda.w !heart_tanks
        and.l .bit_check,x
        beq $01
        iny 
        dex 
        bpl ..loop
        tya 
        cmp.l setting_sigma_heart_tank_count
        bcs ..enable
        lda #$00
        rts 
    ..enable 
        lda #$01
        rts


;############################


    .count_sub_tanks
        lda !upgrades
        and #$F0
        pha 
        ldy #$00
        ldx #$07
    ..loop
        lda $01,s
        and.l .bit_check,x
        beq $01
        iny 
        dex 
        bpl ..loop
        pla 
        tya 
        cmp.l setting_sigma_sub_tank_count
        bcs ..enable
        lda #$00
        rts 
    ..enable 
        lda #$01
        rts
        
    .bit_check
        db $01,$02,$04,$08,$10,$20,$40,$80


;##########################################################

handle_heart_tank_upgrade:
        lda !hp_tank_state
        tax 
        jmp (.ptrs,x)
    .ptrs
        dw .waiting
        dw .init
        dw .wait_for_anim
        dw .increment_hp
        dw .end

    .waiting
        rts
    .init
        lda !max_hp
        cmp #$38
        bcc ..continue
        lda #$00
        sta !hp_tank_state
        rts
    ..continue
        lda #$04
        sta !hp_tank_state
        lda #$50
        sta !hp_tank_timer
        lda #$01
        sta $1F13
        sta $1F14
        sta $1F15
        sta $1F16
        sta $1F17
        sta $1F18
        sta $0BB6
        jsl $849F85
        lda #$29
        jsl play_sfx     ; sfx
        rts 
    
    .wait_for_anim
        lda !hp_tank_timer
        dec 
        sta !hp_tank_timer
        bne ..not_yet
        lda #$06
        sta !hp_tank_state
        lda.l setting_heart_tank_effectiveness
        sta !hp_tank_counter
        lda #$02
        sta !hp_tank_timer_2
    ..not_yet
        rts

    .increment_hp
        lda !current_hp
        and #$7F
        beq ..not_done_inc
        lda !hp_tank_timer_2
        dec 
        sta !hp_tank_timer_2
        bne ..not_done_inc
        lda #$04
        sta !hp_tank_timer_2
        lda !max_hp
        inc 
        cmp #$38
        bcc ..not_max
        lda #$08
        sta !hp_tank_state
        lda #$38
    ..not_max
        sta !max_hp
        inc !current_hp
        lda #$80
        tsb !current_hp
        lda #$0C
        jsl play_sfx     ; sfx
        lda !hp_tank_counter
        dec 
        sta !hp_tank_counter
        bne ..not_done_inc
        lda #$08
        sta !hp_tank_state
    ..not_done_inc
        jsl $81EB89
        rts 
    .end
        stz $1F13
        stz $1F14
        stz $1F15
        stz $1F16
        stz $1F17
        stz $1F18
        lda #$00
        sta !hp_tank_state
        sta !receiving_item
        jsl $849FAD
        jsl $81EB9A
        stz $1F3B
        rts 

;##########################################################

handle_hp_refill:
        lda !hp_refill_state
        tax 
        jmp (.ptrs,x)
    .ptrs
        dw .waiting
        dw .init
        dw .increment_hp
        dw .end
        dw .end_tank

    .waiting
        rts
    .init
        lda !current_hp
        and #$7F
        cmp !max_hp
        beq ..max_hp
        jmp ..not_max
    ..max_hp
        lda !hp_refill_amount
        dec 
        dec 
        sta $0000
        ldx #$00
    ..loop
        lda !sub_tanks,x
        bpl ..next_tank
        cmp #$8E
        bcs ..next_tank
        pha 
        lda #$0D
        jsl play_sfx
        pla 
        inc 
        sta !sub_tanks,x
        cmp #$8E
        beq ..max_tank
        ldy $0000
        bne ..done_filling
        inc 
        sta !sub_tanks,x
        cmp #$8E
        beq ..max_tank
        lda #$06
        sta !hp_refill_state
        lda #$04
        sta !hp_refill_timer
        rtl 
    ..next_tank
        inx 
        cpx #$04
        bne ..loop
    ..done_filling
        lda #$00
        sta !hp_refill_state
        rts
    ..max_tank
        lda #$2B
        jsl play_sfx
        bra ..done_filling

    ..not_max
        lda #$04
        sta !hp_refill_state
        lda #$04
        sta !hp_refill_timer
        lda #$01
        sta $1F13
        sta $1F14
        sta $1F15
        sta $1F16
        sta $1F17
        sta $1F18
        sta $1F19
        sta $0BB6
        jsl $849F85
        rts

    .increment_hp
        lda !current_hp
        and #$7F
        beq ..force_finish
        lda !hp_refill_timer
        dec 
        sta !hp_refill_timer
        bne ..not_done_inc
        lda #$04
        sta !hp_refill_timer
        lda !current_hp
        and #$7F
        inc 
        cmp !max_hp
        bcc ..not_max
        lda #$06
        sta !hp_refill_state
        lda !max_hp
    ..not_max
        ora #$80
        sta !current_hp
        lda #$0C
        jsl play_sfx     ; sfx
        lda !hp_refill_amount
        dec 
        sta !hp_refill_amount
        bne ..not_done_inc
    ..force_finish
        lda #$06
        sta !hp_refill_state
    ..not_done_inc
        rts
    .end
        stz $1F13
        stz $1F14
        stz $1F15
        stz $1F16
        stz $1F17
        stz $1F18
        stz $1F19
        lda #$00
        sta !hp_refill_state
        sta !receiving_item
        jsl $849FAD
        rts

    .end_tank
        lda !hp_refill_timer
        dec
        sta !hp_refill_timer
        bne ..not_yet
        lda #$0D
        jsl play_sfx
        lda #$00
        sta !hp_refill_state
    ..not_yet
        rts

;##########################################################

handle_weapon_refill:
        lda !weapon_refill_state
        tax 
        jmp (.ptrs,x)
    .ptrs
        dw .waiting
        dw .init
        dw .increment_weapon
        dw .end
;81E032
    .waiting
        rts

    .init
        ldy $0BDB
        bne ..weapon
    ..no_weapon
        jsr .refill_other_weapons
        lda #$06
        sta !weapon_refill_state
        rts 
    ..weapon
        lda !weapons-$02,y
        and #$3F
        cmp #$1C
        beq ..no_weapon
        lda #$04
        sta !weapon_refill_state
        lda #$02
        sta !weapon_refill_timer
        lda #$01
        sta $1F13
        sta $1F14
        sta $1F15
        sta $1F16
        sta $1F17
        sta $1F18
        sta $1F19
        sta $0BB6
        jsl $849F85
        rts

    .increment_weapon
        lda !current_hp
        and #$7F
        beq ..not_frozen
        lda !weapon_refill_timer
        dec 
        sta !weapon_refill_timer
        bne ..not_yet
        lda #$04
        sta !weapon_refill_timer
        ldy $0BDB
        rep #$21
        lda !weapons-$03,y
        and #$3FFF
        adc #$0100
        cmp #$1C00
        bcc ..not_max
        lda !weapon_refill_amount
        and #$00FF
        dec 
        beq ..done
        sta !weapon_refill_amount
        jsr .refill_other_weapons
    ..done
        sep #$20
        lda #$06 
        sta !weapon_refill_state
        rep #$20
        lda #$1C00
    ..not_max
        ora #$C000
        sta !weapons-$03,y
        sep #$20
        lda #$0C
        jsl play_sfx
        lda !weapon_refill_amount
        dec 
        sta !weapon_refill_amount
        bne ..not_yet
    ..not_frozen
        lda #$06
        sta !weapon_refill_state
    ..not_yet
        rts

    .end
        stz $1F13
        stz $1F14
        stz $1F15
        stz $1F16
        stz $1F17
        stz $1F18
        stz $1F19
        lda #$00
        sta !weapon_refill_state
        sta !receiving_item
        jsl $849FAD
        rts

    .refill_other_weapons
        php 
        rep #$20
        stz $0002
        lda !weapon_refill_amount
        and #$00FF
        xba 
        sta $0000
        ldx #$02
    ..loop
        lda !weapons-$03,x
        bit #$4000
        beq ..next
        and #$3FFF
        cmp #$1C00
        bcs ..next
        adc $0000
        cmp #$1C00
        bcc ..refill_next
        sbc #$1C00
        sta $0000
        beq ..full
        inc $0002
    ..full
        lda #$1C00
    ..finish_weapon
        ora #$C000
        sta !weapons-$03,x
        lda #$0016 
        jsl play_sfx
        lda $0002
        beq ..end
    ..next
        inx #2
        cpx #$12
        bne ..loop
    ..end 
        plp 
        rts 
    ..refill_next
        stz $0002
        bra ..finish_weapon

;##########################################################

give_1up:
        lda !give_1up
        beq .already_full
        dec 
        sta !give_1up
        lda #$00
        sta !receiving_item
        lda !lives
        cmp #$09
        bcs .already_full
    .give
        inc !lives
        lda #$28
        jsl play_sfx
    .already_full
        rts

;##########################################################

fix_softlock:
        lda !hp_tank_state
        ora !hp_refill_state
        ora !give_1up
        bne .nope
        lda #$00
        sta !receiving_item
    .nope
        rts 

;##########################################################

playback_sfx:
        lda !play_sfx_flag
        beq .return
        lda !play_sfx_num
        jsl play_sfx
        lda #$00
        sta !play_sfx_flag
    .return
        rts 

;##########################################################

!map_mode = $1E4B

draw_stage_select:
    .game 
        jsr count_total_medals

        lda !selected_level
        beq ..nope
        cmp #$0A
        bcs ..nope
        dec 
        asl
        tax  
        jsr (..ptrs,x)
        rts 
    ..nope
    ..clear_tilemaps
        ldx #$00
        rep #$20
        lda #$2020
    ...loop
        sta !top_text_tilemap,x
        sta !bottom_text_tilemap,x
        inx #2
        cpx #$40
        bne ...loop
        sep #$20
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
        phx 
        jsr ..clear_tilemaps
        plx 
        lda !levels_completed,x
        and #$40
        ;beq ...skip
        lda !upgrades
        and #$01
        beq ...skip
        lda $00AB
        and #$30
        beq ...no_change_checkpoint
        lda !current_checkpoint
        and #$7F
        inc 
        sta !current_checkpoint
        lda #$2C
        jsl play_sfx
    ...no_change_checkpoint
        lda !current_checkpoint
        cmp #$03
        bcc ...no_fix
        lda #$00
        sta !current_checkpoint
    ...no_fix
        jsr ..process_checkpoints
    ...skip
        rts 

    ..sigma
        jsr ..clear_tilemaps

        lda $00AC
        and #$20
        beq ...no_change
        lda #$2C
        jsl play_sfx
        inc $1F7B
        lda $1F7B
        cmp !fortress_backup
        bcc ...no_change
        stz $1F7B
    ...no_change

        ldx $1F7B
        lda.l ...completed_level_ids,x
        tax 
        lda !bosses_defeated,x
        ;beq ...skip_checkpoints
        lda !upgrades
        and #$01
        beq ...skip_checkpoints
        lda $00AB
        and #$30
        beq ...no_change_checkpoint
        lda !current_checkpoint
        and #$7F
        inc 
        sta !current_checkpoint
        lda #$2C
        jsl play_sfx
    ...no_change_checkpoint
        lda !current_checkpoint
        ldy $1F7B
        beq ...level_1
        cpy #$01
        beq ...level_2
        cpy #$02
        beq ...level_3
    ...level_4
        bra ...force
    ...level_1
        cmp #$05
        bcc ...no_fix
        bra ...force
    ...level_2
        cmp #$04
        bcc ...no_fix
        bra ...force
    ...level_3
        cmp #$06
        bcc ...no_fix
    ...force
        lda #$00
        sta !current_checkpoint
    ...no_fix
        jsr ..process_checkpoints
    ...skip_checkpoints

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
        lda $1F7B
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

    ...completed_level_ids
        db $08,$0D,$1E,$1F


    ..process_checkpoints
        lda !upgrades
        and #$01
        beq ...skip
        phb 
        phk 
        plb 
        rep #$20
        ldy #$00
        ldx #$14
    ...loop_text
        lda.w ...text,y
        cmp #$FFFF
        beq ...done_text
        sta !top_text_tilemap,x
        inx #2
        iny #2
        bra ...loop_text
    ...done_text
        inx #2
        lda !current_checkpoint
        and #$007F
        asl 
        tay 
        lda.w ...progress,y
        sta !top_text_tilemap,x
        sep #$20
        plb 
    ...skip
        rts 

    ...text
        dw $3443,$3468,$3465,$3463,$346B,$3470,$346F,$3469,$346E,$3474
        dw $FFFF

    ...progress
        dw $3431,$3432,$3433,$3434,$3435,$3436,$3437,$3438
        dw $3439,$343A,$343B,$343C,$343D,$343E,$343F,$3430



;############################

    .nmi
        lda !selected_level
        beq ..nope
        cmp #$0A
        bcs ..nope
        dec 
        asl 
        tax 
        jsr (..ptrs,x)
        jsr ..texts
    ..nope
        rts 

    ..texts
        ldy #$80
        sty $2115
        rep #$20
        lda #$1801
        sta $4300
        ldy #$7F
        sty $4304

        lda #$0820
        sta $2116
        lda.w #!top_text_tilemap
        sta $4302
        lda #$0040
        sta $4305
        ldy #$01
        sty $420B

        lda #$0B40
        sta $2116
        lda #$0040
        sta $4305
        ldy #$01
        sty $420B

        sep #$20
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
    ..sigma
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

calculate_fortress_access:
        lda !bosses_defeated+$1E
        beq +
        lda !bosses_defeated+$0D
        beq + 
        lda !bosses_defeated+$08
        beq +
        lda #$04
        sta !fortress_backup
        rts
    +
        lda $1FAF
        cmp #$03
        bcc +
        lda #$02
        sta $1FAF
    +   
        lda.l setting_sigma_all_levels
        beq +
        lda #$03
        sta !fortress_backup
        rts
    +   

        lda !bosses_defeated+$0D
        beq +
        lda !bosses_defeated+$08
        beq +
        lda #$03
        sta !fortress_backup
        rts
    +
        lda !bosses_defeated+$08
        beq +
        lda #$02
        sta !fortress_backup
    +   
        rts

pushpc
    org $808188
        jsl nmi_code
        nop #2
pullpc

nmi_code:
        lda $00D1
        beq .original_code
        lda $00D2
        bne .original_code
        jsr draw_stage_select_nmi
        jsl hack_portraits
    .original_code
        lda $0B9D
        ora $0BA0
        rtl
