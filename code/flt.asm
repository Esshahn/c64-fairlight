; converted with pydisass6502 by awsm of mayday!

* = $c000

            sei
            lda # >irq
            sta $0315                       ; IRQ vector routine high byte
            lda # <irq
            sta $0314                       ; IRQ vector routine low byte
            lda #$01
            sta $d012                       ; raster line
            sta $d01a                       ; interrupt control
            lda #$7f
            sta $dc0d                       ; CIA #1 - interrupt control and status
            lda #$1b
            sta $d011                       ; screen control register #1, vertical scroll
            lda #$94
            sta $dd00                       ; CIA #2 - port A, serial bus access
            lda #$12
            sta $d018                       ; memory setup
            
;
; set colors of the whole screen in color RAM
;
         
            lda #$09
            ldx #$00
-
            sta $d800,x                     ; color RAM
            inx
            bne -
            ldx #$20
-
            sta $d900,x
            dex
            bne -
            lda #$01
-
            sta $d920,x
            sta $da00,x
            sta $db00,x
            inx
            bne -


            lda #$00
            sta $d020                       ; border color
            sta $d021                       ; background color
            
            lda #$0a
            sta $d023                       ; extra background color #2
            lda #$02
            sta $d022                       ; extra background color #1
            lda #$d8
            sta $d016                       ; screen control register #2, horizontal scroll, multicolor, screenwidth
            
;
; Init all sprites and position them as one fake raster bar
;
            
            lda #$ff
            sta $d015                       ; sprite enable/disable
            lda #$18
            sta $d000                       ; sprite #0 X position (bits 0-7)
            lda #$48
            sta $d002                       ; sprite #1 X position (bits 0-7)
            lda #$78
            sta $d004                       ; sprite #2 X position (bits 0-7)
            lda #$a8
            sta $d008                       ; sprite #4 X position (bits 0-7)
            lda #$d8
            sta $d00a                       ; sprite #5 X position (bits 0-7)
            lda #$08
            sta $d00c                       ; sprite #6 X position (bits 0-7)
            lda #$38
            sta $d00e                       ; sprite #7 X position (bits 0-7)
            lda #$c0
            sta $d010                       ; sprites 0-7 X position (bit 8)
            lda #$ff
            sta $d01c                       ; sprite multicolor mode
            sta $d01d                       ; sprite double width

;
; set all sprite colors
;
            lda #$0d
            ldx #$07
-
            sta $d027,x                     ; sprite #0 color
            dex
            bpl -
            lda #$05
            sta $d025                       ; sprite extra color #1
            lda #$01
            sta $d026                       ; sprite extra color #2
            
            
            lda #$00                        ; set address $02 to 0
            sta $02
            jsr lc200
            cli


endless_loop
            jmp *


lc0b7
            jsr lcc5e
            inc $02
            ldx $02
            lda table_sprite_y_pos,x
            ldy #$0e
-
            sta $d001,y                     ; sprite #0 Y position
            dey
            dey
            bpl -
            lda $d001                       ; sprite #0 Y position
            cmp #$32
            bne +
            lda #$00
-
            sta $d01b                       ; sprite priority foreground/background
            jmp lc0f0
+
            cmp #$7b
            bne +
            lda #$ff
            jmp -
+
            cmp #$33
            bne lc0f0
            lda lc0f0 +1
            cmp #$1f
            beq lc0f0
            inc lc0f0 +1


lc0f0
            lda #$1f
            sta $d418                       ; volume and filter modes
            
            
            ;
            ; set raster line for the (real) raster bars
            ;
            lda #$98
            ldx #$00
-
            cmp $d012                       ; raster line
            bne -


draw_rasterbars
            lda raster_color,x              ; fetch a color from the table
            tay
            lda $d012                       ; raster line
-
            cmp $d012                       ; raster line
            beq -
            sty $d021                       ; background color
            inx
            cpx #$2a
            bne draw_rasterbars
-

            lda $d012                       ; raster line
            cmp #$d2
            bne -
            lda $09
            sta $d016                       ; screen control register #2, horizontal scroll, multicolor, screenwidth
            ldx #$64
-
            dex
            bne -
            lda #$d8
            sta $d016                       ; screen control register #2, horizontal scroll, multicolor, screenwidth
            dec $09
            lda $09
            cmp #$ff
            bne lc15c
            lda #$07
            sta $09
            ldx #$00
-
            lda lc721,x
            sta lc720,x
            inx
            cpx #$27
            bne -
            ldx #$00
            lda ($39,x)                   ; address of scrolltext
            sta lc747
            inc $39
            lda $39
            cmp #$00
            bne lc15c
            inc $3a
            lda $3a
            cmp #$cc
            bne lc15c
            lda #$ca
            sta $3a


