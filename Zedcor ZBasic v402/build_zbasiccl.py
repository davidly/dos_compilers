"""Build ZBASICCL.COM from the original DOS ZBasic 4.02 image.

Requires Python 3 and GNU binutils with i386 support.
"""
from hashlib import sha256
from pathlib import Path
from subprocess import check_output, run
from tempfile import TemporaryDirectory

root = Path(__file__).resolve().parent
image = bytearray((root / "ZBASIC.COM").read_bytes())
if sha256(image).hexdigest() != "071ecc9e7fb80e89e679f637884084c12a1625c9cb79b14f50e5f0ead0771fea":
    raise SystemExit("Expected the original DOS ZBasic 4.02 image")

# Startup uses the uninitialized data area before ZBasic initializes it.
# The resident hooks occupy the low end of the compiler's stack reserve.
sections = (("startup", 0xD3E2, 0xD4F0), ("driver", 0xCE8F, 0xCFC0))
with TemporaryDirectory() as tmp:
    work = Path(tmp)
    obj, exe, binary = (work / filename for filename in ("driver.o", "driver.elf", "driver.bin"))
    run(["as", "--32", "-o", obj, root / "zbasiccl.s"], check=True)
    addresses = [f"--section-start=.{name}={start:#x}" for name, start, _ in sections]
    run(["ld", "-m", "elf_i386", "-e", "start", *addresses, "-o", exe, obj], check=True)
    for name, start, limit in sections:
        run(["objcopy", "-O", "binary", "-j", f".{name}", exe, binary], check=True)
        data = binary.read_bytes()
        offset = start - 0x100
        if start + len(data) > limit or any(image[offset:offset + len(data)]):
            raise SystemExit(f"ZBasic {name} exceeds its reserved space ({len(data)} bytes)")
        image[offset:offset + len(data)] = data
    labels = {}
    for line in check_output(["nm", "-g", "--defined-only", exe], text=True).splitlines():
        address, _, name = line.split()
        labels[name] = int(address, 16)

for address, opcode, target, padding in (
    (0x0100, 0xE9, "start", 0),
    (0x5263, 0xE8, "command", 0),
    (0x5289, 0xE8, "command_line", 0),
    (0x0D11, 0xE8, "output_line", 0),
    (0x9E13, 0xE8, "closed", 0),
):
    offset = address - 0x100
    displacement = (labels[target] - address - 3) & 0xFFFF
    image[offset:offset + 3 + padding] = bytes([opcode]) + displacement.to_bytes(2, "little") + bytes([0x90]) * padding

(root / "ZBASICCL.COM").write_bytes(image)
