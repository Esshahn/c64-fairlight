;
;   This version is slightly optimized in many areas, moving around code 
;   where it makes sense. In addtion I added lots of comments
;

;==========================================================
; main entry
;==========================================================

* = CODE_START

            sei
            lda # >irq
            sta $0315                       ; IRQ vector routine high byte
            lda # <irq
            sta $0314                       ; IRQ vector routine low byte
            lda #$f
            sta $d012                       ; raster line
            lda #$01
            sta $d01a                       ; interrupt control
            lda #$7f
            sta $dc0d                       ; CIA #1 - interrupt control and status
            lda #$1b
            sta $d011                       ; screen control register #1, vertical scroll
            lda #$94
            sta $dd00                       ; CIA #2 - port A, serial bus access
            lda #$12
            sta $d018                       ; memory setup
            

;==========================================================
; set colors of the whole screen in color RAM
;==========================================================
         
            lda #$09                        ; set color ram for the logo
            ldx #$00                        ; x = 0
-
            sta $d800,x                     ; store 9 at $d800+x
            inx                             ; x = x + 1
            bne -                           ; loop until x wrapped to 0
            ldx #$20                        ; x = 20
-
            sta $d900,x                     ; store 20 at $d900+x
            dex                             ; x = x - 1
            bne -                           ; loop until x = 0
            lda #$01                        ; $01 = white
-
            sta $d920,x                     ; store 1 at $d920+x
            sta $da00,x                     ; store 1 at $da00+x
            sta $db00,x                     ; store 1 at $db00+x
            inx                             ; x = x + 1
            bne -                           ; loop until x = 0

            ldx #$c0                        ; sets color of text over the raster bars to 
            lda #$00                        ; $00 = black
-
            sta $da40,x
            dex
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
            

;==========================================================
; Init all sprites and position them as one fake raster bar
;==========================================================
            
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


;==========================================================
; set all sprite colors
;==========================================================

            lda #$0d                        ; $0d = light green 
            ldx #$07                        ; 0-7 sprites
-
            sta $d027,x                     ; sprite color
            dex
            bpl -                           ; loop until all sprite colors have been set
            lda #$05                        ; $05 = green
            sta $d025                       ; sprite extra color #1
            lda #$01                        ; $01 = white
            sta $d026                       ; sprite extra color #2
            
            lda #$00                        ; set address $02 to 0
            sta $02                         ; which is the position of the sinus table for the sprite raster bar
            
            jsr music_init
            lda #$10
            sta set_volume +1               ; set the volume level 
            
            lda # >scrolltext               ; store the address of the scrolltext
            sta $3a                         ; at zero page $39, $3a
            lda # <scrolltext
            sta $39

            ldx #$00
-
            lda color_wash,x                ; writes the colory cycle effect into color RAM
            sta $db20,x                    
            inx
            cpx #$28
            bne -

            lda #$00                        ; set $c5 and $c6 (keyboard matrix and buffer) to 0
            sta $c6
            sta $c5
            cli


endless_loop
            jmp *                           ; endless loop, all code is done in IRQ routine


























;==========================================================
; IRQ entrypoint
;==========================================================

irq
            lda #$01                        ; acknowlege IRQ
            sta $d019                       ; interrupt status
            lda set_volume +1               ; selfmod 
            cmp #$1f                        ; do not allow pressing space key before music is at full volume :)
            bne +
            jsr $ffe4                       ; GETIN
            cmp #$20                        ; check for space key
            bne +                           ; pressed?
            jmp exit                        ; yes, exit intro
+
       
            jsr $ffe4                       ; GETIN
            
            inc $02                         
            ldx $02
            lda table_sprite_y_pos,x
            ldy #$0e                        ; $0e is double the amount of sprites
-
            sta $d001,y                     ; but we skip every second address here with 2 deys
            dey                             ; effectively only changing the y pos of each sprite - clever
            dey
            bpl -
            lda $d001                       ; sprite #0 Y position
            cmp #$32                        ; is our raster bar at the topmost position?
            bne +
            lda #$00                        ; then we change the 
