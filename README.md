# which.gb

Just a little Game Boy ROM which tries to determine which model/revision your device is.  

It makes use of register values at boot, "extra OAM" differences, PPU quirks, APU quirks, and OAM DMA bus conflicts that differ between device revisions.

## Limitations

It might not be perfect. Let me know if your device is detected incorrectly!

Currently it cannot discern between all SoC revisions. Devices will be reported as one of the following:

- DMG-CPU
- DMG-CPU A/B/C
- CPU MGB
- SGB-CPU 01
- CPU SGB2
- CPU CGB
- CPU CGB A
- CPU CGB B
- CPU CGB C
- CPU CGB D
- CPU CGB E
- CPU AGB 0/A/A E
- CPU AGB B/B E

It can also detect and discern between a few different Gameboy clone SoCs! Here are the ones currently supported:

- Kong Feng KF2001 (early- estimated to be 1997-2008)
- Kong Feng KF2001 (late- estimated to be 2008-2009)
- Kong Feng KF2005 (early GB Boy Colour) or KF2007 (later GB Boy Colour) (though it cannot discern between the two specifically)

## Release Notes

v0.4.2

- Removed CGB B early and late detection due to behavior being unit specific
- Changed GB Boy Colour detection back to the length counter method due to the OAM DMA test being unit specific and sometimes erroneously detecting as CGB B
- Cleaned up the code a bit

v0.4.1

- Detect KF2001 clone SoCs based on different wave RAM corruption behavior, and discern between earlier and later revisions using channel 1 sweep behavior differences
- Changed KF2005/KF2007 (GB Boy Colour) detection method to be based based on OAM DMA bus conflict behavior added in v0.4 instead of channel 2 length counter behavior in v0.3.GBBC
- Added CGB B early and late detection based on channel 3 length counter behavior (however, it may just be unit specific)
- Removed GB Boy Colour wave RAM test

The OAM DMA conflict test actually returns $10 for CGB B and $00 for GB Boy Colour, though I need to test more units to verify the behavior properly.

v0.4

- Use an OAM DMA bus conflict to discern between devices with CPU CGB A and CPU CGB B revision SOCs. Thanks to [LIJI32](https://github.com/LIJI32/) for discovering this!

v0.3.GBBC

- Discern between CGB A and B using differences in the wave channel length counter. Behavior has since been used for early and late CGB B detection since CGB A cannot be detected using this method, but rather with other means.
- Fixed GB Boy Colour being detected as CPU CGB C (or CPU CGB)
- Discern between CGB0/A/B and GB Boy Colour using channel 2's length counter. Instead of behaving like CGB0/A/B channel 1/2/4 (behavior is identical across those channels,) the channels behave like a late CGB B's wave channel length counter, which requires one extra write to NRx4 in order to disable the channel.
- Discern between older (pre-2018) and newer (post-2018) GB Boy Colour SoCs with a different wave RAM test. This detection feature has been removed due to it being unit specific and dependent on faulty wave RAM.

v0.3

- Use VRAM reads at the transition from PPU mode 3 to mode 0 discern between devices with CPU AGB 0/A/A E (AGB and GB Player) and CPU AGB B/B E (AGS) revisions

v0.2.2

- Discern between CPU CGB 0/A/B/C, CPU CGB D, and CPU CGB E revisions using more simple "extra OAM" test

v0.2.1

- Fix for some "CPU CGB" devices incorrectly reporting as "CPU CGB A/B"

v0.2

- Add support for discerning between CPU CGB A/B and C revisions

## Credits

- Thanks to Lior Halphon (LIJI32) for his research and [SameSuite](https://github.com/LIJI32/SameSuite) test ROMs.
- Thanks to authors of [Gameboy sound hardware](https://gbdev.gg8.se/wiki/articles/Gameboy_sound_hardware) on the Gameboy Development Wiki.
- Thanks to Joonas Javanainen (gekkio) for his [mooneye-gb](https://github.com/Gekkio/mooneye-gb/) test ROMs which document the register values at boot.
- Thanks to Ben Morris for archiving [blargg's Gameboy hardware tests](https://github.com/retrio/gb-test-roms) on which KF2001 (revision) detection was based.
- Written by Matt Currie
- Clone detection modifications by Jackson Shelton / Reverse Retro

## License

MIT License. See included LICENSE file for details.