lc15c
            lda $db20
            pha
            ldx #$00
-
            lda $db21,x
            sta $db20,x
            inx
            cpx #$27
            bne -
            pla
            sta $db47
            jmp $ea31                       ; KERNAL's standard interrupt routine


irq
            lda #$01
            sta $d019                       ; interrupt status
            lda lc0f0 +1
            cmp #$1f
            bne +
            jsr $ffe4                       ; GETIN
            cmp #$20
            beq lc18d
+
            jsr $ffe4                       ; GETIN
            jmp lc0b7


lc18d
            sei
            lda #$ea
            sta $0315                       ; IRQ vector routine high byte
            lda #$31
            sta $0314                       ; IRQ vector routine low byte
            jsr $ff81                       ; SCINIT
            lda #$97
            sta $dd00                       ; CIA #2 - port A, serial bus access
            cli
            jmp $fce2


lc200
            jsr lcc19
            lda #$10
            sta lc0f0 +1
            ldx #$c0
            lda #$00
-
            sta $da40,x
            dex
            bne -
            lda # >scrolltext
            sta $3a
            lda # <scrolltext
            sta $39
            ldx #$00
-
            lda color_wash,x
            sta $db20,x
            inx
            cpx #$28
            bne -
            lda #$00
            sta $c6
            sta $c5
            rts

color_wash

!byte $01, $01, $01, $01, $01, $0f, $0f, $0f, $0f, $0f, $0c, $0c, $0c, $0c, $0c, $0b, $0b, $0b, $0b, $0b, $01, $01, $01, $01, $01, $0f, $0f, $0f, $0f, $0f, $0c, $0c, $0c, $0c, $0c, $0b, $0b, $0b, $0b, $0b


raster_color

!byte $00, $00, $00, $00, $00, $00, $00, $00
!byte $00, $00, $00, $00, $00, $00, $00, $02
!byte $0a, $01, $01, $01, $0a, $0a, $02, $00
!byte $00, $00, $00, $00, $00, $06, $0e, $0e
!byte $01, $01, $0e, $0e, $06, $00, $00, $00
!byte $00, $00, $00, $00, $00, $00, $00, $00
!byte $00, $00, $00, $00, $00, $00, $00, $00
!byte $00, $00, $00, $00, $00, $00, $57, $59

* = $c2c0
;
; sprite y position table
;
table_sprite_y_pos

!byte $57, $59, $5c, $5f, $61, $64, $66, $69, $6b, $6d, $6f, $71, $73, $75, $76, $78, $79, $7a, $7a, $7b, $7b, $7b, $7b, $7b, $7b, $7a, $79, $78, $77, $76, $74, $73, $71, $6f, $6d, $6a, $68, $65, $63, $60, $5e, $5b, $58, $56, $53, $50, $4e, $4b, $48, $46, $43, $41, $3f, $3d, $3b, $39, $38, $36, $35, $34, $33, $32, $32, $32, $32, $32, $32, $32, $33, $34, $35, $36, $38, $39, $3b, $3d, $3f, $41, $43, $46, $48, $4b, $4e, $50, $53, $56, $58, $5b, $5e, $60, $63, $65, $68, $6a, $6d, $6f, $71, $73, $74, $76, $77, $78, $79, $7a, $7b, $7b, $7b, $7b, $7b, $7b, $7a, $7a, $79, $78, $76, $75, $73, $71, $6f, $6d, $6b, $69, $66, $64, $61, $5f, $5c, $59, $57, $54, $51, $4e, $4c, $49, $47, $44, $42, $40, $3e, $3c, $3a, $38, $37, $35, $34, $33, $33, $32, $32, $32, $32, $32, $32, $33, $34, $35, $36, $37, $39, $3a, $3c, $3e, $40, $43, $45, $48, $4a, $4d, $4f, $52, $55, $57, $5a, $5d, $5f, $62, $65, $67, $6a, $6c, $6e, $70, $72, $74, $75, $77, $78, $79, $7a, $7b, $7b, $7b, $7b, $7b, $7b, $7b, $7a, $79, $78, $77, $75, $74, $72, $70, $6e, $6c, $6a, $67, $65, $62, $5f, $5d, $5a, $57, $55, $52, $4f, $4d, $4a, $48, $45, $43, $40, $3e, $3c, $3a, $39, $37, $36, $35, $34, $33, $32, $32, $32, $32, $32, $32, $33, $33, $34, $35, $37, $38, $3a, $3c, $3e, $40, $42, $44, $47, $49, $4c, $4e, $51, $54, $55, $55, $55, $55, $55, $55, $aa, $aa, $aa, $55, $55, $55, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $ff, $ff, $ff, $aa, $aa, $aa, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $aa, $aa, $aa, $ff, $ff, $ff, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa, $55, $55, $55, $aa, $aa, $aa, $55, $55, $55, $55, $55, $55, $00

