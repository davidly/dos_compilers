#!/usr/bin/env python3
"""
perfrun.py - build and run the sieve / e / tm / mmi / mm / ttt benchmarks for each
compiler and record the numbers used by images/table.xlsx:

    sieve ms, e ms, tm ms, mm int ms, mm fp ms, ttt ms (per iteration), ttt app file size

mm is the BYTE (October 1982) 20x20 matrix multiply in floating point (MM.*;
software floating point: ntvdm has no 8087). mmi (MMI.*) is the same matrix
multiply with 16-bit integers: each element of C fits in 16 bits and the sum is
kept in base 10000. A tool runs whichever of the two its language supports.

Each compiler's m.sh (m.bat on Windows) builds a benchmark, deletes its
intermediate files, and runs the app with ntvdm -p. Times are for a 4.77 MHz
8086: the 8086 cycles ntvdm reports / 4770, the same figure as its "approx ms
at 4.77Mhz" line.

Each compiler runs in a temporary copy of its folder. Nothing in the repo is
modified; everything is deleted when the run finishes or is interrupted.
Results go to perfrun_results.csv, with rows named exactly as in column A of
the spreadsheet. A benchmark whose output doesn't show the expected result
(e.g. 1899 primes, 6493 moves, sum 465880) is recorded as FAIL.

usage: perfrun.py [-j jobs] [-t seconds] [-b benches] [-k] [--ntvdm path] [name-filter ...]

Works on Linux, macOS, and Windows (Python 3.8+). perfrun.sh and perfrun.bat
are wrappers for this script.
"""

import argparse
import concurrent.futures
import csv
import os
import re
import shutil
import signal
import subprocess
import sys
import tempfile
import threading
import time

IS_WINDOWS = os.name == "nt"

