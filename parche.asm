!current_hp = $0BCF
!max_hp = $1F9A
!lives = $1F80
!weapons = $1F88
!exit = $1F98
!heart_tanks = $1F9C
!sub_tanks = $1F83
!upgrades = $1F99

!level_id = $1F7A

!selected_level = $1E65
!checkpoint = $1F81
;0BBC
!paused_game = $1F24
!fortress_progress = $1F7B

; $1F1D = id of shot that just hit
; $1F7F goal
; Intro level cleared = $1F9B
!completed_intro_level = $1F9B

!ram = $7FEE00

!recv_index = !ram+$00
!sigma_access = !ram+$02
!play_sfx_flag = !ram+$03
!play_sfx_num = !ram+$04
!heart_tank_collected = !ram+$05
!upgrades_collected = !ram+$06
!hadouken_collected = !ram+$07
!victory = !ram+$08
!energy_link_send_packet = !ram+$09

!receiving_item = !ram+$15

!hp_tank_state = !ram+$0B
!hp_tank_timer = !ram+$0C
!hp_tank_counter = !ram+$0D
!hp_tank_timer_2 = !ram+$0E

!hp_refill_state = !ram+$0F
!hp_refill_amount = !ram+$10
!hp_refill_timer = !ram+$11

!give_1up = !ram+$12

!validation_check = !ram+$13

!unlocked_charge = !ram+$16

!medal_count = !ram+$17
!fortress_backup = !ram+$18
!current_checkpoint = !ram+$19

!weapon_refill_state = !ram+$1A
!weapon_refill_amount = !ram+$1B
!weapon_refill_timer = !ram+$1C

!msu_fade_flags = !ram+$1D
!msu_fade_volume = !ram+$1E
!msu_skip_msu = !ram+$1F
!msu_original_song = !ram+$20
!msu_fade_limit = !ram+$21

!unlocked_air_dash = !ram+$22

!msu_song_backup = !ram+$23

!energy_link_amount = !ram+$0100
!level_timer_fractions = !ram+$0102
!level_timer_seconds = !ram+$0103
!level_timer_minutes = !ram+$0104
!global_timer_fractions = !ram+$0106
!global_timer_seconds = !ram+$0107
!global_timer_minutes = !ram+$0108

!total_deaths =  !ram+$010A
!total_damage_dealt =  !ram+$010C
!total_damage_taken =  !ram+$010E

!refill_request =  !ram+$0110
!refill_target =  !ram+$0111
!arsenal_sync =  !ram+$0112
!max_hp_recorded = !ram+$0114
!selected_level_backup = !ram+$0115
!refill_timer = !ram+$0116

!checkpoints_reached = !ram+$0120

!entity_ram = !ram+$30

!levels_unlocked = !ram+$40
!levels_completed = !ram+$60
!bosses_defeated = !ram+$80
!pickup_array = !ram+$C0
!map_portraits_array = !ram+$E0

!weakness_table_ram = $7FEC00

!top_text_tilemap = $7FED80
!bottom_text_tilemap = $7FEDC0
;80C7D0

!msu_status = $2000
!msu_music_id = $2002
!msu_audio_track = $2004
!msu_audio_volume = $2006
!msu_audio_flags = $2007
!msu_status_data_busy = $80
!msu_status_audio_busy = $40
!msu_status_audio_repeat = $20
!msu_status_audio_playing = $10
!msu_status_track_missing = $08
!msu_status_revision = $07
!msu_audio_volume_max = $FF
!msu_audio_volume_drop = $60
!msu_audio_volume_delta = $02

!completed_launch_octopus = !levels_completed+$00
!completed_sting_chameleon = !levels_completed+$02
!completed_armored_armadillo = !levels_completed+$04
!completed_flame_mammoth = !levels_completed+$06
!completed_storm_eagle = !levels_completed+$08
!completed_spark_mandrill = !levels_completed+$0A
!completed_boomer_kuwanger = !levels_completed+$0C
!completed_chill_penguin = !levels_completed+$0E

!control_array = $7EFFC0
!control_shot = !control_array+$00
!control_jump = !control_array+$01
!control_dash = !control_array+$02
!control_select_l = !control_array+$03
!control_select_r = !control_array+$04
!control_menu = !control_array+$05

!mirror_brightness = $00B3