;
; screen text
;

* = $c400
!source "code/screen-text.asm"

;
;
;


; unused memory

!fill 16, $20

; sprite pointers 

!byte $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f 

;
; character set
;

* = $c800

!byte $55, $aa, $aa, $ff, $ff, $aa, $aa, $55, $3e, $60, $c6, $fe, $c6, $c6, $66, $00, $fc, $06, $ce, $fc, $c6, $ce, $fc, $00, $1e, $30, $60, $60, $60, $66, $3c, $00, $fc, $06, $c6, $c6, $cc, $dc, $f0, $00, $fe, $00, $c0, $f8, $c0, $e6, $7c, $00, $fe, $00, $c0, $f8, $c0, $c0, $60, $00, $7c, $e6, $c0, $ce, $c6, $ce, $7c, $00, $c6, $06, $c6, $fe, $c6, $c6, $66, $00, $fc, $00, $30, $30, $30, $30, $7c, $00, $7e, $00, $18, $18, $98, $d8, $70, $00, $c6, $0c, $d8, $f0, $d8, $cc, $46, $00, $c0, $00, $c0, $c0, $c0, $ce, $fc, $00, $26, $70, $fe, $d6, $d6, $c6, $66, $00, $66, $e0, $f6, $fe, $ce, $c6, $66, $00, $7c, $e6, $c6, $c6, $c6, $ce, $7c, $00, $fc, $06, $c6, $fc, $c0, $c0, $60, $00, $7c, $e6, $c6, $c6, $ce, $fe, $76, $00, $fc, $06, $c6, $fc, $d8, $cc, $66, $00, $7c, $e6, $c0, $7c, $06, $ce, $7c, $00, $fe, $00, $38, $38, $38, $38, $1c, $00, $c6, $c0, $c6, $c6, $c6, $6e, $3e, $00, $c6, $c0, $c6, $c6, $66, $36, $1c, $00, $66, $c0, $d6, $d6, $fe, $76, $32, $00, $66, $e0, $7c, $18, $7c, $ee, $66, $00, $c6, $c0, $c6, $6c, $38, $38, $38, $00, $7e, $46, $0c, $18, $30, $66, $7c, $00, $00, $00, $00, $03, $0f, $5f, $5f, $5f, $00, $00, $c0, $c0, $80, $ff, $ff, $f0, $5f, $5f, $5f, $5f, $0f, $00, $00, $00, $f0, $e0, $e0, $80, $80, $00, $00, $00, $00, $07, $0e, $0f, $1e, $1f, $1e, $1f, $00, $00, $00, $00, $00, $00, $00, $00, $b9, $b9, $b9, $b9, $b9, $b9, $b9, $b9, $66, $66, $66, $00, $00, $00, $00, $00, $66, $66, $ff, $66, $ff, $66, $66, $00, $18, $3e, $60, $3c, $06, $7c, $18, $00, $62, $66, $0c, $18, $30, $66, $46, $00, $3c, $66, $3c, $38, $67, $66, $3f, $00, $06, $0c, $18, $00, $00, $00, $00, $00, $0c, $18, $30, $30, $30, $18, $0c, $00, $30, $18, $0c, $0c, $0c, $18, $30, $00, $00, $66, $3c, $ff, $3c, $66, $00, $00, $00, $18, $18, $7e, $18, $18, $00, $00, $00, $00, $00, $00, $00, $18, $18, $30, $00, $00, $00, $7e, $00, $00, $00, $00, $00, $00, $00, $00, $00, $18, $18, $00, $00, $03, $06, $0c, $18, $30, $60, $00, $7c, $e6, $c6, $c6, $c6, $ce, $7c, $00, $38, $60, $18, $18, $18, $18, $1c, $00, $3c, $60, $06, $1c, $30, $66, $7c, $00, $7c, $00, $06, $3c, $06, $66, $3c, $00, $1c, $20, $6c, $cc, $fe, $0c, $0e, $00, $fe, $00, $c0, $fc, $06, $ce, $7c, $00, $3c, $66, $c0, $fc, $c6, $ce, $7c, $00, $fe, $00, $0c, $0c, $18, $18, $18, $00, $7c, $e0, $c6, $7c, $c6, $ce, $7c, $00, $7c, $e0, $c6, $7e, $06, $ce, $7c, $00, $00, $00, $18, $00, $00, $18, $00, $00, $00, $00, $18, $00, $00, $18, $18, $30, $0e, $18, $30, $60, $30, $18, $0e, $00, $00, $00, $7e, $00, $7e, $00, $00, $00, $70, $18, $0c, $06, $0c, $18, $70, $00, $3c, $66, $06, $0c, $18, $00, $18, $00


