chill_penguin_config_bytes:
    ;dw $07FF
    skip 2
armored_armadillo_config_bytes:
    ;dw $2000
    skip 2
spark_mandrill_config_bytes:
    ;dw $001F
    skip 2

!entity_direction = $11
!entity_x_speed = $1A
!entity_y_speed = $1C
!entity_blocked = $2B
!entity_accel = $1E
!entity_x_pos = $05
!entity_y_pos = $08

;#########################################################################
;# Chill Penguin
;#
;# States:
;# $00 - Shoot Ice Blocks
;# $02 - Blizzard
;# $04 - Slide
;# $06 - Leap
;# $08 - Mist
;# 
;# Config:
;# bit 0 - "Random horizontal slide speed"
;# bit 1 - "Jumps when starting slide"
;# bit 2 - "Random ice block horizontal speed"
;# bit 3 - "Random ice block vertical speed"
;# bit 4 - "Shoot random amount of ice blocks"
;# bit 5 - "Ice block shooting rate enhancer #1"
;# bit 6 - "Ice block shooting rate enhancer #2"
;# bit 7 - "Ice block shooting rate enhancer #3"
;# bit 8 - "Random blizzard strength"
;# bit 9 - "Fast falls after jumping"
;# bit A - "Random mist range"
;# bit E - "Can't be stunned/set on fire with incoming damage"
;# bit F - "Can't be set on fire with weakness"

!chill_penguin_random_blizzard_strength = !entity_ram+$00
!chill_penguin_random_mist_speed = !entity_ram+$01

pushpc
    org $81C022
        ; state hardcode
        ;lda #$0a
        ;nop 
    org $81B8A9
        jml chill_penguin_slide
    org $81B8EB
        ; give slide gravity
        jsl chill_penguin_slide_gravity


    org $81B70A
        jsl chill_penguin_random_ice_block_count
    org $81BC0C
        jml chill_penguin_ice_block_no_gravity
    org $81BC72
        jsl chill_penguin_ice_block_no_gravity_add_vertical_speed
    org $81BC38
        jml chill_penguin_ice_block_with_gravity
    org $81B717
        jsl chill_penguin_faster_ice_block_shooting
    
    org $87F04F
        jml chill_penguin_blizzard_strength
    org $81B79D
        jsl chill_penguin_setup_blizzard_strength

    ;# Upwards gravity
    ;org $81B97F
    ;    jsl chill_penguin_jump_fall_gravity
    org $81B99E
        jsl chill_penguin_jump_fall_gravity


    org $81BA44
        jsl chill_penguin_setup_mist_speed
    org $81BCB8
        jml chill_penguin_mist_speed

    org $81B658
        jml chill_penguin_damage_routine
pullpc

chill_penguin_slide:
        phx 
        ldx #$00
        lda !entity_direction
        asl #2
        bcs .right
    .left
        inx #2
    .right
        rep #$20
        lda.l chill_penguin_config_bytes
        and #$0001
        bne .random_x_speed
        lda #$0600
        bra .static_x_speed
    .random_x_speed
        jsl call_random
        and #$03C0
        clc 
        adc #$0440
    .static_x_speed
        cpx #$00
        beq +
        eor #$FFFF
        inc 
    +
        sta !entity_x_speed

        lda.l chill_penguin_config_bytes
        and #$0002
        bne .can_jump_slide
        stz !entity_y_speed
        bra .end_slide
    .can_jump_slide
        jsl call_random
        and #$03FF
        lsr 
        bra .jump
        lda #$0000
        bra +
    .jump
        clc 
        adc #$02E0
    +   
        sta !entity_y_speed
    .end_slide
        plx 
        sep #$20
        lda #$04
        trb !entity_blocked
        jml $81B8BB

chill_penguin_slide_gravity:
        jsl $8491BE
        lda !entity_accel
        pha 
        lda #$2C
        sta !entity_accel
        jsl $8281E8
        pla 
        sta !entity_accel
        rep #$20
        lda !entity_y_speed
        sep #$20
        bpl .on_ground
        lda !entity_blocked
        and #$04
        beq .on_ground
        rep #$20
        stz !entity_y_speed
        sep #$20
    .on_ground
        rtl 