-
            sta $d01b                       ; sprite priority foreground/background
            jmp set_volume
+
            cmp #$7b                        ; is our raster bar at the bottom position?
            bne +
            lda #$ff                        ; yes, so change priority foreground/background value again
            jmp -
+
            cmp #$33
            bne set_volume
            lda set_volume +1               ; load volume
            cmp #$1f                        ; is it loud enough already?
            beq set_volume                  ; yes, move on
            inc set_volume +1               ; no, increase it


set_volume
            lda #$1f
            sta $d418                       ; volume and filter modes
            
            
;==========================================================
; set raster line for the (real) raster bars
;==========================================================

            lda #$a9                        ; start position of raster bars
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
            cpx #raster_color_end - raster_color
            bne draw_rasterbars

            lda #$d2                       ; raster line
-    
            cmp $d012
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
            bne color_cycle
            lda #$07
            sta $09
            ldx #$00                        ; x = 0
-
            lda scrollline+1,x              ; get character at scrolline+1+x
            sta scrollline,x                ; copy it to scrolline+x, moving it 1 char to the left
            inx                             ; x=x+1
            cpx #$27                        ; have we copied the full line already?
            bne -                           ; no, keep going
            ldx #$00                        ; yes, x = 0
            lda ($39,x)                     ; fetch a new character
            sta last_character              ; store it at the last character pos
            inc $39                         ; increase address position
            lda $39                         ; and read it
            cmp #$00                        ; is it 0?
            bne color_cycle                 ; no, jump to next section
            inc $3a                         ; yes, increase high byte of address position
            lda $3a                         ; and load it
            cmp # >scrolltext_end           ; is it $cc? (high byte of end of scrolltext)
            bne color_cycle                 ; no, next section
            lda # >scrolltext               ; yes, set high byte to start of scrolltext again
            sta $3a


color_cycle
            lda $db20                       ; get color value at $db20
            pha                             ; push it on the stack
            ldx #$00                        ; x=0
-
            lda $db21,x                     ; load color value at $db21+x
            sta $db20,x                     ; save it at $db20+x
            inx                             ; x=x+1
            cpx #$27                        ; have cycled through a full line?
            bne -                           ; no, keep going
            pla                             ; yes, get initial value from stack
            sta $db47                       ; put it at the end of the line

            jsr music_play

            jmp $ea31                       ; KERNAL's standard interrupt routine


exit
            sei
            lda #$ea                        ; $ea31 = original IRQ vector
            sta $0315                       ; IRQ vector routine high byte
            lda #$31
            sta $0314                       ; IRQ vector routine low byte
            jsr $ff81                       ; SCINIT
            lda #$97
            sta $dd00                       ; CIA #2 - port A, serial bus access
            cli
            jmp $fce2                       ; clean up IRQ and reset

























;==========================================================
; color wash effect table
;==========================================================

color_wash
!byte $01, $01, $01, $01, $01, $0f, $0f, $0f, $0f, $0f, $0c, $0c, $0c, $0c, $0c, $0b, $0b, $0b, $0b, $0b
!byte $01, $01, $01, $01, $01, $0f, $0f, $0f, $0f, $0f, $0c, $0c, $0c, $0c, $0c, $0b, $0b, $0b, $0b, $0b


;==========================================================
; color for the red and blue rasters
;==========================================================

raster_color
!byte $02
!byte $0a, $01, $01, $01, $0a, $0a, $02, $00
!byte $00, $00, $00, $00, $00, $06, $0e, $0e
!byte $01, $01, $0e, $0e, $06, $00, $00, $00
!byte $00, $00
raster_color_end

;==========================================================
; sinus table for the sprite rasterbar
;==========================================================

