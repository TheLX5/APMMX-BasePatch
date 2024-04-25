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
        lda #$00
        sta !receiving_item
        jsr playback_sfx
        rts 

;########################################################################################

level:
        jsr unlock_sigma_fortress
        jsr handle_heart_tank_upgrade
        jsr handle_hp_refill
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
        cmp #$20
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
        jsl $8088CD     ; sfx
        rts 
    
    .wait_for_anim
        lda !hp_tank_timer
        dec 
        sta !hp_tank_timer
        bne ..not_yet
        lda #$06
        sta !hp_tank_state
        lda #$02
        sta !hp_tank_counter
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
        cmp #$20
        bcc ..not_max
        lda #$08
        sta !hp_tank_state
        lda #$20
    ..not_max
        sta !max_hp
        inc !current_hp
        lda #$80
        tsb !current_hp
        lda #$0C
        jsl $8088CD     ; sfx
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
        jsl $8088CD
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
        jsl $8088CD
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
        jsl $8088CD     ; sfx
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
        jsl $8088CD
        lda #$00
        sta !hp_refill_state
    ..not_yet
        rts

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
        jsl $8088CD
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
        jsl $8088CD
        lda #$00
        sta !play_sfx_flag
    .return
        rts 

;##########################################################
