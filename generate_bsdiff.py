import bsdiff4
import os
import sys

base_path = sys.argv[1]
patch_path = sys.argv[2]
base = open(base_path, 'rb').read()
patch = open(patch_path, 'rb').read()

bsdiff4.file_diff(base_path, patch_path, patch_path.replace(".sfc", ".bsdiff4"))

if not os.path.exists(patch_path.replace(".sfc", ".bsdiff4")):
    print("PATCH FAILED")

diff = bsdiff4.diff(base, patch)

print(len(diff))
