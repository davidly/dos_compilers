"""Build TURBOCL.COM from the original DOS Turbo Pascal image.

Requires Python 3 and GNU binutils with i386 support. Run the result with
ntvdm -c TURBOCL.COM NAME.PAS alongside Turbo's message file. On Unix,
add -r:. -u to map DOS paths to uppercase filenames in the working directory.
"""

from hashlib import sha256
from pathlib import Path
from subprocess import check_output, run
from tempfile import TemporaryDirectory

ROOT = Path(__file__).resolve().parent
image = bytearray((ROOT / "TURBO.COM").read_bytes())
digest = sha256(image).hexdigest()

# Addresses are DOS COM load offsets, including the 100h PSP bias.
if digest == "9c2eaf393329ad4e2c08cc5718e43762076b17f01a99ac43dd07d7fb36171cc2":
    startup, menu, pause, poll = 0x24C7, 0x256F, 0x284F, 0x7AB0
    parser, parser_end = 0x25BE, 0x2668
    make_call, close_call, dos_io = 0x4A5C, 0x7A52, 0x7969
    symbols = dict(
        uses_fcb=1, diagnostics_flag=0x1C0, load_diagnostics=0x32EF,
        reset_source=0x3295, missing_vector=0x1C6, missing_source=0x2A2C,
        source_name=0x196, load_source=0x2957, compile_mode=0x1C1,
        compile_source=0x2EB8, output_name=0x455, disk_error=0x2F7F,
        dos_make=dos_io, dos_close=dos_io,
    )
elif digest == "232f3aa315a6bd2398ec1ab3156a2c8def5e03a935c9c3123e7e2a763782a9c9":
    startup, menu, pause, poll = 0x28E4, 0x29FE, 0x2D0E, 0x84D6
    parser, parser_end = 0x2A4D, 0x2B27
    make_call, close_call, dos_io = 0x522B, 0x8470, 0x8383
    symbols = dict(
        uses_fcb=1, diagnostics_flag=0x23D, load_diagnostics=0x3820,
        reset_source=0x37AC, missing_vector=0x243, missing_source=0x2EDC,
        source_name=0x1D1, load_source=0x2E03, compile_mode=0x23E,
        compile_source=0x33C6, output_name=0x4EB, disk_error=0x348D,
        dos_make=dos_io, dos_close=dos_io,
    )
elif digest == "71c0885778c1ad69eafdc459453da5a31e829266bc9bf67051a824cfa04a0614":
    startup, menu, pause, poll = 0x2E29, 0x2F64, 0x32A4, 0x9262
    parser, parser_end = 0x2FC4, 0x3090
    make_call, close_call = 0x5B07, None
    symbols = dict(
        uses_fcb=0, diagnostics_flag=0x34A, load_diagnostics=0x3D79,
        reset_source=0x3D0D, missing_vector=0x282, missing_source=0x347E,
        source_name=0x2C9, load_source=0x33DF, compile_mode=0x34B,
        compile_source=0x3912, output_name=0x5C8, disk_error=0x39D9,
        dos_make=0x0910, dos_close=0x0924,
    )
else:
    raise SystemExit("Expected an original DOS Turbo Pascal 1.00A, 2.00B, or 3.02A TURBO.COM")


def patch(address, code):
    offset = address - 0x100
    image[offset:offset + len(code)] = code


def branch(address, target, opcode):
    patch(address, bytes([opcode]) + (target - address - 3).to_bytes(2, "little", signed=True))


driver = startup + 3
with TemporaryDirectory() as temp:
    work = Path(temp)
    obj, linked = work / "cli.o", work / "cli.elf"
    definitions = [f"--defsym={key}={value}" for key, value in symbols.items()]
    run(["as", "--32", *definitions, "-o", obj, ROOT / "turbocl.s"], check=True)
    run(["ld", "-m", "elf_i386", "-e", "entry", f"--section-start=.driver={driver:#x}",
         f"--section-start=.parser={parser:#x}", "-o", linked, obj], check=True)
    labels = {}
    for line in check_output(["nm", "-g", "--defined-only", linked], text=True).splitlines():
        address, _, label = line.split()
        labels[label] = int(address, 16)
    for name, address, limit in [("driver", driver, menu), ("parser", parser, parser_end)]:
        binary = work / f"{name}.bin"
        run(["objcopy", "-O", "binary", "-j", f".{name}", linked, binary], check=True)
        code = binary.read_bytes()
        if address + len(code) > limit:
            raise SystemExit(f"{name} exceeds its reserved space")
        patch(address, code)

branch(startup, labels["entry"], 0xE9)
branch(menu, labels["failure"], 0xE9)
branch(pause, labels["failure"], 0xE9)
branch(make_call, labels["make_output"], 0xE8)
if close_call is not None:
    branch(close_call, labels["close_output"], 0xE8)
# Always report no pending keystroke at the compiler's abort check.
patch(poll, b"\x30\xc0\x90")
(ROOT / "TURBOCL.COM").write_bytes(image)