setting_sigma_configuration = $ACFC20
setting_sigma_medal_count = $ACFC21
setting_sigma_weapon_count = $ACFC22
setting_sigma_armor_count = $ACFC23
setting_sigma_heart_tank_count = $ACFC24
setting_sigma_sub_tank_count = $ACFC25
setting_starting_lives = $ACFC26
setting_pickupsanity_configuration = $ACFC27
setting_energy_link_configuration = $ACFC28
setting_death_link_configuration = $ACFC29
setting_jammed_buster_configuration = $ACFC2A
setting_boss_weakness_rando = $ACFC2C
setting_starting_hp = $ACFC2D
setting_heart_tank_effectiveness = $ACFC2E
setting_sigma_all_levels = $ACFC2F
setting_boss_weakness_strictness = $ACFC30
setting_abilities = $ACFC31

play_sfx = $8088CD
send_spc_command = $80887F

call_random = $849086

;# PPU systems

!palette_upload = $00A1
!indirect_dma_queue_index = $00A3
!direct_dma_queue_index = $00A4

org $000000

struct indirect_dma_queue $0500
        .vmain: skip 1
        .destination: skip 2
        .size: skip 2
        .source: skip 3
endstruct

struct direct_dma_queue $0600
        .vmain: skip 1
        .destination: skip 2
        .size: skip 1
        .data: 
endstruct

;# 2MiB ROM
org $00FFD7
    db $0C
org $BFFFFF
    db $FF

incsrc "remove_antitamper.asm"

org $808012
    jsl init_ram

org $8080A6
    jsl main_loop
    nop

;# Remove text boxes
;org $87CFEA
    ;sep #$30
    ;rts 

;# Permanent title screen
org $8092BD
    rts 

;# Disable demo level
org $80900C
    jmp $CC9E

;# Disable being given weapons on level end
org $80B00A
    nop #5

;# control sigma level unlock
org $80C184
    lda.l !sigma_access

;# darkens portraits
org $80C140
    jsl check_completed_levels
    nop 

;# Disables spec button
org $80C257
    jsl disable_spec_button

;# zero no longer gives an upgrade
org $88D7BE
    nop #2

;# Override checkpoints
org $80E6A4
    jsl load_different_checkpoint
    nop #1

;# shows the cutscene
org $80A007
    jsr check_completed_bosses_bank_80

;# Rewrite credits unlock
org $809C09
    jsr rewrite_credits_unlock
    beq $05

org $80C059
    jml check_boss_unlock

org $80932B
    load_map_from_title:
        stz $0BA9
        stz $0BAA
        stz $0BAB
        jsr load_map_extended
        jmp $94D9

    check_completed_bosses_bank_80:
        jsl check_completed_bosses
        rts 

    rewrite_credits_unlock:
        lda.l !sigma_access
        rts 

    warnpc $80934F

; Can exit stages at any time
org $80C957
    lda #$40
    rts 

;# Remove HP threshold from vile
org $83D71D
    nop #2
org $83EE8B
    nop #2


org $809DA8
    jsl new_starting_lives
    nop 
org $8094F9
    jsl new_starting_lives
    nop 

;org $80FBE3
org $80FEC0
    load_map_extended:
        ldx #$00
        jsr $8B90
        ldx #$01
        jsr $8B90
        jsr $891B
        jsr $DB55
        jsr $8BCB
        jsr $8A45
        stz $1F7A
        stz $1F7B
        stz $1F7C
        stz $1F7D
        stz $1F7E
        stz $1F7F
        lda #$04
        sta !completed_intro_level
        lda #$02
        sta $D1
        stz $D2
        lda #$01
        sta $D3
        stz $D4 
        lda.l setting_starting_lives
        sta !lives
        lda.l setting_starting_hp
        sta !max_hp
        stz $1F99
        stz $1F82
        stz $1F9C
        rep #$20
        stz $1F83
        stz $1F85
        sep #$20
        lda #$00
        sta !unlocked_air_dash
        sta !unlocked_charge
        lda #$40
        sta !exit
        ;jsl debug_start
        rts 

    msu_invoke_short:
        jsl msu_invoke_long
        rts
    
    start_pause_spc_command_short:
        jsl start_pause_spc_command
        rts 
    
    fix_ram_unlocks:
        stz $1F99
        lda #$00
        sta !unlocked_air_dash
        sta !unlocked_charge
        rts 

    print pc

org $8091DC
    jsr fix_ram_unlocks

org $AFE9A2
weakness_table:
    skip (23*16)


new_starting_lives:
    lda.l setting_starting_lives
    sta !lives
    rtl 

init_ram:
    sta $7EFFFF
    rep #$30
    ldx #$0FFE
    lda #$0000
