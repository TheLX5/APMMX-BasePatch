;#########################################################################

pushpc
    org $81E98D
        jsl check_heart_tank_collected
        nop 
    org $81EADA
        lda $0B
        sta.l !heart_tank_collected
        stz $1F3B
        lda #$29
        jsl $8088CD
        jml $828398
pullpc

check_heart_tank_collected:
    lda $0B
    and.l !heart_tank_collected
    rtl

;#########################################################################

pushpc
    org $87CABF
        jml check_capsule_collected
    org $87D0B2
        jml write_capsule_collected
    org $87FC44
        jsl check_body_capsule_collected
        nop 
pullpc

check_capsule_collected:
    and.l !upgrades_collected
    beq .available
    jml $87CAC4
.available
    jml $87CAC8

write_capsule_collected:
    ldx !level_id
    cpx #$03 
    beq .hadouken
    ora !upgrades_collected
    sta !upgrades_collected
    jml $87D0B8
.hadouken
    jml $87D0BD

check_body_capsule_collected:
    lda.l !upgrades_collected
    and #$04
    rtl 

;#########################################################################

pushpc
    org $87CA8D
        check_capsule_hadouken_collected:
            lda.l !hadouken_collected
            bmi .collected
            jml $87CAC8
    org $87CAC4
        .collected
    org $87D0D9
        jsl write_capsule_hadouken_collected
        rts 
pullpc 

write_capsule_hadouken_collected:
        lda #$80
        sta.l !hadouken_collected
        rtl 

;#########################################################################

pushpc
    org $81E4B7
        jsl check_sub_tank_collected
        nop 
    org $81E63A
        lda !upgrades_collected
        ora $0B
        sta !upgrades_collected
        jmp $E652
pullpc

check_sub_tank_collected:
        lda !upgrades_collected
        and $0B
        rtl 
        

;#########################################################################

pushpc
    org $82E4DB
        jsl pickupsanity_hp
        nop 
    org $81E032
        jsl pickupsanity_weapon
        nop 
    org $81E48F
        jsl pickupsanity_1up
        nop 
    
pullpc