chill_penguin_ice_block_no_gravity:
        phx
        ldx #$00
        lda !entity_direction
        asl #2
        bcs .right
    .left
        inx #2
    .right
        rep #$20
        lda.l chill_penguin_config_bytes
        and #$0004
        bne .random_x_speed
        lda #$0400
        bra .static_x_speed
    .random_x_speed
        jsl call_random
        and #$03FF
        clc 
        adc #$02E0
    .static_x_speed
        cpx #$02
        bne +
        eor #$FFFF
        inc 
    +   
        sta !entity_x_speed
        lda.l chill_penguin_config_bytes
        and #$0008
        bne .can_move_vertically
        stz !entity_y_speed
        bra .end_ice_block
    .can_move_vertically
        jsl call_random
        and #$03FF
        sec 
        sbc #$0080
        sta !entity_y_speed
    .end_ice_block
        plx 
        jml $81BC1C

    .x_speed
        dw $0200,$FE00

chill_penguin_random_ice_block_count:
        lda.l chill_penguin_config_bytes
        and #$10
        beq .original
        jsl call_random
        and #$0F
        clc 
        adc #$02
        bra .store
    .original
        lda #$04
    .store
        sta $36
        rtl 

chill_penguin_ice_block_no_gravity_add_vertical_speed:
        jsl $82823E
        lda !entity_blocked
        and #$04
        beq .not_on_ground
        rep #$20
        stz !entity_y_speed
        sep #$20
    .not_on_ground
        jsl $82825D
        rtl 


chill_penguin_ice_block_with_gravity:
        phx
        ldx #$00
        lda !entity_direction
        asl #2
        bcs .right
    .left
        inx #2
    .right
        rep #$20
        lda.l chill_penguin_config_bytes
        and #$0004
        bne .random_x_speed
        lda #$0200
        bra .static_x_speed
    .random_x_speed
        jsl call_random
        and #$03FF
        clc 
        adc #$01A0
    .static_x_speed
        cpx #$02
        bne +
        eor #$FFFF
        inc 
    +   
        sta !entity_x_speed
        lda.l chill_penguin_config_bytes
        and #$0008
        bne .can_move_vertically
        lda #$0221
        bra .end_ice_block
    .can_move_vertically
        jsl call_random
        and #$07FF
        clc  
        adc #$01E0
        sta !entity_y_speed
    .end_ice_block
        plx 
        jml $81BC4B

chill_penguin_faster_ice_block_shooting:
        lda.l chill_penguin_config_bytes
        and #$20
        beq +
        jsl $848EEA
    +   
        lda.l chill_penguin_config_bytes
        and #$40
        beq +
        jsl $848EEA
    +   
        lda.l chill_penguin_config_bytes
        and #$80
        beq +
        jsl $848EEA
    +   
        jml $848EEA


chill_penguin_blizzard_strength:
        phx
        ldx #$00
        lda !entity_direction
        asl #2
        bcs .right
    .left
        inx #2
    .right
        rep #$20
        lda.l chill_penguin_config_bytes
        and #$0100
        bne .random_x_speed
        lda #$0002
        bra .static_x_speed
    .random_x_speed
        lda !chill_penguin_random_blizzard_strength
        and #$00FF
    .static_x_speed
        cpx #$02
        bne +
        eor #$FFFF
        inc 
    +   
        clc 
        adc $0BAD
        sta $0BAD
        plx 
        jml $87F064

chill_penguin_setup_blizzard_strength:
        lda #$02
        sta $03
        jsl call_random
        and #$03
        inc 
        sta !chill_penguin_random_blizzard_strength
        rtl 

chill_penguin_jump_fall_gravity:  
        lda.l chill_penguin_config_bytes+$01
        and #$02
        beq +
        jsl $8281E8
    +   
        jml $8281E8
