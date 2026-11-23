"""Generate TBCL.EXE or PBCL.EXE from the matching DOS BASIC executable.

Requires Python 3 and GNU binutils with i386 support.
"""
from hashlib import sha256
from pathlib import Path
from struct import pack_into, unpack_from
from subprocess import check_output, run
from tempfile import TemporaryDirectory

root = Path(__file__).resolve().parent
powerbasic = (root / "PB.EXE").is_file()
name = "PB" if powerbasic else "TB"
image = bytearray((root / f"{name}.EXE").read_bytes())
sha = ("419dd02e454752805c662a4cb0ffd1a2a961d5d6b464955aec5588c36376dd79" if powerbasic
       else "8b7a69067f11561a2f98baa4c8e69627195b65fd1ef2079296fa143788787caf")
if sha256(image).hexdigest() != sha:
    raise SystemExit(f"Unexpected {name}.EXE version")

reloc_count, header = unpack_from("<HH", image, 6)
header *= 16
reloc_table, = unpack_from("<H", image, 0x18)
old_ip, old_cs = unpack_from("<HH", image, 0x14)
if not powerbasic:
    image.extend(bytes(-len(image) % 16))
# PowerBASIC clears memory after its original image. Keep its driver in the
# unused space before the IDE code segment. Turbo BASIC can use appended code.
driver_offset = 0x31650 if powerbasic else len(image)
driver_segment = (driver_offset - header) // 16

with TemporaryDirectory() as tmp:
    work = Path(tmp)
    obj, elf, binary = (work / filename for filename in ("basiccl.o", "basiccl.elf", "basiccl.bin"))
    run(["as", "--32", f"--defsym=IMAGE_SEGMENT={driver_segment}",
         f"--defsym=OLD_IP={old_ip}", f"--defsym=OLD_CS={old_cs}",
         f"--defsym=POWERBASIC={int(powerbasic)}", "-o", obj, root / "basiccl.s"], check=True)
    run(["ld", "-m", "elf_i386", "-e", "start", "--section-start=.text=0", "-o", elf, obj], check=True)
    run(["objcopy", "-O", "binary", "-j", ".text", elf, binary], check=True)
    labels = {}
    for line in check_output(["nm", "-g", "--defined-only", elf], text=True).splitlines():
        address, _, label = line.split()
        labels[label] = int(address, 16)
    driver = binary.read_bytes()
    if powerbasic:
        end = driver_offset + len(driver)
        if end > 0x31950 or any(image[driver_offset:end]):
            raise SystemExit("PowerBASIC driver does not fit the reserved image region")
        image[driver_offset:end] = driver
    else:
        image.extend(driver)

def patch(file_offset, original, replacement):
    expected = bytes.fromhex(original)
    if image[file_offset:file_offset + len(expected)] != expected or len(expected) != len(replacement):
        raise SystemExit(f"Unexpected bytes at {file_offset:05x}")
    image[file_offset:file_offset + len(expected)] = replacement

# Route the IDE's compile command without calling the keyboard reader.
if powerbasic:
    selector, expected = 0x37591, "e8 fa fe 0b c0 74 f9"
    success, finish = 0x24705, "83 3e d8 38 00"
else:
    selector, expected = 0x2290, "e8 e9 0d 89 46 fe"
    success, finish = 0x2253A, "e8 6a 27 e8 56"
patch(selector, expected, b"\x9a" + labels["select_compile"].to_bytes(2, "little")
      + driver_segment.to_bytes(2, "little") + bytes.fromhex("c3 90" if powerbasic else "90"))
patch(success, finish, bytes.fromhex("b8 00 4c cd 21"))
if powerbasic:
    # Compile-error dialogs wait for input through this second reader.
    patch(0x361A1, "e8 ed 13 8b f0", bytes.fromhex("b8 01 4c cd 21"))

# DOS must relocate the segment word of the new far call.
reloc_word = selector - header + 3
reloc_entry = reloc_table + reloc_count * 4
if reloc_entry + 4 > header:
    raise SystemExit("No room for the new DOS relocation")
pack_into("<HH", image, reloc_entry, reloc_word % 16, reloc_word // 16)
pack_into("<H", image, 6, reloc_count + 1)
pack_into("<HH", image, 0x14, labels["start"], driver_segment)
pack_into("<HH", image, 2, len(image) % 512, (len(image) + 511) // 512)
(root / f"{name}CL.EXE").write_bytes(image)
