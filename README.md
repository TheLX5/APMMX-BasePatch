# Archipelago's Mega Man X Base Patch
This repository contains all the static ASM that's used to implement MMX in [Archipelago](https://github.com/ArchipelagoMW/Archipelago).

## Build
Requires:
* Python for building asm files automatically
  * Any version that supports fstrings works
* [Asar 1.81](https://github.com/RPGHacker/asar/releases/tag/v1.81) for compiling (1.90 is fine, but it'll yell about warnpc)

Steps:
* Run `asar parche.asm <SMW ROM>`
  * Or `generate.bat`

You now have gotten the MMX ROM with the static code used in AP.