.loop
    sta.l !ram,x
    dex #2
    bpl .loop
    sep #$10
    lda #$DEAD
    sta !validation_check
    lda #$1337
    sta !arsenal_sync
    sep #$20
    lda #$FF
    sta !sigma_access
    lda #$00
    sta.l !levels_unlocked+$09

    rep #$10
    ldx #$0000
..loop
    lda.l weakness_table,x
    sta !weakness_table_ram,x
    inx 
    cpx.w #23*16
    bne ..loop
    sep #$10

    rtl

check_completed_bosses:
        phb 
        pea $7F7F
        plb 
        plb 
        bit.w !levels_completed,x
        plb 
        rtl


check_completed_levels:
        lda.l !levels_completed,x
        and #$40
        rtl 

check_boss_unlock:
        pha 
        ldx !selected_level
        lda.l !levels_unlocked,x
        beq .locked_level
    .unlocked_level
        pla 
        sta $1F7A
        inc $01
        jml $80C05E
    .locked_level
        lda #$74
        jsl play_sfx
        pla 
        jml $80C064

;########################################################################################

pushpc
    org $80C08B
        jml check_boss_unlock_middle
pullpc

check_boss_unlock_middle:
        ldx !selected_level
        lda.l !levels_unlocked,x
        beq .locked_level
    .unlocked_level
        lda $03
        bne ..nop
        jml $80C08F
    ..nop
        jml $80C097
    .locked_level
        jml $80C064

disable_spec_button:
        cmp #$04
        bne +
        lda #$74
        jsl play_sfx
        lda #$00
    +   
        sta $03
        asl 
        tay 
        rtl 

;########################################################################################

pushpc
    org $80CC68
        jsl process_odd_hp_values
        nop
pullpc

process_odd_hp_values:
    stz $09
    lda !max_hp
    cmp #$02
    bcc .adjust
    bit #$01
    beq .even
    inc 
    rtl 
.adjust
    lda #$02
.even
    rtl 

;########################################################################################

pushpc
    org $81985F
        jsl block_charge
pullpc

block_charge:
        dec $57
        lda.l setting_jammed_buster_configuration
        beq .normal
        lda !unlocked_charge
        beq .block
    .normal
        lda $57
        rtl
    .block
        lda #$B5
        rtl

;########################################################################################

load_different_checkpoint:
        lda $00D1
        beq .use_original_ram
        lda !current_checkpoint
        bmi .already_loaded
        sta !checkpoint
        lda #$80
        sta !current_checkpoint
    .already_loaded
    .use_original_ram
        rep #$20
        lda !checkpoint
        rtl 

;########################################################################################

pushpc
    org $80DA24
        jml boss_hp_bar_init
    org $80DAE0
        jsl boss_hp_bar_adjust
        nop #2
pullpc

boss_hp_bar_init:
        ldx $1F0E
        bne .draw
        lda #$01
        sta !max_hp_recorded
        jml $80DA23
    .draw
        phy 
        ldy $1F0E
        lda $0027,y
        ply 
        and #$7F
        cmp !max_hp_recorded
        beq .skip
        bcc .skip
        sta !max_hp_recorded
    .skip
        jml $80DA29

boss_hp_bar_adjust:
        lda !max_hp_recorded
        sec 
        sbc $0027,y
        rtl 

incsrc "listeners.asm"
incsrc "locations.asm"
incsrc "abilities.asm"
incsrc "unlink.asm"
incsrc "msu.asm"
incsrc "weakness.asm"

debug_start:
        lda #$FF
        sta !upgrades
        lda #$FF
        sta !heart_tanks
        lda #$30
        sta !max_hp
        lda #$01
        sta !unlocked_charge
        sta !unlocked_air_dash
        rep #$20
        lda #$FFFF
        sta !energy_link_send_packet
        ldx #$1E
    .loop
        sta !levels_unlocked+$00,x
        dex #2
        bpl .loop
        sep #$20
        lda #$00
        sta !sigma_access
        rtl 

org $AB8000
    incsrc "enemy_adjuster.asm"
    print pc

warnpc $ABAAE0


    
org $B08000
    incsrc "sincos.asm"

org $B18000
    incsrc "main_loop.asm"
    incsrc "map.asm"
    incsrc "password_menu.asm"
    incsrc "pause_menu.asm"

org $B28000
    password_menu_blank_tilemap:
            incbin "data/password_menu/tilemap.bin"
    pause_menu_blank_tilemap:
            incbin "data/pause_menu/tilemap.bin"

    db "how come I need ANOTHER random string somewhere in order to get the apworld working smh"
    db "ASDASDASDASDASDASDASDASDASDASDASD"

incsrc "text.asm"


;#########################################################################
