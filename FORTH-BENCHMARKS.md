# Forth benchmark improvements

Measured on 2026-11-01 with `ntvdm`, comparing the updated examples
with commit `ee1f19e69beccddd0969889f304392939df0ed90`. Values are median emulated CPU cycles
from three complete invocations, including interpreter startup, source loading,
compilation, output and stack checks. They are not modern-host timings.
Sieve retains ten passes over the original 8190 flags; e prints 192 digits;
TTT retains ten iterations, three openings and 6493 search nodes per iteration.

| Forth | App | Before cycles | After cycles | Reduction |
| --- | --- | ---: | ---: | ---: |
| 8086 Forth 83 v2.1.0 | SIEVE | 472,185,133 | 396,755,668 | 16.0% |
| 8086 Forth 83 v2.1.0 | E | 338,636,553 | 318,463,057 | 6.0% |
| 8086 Forth 83 v2.1.0 | TTT | 1,885,489,147 | 1,503,742,769 | 20.2% |
| DX-FORTH v430 | SIEVE | 408,952,066 | 347,816,074 | 14.9% |
| DX-FORTH v430 | E | 267,834,441 | 241,192,304 | 9.9% |
| DX-FORTH v430 | TTT | 1,413,056,703 | 1,157,208,026 | 18.1% |

## Changes

* Sieve uses a guarded `DO ... +LOOP` for marking multiples and keeps just
  the final pass count. The old version leaked nine counts onto the data stack.
* E keeps its accumulator on the data stack instead of in global `X`, reuses
  `/MOD` results, and drops both loop bookkeeping values when finished.
  The old version leaked its final high-water index (`9`). Its existing
  space-separated numeric output is preserved.
* TTT passes the last move explicitly, checks only winning lines through that
  move, reuses its board address, and keeps returned scores on the stack.
  Recursive move enumeration uses `DO`/`I` instead of global `boardIndex`.
  DX-Forth and CamelForth use `UNLOOP EXIT` on cutoffs; F83 uses its native
  immediate `LEAVE`, followed by the normal score return. No kernel is changed.
  Portable `< 0=` / `> 0=` comparisons avoid DX-Forth's missing `>=` / `<=`.

## Reproduce and validate

From this repository root:

```sh
python3 bench_forth.py --emulator ../ntvdm/ntvdm --output /tmp/forth-current.json
```

The runner works in temporary copies and leaves the checkout unchanged. It
independently checks all 192 digits using Python Decimal, the 1899-prime result,
TTT ties and node count, preservation of a caller stack value, and zero stack
growth. All updated examples pass those checks in all included Forth versions.
For a baseline checkout, use `--root /path/to/old/checkout` with
`--allow-old-stack-leaks`; this records the known old stack leaks while still
checking application results. `--samples` changes the number of invocations.

F83 source is temporarily converted into 1024-byte screens and loaded with
`FROM TEST.BLK 1 LOAD`. This avoids counting long, host-scheduled keyboard
polling loops while feeding entire source files as keystrokes. DX-Forth uses
`include TEST.F`; CamelForth uses redirected input. The usual `m.sh` and
`m.bat` workflows still run the examples normally. DOS keyboard/timer activity
causes some cycle variation, so the raw samples and binary SHA-256 are retained
in [forth-benchmark-results.json](forth-benchmark-results.json). Results measure
the local emulator binaries; no emulator changes are part of this update.