;81BA71 <- creates ice penguins

chill_penguin_mist_speed:
        phx
        ldx #$00
        lda !entity_direction
        asl #2
        bcs .right
    .left
        inx #2
    .right
        rep #$20
        lda.l chill_penguin_config_bytes
        and #$0400
        bne .random_x_speed
        lda #$0002
        bra .static_x_speed
    .random_x_speed
        lda !chill_penguin_random_mist_speed
    .static_x_speed
        cpx #$02
        bne +
        eor #$FFFF
        inc 
    +   
        plx 
        jml $81BCC6

chill_penguin_setup_mist_speed:
        rep #$20
        jsl call_random
        and #$03FF
        clc 
        adc #$01C0
        sta !chill_penguin_random_mist_speed
        sep #$20
        jsl $848EEA
        rtl 

chill_penguin_damage_routine:
        jsl call_damage_routine
        beq .no_incoming_dmg
        lda $35
        bne .iframes
        lda #$46
        sta $35
        lda.l chill_penguin_config_bytes+$01
        and #$40
        bne .damage_normal
        lda $38
        beq .cant_stun
        lda #$40
        trb $11
        lda $1F1B
        tsb $11
        lda #$0A
        sta $02
        stz $03
    .cant_stun
    .check_on_fire
        lda.l chill_penguin_config_bytes+$01
        and #$80
        bne .damage_normal
        ldx #$00
        lda $1F1D
    .loop
        cmp.l weakness_table+$0018,x
        beq .damage_trigger_burn
        inx 
        cpx #$08
        bne .loop
    .damage_normal
        jml $81B694
    .damage_trigger_burn
        jml $81B684
    .iframes
    .no_incoming_dmg
        jml $81B6BA



;#########################################################################
;# Armored Armadillo
;#
;# States:
;# $00 - Bouncing
;# $02 - Energy Blasts
;# $04 - Idle
;# $06 - Energy Release
;# $08 - Stun
;# 
;# Config:
;# bit 0 - "Random bouncing speed"
;# bit 1 - "Random bouncing angle"
;# bit 2 - "Random energy horizontal speed"
;# bit 3 - "Random energy vertical speed"
;# bit 4 - "Energy shooting rate enhancer #1"
;# bit 5 - "Energy shooting rate enhancer #2"
;# bit C - "Don't absorb any projectile"
;# bit D - "Absorbs any projectile except weakness"
;# bit E - "Don't flinch from incoming damage without armor"
;# bit F - "Can't block incoming projectiles"

!armored_armadillo_bounce_speed = !entity_ram+$00
!armored_armadillo_bounce_angle = !entity_ram+$02
!armored_armadillo_energy_x_speed = !entity_ram+$04
!armored_armadillo_energy_y_speed = !entity_ram+$06

pushpc
    org $83B411
        jsl armored_armadillo_setup_bounce
    org $83B47E
        jml armored_armadillo_ground_rolling_initial_speed
    org $83B4E2
        jml armored_armadillo_bouncing_initial_speed

    
    org $83B6BE
        jsl armored_armadillo_faster_shooting
    org $83B98E
        jml armored_armadillo_faster_energy
    org $83B6E3
        jml armored_armadillo_setup_energy

    org $83B32A
        jml armored_armadillo_incoming_damage
    org $83B617
        jml armored_armadillo_incoming_projectiles
    org $83B746
        jml armored_armadillo_incoming_projectiles_secondary_routine
pullpc

armored_armadillo_setup_bounce:
        lda.l armored_armadillo_config_bytes
        and #$02
        bne .random_angle
        lda #$08
        bra .store_angle
    .random_angle
        jsl call_random
        and #$0F
        clc 
        adc #$01
    .store_angle
        sta !armored_armadillo_bounce_angle
        rep #$20
        lda.l armored_armadillo_config_bytes
        and #$0001
        bne .random_speed
        lda #$0600
        bra .store_speed
    .random_speed
        jsl call_random
        and #$03FF
        clc 
        adc #$0340
    .store_speed
        sta !armored_armadillo_bounce_speed
        sep #$20
        lda #$FF
        sta $2F
        rtl 

