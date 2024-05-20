
pushpc
    org $86FE00
        damage_table:
            .vile
                skip $20
            .sting_chameleon
                skip $20
            .drex
                skip $20
            .storm_eagle
                skip $20
            .flame_mammoth
                skip $20
            .chill_penguin
                skip $20
            .bospider
                skip $20
            .velguarder
                skip $20
            .thunder_slimer
                skip $20
pullpc

pushpc
    org $849E40
        jsr reroute_dmg_table_1
    org $849E6E
        jsr reroute_dmg_table_2

    org $84F200
        reroute_dmg_table:
        .1  
            clc
        .2  
            jsl damage_routine
            rts 
pullpc


damage_routine:
        php
        lda #$00
        xba 
        lda.l setting_boss_weakness_rando
        bne .custom
    .original
        plp 
        bcs ..sub
    ..load
        lda.w $EF37,y
        rtl 
    ..sub
        lda $27
        and #$7F
        sec 
        sbc.w $EF37,y
        jsr .process_hadouken
        rtl

    .custom
        lda $28
        cmp #$03
        beq ..reroute_vile_thunder_slimer
        cmp #$07
        bne +
        jmp ..reroute_storm_eagle
    +   
        cmp #$08
        bne +
        jmp ..reroute_flame_mammoth
    +   
        cmp #$06
        bne +
        jmp ..reroute_sting_chameleon_drex
    +   
        cmp #$0A
        bne +
        jmp ..reroute_bospider_velguarder
    +   
        cmp #$09
        bne +
        jmp ..reroute_chill_penguin
    +   
        bra .original
        ; $0A = Sprite ID

    ..reroute_vile_thunder_slimer
        lda $0A
        cmp.b #105
        beq ..vile
        cmp.b #3
        beq ..thunder_slimer
        jmp .original
    ..vile
        plp 
        bcs ...sub
        phx 
        lda $1F1D
        tax 
        lda.l damage_table_vile,x
        plx 
        cmp #$00
        rtl 
    ...sub
        phx 
        lda $1F1D
        tax 
        lda $27
        and #$7F
        sec 
        sbc.l damage_table_vile,x
        jsr .process_hadouken
        plx 
        cmp #$00
        rtl 
    ..thunder_slimer
        plp 
        bcs ...sub
        phx 
        lda $1F1D
        tax 
        lda.l damage_table_thunder_slimer,x
        plx 
        cmp #$00
        rtl 
    ...sub
        phx 
        lda $1F1D
        tax 
        lda $27
        and #$7F
        sec 
        sbc.l damage_table_thunder_slimer,x
        jsr .process_hadouken
        plx 
        cmp #$00
        rtl 


    ..reroute_chill_penguin
        lda $0A
        cmp.b #2
        beq ..chill_penguin
        jmp .original
    ..chill_penguin
        plp 
        bcs ...sub
        phx 
        lda $1F1D
        tax 
        lda.l damage_table_chill_penguin,x
        plx 
        cmp #$00
        rtl 
    ...sub
        phx 
        lda $1F1D
        tax 
        lda $27
        and #$7F
        sec 
        sbc.l damage_table_chill_penguin,x
        jsr .process_hadouken
        plx 
        cmp #$00
        rtl 


    ..reroute_storm_eagle
        lda $0A
        cmp.b #82
        beq ..storm_eagle
        jmp .original
    ..storm_eagle
        plp 
        bcs ...sub
        phx 
        lda $1F1D
        tax 
        lda.l damage_table_storm_eagle,x
        plx 
        cmp #$00
        rtl 
    ...sub
        phx 
        lda $1F1D
        tax 
        lda $27
        and #$7F
        sec 
        sbc.l damage_table_storm_eagle,x
        jsr .process_hadouken
        plx 
        cmp #$00
        rtl 


    ..reroute_flame_mammoth
        lda $0A
        cmp.b #12
        beq ..flame_mammoth
        jmp .original
    ..flame_mammoth
        plp 
        bcs ...sub
        phx 
        lda $1F1D
        tax 
        lda.l damage_table_flame_mammoth,x
        plx 
        cmp #$00
        rtl 
    ...sub
        phx 
        lda $1F1D
        tax 
        lda $27
        and #$7F
        sec 
        sbc.l damage_table_flame_mammoth,x
        jsr .process_hadouken
        plx 
        cmp #$00
        rtl 


    ..reroute_sting_chameleon_drex
        lda $0A
        cmp.b #10
        beq ..sting_chameleon
        cmp.b #97
        beq ..drex
        cmp.b #98
        beq ..drex
        jmp .original
    ..sting_chameleon
        plp 
        bcs ...sub
        phx 
        lda $1F1D
        tax 
        lda.l damage_table_sting_chameleon,x
        plx 
        cmp #$00
        rtl 
    ...sub
        phx 
        lda $1F1D
        tax 
        lda $27
        and #$7F
        sec 
        sbc.l damage_table_sting_chameleon,x
        jsr .process_hadouken
        plx 
        cmp #$00
        rtl 
    ..drex
        plp 
        bcs ...sub
        phx 
        lda $1F1D
        tax 
        lda.l damage_table_drex,x
        plx 
        cmp #$00
        rtl 
    ...sub
        phx 
        lda $1F1D
        tax 
        lda $27
        and #$7F
        sec 
        sbc.l damage_table_drex,x
        jsr .process_hadouken
        plx 
        cmp #$00
        rtl 

    ..reroute_bospider_velguarder
        lda $0A
        cmp.b #99
        beq ..bospider
        cmp.b #38
        beq ..velguarder
        jmp .original
    ..bospider
        plp 
        bcs ...sub
        phx 
        lda $1F1D
        tax 
        lda.l damage_table_bospider,x
        plx 
        cmp #$00
        rtl 
    ...sub
        phx 
        lda $1F1D
        tax 
        lda $27
        and #$7F
        sec 
        sbc.l damage_table_bospider,x
        jsr .process_hadouken
        plx 
        cmp #$00
        rtl 
    ..velguarder
        plp 
        bcs ...sub
        phx 
        lda $1F1D
        tax 
        lda.l damage_table_velguarder,x
        plx 
        cmp #$00
        rtl 
    ...sub
        phx 
        lda $1F1D
        tax 
        lda $27
        and #$7F
        sec 
        sbc.l damage_table_velguarder,x
        jsr .process_hadouken
        plx 
        cmp #$00
        rtl 

    .process_hadouken
        pha 
        lda $1F1D
        cmp #$04
        beq ..is_hadouken
        pla 
        rts 
    ..is_hadouken
        lda !current_hp
        and #$7F
        sta $01,s
        lda.l setting_boss_weakness_strictness
        beq ..dont_halve
        lda $01,s
        lsr 
        sta $01,s
        cmp #$00
        bne ..dont_halve
        inc 
        sta $01,s
    ..dont_halve
        lda $27
        and #$7F
        sec 
        sbc $01,s
        sta $01,s
        pla 
        rts 

db "how come inserting some random ass data into the game makes bsdiff respect my tokens"
