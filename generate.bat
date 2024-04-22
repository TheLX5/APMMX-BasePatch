del "%~dp0mmx_basepatch.sfc"
del "%~dp0mmx_basepatch.bsdiff4"
copy /b/v/y "%~dp0Mega Man X (USA).sfc" "%~dp0mmx_basepatch.sfc"
asar.exe parche.asm "mmx_basepatch.sfc"
python generate_bsdiff.py "Mega Man X (USA).sfc" mmx_basepatch.sfc

copy /b/v/y "%~dp0mmx_basepatch.bsdiff4" "C:\ProgramData\Archipelago\lib\worlds\mmx\data\mmx_basepatch.bsdiff4"