# One line per spreadsheet row. Fields are separated by '|'; '-' means none.
#   name    : spreadsheet row name (column A)
#   folder  : folder in this repo (copied as a whole; some scripts use ..)
#   dir     : subfolder holding the scripts and sources, . for the folder
#   benches : benchmarks to run
#   script  : m = m.sh / m.bat; mi = mi.sh / mi.bat (QuickBASIC interpreter)
#   timing  : which timing the script prints to use: last, or first (Artek's
#             script runs its interpreter and then its native code)
#   tttdiv  : ttt iterations performed by the benchmark (sheet shows per-iteration ms)
#   size    : file whose size is the "ttt app file size"; prog = the built .EXE/.COM
#   flags   : nocheck = app writes straight to video memory; don't look for the
#             expected result in its output. Otherwise -
# Artek Ada (comp) has no mm: its a86 translator makes wrong native code for every
# variation tried (float or integer, 2-D or 1-D arrays, nested procedures or not), though
# the interpreter (interp) runs the same MM.ADA correctly.
TABLE = r"""
Microsoft Assembler v1.0|Microsoft MASM v5|.|sieve,e,mmi,ttt|m|last|1|prog|-
Microsoft Pascal v1.1|Microsoft Pascal v1|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
Microsoft Pascal v2.0|Microsoft Pascal v2|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
IBM PC Pascal v1.00|IBM Pascal v1|.|sieve,e,mmi,mm,ttt|m|last|10|prog|-
IBM PC Fortran v1.00|IBM PC Fortran v1.00|.|sieve,e,mmi,mm,ttt|m|last|10|prog|-
DR MT+86 Pascal v3.1.1|Digital Research MT+86 Pascal v311|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
IBM PC BASIC Compiler v1.0|IBM PC BASIC Compiler v1.0|.|sieve,e,mmi,mm,ttt|m|last|10|prog|-
Microsoft BASIC Compiler v5.36|Microsoft BASIC Compiler v5.36|.|sieve,e,mmi,mm,ttt|m|last|100|prog|-
Digital Research CB-86 v2.0|Digital Research CB-86 v2|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
Digital Research PL/I-86 v1.0|Digital Research PLI-86 v1|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
Lattice C v2.12|Lattice C v2.12|.|sieve,e,tm,mmi,mm,ttt|m|last|10|prog|-
Microsoft C v1.0 (Lattice)|Microsoft C v1|.|sieve,e,tm,mmi,mm,ttt|m|last|100|prog|-
Microsoft Fortran v3.13|Microsoft Fortran v313|.|sieve,e,mmi,mm,ttt|m|last|10|prog|-
Microsoft C v2.03 (Lattice)|Microsoft C v203|.|sieve,e,tm,mmi,mm,ttt|m|last|100|prog|-
Borland Turbo Pascal v1.0|Borland Turbo Pascal v1|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
8086 Forth 83 v2.1.0|8086 Forth 83 v2.1.0|.|sieve,e,mmi,ttt|m|last|10|TTT.F|-
Digital Research C v1.1|Digital Research C v11|.|sieve,e,tm,mmi,mm,ttt|m|last|10|prog|-
BYTE Magazine Small-C v1.0|byte small-c v1|.|sieve,e,mmi,ttt|m|last|10|prog|-
RHA (Minisystems) ALGOL v5.5|RHA (Minisystems) ALGOL v55|.|sieve,e,mmi,mm,ttt|m|last|10|TTT.OBJ|-
DeSmet C88 v2.4|DeSmet C88 v24|.|sieve,e,tm,mmi,mm,ttt|m|last|10|prog|-
Microsoft GW-BASIC v2.02|Microsoft GW-BASIC v202|.|sieve,e,mmi,mm,ttt|m|last|10|TTT.BAS|-
Logitech Modula-2 v1.00|Logitech Modula-2 v1|.|sieve,e,mmi,ttt|m|last|10|TTT.LOD|-
Microsoft COBOL v1.12|Microsoft COBOL v112|.|sieve,e,mmi,ttt|m|last|1|prog|-
Borland Turbo Pascal v2.0|Borland Turbo Pascal v2|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
Logitech Modula-2 v1.10|Logitech Modula-2 v1.1|.|sieve,e,mmi,ttt|m|last|10|TTT.LOD|-
IBM PC Pascal v2.00|IBM Pascal v2|.|sieve,e,mmi,mm,ttt|m|last|10|prog|-
IBM PC Fortran v2.00|IBM PC Fortran v2.00|.|sieve,e,mmi,mm,ttt|m|last|10|prog|-
Addison-Wesley True BASIC v1.0|Addison-Wesley True BASIC v1.0|.|sieve,e,mm,ttt|m|last|10|TTT.TRU|-
Janus / ADA v1.5.2|Janus Ada v152|.|sieve,e,mmi,mm,ttt|m|last|10|prog|-
Microsoft COBOL v 2.1|Microsoft COBOL v21|.|sieve,e,mmi,ttt|m|last|1|TTT.INT|-
Mix C v2.0.2|Mix C v202|.|sieve,e,mmi,mm,ttt|m|last|10|prog|-
Microsoft C v3.0|Microsoft C v3|.|sieve,e,tm,mmi,mm,ttt|m|last|100|prog|-
Microsoft Fortran v3.31|Microsoft Fortran v331|.|sieve,e,mmi,mm,ttt|m|last|100|prog|-
Microsoft QuickBASIC v1.0|Microsoft QuickBASIC v1|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
Microsoft Pascal v3.31|Microsoft Pascal v3.31|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
Mix C v2.5.1|Mix C v251|.|sieve,e,mmi,mm,ttt|m|last|10|prog|-
Intel PL/M-86 v2.7|Intel PLM-83 v2.7|.|sieve,e,mmi,ttt|m|last|10|prog|-
Microsoft muLISP-86 v5.10|Microsoft muLISP-86 v51|.|sieve,e,mmi,ttt|m|last|10|TTT.LSP|-
Mark Williams MWC v3.1.1|Mark Williams MWC v311|code|sieve,e,tm,mmi,mm,ttt|m|last|100|prog|-
Manx Aztec C86 v3.40a|Manx Aztec C86 v340a|CODE|sieve,e,tm,mmi,mm,ttt|m|last|10|prog|-
Microsoft QuickBASIC v2.00|Microsoft QuickBASIC v200|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
Microsoft C v4.00|Microsoft C v4|.|sieve,e,tm,mmi,mm,ttt|m|last|100|prog|-
Borland Turbo Pascal v3.02A|Borland Turbo Pascal v3|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
Microsoft Fortran v4.10|Microsoft Fortran v41|.|sieve,e,mmi,mm,ttt|m|last|10|prog|-
Artek Ada Compiler v1.25 (comp)|Artek Ada v125|.|sieve,e,ttt|m|last|10|prog|-
Artek Ada Compiler v1.25 (interp)|Artek Ada v125|.|sieve,e,mmi,mm,ttt|m|first|10|TTT.AXE|-
Microsoft QuickBASIC v3.00|Microsoft QuickBASIC v3|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
Microsoft GW-BASIC v3.22|Microsoft GW-BASIC v322|.|sieve,e,mmi,mm,ttt|m|last|10|TTT.BAS|-
Borland Turbo C v1.0|Borland Turbo C v1|.|sieve,e,tm,mmi,mm,ttt|m|last|100|prog|-
Mark Williams MWC v4.0.12|Mark Williams MWC v4|code|sieve,e,tm,mmi,mm,ttt|m|last|100|prog|-
Mix Power C v1.0.0|Mix Power C v1|.|sieve,e,mmi,mm,ttt|m|last|10|prog|-
Borland Turbo BASIC 1.1|Borland Turbo BASIC v11|.|sieve,e,mmi,mm,ttt|m|last|10|prog|-
Microsoft QuickC v1.0|Microsoft QuickC v1|BIN|sieve,e,tm,mmi,mm,ttt|m|last|100|prog|-
Microsoft QuickBASIC v4.00 (comp)|Microsoft QuickBASIC v4|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
Microsoft QuickBASIC v4.00 (interp)|Microsoft QuickBASIC v4|.|sieve,e,mmi,mm,ttt|mi|last|1|TTT.BAS|-
Borland Turbo Pascal v4.0|Borland Turbo Pascal v4|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
Zedcor ZBasic v4.02|Zedcor ZBasic v402|.|sieve,e,mmi,mm,ttt|m|last|100|prog|-
Intel PL/M-83 v3.1|Intel PLM-83 v3.1|.|sieve,e,mmi,ttt|m|last|10|prog|-
Lattice C v3.30|Lattice C v3.30|.|sieve,e,tm,mmi,mm,ttt|m|last|10|prog|-
Microsoft COBOL v3.00A|Microsoft COBOL v300A|.|sieve,e,mmi,ttt|m|last|10|prog|-
DeSmet C88 v3.1b|DeSmet C88 v31b|.|sieve,e,mmi,mm,ttt|m|last|10|prog|-
TopSpeed Modula-2 v1.15|TopSpeed Modula-2 v1.15|.|sieve,e,mmi,mm,ttt|m|last|10|EXE/TTT.EXE|-
Microsoft QuickBASIC v4.50 (comp)|Microsoft QuickBASIC v45|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
Microsoft QuickBASIC v4.50 (interp)|Microsoft QuickBASIC v45|.|sieve,e,mmi,mm,ttt|mi|last|1|TTT.BAS|-
Microsoft Pascal v4.00|Microsoft Pascal v4|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
Microsoft C v5.0|Microsoft C v5|.|sieve,e,tm,mmi,mm,ttt|m|last|100|prog|-
Borland Turbo Pascal v5.0|Borland Turbo Pascal v5|.|sieve,e,mmi,mm,ttt|m|last|100|prog|-
Borland Turbo C v2.0|Borland Turbo C v2|.|sieve,e,tm,mmi,mm,ttt|m|last|100|prog|-
DeSmet PCC v1.2c|DeSmet PCC v12c|.|sieve,e,tm,mmi,mm,ttt|m|last|100|prog|-
Microsoft QuickC v2.0|Microsoft QuickC v2|.|sieve,e,tm,mmi,mm,ttt|m|last|100|prog|-
Borland Turbo Pascal v5.5|Borland Turbo Pascal v55|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
Microsoft QuickPascal v1.00|Microsoft QuickPascal v1|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
Microsoft Fortran v5.0|Microsoft Fortran v5|.|sieve,e,mmi,mm,ttt|m|last|10|prog|-
Manx Aztec C86 v4.2b|Manx Aztec C86 v42b|code|sieve,e,tm,mmi,mm,ttt|m|last|100|prog|-
Borland Turbo Pascal v6.0|Borland Turbo Pascal v6|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
Spectra PowerBASIC v2.10f|Spectra PowerBASIC v210f|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
Intel iC-86 Compiler v4.5|Intel iC-86 Compiler v4.5|.|sieve,e,tm,mmi,mm,ttt|m|last|10|prog|-
Ashwood-Smith PC-LISP v3.00|Ashwood-Smith PC-LISP v3|.|sieve,e,mmi,mm,ttt|m|last|1|TTT.LSP|-
Logitech Modula-2 v3.40|Logitech Modula-2 v34|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
Zortech C++ v2.06|Zortech C++ v206|CODE|sieve,e,tm,mmi,mm,ttt|m|last|10|prog|-
Borland Turbo C++ v1.0|Borland Turbo C++ v1|BIN|sieve,e,tm,mmi,mm,ttt|m|last|10|prog|-
Microsoft QuickBASIC v7.1 (comp)|Microsoft QuickBASIC v71|.|sieve,e,mmi,mm,ttt|m|last|1|prog|-
Microsoft QuickBASIC v7.1 (interp)|Microsoft QuickBASIC v71|.|sieve,e,mmi,mm,ttt|mi|last|1|TTT.BAS|-
Microsoft C v6.00AX|Microsoft C v6ax|CODE|sieve,e,tm,mmi,mm,ttt|m|last|10|prog|-
Microsoft COBOL v4.5|Microsoft COBOL v45|BINB|sieve,e,mmi,ttt|m|last|10|prog|-
Microsoft Fortran v5.1|Microsoft Fortran v51|.|sieve,e,mmi,mm,ttt|m|last|10|prog|-
Zortech C++ 3.0r1|Zortech C++ v30r1|CODE|sieve,e,tm,mmi,mm,ttt|m|last|10|prog|-
Oberon v1.2|Oberon-M v1.2|.|sieve,e,mmi,ttt|m|last|1|prog|nocheck
Microsoft QuickC v2.51|Microsoft QuickC v251|BIN|sieve,e,tm,mmi,mm,ttt|m|last|100|prog|-
Borland Turbo Pascal v7.0|Borland Turbo Pascal v7|BIN|sieve,e,mmi,mm,ttt|m|last|1|prog|-
TopsSpeed Modula-2 v3.10|TopSpeed Modula-2 v3.40|.|sieve,e,mmi,mm,ttt|m|last|10|prog|-
Manx Aztec C86 v5.2a|Manx Aztec C86 v52a|code|sieve,e,tm,mmi,mm,ttt|m|last|100|prog|-
Stony Brook Pascal+ v6.14e|Stony Brook Pascal+ v614e|CODE|sieve,e,mmi,mm,ttt|m|last|10|prog|-
Mix Power C v2.2.0|Mix Power C v22|.|sieve,e,mmi,mm,ttt|m|last|10|prog|-
Microsoft COBOL v5.0|Microsoft Cobol v5|BIN|sieve,e,mmi,ttt|m|last|10|prog|-
DDS MICRO-C 8086 Compiler v3.02|DDS MICRO-C 8086 v3.02|.|sieve,e,tm,mmi,ttt|m|last|10|prog|-
DX-Forth v4.30|DX-FORTH v430|.|sieve,e,mmi,ttt|m|last|10|TTT.F|-
DDS MICRO-C PC86 v3.23|dds micro-c pc86 v3.23|.|sieve,e,mmi,ttt|m|last|10|prog|-
"""

