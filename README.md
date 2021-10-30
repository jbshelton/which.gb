# which.gb

Just a little Game Boy ROM which tries to determine which model/revision your device is.  

It makes use of register values at boot, "extra OAM" differences, PPU quirks, and APU quirks that differ between device revisions.

## Limitations

It might not be perfect. I only had one case of someone's GB Boy Colour initializing wave RAM weird, so new GBBC detection may not be true.

Currently it cannot discern between all SoC revisions. Devices will be reported as one of the following:

- DMG-CPU
- DMG-CPU A/B/C
- CPU MGB
- SGB-CPU 01
- CPU SGB2
- CPU CGB
- CPU CGB A*
- CPU CGB B
- CPU CGB C
- CPU CGB D
- CPU CGB E
- CPU AGB 0/A/A E
- CPU AGB B/B E
- GB Boy Colour, June 2020(?) and older*
- GB Boy Colour, July 2020(?) and newer*

## Release Notes

v0.3.GBBC

- Discern between CGB A and B using differences in the wave channel length counter. Seems to be non-deterministic, but actual CGB Bs are detected correctly. Others may be detected incorrectly as CGB A due to non-deterministic behavior. Tell me if your CGB detects as A and B on separate test runs!
- Fixed GB Boy Colour being detected as CPU CGB C or CPU CGB
- Discern between CGB0/A/B and GB Boy Colour using channel 2's length counter. Instead of behaving like CGB0/A/B channel 1/2/4 (behavior is identical across those channels,) the channels behave like a true CGB B's wave channel length counter, which requires one extra write to NRx4 in order to disable the channel.
- Discern between older and newer GB Boy Colour SoCs with a different wave RAM test. I have not had the chance to test that many new GB Boy Colours to confirm this, so this detection feature may be removed due to it being non-deterministic.

v0.3

- Use VRAM reads at the transition from PPU mode 3 to mode 0 discern between devices with CPU AGB 0/A/A E (AGB and GB Player) and CPU AGB B/B E (AGS) revisions

v0.2.2

- Discern between CPU CGB 0/A/B/C, CPU CGB D, and CPU CGB E revisions using more simple "extra OAM" test

v0.2.1

- Fix for some "CPU CGB" devices incorrectly reporting as "CPU CGB A/B"

v0.2

- Add support for discerning between CPU CGB A/B and C revisions

## Credits

- Thanks to authors of [Gameboy sound hardware](https://gbdev.gg8.se/wiki/articles/Gameboy_sound_hardware) on the Gameboy Development Wiki.
- Thanks to Joonas Javanainen (gekkio) for his [mooneye-gb](https://github.com/Gekkio/mooneye-gb/) test ROMs which document the register values at boot.
- Original which.gb written by Matt Currie. 
- v0.3.GBBC version made by Jackson Shelton.

## License

MIT License. See included LICENSE file for details.
