# Debug Check List

If a core synthesizes correctly but shows odd behaviour, these are some of the items that may have gone wrong

## Total Failure
- Is the CPU memory size correct? The game may boot with a smaller RAM but fail later on
- Are the clock enable signals applied to the right clock domain? Check the CPU clk/clk_en pair
- Is the port direction correct in all modules? Quartus will fail to drive signals that are defined in all modules as inputs
- Are level interrupts held long enough?
- Strobe signals from one clock domain to another, or one cen-domain to another must use jtframe strobe synchronizers
- Is the frame interrupt getting to the CPU?
- Try disabling cycle recovery in the CPUs

## Video Artefacts
- The shifted screen counter should keep the right sequence around LVBL transitions

## Wrong Colours
- Is JTFRAME_COLORW correct?
- Is the bit plane order correct?
- If a color PROM is used, the bit plane order must be set right at the input
- Is the right part of the palette selected?

## Sound Problems
- Are interrupts coming correctly to the CPU?
- If unsigned and signed output modules are used for sound, the unsigned ones must be converted to signed using *jtframe_dcrm*

# New Core Check List

This text can be used in GitHub to generate a check list to use during code development

## Beta core development

**Ground Work**
- [ ] Schematics
- [ ] Hardware dependencies
- [ ] SDRAM mapping (mame2mra.toml and mem.yaml)
**RTL**
- [ ] Logic connected
- [ ] Tilemap logic
- [ ] Sprite logic
- [ ] Color mixer
- [ ] Graphics are correct
- [ ] Top level simulation hooked up correctly
- [ ] Simulation starts up correctly (See #27)
- [ ] Music sounds
- [ ] OSD sound options (FX level, FM/PSG enable)
- [ ] Synthesis ok
- [ ] Playable
**Final Verification**
- [ ] Button names in mame2mra.toml
- [ ] Add Patreon message
- [ ] Update README file
- [ ] Github actions updated so jtbuild builds the new core
- [ ] Check MiSTer
- [ ] Check Pocket
- [ ] Write Patreon entry

## Beta core publishing

**JTALPHA checks, if you didn't use jtbeta to make the JTALPHA files**
- [ ] Update README
- [ ] Folder Arcade/cores deleted in the other_zip
- [ ] MRA files included in the other_zip
- [ ] MiSTer file includes jtbeta.zip
**JTBIN checks**
- [ ] No files for non-beta RBF in JTBIN
- [ ] JTBIN has been comitted and pushed
- [ ] Correct link in JTBIN wiki
- [ ] Run update_all and check the files
- [ ] Files in Patreon, including jtbeta.zip as a separate file
**If jtbeta did not generate all the files directly**
- [ ] Files in github/jtbeta, including jtbeta.zip as a separate file
- [ ] No MRA/JSON files for unsupported games
- [ ] No empty folders in pocket
- [ ] No half-baked folders in pocket
- [ ] MRA files must be in JTBIN/mra and added to git
- [ ] At least one MRA file in JTBIN/mister/core/releases and added to git
- [ ] Beta MRA files should not load debug ROMs
- [ ] No RBF files for non MiSTer platforms in JTBIN
**After publishing**
- [ ] Tweet about the beta
- [ ] Files in #betafiles, including jtbeta.zip as a separate file

## Public release

- [ ] Remove jtbeta.zip from MRAs
- [ ] Recompile MiSTer without beta
- [ ] Recompile Sockit without beta
- [ ] Copy minor platforms to JTBIN
- [ ] Copy Pocket files to JTBIN
- [ ] Push branch to GitHub, if a local remote was used
- [ ] Make source code repository public, if it was private
**Unsupported games**
- [ ] mame2mra.toml discards unsupported games
- [ ] No MRA/JSON files for unsupported games in any repository
- [ ] issue in main repository listing unsupported games as possible _new cores_
