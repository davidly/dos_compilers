# Build sample program that uses BGIFONT.TPU and BGIDRIV.TPU
bgilink.exe: bgidriv.tpu bgifont.tpu
  tpc bgilink /m

# Build unit with all fonts linked in
bgifont.tpu: bgifont.pas goth.obj litt.obj sans.obj trip.obj
  tpc bgifont
goth.obj: goth.chr
  binobj goth.chr goth GothicFontProc
litt.obj: litt.chr
  binobj litt.chr litt SmallFontProc
sans.obj: sans.chr
  binobj sans.chr sans SansSerifFontProc
trip.obj: trip.chr
  binobj trip.chr trip TriplexFontProc


# Build unit with all drivers linked in
bgidriv.tpu: bgidriv.pas cga.obj egavga.obj herc.obj pc3270.obj att.obj
  tpc bgidriv
cga.obj: cga.bgi
  binobj cga.bgi cga CGADriverProc
egavga.obj: egavga.bgi
  binobj egavga.bgi egavga EGAVGADriverProc
herc.obj: herc.bgi
  binobj herc.bgi herc HercDriverProc
pc3270.obj: pc3270.bgi
  binobj pc3270.bgi pc3270 PC3270DriverProc
att.obj: att.bgi
  binobj att.bgi att ATTDriverProc
