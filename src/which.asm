; Copyright (C) 2020 Matt Currie <me@mattcurrie.com>
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in
; all copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;
; which.gbbc modification created by Jackson Shelton <jacksonshelton8@gmail.com>, 2021

IF (__RGBDS_MAJOR__ == 0 && (__RGBDS_MINOR__ < 4 || (__RGBDS_MINOR__ == 4 && __RGBDS_PATCH__ < 2)))
    FAIL "Requires RGBDS v0.4.2+"
ENDC

SECTION "lib", ROMX
INCLUDE "mgblib/src/hardware.inc"
INCLUDE "mgblib/src/macros.asm"
    enable_cgb_mode
INCLUDE "mgblib/src/old_skool_outline_thick.asm"
INCLUDE "mgblib/src/display.asm"
INCLUDE "mgblib/src/print.asm"
INCLUDE "mgblib/src/misc/delay.asm"


SECTION "initial-register-values", WRAM0

wInitialA::
    DS 1

wInitialB::
    DS 1

wInitialC::
    DS 1


SECTION "boot", ROM0[$100]
    nop                                       
    jp main         

SECTION "header", ROM0[$104]
    ds $143-@, $0

SECTION "header-remainder", ROM0[$144]
    ds $150-@, $0

SECTION "main", ROM0[$150]

main::
    di
    ld sp, $cfff

    ld [wInitialA], a
    ld a, b
    ld [wInitialB], a
    ld a, c
    ld [wInitialC], a

    call ResetDisplay
    call ResetCursor
    call LoadFont

    print_string_literal "which.gb v0.3.GBBC\n-------------\n\nseems to be a...\n\n"

    ld a, [wInitialA]
    cp $01
    jp z, is_dmg_or_sgb

    cp $ff
    jp z, is_mgb_or_sgb2

    cp $11
    jp z, is_cgb_or_agb_or_ags

    print_string_literal "Unknown!"
    jp done



is_dmg_or_sgb::
    ld a, [wInitialB]
    cp $ff
    jr z, is_dmg0

    ld a, [wInitialC]
    cp $13
    jr z, is_dmgABC

is_sgb::
    print_string_literal "SGB-CPU 01"
    jp done

is_dmg0::
    print_string_literal "DMG-CPU"
    jp done

is_dmgABC::
    print_string_literal "DMG-CPU A/B/C"
    jp done



is_mgb_or_sgb2::
    ld a, [wInitialC]
    cp $13
    jr z, is_mgb

is_sgb2::
    print_string_literal "CPU SGB2"
    jp done    

is_mgb::
    print_string_literal "CPU MGB"
    jp done    



is_cgb_or_agb_or_ags::
    ld a, [wInitialB]
    cp $00
    jp nz, is_agb_or_ags

is_cgb::
    ; wave ram is not initialised on cgb0
    ; and is initialized differently on newer (2020+?) GB Boy Colour revisions
    ; a checksum (adding the bytes) should result in a value of $7F8 on normal
    ; CGBs and GBBCs, so this assumes CGB0 if bit 3 is set after the test,
    ; and 2020+ GBBC if any bits 0-2 are set after the test.
    xor a
    ldh [$80], a
    ld c, $00
    ld hl, $ff30
.loop:
    xor a
    ld a, [hli]
    add c
    ld c, a
    ld a, l
    cp $40
    jr nz, .loop
    ld a, c
    add $08
    jp nc, is_cgb0
    and $07
    jr z, is_cgbABCDE
    ldh [$80], a

is_cgbABCDE::

    ; do some extra OAM writes
    ld hl, $fea0
    ld b, $55
    wait_vram_accessible
    ld [hl], b

    ld hl, $feb8
    ld b, $44
    wait_vram_accessible
    ld [hl], b

    ; read back value from $fea0
    ld hl, $fea0    
    wait_vram_accessible
    ld a, [hl]

    ; Expected values:
    ;   - cgb 0ABC: $44 - because $feb8 & ~$18 == $fea0, so more recent write overwrote $55
    ;   - cgb D: $55
    ;   - cgb E: $aa - ($fea0 & $f0) | (($fea0 & $f0) >> 4))

    cp $55
    jp z, is_cgbD

    cp $aa
    jp z, is_cgbE


is_cgbABC::
    call check_cgb_ab_or_c
    cp $00
    jr z, is_cgbA
    cp $01
    jr z, is_cgbB
    cp $02
    jp z, is_gbbc
    jr is_cgbC
    

