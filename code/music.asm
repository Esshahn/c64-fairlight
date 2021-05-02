init_voices
!byte $00, $00, $00, $08

lcc04
!byte $10, $2e, $4e, $00, $00, $00, $08

lcc0b
!byte $40, $8a, $0a, $00, $00, $00, $07

lcc12
!byte $40, $0a, $0a, $00, $7d, $d6, $1f

music_init
            ldx #$18
-
            lda init_voices,x
            sta $d400,x                     ; voice 1 frequency low byte
            dex
            bpl -
            lda lcc04
            sta $0355
            lda lcc0b
            sta $0356
            lda lcc12
            sta $0357
            ldx #$02
            lda #$01
-
            sta $0358,x
            dex
            bpl -
            ldx #$08
            lda #$00
-
            sta $035b,x
            dex
            bpl -
            lda #$01
            sta $0354
            ldx #$05
-
            lda lce00,x
            sta $0364,x
            dex
            bpl -
            inc $0358
            rts


music_play
            dec $0354
            beq +
            rts                              ; jmp lcd1d
+
            lda #$0a
            sta $0354
            ldx #$02


lcc6d
            dec $0358,x
            bne lccd1
            txa
            sta $9e
            asl
            pha
            asl
            asl
            sec
            sbc $9e
            tay
            lda $0355,x
            sta $d404,y                     ; voice 1 control register
            pla
            tay


lcc85
            lda $0364,y
            sta $9e
            clc
            adc #$03
            sta $0364,y
            lda $0365,y
            sta $9f
            adc #$00
            sta $0365,y
            ldy #$02
            lda ($9e),y
            beq lccc8
            sta $035e,x
            dey
            lda ($9e),y
            sta $035b,x
            lda #$01
            sta $0361,x


lccae
            dey
            lda ($9e),y
            sta $0358,x
            bne lccd1
            txa
            asl
            tay
            lda lce00,y
            sta $0364,y
            lda song_data,y
            sta $0365,y
            jmp lcc85


lccc8
            dey
            lda #$00
            sta $0361,x
            jmp lccae


lccd1
            dex
            bpl lcc6d
            lda $a0
            and #$07
            clc
            adc #$04
            sta $d40a                       ; voice 2 pulse width high byte
            lda $035b
            sta $d400                       ; voice 1 frequency low byte
            lda $035e
            sta $d401                       ; voice 1 frequency high byte
            lda $035c
            sta $d407                       ; voice 2 frequency low byte
            lda $035f
            sta $d408                       ; voice 2 frequency high byte
            lda $035d
            sta $d40e                       ; voice 3 frequency low byte
            lda $0360
            sta $d40f                       ; voice 3 frequency high byte
            lda $0355
            ora $0361
            sta $d404                       ; voice 1 control register
            lda $0356
            ora $0362
            sta $d40b                       ; voice 2 control register
            lda $0357
            ora $0363
            sta $d412                       ; voice 3 control register
            rts


!align 255, 0

;==========================================================
; I think this is the music, not sure yet
;==========================================================

lce00
!byte $57

song_data
!byte $ce, $06, $ce, $57, $ce, $03, $85, $06, $03, $e2, $04, $06, $2c, $05, $03, $cf, $05, $03, $cf, $05, $06, $85, $06, $03, $85, $06, $03, $e2, $04, $06, $2c, $05, $03, $cf, $05, $03, $cf, $05, $06, $85, $06, $03, $85, $06, $02, $85, $06, $01, $0a, $0d, $06, $2c, $05, $03, $cf, $05, $02, $e2, $04, $01, $cf, $05, $06, $85, $06, $03, $85, $06, $03, $e2, $04, $06, $2c, $05, $03, $cf, $05, $03, $e2, $04, $06, $42, $03, $00, $00, $00, $60, $00, $00, $03, $29, $34, $01, $8c, $3a, $01, $08, $3e, $01, $29, $34, $04, $a1, $45, $02, $08, $3e, $01, $8d, $3a, $01, $08, $3e, $04, $8d, $3a, $06, $29, $34, $03, $29, $34, $01, $8d, $3a, $01, $08, $3e, $01, $29, $34, $04, $a1, $45, $02, $08, $3e, $01, $8c, $3a, $01, $08, $3e, $04, $a1, $45, $06, $27, $4e, $03, $27, $4e, $01, $cd, $52, $01, $27, $4e, $01, $cd, $52, $04, $27, $4e, $02, $a1, $45, $01, $08, $3e, $01, $a1, $45, $04, $8d, $3a, $06, $29, $34, $03, $29, $34, $01, $8d, $3a, $01, $08, $3e, $01, $29, $34, $04, $a1, $45, $02, $08, $3e, $01, $8c, $3a, $01, $08, $3e, $02, $8c, $3a, $02, $78, $2e, $06, $29, $34, $02, $0a, $0d, $02, $0a, $0d, $01, $a3, $0e, $01, $82, $0f, $04, $b3, $14, $02, $89, $13, $02, $68, $11, $02, $82, $0f, $02, $a3, $0e, $03, $82, $0f, $01, $68, $11, $02, $a3, $0e, $02, $0a, $0d, $02, $0a, $0d, $01, $a3, $0e, $01, $82, $0f, $02, $b3, $14, $02, $89, $13, $02, $68, $11, $02, $82, $0f, $02, $a3, $0e, $02, $82, $0f, $06, $c4, $09, $02, $0a, $0d, $02, $a3, $0e, $02, $82, $0f, $02, $b3, $14, $02, $89, $13, $02, $68, $11, $02, $82, $0f, $02, $a3, $0e, $02, $82, $0f, $06, $82, $0f, $02, $0a, $0d, $02, $0a, $0d, $01, $a3, $0e, $01, $82, $0f, $02, $b3, $14, $02, $b3, $14, $02, $89, $13, $02, $68, $11, $02, $82, $0f, $01, $a3, $0e, $01, $82, $0f, $06, $0a, $0d, $06, $0a, $0d, $09, $82, $0f, $03, $a3, $0e, $06, $0a, $0d, $06, $13, $27, $09, $d0, $22, $03, $04, $1f, $06, $14, $1a, $03, $14, $1a, $02, $14, $1a, $01, $13, $27, $06, $66, $29, $03, $d0, $22, $02, $04, $1f, $01, $46, $1d, $06, $14, $1a, $03, $14, $1a, $03, $8a, $13, $06, $b3, $14, $04, $04, $1f, $05, $d0, $22, $03, $14, $1a, $00, $00, $00, $20, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00