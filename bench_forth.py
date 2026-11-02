#!/usr/bin/env python3
"""Validate Forth benchmarks and report emulated cycles, using temporary copies."""
import argparse
from decimal import Decimal, localcontext
import json
from pathlib import Path
import re
import shutil
import statistics
import subprocess
import tempfile


def blocks(source):
    # F83 LOAD reads 16 fixed-width lines per 1024-byte screen. Reserve the
    # last line for -->; remove comments before wrapping long source lines.
    source = re.sub(r'\([^)]*\)', '', source)
    lines = []
    for line in source.splitlines():
        line = line.strip()
        if not line:
            continue
        while len(line) > 64:
            end = line.rfind(' ', 0, 64)
            if end <= 0:
                raise ValueError('F83 token longer than 64 characters')
            lines.append(line[:end])
            line = line[end+1:]
        lines.append(line)
    screens = [b' ' * 1024]
    for start in range(0, len(lines), 15):
        group = lines[start:start+15]
        if start+15 < len(lines):
            group.append('-->')
        screens.append(''.join(s.ljust(64) for s in group).ljust(1024).encode('ascii'))
    return b''.join(screens)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parent)
    parser.add_argument('--emulator', type=Path, required=True)
    parser.add_argument('--samples', type=int, default=3)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--allow-old-stack-leaks', action='store_true',
                        help='measure older versions while recording their stack leaks')
    args = parser.parse_args()
    if args.samples < 1:
        parser.error('samples must be positive')
    root = args.root.resolve()
    emulator = args.emulator.resolve()
    dos = 'ntvdm' in emulator.name.lower()
    with localcontext() as context:
        context.prec = 220
        digits = str(Decimal(1).exp()).replace('.', '')[:192]
    results = {}
    for directory in sorted(root.iterdir()):
        if not directory.is_dir() or 'forth' not in directory.name.lower():
            continue
        dx = directory.name.startswith('DX-')
        f83 = 'Forth 83' in directory.name
        row = {}
        results[directory.name] = row
        with tempfile.TemporaryDirectory(prefix='forth-bench-') as temporary:
            work = Path(temporary)
            # CP/M filenames remain uppercase; no files in the checkout change.
            for path in directory.iterdir():
                if path.is_file():
                    shutil.copy2(path, work/path.name)
            for app in ('SIEVE', 'E', 'TTT'):
                source = (directory/(app+'.F')).read_text()
                if not dx:
                    source = source[:source.rindex('\n'+app)]
                source += ('\n: BENCHMARK\n ." BENCH-BEGIN" CR\n'
                           ' 1234 '+app+'\n ." STACK " . DEPTH . CR\n'
                           ' ." BENCH-END" CR ;\n')
                command = [str(emulator), '-p', '-c']
                command += ['-u', '-r:.'] if dos else ['-n']
                if dx:
                    (work/'TEST.F').write_bytes(source.replace('\n', '\r\n').encode('ascii'))
                    command += ['FORTH.EXE' if dos else 'FORTH.COM', '-',
                                'include', 'TEST.F', 'BENCHMARK', 'bye']
                    input_bytes = None
                elif f83:
                    (work/'TEST.BLK').write_bytes(blocks(source+'\nBENCHMARK\nBYE\n'))
                    command += ['F83.COM']
                    input_bytes = b'FROM TEST.BLK 1 LOAD\r\nBYE\r\n'
                else:
                    command += ['CAMEL80.COM']
                    input_bytes = (source+'\nBENCHMARK\nBYE\n').replace('\n', '\r\n').encode('ascii')
                samples = []
                for _ in range(args.samples):
                    run = subprocess.run(command, cwd=work, input=input_bytes,
                                         capture_output=True, timeout=60, check=True)
                    output = (run.stdout+run.stderr).decode('latin1').replace('\r', '')
                    body = output.split('BENCH-BEGIN\n', 1)[1].split('BENCH-END', 1)[0]
                    result, stack = body.rsplit('STACK ', 1)
                    stack_values = [int(v) for v in stack.split()]
                    if not args.allow_old_stack_leaks and stack_values != [1234, 0]:
                        raise AssertionError((directory.name, app, 'unbalanced stack', stack_values))
                    if app == 'E':
                        actual = ''.join(re.findall(r'\d+', result))
                        assert actual == digits and 'done' in result, (directory.name, app, result)
                    elif app == 'SIEVE':
                        assert re.search(r'count of primes:\s*1899\b', result), result
                    else:
                        assert re.search(r'10 iterations\s+moves evaluated:\s*6493\b', result), result
                        assert 'bug' not in result and 'FAIL' not in result, result
                    cycle = re.search(r'(?:Z80|8080|8086)\s+cycles:\s*([\d,]+)', output)
                    samples.append(int(cycle[1].replace(',', '')))
                row[app] = dict(cycles=samples, median=statistics.median(samples),
                                stack=stack_values)
                print(directory.name, app, row[app], flush=True)
        args.output.write_text(json.dumps(results, indent=2)+'\n')
    if not results:
        raise ValueError('no Forth installations found')


if __name__ == '__main__':
    main()