is_cgbA::
    print_string_literal "\nCPU CGB A\n"
    print_string_literal "(if serial starts\nwith C10406\nor less)\n"
    jp done

is_cgbB::
    print_string_literal "\nCPU CGB B\n"
    jp done

is_cgbC::
    print_string_literal "CPU CGB C"
    jp done

is_cgbD::
    print_string_literal "CPU CGB D"
    jp done

is_cgbE::
    print_string_literal "CPU CGB E"
    jp done

is_cgb0::
    print_string_literal "CPU CGB\n"
    jp done

is_gbbc::
    ldh a, [$80]
    and $07
    jr nz, is_gbbc_2020
    print_string_literal "GB Boy Colour"
    print_string_literal "\n'05 - June '20 rev\n"
    jp done    

is_gbbc_2020::
    print_string_literal "GB Boy Colour"
    print_string_literal "\nJuly '20 rev\n"
    jp done

is_agb_or_ags::
    call check_agb_or_ags
    cp $22
    jr z, is_ags

is_agb::
    print_string_literal "CPU AGB 0/A/A E"
    jp done

is_ags::
    print_string_literal "CPU AGB B/B E"
    jp done


done::
    lcd_on

.forever:
    jr .forever

; Check some APU behavior to test if is a CGB CPU A/B or CPU CGB C or GB Boy Colour
;
; @return a '0' on CGB A, or '1' on CGB B, '2' on GBBC and '3' on CGB C
check_cgb_ab_or_c::
    ld hl, rNR52
    ld [rDIV], a
    xor a
    ldh [rNR52], a
    cpl
    ldh [rNR52], a

    ld a, 63
    ld [rNR31], a

    ld a, $80
    ld [rNR30], a

    ld a, $70
    ld [rNR33], a

    ; trigger the channel with length counter disabled
    ld a, $80
    ld [rNR34], a

    ; frame sequencer's next step is one that doesn't
    ; clock the length counter
    delay $800

    ; set sound length to 1
    ld a, 63
    ld [rNR31], a

    ; trigger the channel with length counter disabled again,
    ; should stop the channel on CGB 0/A and inconsistent Bs
    ld a, $00
    ld [rNR34], a

    nop

    ld a, [hl]
    bit 2, a
    jr nz, not_cgbA
    xor a
    ret
not_cgbA:
    ld [rDIV], a
    xor a
    ldh [rNR52], a
    cpl
    ldh [rNR52], a

    ld a, 63
    ld [rNR21], a

    ld a, $f0
    ld [rNR22], a

    ld a, $70
    ld [rNR23], a

    ; trigger the channel with length counter disabled
    ld a, $80
    ld [rNR24], a

    ; frame sequencer's next step is one that doesn't
    ; clock the length counter
    delay $800

    ; set sound length to 1
    ld a, 63
    ld [rNR31], a

    ; trigger the channel with length counter disabled again,
    ; should stop the channel on CGB B but not GBBC
    ld a, $00
    ld [rNR24], a

    nop

    ld a, [hl]
    bit 1, a
    jr nz, check_gbbc
    ld a, $01
    ret
check_gbbc:
    xor a
    ldh [rNR24], a
    ld a, [hl]
    bit 1, a
    jr nz, confirm_cgbC
    ld a, $02
    ret
confirm_cgbC:
    ld a, $03
    ret

; Check how VRAM reads behave at the transition from mode 3 to mode 0.
; Assumes LCD is off, and leaves LCD on afterwards.
; 
; @return a `$11` on AGB devices, or `$22` on AGS devices
check_agb_or_ags::
    ; fill tile data from $8000-8fff with alternating $11 and $22 values
    ld hl, $8000
    ld bc, $1000 / 2
.tile_data_loop:
    ld a, $11
    ld [hl+], a
    ld a, $22
    ld [hl+], a
    dec bc
    ld a, b
    or c
    jr nz, .tile_data_loop

    ; fill first row of tile map with $00
    xor a
    ld hl, $9c00
    ld bc, 32
    call MemSetSmall

    ; configure ppu registers
    bg_map_9c00
    bg_tile_data_8800
    xor a
    ldh [rSCY], a
    ld a, 3
    ldh [rSCX], a   ; SCX must be 3 to get the correct timing

    ; turn on the lcd
    ld hl, rLCDC
    set 7, [hl]

    ld hl, $8000
    delay 172

    ; first read is $00
    ld a, [hl]

    ; second read is $11 or $22
    delay 114 - 2
    ld a, [hl]

    ; reset registers to original values
    push af
    bg_map_9800
    xor a
    ldh [rSCX], a
    pop af

    ret