armored_armadillo_bouncing_initial_speed:
        phx 
        lda #$00
        xba 
        lda !armored_armadillo_bounce_angle
        asl 
        tax 
        lda.l sincos,x
        sta $211B
        lda.l sincos+$01,x
        sta $211B
        rep #$20
        lda !armored_armadillo_bounce_speed
        lsr #4
        sep #$20
        sta $211C
        rep #$20
        lda $2134
        lsr #4
        pha 
        lda $2135
        lsr #4
        and #$00F0
        xba 
        ora $01,s
        plx 
        plx 
        sta !entity_y_speed
        sep #$20

        lda !armored_armadillo_bounce_angle
        asl 
        tax 
        lda.l sincos+$20,x
        sta $211B
        lda.l sincos+$21,x
        sta $211B
        rep #$20
        lda !armored_armadillo_bounce_speed
        lsr #4
        sep #$20
        sta $211C
        rep #$20
        lda $2134
        lsr #4
        pha 
        lda $2135
        lsr #4
        and #$00F0
        xba 
        ora $01,s
        plx 
        plx 
        ldx !entity_x_speed+$01
        bmi +
        eor #$FFFF
        inc 
    +   
        sta !entity_x_speed
        plx 
        jml $83B4F7

armored_armadillo_ground_rolling_initial_speed:
        phx
        ldx #$00
        lda !entity_direction
        asl #2
        bcs .right
    .left
        inx #2
    .right
        rep #$20
        lda !armored_armadillo_bounce_speed
        cpx #$00
        beq +
        eor #$FFFF
        inc 
    +   
        sta !entity_x_speed
        stz !entity_y_speed
        plx 
        jml $83B490

armored_armadillo_faster_shooting:
        lda.l armored_armadillo_config_bytes
        and #$10
        beq +
        jsl $848EEA
    +   
        lda.l armored_armadillo_config_bytes
        and #$20
        beq +
        jsl $848EEA
    +   
        jml $848EEA

armored_armadillo_faster_energy:
        phx
        ldx #$00
        lda !entity_direction
        asl #2
        bcs .right
    .left
        inx #2
    .right
        rep #$20
        lda.l armored_armadillo_config_bytes
        and #$0004
        bne .random_x_speed
        lda #$0300
        bra .static_x_speed
    .random_x_speed
        lda !armored_armadillo_energy_x_speed
    .static_x_speed
        cpx #$02
        bne +
        eor #$FFFF
        inc 
    +   
        sta !entity_x_speed
        lda.l armored_armadillo_config_bytes
        and #$0008
        bne .random_y_speed
        lda #$0000
        bra .static_y_speed
    .random_y_speed
        lda !armored_armadillo_energy_y_speed
    .static_y_speed
        sta !entity_y_speed
        plx 
        jml $83B9A0

armored_armadillo_setup_energy:
        rep #$20
        jsl call_random
        and #$03FF
        clc 
        adc #$0100
        sta !armored_armadillo_energy_x_speed
        jsl call_random
        and #$01FF
        sec 
        sbc #$0080
        sta !armored_armadillo_energy_y_speed
        sep #$20
        lda $11
        and #$40
        jml $83B6E7

armored_armadillo_incoming_projectiles:
        lda.l armored_armadillo_config_bytes+$01
        and #$80
        bne .dont_block
        lda #$04
        sta $03
        jml $83B61B
    .dont_block
        jml $83B628
    
    .secondary_routine
        lda.l armored_armadillo_config_bytes+$01
        and #$80
        bne ..dont_block
        lda #$02
        sta $02
        jml $83B74A
    ..dont_block
        jml $83B75B



call_damage_routine = $849B43