scrolltext

!scr "cracked on the 21st of november 1987...   now you can train yourself to kill communists and iranians...    latest top pirates : beastie boys  ikari  ace  hotline  danish gold  new wizax  tpi  tlc  antitrax  c64cg  triad  1001 crew  yeti  triton t  fcs  sca    overseas : eaglesoft  fbr  sol  nepa  abyss  xpb  ts  tih          pray that you will get an invitation to our great copy party in stockholm in december...        fuckings to watcher of the silents. you'll not destroy this party...       l8r           "


lcc00

!byte $00, $00, $00, $08

lcc04

!byte $10, $2e, $4e, $00, $00, $00, $08

lcc0b

!byte $40, $8a, $0a, $00, $00, $00, $07

lcc12

!byte $40, $0a, $0a, $00, $7d, $d6, $1f

lcc19
            ldx #$18
-
            lda lcc00,x
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


lcc5e
            dec $0354
            beq +
            jmp lcd1d
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
            lda lce01,y
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


lcd1d
            rts


!align 255, 0

;
; I think this is the music, not sure yet
;

lce00

!byte $57


lce01

!byte $ce, $06, $ce, $57, $ce, $03, $85, $06, $03, $e2, $04, $06, $2c, $05, $03, $cf, $05, $03, $cf, $05, $06, $85, $06, $03, $85, $06, $03, $e2, $04, $06, $2c, $05, $03, $cf, $05, $03, $cf, $05, $06, $85, $06, $03, $85, $06, $02, $85, $06, $01, $0a, $0d, $06, $2c, $05, $03, $cf, $05, $02, $e2, $04, $01, $cf, $05, $06, $85, $06, $03, $85, $06, $03, $e2, $04, $06, $2c, $05, $03, $cf, $05, $03, $e2, $04, $06, $42, $03, $00, $00, $00, $60, $00, $00, $03, $29, $34, $01, $8c, $3a, $01, $08, $3e, $01, $29, $34, $04, $a1, $45, $02, $08, $3e, $01, $8d, $3a, $01, $08, $3e, $04, $8d, $3a, $06, $29, $34, $03, $29, $34, $01, $8d, $3a, $01, $08, $3e, $01, $29, $34, $04, $a1, $45, $02, $08, $3e, $01, $8c, $3a, $01, $08, $3e, $04, $a1, $45, $06, $27, $4e, $03, $27, $4e, $01, $cd, $52, $01, $27, $4e, $01, $cd, $52, $04, $27, $4e, $02, $a1, $45, $01, $08, $3e, $01, $a1, $45, $04, $8d, $3a, $06, $29, $34, $03, $29, $34, $01, $8d, $3a, $01, $08, $3e, $01, $29, $34, $04, $a1, $45, $02, $08, $3e, $01, $8c, $3a, $01, $08, $3e, $02, $8c, $3a, $02, $78, $2e, $06, $29, $34, $02, $0a, $0d, $02, $0a, $0d, $01, $a3, $0e, $01, $82, $0f, $04, $b3, $14, $02, $89, $13, $02, $68, $11, $02, $82, $0f, $02, $a3, $0e, $03, $82, $0f, $01, $68, $11, $02, $a3, $0e, $02, $0a, $0d, $02, $0a, $0d, $01, $a3, $0e, $01, $82, $0f, $02, $b3, $14, $02, $89, $13, $02, $68, $11, $02, $82, $0f, $02, $a3, $0e, $02, $82, $0f, $06, $c4, $09, $02, $0a, $0d, $02, $a3, $0e, $02, $82, $0f, $02, $b3, $14, $02, $89, $13, $02, $68, $11, $02, $82, $0f, $02, $a3, $0e, $02, $82, $0f, $06, $82, $0f, $02, $0a, $0d, $02, $0a, $0d, $01, $a3, $0e, $01, $82, $0f, $02, $b3, $14, $02, $b3, $14, $02, $89, $13, $02, $68, $11, $02, $82, $0f, $01, $a3, $0e, $01, $82, $0f, $06, $0a, $0d, $06, $0a, $0d, $09, $82, $0f, $03, $a3, $0e, $06, $0a, $0d, $06, $13, $27, $09, $d0, $22, $03, $04, $1f, $06, $14, $1a, $03, $14, $1a, $02, $14, $1a, $01, $13, $27, $06, $66, $29, $03, $d0, $22, $02, $04, $1f, $01, $46, $1d, $06, $14, $1a, $03, $14, $1a, $03, $8a, $13, $06, $b3, $14, $04, $04, $1f, $05, $d0, $22, $03, $14, $1a, $00, $00, $00, $20, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00