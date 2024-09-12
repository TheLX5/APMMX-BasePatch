

pushpc
;   org $80817A
;       jsr msu_nmi_fade
    
    org $80885B
        jsl msu_effects

    org $808611
        jsl msu_init
        nop 

    ;# Generic call
    org $8087AA
        jsr msu_invoke_short

    ;# Stage Music
    org $809A2D
        jmp msu_invoke_short

    ;# Stage Selected
    org $809709
        jsr msu_invoke_short

    ;# Zero Appears
    org $809D10
        jsr msu_invoke_short

    ;# Got weapon
    org $80ABEC
        jsr msu_invoke_short

    ;# Intro title
    org $808D8F
        jsr msu_invoke_short

    ;# Edit pause initial SPC command
    org $809EBC
        jsr start_pause_spc_command_short

    ;# Edit pause final SPC command
    org $80C503
        jml final_pause_spc_command



pullpc

msu_installed:
    macro msu_check(msu, d)
        lda $2002+<d>
        cmp.b #<msu>
        bne .no_msu
    endmacro

        %msu_check($53, 0)
        %msu_check($2D, 1)
        %msu_check($4D, 2)
        %msu_check($53, 3)
        %msu_check($55, 4)
        %msu_check($31, 5)
        lda #$01
        rtl 
    .no_msu
        lda #$00
        rtl 

msu_invoke_long:
        pha 
        phx 
        php 
        sep #$30
        tax 

        jsl msu_installed
        beq .not_found

        txa 
        sec 
        sbc #$10
        tax 
        sta !msu_song_backup
        sta !msu_audio_track+$00
        stz !msu_audio_track+$01
    .wait
        lda !msu_status
        and #!msu_status_audio_busy
        bne .wait

        lda !msu_status
        and #!msu_status_track_missing
        bne .not_found
    
        lda.l .song_loop_status,x
        sta !msu_audio_flags
        lda #!msu_audio_volume_max
        sta !msu_audio_volume
        lda #$00
        sta !msu_fade_flags
        
        lda #$01
        sta !msu_skip_msu

        lda !msu_original_song
        beq +
        lda #$FE
        jsl play_sfx
    +   
        lda #$00
        sta !msu_original_song

        lda #$F6
        ldy #$00
        jsl send_spc_command

        plp 
        plx 
        pla 
        rtl 

    .not_found
        lda #$01
        sta !msu_original_song
        plp 
        plx 
        pla 
        phk 
        pea.w ..jslrts-1
        pea.w $87AF-1
        jml $8087B0
    ..jslrts 
        ldy #$FE
        lda #$FF
        jsl send_spc_command
        lda #$00
        sta !msu_audio_flags
        sta !msu_song_backup
        rtl

    .song_loop_status
        db $01,$03,$03,$03,$03,$03,$03,$03
        db $03,$03,$03,$03,$03,$03,$03,$01
        db $03,$01,$01,$03,$03,$03,$03,$01
        db $03,$03,$03,$03,$03,$03,$01,$03
        db $03,$03,$03,$03,$03,$03,$03,$03
        db $03,$03,$03,$03,$03,$03,$03,$03
        db $03,$03,$03,$03,$03,$03,$03,$03
        db $03,$03,$03,$03,$03,$03,$03,$03

msu_init:
        php 
        sep #$30

        jsl msu_installed
        beq .not_found

        lda #!msu_audio_volume_max
        sta !msu_audio_volume

        lda #$00
        sta !msu_fade_flags

    .not_found
        lda #$10
        phk 
        pea.w ..jslrts-1
        pea.w $87AF-1
        jml $8087B0
    ..jslrts 
        plp
        rtl 

msu_effects:
        pha 
        php 
        sep #$30

        jsl msu_installed
        beq .nope

        lda $02,s
        cmp #$F5
        beq .resume_music
        cmp #$F6
        beq .stop_music
        cmp #$FE
        beq .raise_volume
        cmp #$FF
        beq .drop_volume
        bra .play_sound
    .resume_music
        lda !msu_status
        and #!msu_status_audio_playing
        beq .end

        lda #$F6 
        sta $2140
        lda #$03
        sta !msu_audio_flags
        lda #$02
        sta !msu_fade_flags
        lda #$00
        sta !msu_fade_volume
        bra .end

    .stop_music
        sta $2140

        lda !msu_skip_msu
        cmp #$01
        bne +
        lda #$00
        sta !msu_skip_msu
        bra .end
    +   

        lda !msu_status
        and #!msu_status_audio_playing
        beq .end

        lda #$01
        sta !msu_fade_flags
        lda #$FF
        sta !msu_fade_volume
        bra .end

    .raise_volume
        sta $2140
        
        lda #$FF
        sta !msu_audio_volume
        bra .end

    .drop_volume
        sta $2140
        
        lda #!msu_audio_volume_drop
        sta !msu_audio_volume

    .nope
        plp 
        pla 
        sta $2140
        inx 
        rtl 

    .play_sound
        sta $2140
    .end
        plp 
        pla
        inx 
        rtl

start_pause_spc_command:
        lda !msu_status
        and #!msu_status_audio_playing
        beq .original_song
    .msu_song
        lda #!msu_audio_volume_drop
        ;sta !msu_audio_volume
        sta !msu_fade_limit
        lda #$03
        sta !msu_fade_flags
        lda #$FF
        sta !msu_fade_volume
        rtl 

    .original_song
        phk 
        pea.w ..jslrts-1
        pea.w $87AF-1
        jml $808867
    ..jslrts
        rtl 

final_pause_spc_command:
        lda !msu_status
        and #!msu_status_audio_playing
        beq .original_song
    .msu_song
        ;lda #$FF
        ;sta !msu_audio_volume
        lda #$02
        sta !msu_fade_flags
        lda #!msu_audio_volume_drop
        sta !msu_fade_volume

        jml $80C50B

    .original_song
        ldy #$FF
        lda #$FE
        jml $80C507

pushpc
    ;# Edit capsule SPC commands
    ;org $87CBD5
    ;    jsl start_capsule_spc_command
    ;    nop #2
    org $88A8C6
        jml final_capsule_spc_command
pullpc

final_capsule_spc_command:
        jsl msu_installed
        beq .original_song
    .msu_song
        ;lda #$FF
        ;sta !msu_audio_volume
        lda #$03
        sta !msu_audio_flags
        lda #$02
        sta !msu_fade_flags
        lda #$00
        sta !msu_fade_volume
        ldy #$10
        lda #$F5
        jsl $80887F
        jml $88A8CE

    .original_song
        ldy #$10
        lda #$F5
        jml $88A8CA
