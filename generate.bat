del "%~dp0mmx_basepatch.sfc"
del "%~dp0mmx_dirty.sfc"
del "%~dp0mmx_basepatch.bsdiff4"
copy /b/v/y "%~dp0Mega Man X (USA).sfc" "%~dp0mmx_basepatch.sfc"
copy /b/v/y "%~dp0Mega Man X (USA).sfc" "%~dp0mmx_dirty.sfc"

asar.exe neutralize.asm "mmx_dirty.sfc"

asar.exe parche.asm "mmx_basepatch.sfc"
python generate_bsdiff.py "mmx_dirty.sfc" mmx_basepatch.sfc

copy /b/v/y "%~dp0mmx_basepatch.bsdiff4" "A:\Archipelago\worlds\mmx\data\mmx_basepatch.bsdiff4"