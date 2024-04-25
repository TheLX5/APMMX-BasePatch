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

!levels_unlocked = !ram+$40
!levels_completed = !ram+$60
!bosses_defeated = !ram+$80
!pickup_array = !ram+$C0
;80C7D0

!completed_launch_octopus = !levels_completed+$00
!completed_sting_chameleon = !levels_completed+$02
!completed_armored_armadillo = !levels_completed+$04
!completed_flame_mammoth = !levels_completed+$06
!completed_storm_eagle = !levels_completed+$08
!completed_spark_mandrill = !levels_completed+$0A
!completed_boomer_kuwanger = !levels_completed+$0C
!completed_chill_penguin = !levels_completed+$0E

setting_sigma_configuration = $AFFFE0
setting_sigma_medal_count = $AFFFE1
setting_sigma_weapon_count = $AFFFE2
setting_sigma_armor_count = $AFFFE3
setting_sigma_heart_tank_count = $AFFFE4
setting_sigma_sub_tank_count = $AFFFE5
setting_starting_lives = $AFFFE6
setting_pickupsanity_configuration = $AFFFE7
setting_energy_link_configuration = $AFFFE8
setting_death_link_configuration = $AFFFE9
setting_jammed_buster_configuration = $AFFFEA

org setting_sigma_configuration
    padbyte $FF : pad $AFFFFF

org $808012
    jsl init_ram

org $8080A6
    jsl main_loop
    nop


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

;# zero no longer gives an upgrade
org $88D7BE
    nop #2

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
        lda #$10
        sta !max_hp
        stz $1F99
        stz $1F82
        stz $1F9C
        rep #$20
        stz $1F83
        stz $1F85
        sep #$20
        lda #$40
        sta !exit
        rts 


org $AFEC00
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
    sep #$30
    rep #$20
    lda #$DEAD
    sta !validation_check
    sep #$20
    lda #$FF
    sta !sigma_access
    lda #$00
    sta.l !levels_unlocked+$09
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
        jsl $8088CD
        pla 
        jml $80C064

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

incsrc "main_loop.asm"
incsrc "listeners.asm"
incsrc "locations.asm"
incsrc "unlink.asm"

incsrc "remove_antitamper.asm"

incsrc "text.asm"


;#########################################################################