armored_armadillo_incoming_damage:
        jsl call_damage_routine
        bvs .no_damage
        jmp .dealt_damage
    .no_damage
        lda $3C
        clc 
        adc #$02
        sta $3C
        lda #$01
        sta $3B
        lda $37
        lsr 
        bcs .is_blocking
        jmp .return
    .is_blocking
        lda.l armored_armadillo_config_bytes+$01
        and #$10
        bne .dont_absorb
        lda.l armored_armadillo_config_bytes+$01
        and #$20
        bne .may_absorb
        lda $1F1D
        cmp #$02
        beq .may_absorb
        cmp #$03
        beq .may_absorb
        cmp #$01
        bne .dont_absorb
    .may_absorb
        ldx #$00
        lda $1F1D
    ..loop
        cmp.l weakness_table+$0028,x
        beq .continue
        inx 
        cpx #$08
        bne ..loop
    .perform_absorb
        lda #$06
        sta $02
        stz $03
        jmp .return
    .dealt_damage
        bne .continue
    .return
        jml $83B3C7
    .dont_absorb
    .continue
        lda $38
        beq .not_iframes
        lda $39
        sta $27
        bra .return
    .not_iframes
        lda #$3C
        sta $38
        lda $02
        bne .can_stun
        lda $03
        cmp #$0C
        bcc .damage_without_stun
    .can_stun
        lda.l armored_armadillo_config_bytes+$01
        and #$40
        bne .damage_without_stun_checks
    .damage_and_lose_armor
        lda #$08
        sta $02
        stz $03
        lda #$40
        trb $11
        lda $1F1B
        tsb $11
        lda $33
        bne .damage_without_stun
        ldx #$00
        lda $1F1D
    .loop
        cmp.l weakness_table+$0028,x
        beq .damage_lose_armor
        inx 
        cpx #$08
        bne .loop
        bra .damage_without_stun
    .damage_lose_armor
        lda #$02
        sta $03
        lda #$B4
        sta $38
    .damage_without_stun
        jml $83B39A
    
    .damage_without_stun_checks
        lda $33
        beq .damage_and_lose_armor
        bra .damage_without_stun

        

;#########################################################################
;# Spark Mandrill
;#
;# States (Ptrs: 889E2C):
;# $00 - Electric Spark
;# $02 - Clinging
;# $04 - Dash Punch
;# $06 - Leap
;# $08 - ?
;# $0A - Frozen
;# 
;# Config:
;# bit 0 - "Random Electric Spark speed"
;# bit 1 - "Additional Electric Spark #1"
;# bit 2 - "Additional Electric Spark #2"
;# bit 3 - "Landing creates Electric Spark"
;# bit 4 - "Hitting a wall creates Electric Spark"
;# bit E - "Can't be stunned during Dash Punch with weakness"
;# bit F - "Can't be frozen with weakness"

!spark_madrill_electric_spark_count = !entity_ram+$00

pushpc
    org $889F00
        jml spark_mandrill_multiple_electric_spark
    org $889E45
        jsl spark_mandrill_setup_multiple_electric_spark
    org $88806D
            lda $3C
            ldx $0B
            bne +
            eor #$FFFF
            inc 
        +   
    org $8880E8
            lda $3C
            bcc +
            eor #$FFFF
            inc 
        +   
        warnpc $8880F0
    org $8880BA
            lda $3C
            bcs +
            eor #$FFFF
            inc 
        +   
        warnpc $8880C2
    org $889EC4
        jsl spark_mandrill_setup_electric_spark_speed
    org $889EEF
        jsl spark_mandrill_setup_electric_spark_speed

    org $88A02D
        jml spark_mandrill_clinging_create_electric_spark
    org $88A1DF
        jml spark_mandrill_leaping_create_electric_spark

    org $88A0FB
        jsl spark_mandrill_hitting_wall_create_electric_spark

    org $888096
        jml spark_mandrill_electric_spark_go_vertical

    org $889DD7
        jml spark_mandrill_stun_handling
pullpc

spark_mandrill_setup_multiple_electric_spark:
        lda #$02
        sta $03
        lda #$00
        sta !spark_madrill_electric_spark_count
        rtl 