table_sprite_y_pos
!byte $57, $59, $5c, $5f, $61, $64, $66, $69, $6b, $6d, $6f, $71, $73, $75, $76, $78, $79, $7a, $7a, $7b
!byte $7b, $7b, $7b, $7b, $7b, $7a, $79, $78, $77, $76, $74, $73, $71, $6f, $6d, $6a, $68, $65, $63, $60
!byte $5e, $5b, $58, $56, $53, $50, $4e, $4b, $48, $46, $43, $41, $3f, $3d, $3b, $39, $38, $36, $35, $34
!byte $33, $32, $32, $32, $32, $32, $32, $32, $33, $34, $35, $36, $38, $39, $3b, $3d, $3f, $41, $43, $46
!byte $48, $4b, $4e, $50, $53, $56, $58, $5b, $5e, $60, $63, $65, $68, $6a, $6d, $6f, $71, $73, $74, $76
!byte $77, $78, $79, $7a, $7b, $7b, $7b, $7b, $7b, $7b, $7a, $7a, $79, $78, $76, $75, $73, $71, $6f, $6d
!byte $6b, $69, $66, $64, $61, $5f, $5c, $59, $57, $54, $51, $4e, $4c, $49, $47, $44, $42, $40, $3e, $3c
!byte $3a, $38, $37, $35, $34, $33, $33, $32, $32, $32, $32, $32, $32, $33, $34, $35, $36, $37, $39, $3a
!byte $3c, $3e, $40, $43, $45, $48, $4a, $4d, $4f, $52, $55, $57, $5a, $5d, $5f, $62, $65, $67, $6a, $6c
!byte $6e, $70, $72, $74, $75, $77, $78, $79, $7a, $7b, $7b, $7b, $7b, $7b, $7b, $7b, $7a, $79, $78, $77
!byte $75, $74, $72, $70, $6e, $6c, $6a, $67, $65, $62, $5f, $5d, $5a, $57, $55, $52, $4f, $4d, $4a, $48
!byte $45, $43, $40, $3e, $3c, $3a, $39, $37, $36, $35, $34, $33, $32, $32, $32, $32, $32, $32, $33, $33
!byte $34, $35, $37, $38, $3a, $3c, $3e, $40, $42, $44, $47, $49, $4c, $4e, $51, $54


;==========================================================
; the sprite
;==========================================================

* = SPRITE_DATA
sprite_data
; sprite data (why is it not called from anywhere)
; 3 bytes per horizontal line
; 21 lines
!byte $55, $55, $55
!byte $55, $55, $55
!byte $aa, $aa, $aa
!byte $55, $55, $55
!byte $aa, $aa, $aa
!byte $aa, $aa, $aa
!byte $aa, $aa, $aa
!byte $ff, $ff, $ff
!byte $aa, $aa, $aa
!byte $ff, $ff, $ff
!byte $ff, $ff, $ff
!byte $ff, $ff, $ff
!byte $aa, $aa, $aa
!byte $ff, $ff, $ff
!byte $aa, $aa, $aa
!byte $aa, $aa, $aa
!byte $aa, $aa, $aa
!byte $55, $55, $55
!byte $aa, $aa, $aa
!byte $55, $55, $55
!byte $55, $55, $55


;==========================================================
; all logo and text on the screen
;==========================================================

* = SCREEN
!source "code/screen-text.asm"


;==========================================================
; sprite pointers
;==========================================================

* = SPRITE_POINTERS
!byte $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f 


;==========================================================
; the charset in both assembly and binary format
;==========================================================

* = CHARACTER
;!source "code/charset.asm"
!bin "code/charset.bin"


;==========================================================
; the scrolltext
;==========================================================

scrolltext
!scr "cracked on the 21st of november 1987...   now you can train yourself to kill communists and iranians...    latest top pirates : beastie boys  ikari  ace  hotline  danish gold  new wizax  tpi  tlc  antitrax  c64cg  triad  1001 crew  yeti  triton t  fcs  sca    overseas : eaglesoft  fbr  sol  nepa  abyss  xpb  ts  tih          pray that you will get an invitation to our great copy party in stockholm in december...        fuckings to watcher of the silents. you'll not destroy this party...       l8r           "
scrolltext_end

;==========================================================
; music player and data
;==========================================================

!source "code/music.asm"