# Spreadsheet rows this script can't produce: the binaries come from
# cross-compilers or tools that aren't in this repo.
NOT_COVERED = [
    "Digital Mars Compiler v8.42n, ia16 GCC v6.3.0, Bruce's bcc v0.16.10a, Free Pascal v3.2.2, "
    "Open Watcom v2.0 beta (cross-compilers)",
    "BA BASIC (comp/interp/OneImage interp), OI Assembler (not in this repo)",
]

# Text a correct run prints; without it the timing is meaningless.
EXPECTED = {
    "sieve": re.compile(rb"1899"),
    "e": re.compile(rb"(?i)\bdo(ne)?\b|27182818|13232862794349076323382988075319"),
    "tm": re.compile(rb"(?i)success"),
    # the sum as printed after its label, e.g. "summ is : 465880.000000", "SUM =  465880",
    # "summ is :    4.6588E+05", "summ is exactly 465880" where a runtime rounds what it prints,
    # or "summ rounds to 465880" where a runtime's reals are too short to be exact
    "mm": re.compile(rb"(?i)summ?\s*(is\s*)?(:|=|exactly|rounds to)?\s*(465880\b|4\.65880*\s*E\+?0*5\b)"),
    "mmi": re.compile(rb"(?i)summ?\s*(is\s*)?(:|=|exactly)?\s*465880\b"),
    "ttt": re.compile(rb"6493"),
}

