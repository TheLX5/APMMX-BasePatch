pushpc
    org $80C695
        jsl draw_pause_menu

    ; Can exit stages at any time
    org $80C952
        lda #$40
        rts 

    org $80C70F
        jml wait_for_energy_link

    ;org $009F49
    ;    jml pause_rules

    ;# Do not draw lives
    ;org $80C60A
    ;    nop #3
    org $80CC21
        jsl draw_blank_tilemap
        jsl draw_static_data
        jsr $8100
        lda #$80
        sta $2100
        jsl draw_lives
        jsl draw_energy_link
        rts 

    org $80C930
        lda #$6E
    org $80C934
        lda #$A4

; pause code starts here: 80C43A
; main code at: 80C4F4
pullpc

;#########################################################################

draw_pause_menu:
        ;lda #$04
        ;sta !completed_intro_level

        lda $0A
        sta $0B
        
        phk 
        pea.w .draw_hp_menu-$01
        pea.w $E02D-$01
        jml $80CC56
    .draw_hp_menu
        phk 
        pea.w .draw_sub_tanks-$01
        pea.w $E02D-$01
        jml $80CD2C
    .draw_sub_tanks


        phb 
        phk 
        plb 
        lda $0B9E
        asl 
        pha 
    .draw_weapons
        ldy #$00
    ..loop
        tya 
        clc 
        adc $01,s
        lsr #2
        bcs ..nope
        lda !weapons,y
        and #$40
        beq ..nope
        jsl draw_weapon_menu
    ..nope
        iny #2
        cpy #$10
        bne ..loop
        pla 

        lda $0B9E
        lsr 
        bcs +
        jsl draw_energy_link
        bra ++
    +   
        jsl draw_lives
    ++  
        plb 
        rtl 
        
;#########################################################################
        
draw_weapon_menu:
    .draw
        ldx !direct_dma_queue_index
        lda #$80
        sta.w direct_dma_queue.vmain,x
        rep #$20
        lda.w .weapon_offsets,y
        sta.w direct_dma_queue.destination,x
        lda #$2882
        sta.w direct_dma_queue.data,x
        sep #$20
        lda #$12
        sta.w direct_dma_queue.size,x
        lda #$1C
        sta $0000
        lda #$07
        sta $0002
        lda !weapons,y
        and #$1F
        sta $0004
        inx #6
    ..loop
        lda $0004
        beq ..empty
        cmp #$04
        bcs ..full
    ..not_full
        stz $0004
        clc 
        adc #$83
        bra ..draw
    ..empty
        lda #$83
        bra ..draw
    ..full
        sec 
        sbc #$04
        sta $0004
        lda #$87
    ..draw
        sta.w direct_dma_queue.data-$04+$00,x
        lda #$28
        sta.w direct_dma_queue.data-$04+$01,x
        inx #2
        dec $0002
        bne ..loop
        lda #$82
        sta.w direct_dma_queue.data-$04+$00,x
        lda #$68
        sta.w direct_dma_queue.data-$04+$01,x
        inx #2
        stx !direct_dma_queue_index
        rtl 

    .weapon_offsets
        dw $A20C>>1    ; Homing Torpedo
        dw $A28C>>1    ; Chameleon Sting
        dw $A30C>>1    ; Rolling Shield
        dw $A38C>>1    ; Fire Wave
        dw $A1A6>>1    ; Storm Tornado
        dw $A226>>1    ; Electric Spark
        dw $A2A6>>1    ; Boomerang Cutter
        dw $A326>>1    ; Shotgun Ice

;#########################################################################
        
draw_lives:
        ldy #$00
        ldx !direct_dma_queue_index
        lda #$80
        sta.w direct_dma_queue.vmain,x
        rep #$20
        lda.w #$B4AE>>1
        sta.w direct_dma_queue.destination,x
        sep #$20
    .loop
        lda #$04
        sta.w direct_dma_queue.size,x
        rep #$20
        lda !lives
        and #$00FF
        jsr hex_to_dec_super
        tya
        asl #4
        clc 
        adc #$E0
        sta $0005
        lda $0001
        beq .skip_10s
        lda $0001
        clc 
        adc $0005
    .skip_10s
        sta.w direct_dma_queue.data,x
        lda #$28
        sta.w direct_dma_queue.data+$01,x
        lda $0000
        clc 
        adc $0005
        sta.w direct_dma_queue.data+$02,x
        lda #$28
        sta.w direct_dma_queue.data+$03,x
        txa 
        clc 
        adc #$08
        sta !direct_dma_queue_index
        iny 
        cpy #$02
        bne .prepare
        rtl 

    .prepare
        ldx !direct_dma_queue_index
        lda #$80
        sta.w direct_dma_queue.vmain,x
        rep #$20
        lda.w #$B4EE>>1
        sta.w direct_dma_queue.destination,x
        sep #$20
        jmp .loop

;#########################################################################

