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
            lda #$0
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
; to get a reliable stable raster, code from this 
; excellent german article was used: 
; https://www.retro-programming.de/programming/nachschlagewerk/interrupts/der-rasterzeileninterrupt/raster-irq-endlich-stabil/
; 
; everything in here is only used to make sure the exact
; needed amount of cycles are count so that the real
; raster routine can be stable
;==========================================================

irq

            lda #<double_irq                ; 2 cycles create 2nd raster irq
            sta $0314                       ; 4 cycles
            lda #>double_irq                ; 2 cycles
            sta $0315                       ; 4 cycles
            tsx                             ; 2 cycles 
            stx double_irq+1                ; 4 cycles 
            nop                             ; 2 cycles
            nop                             ; 2 cycles
            nop                             ; 2 cycles
            lda #%00000001                  ; 2 cycles 
                                            ; = 26 cycles

            inc $d012                       ; 6 cycles                  
            sta $d019                       ; 4 cycles acknowledge irq
            cli                             ; 2 cycles 
                                
            ldx #$08                        ; 2 cycles
-
            dex                             ; 8 * 2 cycles = 16 cycles
            bne -                           ; 7 * 3 cycles = 21 cycles
                                            ; 1 * 2 cycles =  2 cycles
                                            ; = 41 cycles
            nop                             ; 2 cycles (56)
            nop                             ; 2 cycles (58)
            nop                             ; 2 cycles (60)
            nop                             ; 2 cycles (62)
            nop                             ; 2 cycles (64)
            nop                             ; 2 cycles (66)

double_irq

            ldx #$00                        ; 2 cycles Placycleshalter für 1. Stackpointer
            txs                             ; 2 cycles Stackpointer vom 1. IRQ wiederherstellen
            nop                             ; 2 cycles
            nop                             ; 2 cycles
            nop                             ; 2 cycles
            nop                             ; 2 cycles
            nop                             ; 2 cycles
            bit $01                         ; 3 cycles
            ldx $d012                       ; 4 cycles
            cpx $d012                       ; 4 cycles 
                                            ; = 25 cycles = 63 or 64 cycles
            
            beq main_irq                    ; 3 cycles waste 1 cycle or
                                            ; 2 cycles just continue
 

;==========================================================
; the main raster routine
;==========================================================

main_irq
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

            inc $02                         
            ldx $02
            cpx #table_sprite_y_pos_end - table_sprite_y_pos -1       ; end of sprite y pos table?
            bne +
            lda #$00
            sta $02
+
            lda table_sprite_y_pos,x
            ldy #$0e                        ; $0e is double the amount of sprites
-
            sta $d001,y                     ; but we skip every second address here with 2 deys
            dey                             ; effectively only changing the y pos of each sprite - clever
            dey
            bpl -
            lda $d001                       ; sprite #0 Y position
            cmp #50                         ; is our raster bar at the topmost position?
            bne +
            lda #$00                        ; then we change the 
-
            sta $d01b                       ; sprite priority foreground/background
            jmp set_volume
+
            cmp #123                        ; is our raster bar at the bottom position?
            bne +
            lda #$ff                        ; yes, so change priority foreground/background value again
            sta $d01b                       ; sprite priority foreground/background
            jmp set_volume

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
; set raster line for the scrolltext
;==========================================================

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
-
            ldx #$00                        ; yes, x = 0
            lda ($39,x)                     ; fetch a new character

            cmp #$00                        ; is the current byte = $00?
            bne +                           ; yes, then reset the scrolltext

            lda # >scrolltext               ; set high byte to start of scrolltext again
            sta $3a
            lda # <scrolltext               ; set low byte to start of scrolltext again
            sta $39
            jmp -                           ; and loop text
            
+
            sta last_character              ; store it at the last character pos
            inc $39                         ; increase address position
            lda $39                         ; and read it
            cmp #$00                        ; is it 0?
            bne color_cycle                 ; no, jump to next section
            inc $3a                         ; yes, increase high byte of address position
            jmp color_cycle


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

            lda set_volume +1               ; selfmod 
            cmp #$1f                        ; do not allow pressing space key before music is at full volume :)
            bne +
            jsr $ffe4                       ; GETIN
            cmp #$20                        ; check for space key
            bne +                           ; pressed?
            jmp exit                        ; yes, exit intro
+
            jsr $ffe4                       ; GETIN

          
            jsr music_play
            asl $d019                       ; acknowlege IRQ interrupt status
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
!byte 87, 89, 92, 95, 97, 100, 102, 105, 107, 109, 111, 113, 115, 116, 118, 119, 120, 121, 122, 122, 123, 123, 123, 123, 122, 122, 121, 120, 119, 117, 116, 114, 112, 110, 108, 106, 103, 101, 98, 96, 93, 91, 88, 85, 82, 80, 77, 75, 72, 70, 67, 65, 63, 61, 59, 57, 56, 54, 53, 52, 51, 51, 50, 50, 50, 50, 51, 51, 52, 53, 54, 55, 57, 58, 60, 62, 64, 66, 68, 71, 73, 76, 78, 81, 84, 87
table_sprite_y_pos_end


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
!source "code/screen-text-awsm.asm"


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
!scr "disassembled by awsm of mayday during many boring evenings of the covid 19 lockdown in 2021... check out my github account for the fully commented source code at   https://github.com/esshahn/c64-fairlight   greetings go out to... drumroll... fairlight   see you next time...         "
!byte $00


;==========================================================
; music player and data
;==========================================================
* = $cc01
!source "code/music.asm"