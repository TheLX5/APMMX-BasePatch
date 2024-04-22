generic_listener:
    lda $27
    bne .nope
    lda #$01
    sta.l !bosses_defeated,x
.nope
    plp 
    plx 
    rtl

generic_listener_2:
    lda $27
    bne .nope
    lda $01
    cmp #$04
    bcc .nope
    lda #$01
    sta.l !bosses_defeated,x
.nope
    plp 
    plx 
    rtl 

maverick_listener:
    lda $27
    bne .nope
    cpy #$02
    beq .skip
    lda $1F0C
    beq .nope
.skip
    lda #$01
    sta.l !bosses_defeated,x
    lda !level_id
    cmp #$09
    bcs .nope
    tyx 
    lda #$FF
    sta.l !levels_completed,x
.nope
    plp 
    plx 
    ply 
    rtl 

;################################################

pushpc
    org $80F9D1
        jsl listener_chill_penguin
pullpc

listener_chill_penguin:
    jsl $81B50C
    phy 
    phx 
    php 
    sep #$30
    ldx #$01
    lda !level_id
    cmp #$09
    bcc .regular
    ldx #$0B
.regular
    ldy #$0E
    jmp maverick_listener

;################################################

pushpc
    org $80F9E0
        jsl listener_boomer_kuwanger
pullpc

listener_boomer_kuwanger:
    jsl $878A7E
    phy 
    phx 
    php 
    sep #$30
    ldx #$04
    lda !level_id
    cmp #$09
    bcc .regular
    ldx #$0A
.regular
    ldy #$0C
    jmp maverick_listener

;################################################

pushpc
    org $80F9EA
        jsl listener_launch_octopus
pullpc

listener_launch_octopus:
    jsl $81C429
    phy 
    phx 
    php 
    sep #$30
    ldx #$03
    lda !level_id
    cmp #$09
    bcc .regular
    ldx #$11
.regular
    ldy #$00
    jmp maverick_listener

;################################################

pushpc
    org $80F9F9
        jsl listener_sting_chameleon
pullpc

listener_sting_chameleon:
    jsl $88853E
    phy 
    phx 
    php 
    sep #$30
    ldx #$05
    lda !level_id
    cmp #$09
    bcc .regular
    ldx #$0F
.regular
    lda $01
    cmp #$04
    bcc .nope
    lda $27
    and #$7F
    bne .nope
.skip
    lda #$01
    sta.l !bosses_defeated,x
    lda !level_id
    cmp #$09
    bcs .nope
    ldx #$02
    lda #$FF
    sta.l !levels_completed,x
.nope
    plp 
    plx 
    ply 
    rtl 

;################################################

pushpc
    org $80FA03
        jsl listener_flame_mammoth
pullpc

listener_flame_mammoth:
    jsl $8791A7
    phy 
    phx 
    php 
    sep #$30
    ldx #$07
    lda !level_id
    cmp #$09
    bcc .regular
    ldx #$12
.regular
    ldy #$06
    jmp maverick_listener

;################################################

pushpc
    org $80FA2B
        jsl listener_armored_armadillo
pullpc

listener_armored_armadillo:
    jsl $83B144
    phy 
    phx 
    php 
    sep #$30
    ldx #$00
    lda !level_id
    cmp #$09
    bcc .regular
    ldx #$0E
.regular
    ldy #$04
    jmp maverick_listener

;################################################

pushpc
    org $80FABC
        jsl listener_spark_mandrill
pullpc

listener_spark_mandrill:
    jsl $889BE1
    phy 
    phx 
    php 
    sep #$30
    ldx #$02
    lda !level_id
    cmp #$09
    bcc .regular
    ldx #$10
.regular
    ldy #$0A
    lda $01
    cmp #$04
    bcc .nope
    lda $27
    and #$7F
    bne .nope
.skip
    lda #$01
    sta.l !bosses_defeated,x
    lda !level_id
    cmp #$09
    bcs .nope
    tyx 
    lda #$FF
    sta.l !levels_completed,x
.nope
    plp 
    plx 
    ply 
    rtl 

;################################################

pushpc
    org $80FB61
        jsl listener_storm_eagle
pullpc

listener_storm_eagle:
    jsl $87D85C
    phy 
    phx 
    php 
    sep #$30
    ldx #$06
    lda !level_id
    cmp #$09
    bcc .regular
    ldx #$0C
.regular
    ldy #$08
    jmp maverick_listener

;################################################

pushpc
    org $80F9D6
        jsl listener_volt_slime
pullpc

listener_volt_slime:
    jsl $84AE3D
    phx 
    php 
    sep #$30
    lda $1E89
    cmp #$02
    bne .nope
    ldx #$17
    lda #$01
    sta.l !bosses_defeated,x
.nope
    plp 
    plx 
    rtl 

;################################################

pushpc
    org $80FA6C
        jsl listener_anglerge
pullpc

listener_anglerge:
    jsl $82AE11
    phx 
    php 
    sep #$30
    ldx #$18
    lda $0B
    and #$7F
    beq .tan
    ldx #$19
.tan
    jmp generic_listener

;################################################

pushpc
    org $80FA71
        jsl listener_bee_blader
pullpc

listener_bee_blader:
    jsl $82B88F
    phx 
    php 
    sep #$30
    ldx #$1C
    lda $0B
    beq .first
    ldx #$1D
.first
    jmp generic_listener

;################################################

pushpc
    org $80FA76
        jsl listener_utoboros
pullpc

listener_utoboros:
    jsl $82BD64
    phx 
    php 
    sep #$30
    ldx #$1A
    lda $0B
    beq .above
    ldx #$1B
.above
    lda $01
    cmp #$04
    bne .nope
    lda #$01
    sta.l !bosses_defeated,x
.nope
    plp 
    plx 
    rtl

;################################################

pushpc
    org $80FA85
        jsl listener_velguarder
pullpc

listener_velguarder:
    jsl $82C833
    phx 
    php 
    sep #$30
    ldx #$13
    jmp generic_listener_2

;################################################

pushpc
    org $80FB98
        jsl listener_rangda_bangda
pullpc

listener_rangda_bangda:
    jsl $88A985
    phx 
    php 
    sep #$30
    ldx #$0D
    jmp generic_listener_2

;################################################

pushpc
    org $80FBAC
        jsl listener_d_rex
pullpc

listener_d_rex:
    jsl $88B689
    phx 
    php 
    sep #$30
    ldx #$1E
    jmp generic_listener

;################################################

pushpc
    org $80FBB6
        jsl listener_bospider
pullpc

listener_bospider:
    jsl $82DB76
    phx 
    php 
    sep #$30
    ldx #$08
    jmp generic_listener_2

;################################################

pushpc
    org $80FBD4
        jsl listener_vile
pullpc

listener_vile:
    jsl $88DAD3
    phx 
    php 
    sep #$30
    ldx #$09
    jmp generic_listener_2
    

;################################################

pushpc
    org $80FAA3
        jsl listener_mole_borer
pullpc

listener_mole_borer:
    jsl $83BF44
    phx 
    php 
    sep #$30
    ldx #$15
    rep #$20
    lda $0C
    cmp #$FAF2
    sep #$20
    beq .first
    ldx #$16
.first
    jmp generic_listener

;################################################

pushpc
    org $88CBEC
        jsl listener_wolf_sigma
pullpc 

listener_wolf_sigma:
    ldx #$1F
    lda #$01
    sta !bosses_defeated,x
    lda #$12
    sta $01
    rtl 