pickupsanity:
    .hp
        lda $00D1
        beq ..skip
        jsr .generic
        jsr .add_el_packet
    ..skip
        lda !current_hp
        and #$7F
        rtl
    .weapon
        lda $00D1
        beq ..skip
        jsr .generic
        jsr .add_el_packet
    ..skip
        lda !current_hp
        and #$7F
        rtl
    .1up
        lda $00D1
        beq ..skip
        jsr .generic
        rep #$20
        lda !energy_link_send_packet
        clc 
        adc #$0060
        sta !energy_link_send_packet
        sep #$20
    ..skip
        lda.b #99
        cmp !lives
        rtl 
    
    .add_el_packet
        rep #$20
        lda $0B
        and #$007F
        bne ..small
    ..large
        lda !energy_link_send_packet
        clc 
        adc #$0010
        bra ..end
    ..small
        lda !energy_link_send_packet
        clc 
        adc #$0004
    ..end
        sta !energy_link_send_packet
        sep #$20
        rts 

    .generic
        lda $0B
        bmi .process
    .skip
        rts
    .process
        phx 
        phy
        phb 
        phk 
        plb 
        php 
        rep #$30
        lda !level_id
        and #$00FF
        asl 
        tax 
        lda.w pickups_ptrs,x
        pha 
        ldy #$0000
    .loop
        lda ($01,s),y
        cmp #$FFFF
        beq .end
        iny #2
        cmp $0C
        bne .next
        lda ($01,s),y
        tax 
        sep #$20
        lda #$01
        sta.l !pickup_array,x
        rep #$20
    .end
        pla 
        plp 
        plb 
        ply 
        plx 
        rts
    .next
        iny #2
        bra .loop
        
    
    pickups:
        .intro
            dw $FACF,$0000 ; Intro Stage - HP Pickup (after Bee Blader)
            dw $FAD4,$0001 ; Intro Stage - Small HP Pickup (after Bee Blader)
            dw $FFFF
        .launch_octopus
            dw $FABB,$0002 ; Launch Octopus Stage - HP Pickup (Crane platform above water)
            dw $FFFF
        .sting_chameleon
            dw $FAD4,$0003 ; Sting Chameleon Stage - 1up Pickup (Inside second mini-cave in mountain)
            dw $FB24,$0004 ; Sting Chameleon Stage - HP Pickup (On top of platform in the swamp)
            dw $FFFF
        .armored_armadillo
            dw $FB65,$0005 ; Armored Armadillo Stage - HP Pickup 1 (In blocked ceiling)
            dw $FB74,$0006 ; Armored Armadillo Stage - HP Pickup 2 (In blocked ceiling)
            dw $FC0F,$0007 ; Armored Armadillo Stage - HP Pickup 3 (Next to Hadouken capsule)
            dw $FFFF
        .flame_mammoth
            dw $FA43,$0008 ; Flame Mammoth Stage - HP Pickup 1 (After first conveyor belts section)
            dw $FA9D,$0009 ; Flame Mammoth Stage - HP Pickup 2 (Top platform in Dig Labour section)
            dw $FA7F,$000A ; Flame Mammoth Stage - 1up Pickup (Top platform in Dig Labour section)
            dw $FFFF
        .storm_eagle
            dw $FA9D,$000B ; Storm Eagle Stage - HP Pickup 1 (Behind first set of gas tanks)
            dw $FA98,$000C ; Storm Eagle Stage - HP Pickup 2 (Behind second set of gas tanks)
            dw $FA93,$000D ; Storm Eagle Stage - HP Pickup 3 (Behind third set of gas tanks)
            dw $FAA7,$001B ; Storm Eagle Stage - 1up Pickup 1 (Behind wall in third set of gas tanks)
            dw $FB33,$000E ; Storm Eagle Stage - 1up Pickup 2 (Behind fourth set of gas tanks)
            dw $FB3D,$000F ; Storm Eagle Stage - 1up Pickup 3 (Above helmet capsule)
            ;dw $FBFB,$0010 ; Storm Eagle Stage - HP Pickup 4 (Right of plane)
            ;dw $FC00,$0011 ; Storm Eagle Stage - Weapon Energy Pickup (Right of plane)
            dw $FFFF
        .spark_mandrill
            dw $FFFF
        .boomer_kuwanger
            dw $FFFF
        .chill_penguin
            dw $FB65,$0012 ; Chill Penguin Stage - Weapon Energy Pickup (Inside third dome)
            dw $FFFF
        .sigma_1
            dw $FFFF
        .sigma_2
            dw $FFFF
        .sigma_3
            dw $FA61,$0013 ; Sigma's Fortress 3 - HP Pickup 1 (Before Sting Chameleon rematch)
            dw $FA84,$0014 ; Sigma's Fortress 3 - Weapon Energy Pickup 1 (Before Spark Mandrill rematch)
            dw $FA8E,$0015 ; Sigma's Fortress 3 - HP Pickup 2 (Before Spark Mandrill rematch)
            dw $FAF2,$0016 ; Sigma's Fortress 3 - HP Pickup 3 (Before Launch Octopus rematch)
            dw $FAF7,$0017 ; Sigma's Fortress 3 - Weapon Energy Pickup 2 (Before Launch Octopus rematch)
            dw $FB42,$0018 ; Sigma's Fortress 3 - HP Pickup 4 (On spikes)
            dw $FB47,$0019 ; Sigma's Fortress 3 - Weapon Energy Pickup 3 (On Spikes)
            dw $FB56,$001A ; Sigma's Fortress 3 - 1up Pickup (On spikes)
            dw $FFFF
        .sigma_4
            dw $FFFF

    .ptrs:
        dw .intro
        dw .launch_octopus
        dw .sting_chameleon
        dw .armored_armadillo
        dw .flame_mammoth
        dw .storm_eagle
        dw .spark_mandrill
        dw .boomer_kuwanger
        dw .chill_penguin
        dw .sigma_1
        dw .sigma_2
        dw .sigma_3
        dw .sigma_4

;#########################################################################

pushpc
    org $84AA12
        jml maverick_medal

pullpc

maverick_medal:
        ora !levels_completed,x
        sta !levels_completed,x 
        jml $84AA18

pushpc
    org $84AADC
        jsl boss_appear_check
        nop
    org $80C95D
        jsl boss_appear_check
        nop
pullpc

boss_appear_check:
        lda.l !levels_completed-2,x
        and #$40
        rtl 

;#########################################################################