draw_energy_link:
        lda.l setting_energy_link_configuration
        bne .do
        rtl 
    .do
        ldy #$00
        ldx !direct_dma_queue_index
        lda #$80
        sta.w direct_dma_queue.vmain,x
        rep #$20
        lda.w #$B570>>1
        sta.w direct_dma_queue.destination,x
        sep #$20
    .loop
        lda #$08
        sta.w direct_dma_queue.size,x
        rep #$20
        lda !energy_link_amount
        jsr hex_to_dec_super

        tya
        asl #4
        clc 
        adc #$E0
        sta $0005

        lda $0003
        beq .skip_1000s
        clc 
        adc $0005
    .skip_1000s
        sta.w direct_dma_queue.data+$00,x
        lda #$28
        sta.w direct_dma_queue.data+$01,x

        lda $0002
        ora $0003
        beq .skip_100s
        lda $0002
        clc 
        adc $0005
    .skip_100s
        sta.w direct_dma_queue.data+$02,x
        lda #$28
        sta.w direct_dma_queue.data+$03,x

        lda $0001
        ora $0002
        ora $0003
        beq .skip_10s
        lda $0001
        clc 
        adc $0005
    .skip_10s
        sta.w direct_dma_queue.data+$04,x
        lda #$28
        sta.w direct_dma_queue.data+$05,x

        lda $0000
        clc 
        adc $0005
        sta.w direct_dma_queue.data+$06,x
        lda #$28
        sta.w direct_dma_queue.data+$07,x
        txa 
        clc 
        adc #$0C
        sta !direct_dma_queue_index

        iny 
        cpy #$02
        bne .prepare
        rtl 

    .prepare
        ldx !direct_dma_queue_index
        lda #$80
        sta.w direct_dma_queue.vmain,x
        rep #$20
        lda.w #$B5B0>>1
        sta.w direct_dma_queue.destination,x
        sep #$20
        jmp .loop

;#########################################################################

draw_blank_tilemap:
        lda #$80
        sta $2115
        lda.b #pause_menu_blank_tilemap>>16
        sta $4314
        rep #$20
        lda #$1801
        sta $4310
        lda.w #pause_menu_blank_tilemap
        sta $4312
        lda #$B000>>1
        sta $2116
        lda #$0800
        sta $4315
        ldy #$02
        sty $420B
        sep #$20
        rtl 

;#########################################################################

draw_static_data:
        lda #$80
        sta $2115
        rep #$20

    .draw_head
        lda #$80
        sta $2115
        rep #$20
        lda #$B4A6>>1
        sta $2116
        lda #$04EA
        ldx #$00
    .loop1
        sta $2118
        inc 
        inx 
        cpx #$03
        bcc .loop1
        lda #$B4E6>>1
        sta $2116
        lda #$04FA
        ldx #$00
    .loop2
        sta $2118
        inc 
        inx 
        cpx #$03
        bcc .loop2

    .draw_energy
        lda.l setting_energy_link_configuration
        and #$00FF
        bne ..do
        sep #$20
        rtl 
    ..do
        ldx #$00
        lda.l .text_energy,x
        sta $2116
        inx #2
    ..loop
        lda.l .text_energy,x
        cmp #$FFFF
        beq ..end
        sta $2118
        inx #2
        bra ..loop
    ..end

    .draw_pool
        ldx #$00
        lda.l .text_pool,x
        sta $2116
        inx #2
    ..loop
        lda.l .text_pool,x
        cmp #$FFFF
        beq ..end
        sta $2118
        inx #2
        bra ..loop
    ..end

        sep #$20
        rtl 

    pushtable
        table "pause_tbl.txt",ltr

    .text
        ..energy
            dw $B562>>1
            dw "ENERGY"
            dw $FFFF
        ..pool
            dw $B5A4>>1
            dw "POOL"
            dw $FFFF

    pulltable

;#########################################################################

wait_for_energy_link:
        lda !refill_request
        bne .waiting
        lda !receiving_item
        bne .stuck
        lda $00AC
        and #$20
        beq .can_move
        lda $1ED2
        beq .refill_hp
        cmp #$09
        bcc .refill_weapon
        jmp .can_move
    .refill_hp
        ldy #$00
        lda !current_hp
        and #$7F
        sta $0000
        lda !max_hp
        and #$7F
        sec 
        sbc $0000
        beq .can_move
    .place_request
        sta !refill_request
        tya 
        sta !refill_target 
        lda #$2B
        jsl play_sfx
        bra .stuck
    .refill_weapon
        asl 
        tay 
        lda !weapons-$02,y
        and #$40
        beq .can_move
        lda !weapons-$02,y
        and #$1F
        sta $0000
        lda #$1C
        sec 
        sbc $0000
        beq .can_move
        ldy #$01
        bra .place_request

    .can_move
        lda $0BE3
        bit #$10
        beq .stuck
        jml $80C716
    .stuck
        jml $80C738

    .waiting
        lda !refill_timer
        dec 
        sta !refill_timer
        bne .stuck
        lda #$00
        sta !refill_request
        sta !refill_target
        lda #$2A
        jsl play_sfx
        bra .stuck

;#########################################################################

hex_to_dec_super:
        stz $0000
        stz $0002
        stz $0004
    .10000s
        cmp #$2710
        bcc .1000s
        sbc #$2710
        inc $0004
        bra .10000s
    .1000s
        cmp #$03E8
        bcc .100s
        sbc #$03E8
        inc $0003
        bra .1000s
    .100s
        cmp #$0064
        bcc .10s
        sbc #$0064
        inc $0002
        bra .100s
    .10s
        cmp #$000A
        bcc .1s
        sbc #$000A
        inc $0001
        bra .10s
    .1s
        sep #$20
        sta $0000
        rts 

    .long
        jsr hex_to_dec_super
        rtl 
