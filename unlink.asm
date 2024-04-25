
pushpc
    org $82FE0D
        jsl storm_eagle_weapon_check
        nop 
pullpc

storm_eagle_weapon_check:
        lda !completed_storm_eagle
        and #$40
        rtl 

;##########################################################

pushpc
    org $80BC87
        jml flame_mammoth_frozen_check
    org $80B51E
        jml flame_mammoth_frozen_check_2
    org $82FA30
        jml flame_mammoth_frozen_check_3
        nop 
    org $87BD75
        jml flame_mammoth_fire_pillar
    org $879E96
        jml flame_mammoth_fire_pillar_2
    org $8498A1
        jml flame_mammoth_fire_pillar_3
pullpc

flame_mammoth_fire_pillar:
        lda !completed_chill_penguin
        and #$40
        bne .return
        jml $87BD7A
    .return
        jml $87BDA6
    .2
        lda !completed_chill_penguin
        and #$40
        bne ..return
        jml $879E9B
    ..return
        jml $879ECF
    .3
        lda !completed_chill_penguin
        and #$40
        beq ..return
        jml $8498A6
    ..return
        jml $8498A9

flame_mammoth_frozen_check:
        lda !completed_chill_penguin
        and #$0040
        beq .return
        jml $80BC8C
    .return
        jml $80BCD0
    .2  
        lda !completed_chill_penguin
        and #$0040
        beq ..return
        jml $80B523
    ..return
        jml $80B528
    .3  
        lda !completed_chill_penguin
        and #$40
        beq ..return
        jml $82FA35
    ..return
        jml $82FA3A

pushpc
    org $80BCAB
        jml sting_chameleon_flooded_check
pullpc

sting_chameleon_flooded_check:
        lda !completed_launch_octopus
        and #$0040
        beq .return
        jml $80BCB0
    .return
        jml $80BCD0

;##########################################################

pushpc
    org $80BC99
        jml spark_mandrill_crash_check
    org $80B512
        jml spark_mandrill_crash_check_2
    org $87FCEC
        jml spark_mandrill_crash_check_3
    org $87F66C
        jml spark_mandrill_crash_check_4
    org $87F6DD
        jml spark_mandrill_crash_check_5
    org $87F714
        jml spark_mandrill_crash_check_6
    org $82FA24
        jml spark_mandrill_crash_check_7
pullpc

spark_mandrill_crash_check:
        lda !completed_storm_eagle
        and #$0040
        beq .return
        jml $80BC9E
    .return
        jml $80BCD0
    .2  
        lda !completed_storm_eagle
        and #$0040
        beq ..return
        jml $80B517
    ..return
        jml $80B528
    .3  
        lda !completed_storm_eagle
        and #$40
        beq ..return
        jml $828398
    ..return
        jml $87FCF5
    .4  
        lda !completed_storm_eagle
        and #$40
        beq ..return
        jml $87F676
    ..return
        jml $87F671
    .5  
        lda !completed_storm_eagle
        and #$40
        beq ..return
        jml $87F6E2
    ..return
        jml $87F6ED
    .6  
        lda !completed_storm_eagle
        and #$40
        beq ..return
        jml $87F719
    ..return
        jml $87F728
    .7
        lda !completed_storm_eagle
        and #$40
        beq ..return
        jml $82FA29
    ..return
        jml $82FA3A

;##########################################################

pushpc
    org $84B110
        jml thunder_slime_check_1
    org $81B4C2
        jml thunder_slime_check_2
pullpc

thunder_slime_check:
    .1 
        lda !completed_storm_eagle
        and #$40
        bne ..return
        jml $84B115
    ..return
        jml $84B127
    .2 
        lda !completed_storm_eagle
        and #$40
        beq ..return
        jml $81B4C7
    ..return
        lda #$02
        jml $81B4C9