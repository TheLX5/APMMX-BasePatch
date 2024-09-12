main_loop:
        jsr msu_fade_update
        lda $00D1
        beq .reset
        cmp #$02
        bne .return
    .playable
        jsl clock_global_timer
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
        sta !level_timer_fractions
        sta !level_timer_seconds
        sta !level_timer_minutes
        sta !global_timer_fractions
        sta !global_timer_seconds
        sta !global_timer_minutes
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
        lda !selected_level
        beq +
        sta !selected_level_backup
    +   
        lda !current_checkpoint
        and #$7F
        sta !current_checkpoint
        lda #$00
        sta !receiving_item
        sta !level_timer_fractions
        sta !level_timer_seconds
        sta !level_timer_minutes
        jsr playback_sfx
        jsr calculate_fortress_access
        jsr draw_stage_select
        jsr sync_medals
        rts 


;########################################################################################

level:
        jsr clock_level_timer
        jsr unlock_sigma_fortress
        jsr track_checkpoints
        lda !mirror_brightness
        cmp #$0F
        bne .screen_is_off
        jsr handle_heart_tank_upgrade
        jsr handle_hp_refill
        jsr handle_weapon_refill
        jsr give_1up
    .screen_is_off
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
        lda.l setting_jammed_buster_configuration
        beq +
        lda !unlocked_charge
        beq +
        iny 
    +   
        lda.l setting_abilities
        and #$02
        beq +
        lda !unlocked_air_dash
        beq +
        iny 
    +   
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
        
    .waiting
        rts

    .init
        lda !paused_game
        beq ..regular_gameplay
        lda $1ED2
        beq ..regular_gameplay
        cmp #$09
        bcc ..pause_weapon
    ..regular_gameplay
        ldy $0BDB
        bne ..valid_weapon
    ..no_weapon
        jsr .refill_other_weapons
        lda #$06
        sta !weapon_refill_state
        rts 
    ..pause_weapon
        asl 
        tay 
    ..valid_weapon
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
        lda !paused_game
        beq ..regular_gameplay
        lda $1ED2
        beq ..regular_gameplay
        cmp #$09
        bcc ..pause_weapon
    ..regular_gameplay
        ldy $0BDB
        bra ..valid_weapon
    ..pause_weapon
        asl 
        tay 
    ..valid_weapon
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
        lda #$000D 
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
        cmp.b #99
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

track_checkpoints:
        lda !selected_level_backup
        cmp #$09
        bne .normal_stage
        clc 
        adc !fortress_progress
    .normal_stage
        tax 
        lda !checkpoint
        and #$7F
        cmp !checkpoints_reached,x
        bcc .skip
        sta !checkpoints_reached,x
    .skip
        rts 

;##########################################################

clock_level_timer:
        lda !fortress_progress
        cmp #$04
        bcs .not_yet
        lda !level_timer_fractions
        inc 
        sta !level_timer_fractions
        cmp.b #60
        bcc .not_yet
        lda #$00
        sta !level_timer_fractions
        lda !level_timer_seconds
        inc 
        sta !level_timer_seconds
        cmp.b #60
        bcc .not_yet
        lda #$00
        sta !level_timer_seconds
        lda !level_timer_minutes
        inc 
        sta !level_timer_minutes
        cmp.b #99
        bcc .not_yet
        lda.b #99
        sta !level_timer_minutes
    .not_yet
        rts 

clock_global_timer:
        lda !fortress_progress
        cmp #$04
        bcs .copy
        lda !global_timer_fractions
        inc 
        sta !global_timer_fractions
        cmp.b #60
        bcc .not_yet
        lda #$00
        sta !global_timer_fractions
        lda !global_timer_seconds
        inc 
        sta !global_timer_seconds
        cmp.b #60
        bcc .not_yet
        lda #$00
        sta !global_timer_seconds
        rep #$20
        lda !global_timer_minutes
        inc 
        sta !global_timer_minutes
        cmp.w #999
        bcc .not_yet
        lda.w #999
        sta !global_timer_minutes
    .not_yet
        sep #$20
        rtl 
    .copy
        lda !global_timer_fractions
        sta !level_timer_fractions
        lda !global_timer_seconds
        sta !level_timer_seconds
        lda !global_timer_minutes
        sta !level_timer_minutes
        lda !global_timer_minutes+$01
        sta !level_timer_minutes+$01
        rtl 

sync_medals:
        ldx #$FF
    .armored_armadillo
        lda !bosses_defeated+$00
        beq +
        txa 
        sta !levels_completed+$04
    +   
    .chill_penguin
        lda !bosses_defeated+$01
        beq +
        txa 
        sta !levels_completed+$0E
    +   
    .spark_mandrill
        lda !bosses_defeated+$02
        beq +
        txa 
        sta !levels_completed+$0A
    +   
    .launch_octopus
        lda !bosses_defeated+$03
        beq +
        txa 
        sta !levels_completed+$00
    +   
    .boomer_kuwanger
        lda !bosses_defeated+$04
        beq +
        txa 
        sta !levels_completed+$0C
    +   
    .sting_chameleon
        lda !bosses_defeated+$05
        beq +
        txa 
        sta !levels_completed+$02
    +   
    .storm_eagle
        lda !bosses_defeated+$06
        beq +
        txa 
        sta !levels_completed+$08
    +   
    .flame_mammoth
        lda !bosses_defeated+$07
        beq +
        txa 
        sta !levels_completed+$06
    +   
        rts

;#############################################

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
        lda $1F7B
        cmp #$03
        bcc +
        lda #$02
        sta $1F7B
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

;#############################################

msu_fade_update:
        jsl msu_installed
        beq .nope

        lda !msu_fade_flags
        beq .nope
        cmp #$01
        beq .fade_out
        cmp #$02
        beq .fade_in
        cmp #$03 
        beq .fade_out_with_limit
    .nope
        rts 

    .fade_out
        lda !msu_fade_volume
        sec 
        sbc.b #!msu_audio_volume_delta
        bcs ..nope
        lda #$00
    ..nope
        sta !msu_fade_volume
        sta !msu_audio_volume
        bne ..not_done
        lda #$00
        sta !msu_audio_flags
        sta !msu_fade_flags
    ..not_done
        rts

    .fade_in
        lda !msu_fade_volume
        clc 
        adc.b #!msu_audio_volume_delta
        bcc +
        lda.b #!msu_audio_volume_max
    +   
        sta !msu_fade_volume
        sta !msu_audio_volume
        cmp #!msu_audio_volume_max
        bne ..not_done
        lda #$00
        sta !msu_fade_flags
    ..not_done
        rts 

    .fade_out_with_limit
        lda !msu_fade_volume
        sec 
        sbc.b #!msu_audio_volume_delta
        bcs ..nope
        lda !msu_fade_limit
    ..nope
        sta !msu_fade_volume
        sta !msu_audio_volume
        cmp !msu_fade_limit
        bcs ..not_done
        lda #$00
        sta !msu_fade_flags
    ..not_done
        rts