CYCLES_RE = re.compile(rb"8086 cycles:\s*([\d,]+)")
CYCLES_PER_MS = 4770  # 4.77 MHz

print_lock = threading.Lock()
active_procs = set()
active_lock = threading.Lock()
stopping = threading.Event()


def say(text=""):
    with print_lock:
        print(text, flush=True)


class Row:
    def __init__(self, index, line):
        f = line.split("|")
        self.index = index
        self.name, self.folder, self.dir, benches, self.script, self.timing = f[:6]
        self.benches = benches.split(",")
        self.tttdiv = int(f[6])
        self.size = f[7]
        self.flags = set() if f[8] == "-" else set(f[8].split(","))


def parse_table():
    return [Row(i, l) for i, l in enumerate(l for l in TABLE.splitlines() if l.strip())]


def kill_tree(p):
    try:
        if IS_WINDOWS:
            subprocess.run(["taskkill", "/T", "/F", "/PID", str(p.pid)],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        else:
            os.killpg(p.pid, signal.SIGKILL)
    except (OSError, ProcessLookupError):
        pass


def run_proc(args, cwd, env, timeout):
    """Run a command, return output bytes. Kills the whole process tree on
    timeout (the scripts start ntvdm as a child)."""
    if stopping.is_set():
        return b""
    kw = {}
    if IS_WINDOWS:
        kw["creationflags"] = subprocess.CREATE_NEW_PROCESS_GROUP
    else:
        kw["start_new_session"] = True
    try:
        p = subprocess.Popen(args, cwd=cwd, env=env, stdin=subprocess.DEVNULL,
                             stdout=subprocess.PIPE, stderr=subprocess.STDOUT, **kw)
    except OSError as e:
        return ("error starting %s: %s\n" % (args[0], e)).encode()
    with active_lock:
        active_procs.add(p)
    try:
        out, _ = p.communicate(timeout=timeout)
        return out
    except subprocess.TimeoutExpired:
        kill_tree(p)
        out, _ = p.communicate()
        return out + b"\n[perfrun: timed out]\n"
    finally:
        with active_lock:
            active_procs.discard(p)


class Runner:
    def __init__(self, args, root, work, ntvdm):
        self.args = args
        self.root = root
        self.work = work
        self.env = dict(os.environ)
        # the scripts run "ntvdm"; make sure it's the one perfrun found
        self.env["PATH"] = os.path.dirname(ntvdm) + os.pathsep + self.env.get("PATH", "")

    def run_entry(self, row):
        top = os.path.join(self.work, "%03d" % row.index)
        d = os.path.join(top, row.dir)
        log = []
        result = {"notes": ""}
        try:
            shutil.copytree(os.path.join(self.root, row.folder), top,
                            ignore=shutil.ignore_patterns("*.pdf", "*.PDF"))
            for b in row.benches:
                result[b] = self.run_bench(row, b, d, log, result)
        except OSError as e:
            log.append(("perfrun: %s\n" % e).encode())
            for b in row.benches:
                result.setdefault(b, "FAIL")
        finally:
            shutil.rmtree(top, ignore_errors=True)
            try:
                with open(os.path.join(self.work, "results", "%03d.log" % row.index), "wb") as f:
                    f.write(b"".join(log).replace(b"\0", b""))
            except OSError:
                pass  # work dir already removed after Ctrl-C
        return result

    def run_bench(self, row, b, d, log, result):
        if IS_WINDOWS:
            argv = ["cmd", "/d", "/c", ".\\%s.bat" % row.script, b]
        else:
            argv = ["bash", "%s.sh" % row.script, b]
        out = run_proc(argv, d, self.env, self.args.timeout)
        log.append(("===== %s: %s\n" % (row.name, b.upper())).encode() + out)

        cycles = list(CYCLES_RE.finditer(out))
        # check the output of the run that's timed: when a script runs two apps (Artek's
        # interpreter, then its native code), the other app's result doesn't count
        if not cycles:
            timed = out
        elif row.timing == "first":
            timed = out[:cycles[0].end()]
        else:
            timed = out[cycles[-2].end() if len(cycles) > 1 else 0:cycles[-1].end()]
        if not cycles or ("nocheck" not in row.flags and not EXPECTED[b].search(timed)):
            result["fail_%s" % b] = out[-2500:]
            return "FAIL"
        c = (cycles[0] if row.timing == "first" else cycles[-1]).group(1)
        ms = int(c.replace(b",", b"")) // CYCLES_PER_MS

        if b == "ttt":
            result["size"] = self.ttt_size(row, d)
            return str((ms + row.tttdiv // 2) // row.tttdiv)
        return str(ms)

    def ttt_size(self, row, d):
        if row.size == "prog":
            names = [f for f in os.listdir(d) if f.upper() in ("TTT.EXE", "TTT.COM")]
            p = os.path.join(d, names[0]) if names else None
        else:
            p = os.path.join(d, row.size)
            if not os.path.isfile(p) and not IS_WINDOWS:
                p = os.path.join(d, row.size.upper())
        return str(os.path.getsize(p)) if p and os.path.isfile(p) else "FAIL"


def find_ntvdm(explicit):
    if explicit:
        return os.path.abspath(explicit) if os.path.isfile(explicit) else None
    name = "ntvdm.exe" if IS_WINDOWS else "ntvdm"
    # search the PATH only, not the current directory
    for p in os.environ.get("PATH", "").split(os.pathsep):
        c = os.path.join(p.strip('"'), name)
        if p and os.path.isfile(c):
            return os.path.abspath(c)
    if IS_WINDOWS and os.path.isfile(r"c:\ntbin\ntvdm.exe"):
        return r"c:\ntbin\ntvdm.exe"
    return None


def fmt(v):
    return v if v else "-"


def main():
    ap = argparse.ArgumentParser(
        description="Build and time the sieve/e/tm/mmi/mm/ttt benchmarks for each compiler; "
                    "writes perfrun_results.csv for images/table.xlsx.")
    ap.add_argument("filters", nargs="*",
                    help="only run rows whose spreadsheet name or folder contains one of these (case-insensitive)")
    ap.add_argument("-j", "--jobs", type=int, default=os.cpu_count() or 4,
                    help="compilers to run in parallel (default: number of cpus)")
    ap.add_argument("-t", "--timeout", type=int, default=3600,
                    help="timeout in seconds for each benchmark's build and run (default 3600)")
    ap.add_argument("-b", "--benches",
                    help="comma-separated benchmarks to run (default: all in the table)")
    ap.add_argument("-k", "--keep-logs", action="store_true",
                    help="keep the build/run logs (the binaries are still deleted)")
    ap.add_argument("--ntvdm", help="ntvdm for the scripts to use (default: the one on the PATH"
                    + (r", then c:\ntbin" if IS_WINDOWS else "") + ")")
    args = ap.parse_args()

    root = os.path.dirname(os.path.abspath(__file__))
    ntvdm = find_ntvdm(args.ntvdm)
    if not ntvdm:
        sys.exit("perfrun: can't find ntvdm; put it on the PATH or use --ntvdm")

    rows = parse_table()
    if args.filters:
        fl = [f.lower() for f in args.filters]
        rows = [r for r in rows if any(f in (r.name + "|" + r.folder).lower() for f in fl)]
        if not rows:
            sys.exit("perfrun: no rows match: " + " ".join(args.filters))

    if args.benches:
        only = args.benches.lower().split(",")
        for r in rows:
            r.benches = [b for b in r.benches if b in only]
        rows = [r for r in rows if r.benches]

    work = tempfile.mkdtemp(prefix="perfrun.")
    os.makedirs(os.path.join(work, "results"))
    runner = Runner(args, root, work, ntvdm)
    results = {}
    start = time.time()

    say("perfrun: %d compilers, %d at a time, using %s" % (len(rows), args.jobs, ntvdm))

    def do(row):
        res = runner.run_entry(row)
        results[row.index] = res
        say("  %-45s sieve %-8s e %-8s tm %-8s mmi %-8s mm %-9s ttt %-8s size %s" % (
            row.name, fmt(res.get("sieve")), fmt(res.get("e")), fmt(res.get("tm")),
            fmt(res.get("mmi")), fmt(res.get("mm")), fmt(res.get("ttt")), fmt(res.get("size"))))

    pool = concurrent.futures.ThreadPoolExecutor(max_workers=max(1, args.jobs))
    try:
        pending = {pool.submit(do, r) for r in rows}
        while pending:
            # short waits so Ctrl-C is seen promptly (also on Windows)
            done, pending = concurrent.futures.wait(pending, timeout=1)
            for f in done:
                f.result()
        pool.shutdown()
    except KeyboardInterrupt:
        say("\nperfrun: interrupted, cleaning up")
        stopping.set()
        with active_lock:
            for p in list(active_procs):
                kill_tree(p)
        pool.shutdown(wait=True, cancel_futures=True)
        shutil.rmtree(work, ignore_errors=True)
        sys.exit(130)

    out_csv = os.path.join(root, "perfrun_results.csv")
    with open(out_csv, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["compiler", "sieve ms", "e ms", "tm ms", "mm int ms", "mm fp ms", "ttt ms",
                    "ttt app file size", "notes"])
        for r in rows:
            res = results.get(r.index, {})
            w.writerow([r.name, res.get("sieve", ""), res.get("e", ""), res.get("tm", ""),
                        res.get("mmi", ""), res.get("mm", ""), res.get("ttt", ""), res.get("size", ""),
                        res.get("notes", "")])

    failed = [r for r in rows if "FAIL" in results.get(r.index, {}).values()]
    if failed:
        say("\nFailures (last lines of output):")
        for r in failed:
            res = results[r.index]
            for b in r.benches:
                detail = res.get("fail_%s" % b)
                if detail is None:
                    continue
                say("---- %s: %s" % (r.name, b))
                text = detail.replace(b"\0", b"").decode("latin-1").replace("\r", "")
                for l in [l for l in text.split("\n") if l.strip()][-10:]:
                    say("    " + l)
            if res.get("size") == "FAIL":
                say("---- %s: ttt size file %s not found" % (r.name, r.size))

    say("\nNot covered by this script:")
    for n in NOT_COVERED:
        say("  " + n)

    if args.keep_logs:
        say("\nperfrun: kept build/run logs in " + os.path.join(work, "results"))
    else:
        shutil.rmtree(work, ignore_errors=True)
    say("\nResults: %s (%ds)" % (out_csv, time.time() - start))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