spark_mandrill_multiple_electric_spark:
        phx 
        ldx #$01
        lda.l spark_mandrill_config_bytes
        and #$02
        beq +
        inx 
    +   
        lda.l spark_mandrill_config_bytes
        and #$04
        beq +
        inx 
    +   
        stx $0000
        plx 
        lda !spark_madrill_electric_spark_count
        inc 
        sta !spark_madrill_electric_spark_count
        cmp $0000
        bcs .done
        lda #$02
        sta $03
        jml $889E49
    .done
        lda #$06
        sta $03
        jml $889F04

spark_mandrill_setup_electric_spark_speed:
        tdc 
        sta $000C,x
        lda #$0000
        sta $003E,x
        lda.l spark_mandrill_config_bytes
        and #$0001
        bne .random
        lda #$0400
        sta $003C,x
        rtl 
    .random
        jsl call_random
        and #$03FF
        clc 
        adc #$01E0
        sta $003C,x
        rtl 

spark_mandrill_clinging_create_electric_spark:
        jsl $84A333
        lda.l spark_mandrill_config_bytes
        and #$08
        beq .return
        lda #$00
        sta $02
        lda #$02
        sta $03
        lda #$03
        sta !spark_madrill_electric_spark_count
        jml $889E49
    .return
        jml $88A031

spark_mandrill_leaping_create_electric_spark:
        jsl $84A333
        lda.l spark_mandrill_config_bytes
        and #$08
        beq .return
        lda #$00
        sta $02
        lda #$02
        sta $03
        lda #$03
        sta !spark_madrill_electric_spark_count
        jml $889E49
    .return
        jml $88A031

call_search_projectile_slot = $828358

spark_mandrill_hitting_wall_create_electric_spark:
        jsl $84A311
        lda.l spark_mandrill_config_bytes
        and #$10
        bne .spawn
        rtl 
    .spawn
        lda #$4D
        jsl play_sfx
        lda !entity_direction
        asl #2
        rep #$20
        lda #$002A
        bcs +
        lda #$FFD6
    +   
        clc 
        adc !entity_x_pos
        sta $0000
        lda !entity_y_pos
        clc 
        adc #$0006
        sta $0002
        jsl call_search_projectile_slot
        bne .not_found
        jsr .shared
        stz $000B,x

        lda #$44
        jsl play_sfx

        jsl call_search_projectile_slot
        bne .not_found
        jsr .shared
        lda #$01
        sta $000B,x

    .not_found
        sep #$30
        rtl 

    .shared
        inc $0000,x
        lda #$28
        sta $000A,x
        rep #$20
        lda $0000
        sta $0005,x
        lda $0002
        sta $0008,x
        jsl spark_mandrill_setup_electric_spark_speed
        sep #$20
        inc $003F,x
        rts 

spark_mandrill_electric_spark_go_vertical:
        lda $3F
        beq +
        lda #$04
        sta $01
        stz $29
        lda #$08
        sta $2A
        jsl $8490A0
        rep #$20
        lda $1A
        sta $1C
        stz $1A
        sep #$20
    +   
        jml $8280B4

spark_mandrill_stun_handling:
        lda.l spark_mandrill_config_bytes+$01
        and #$40
        bne .check_frozen
        lda $02
        cmp #$04
        bne .check_frozen
        lda $03
        cmp #$02
        bne .check_frozen
    .check_stun
        ldx #$00
        lda $1F1D
    ..loop
        cmp.l weakness_table+$0020,x
        beq ..stun
        inx 
        cpx #$08
        bne ..loop
        jml $889E11
    ..stun
        jml $889DF2

    .check_frozen
        lda.l spark_mandrill_config_bytes+$01
        and #$80
        bne ..return
        ldx #$00
        lda $1F1D
    ..loop
        cmp.l weakness_table+$0020,x
        beq ..frozen
        inx 
        cpx #$08
        bne ..loop
    ..return
        jml $889E11
    ..frozen
        jml $889E05