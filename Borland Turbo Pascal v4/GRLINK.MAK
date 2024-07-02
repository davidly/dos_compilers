# Build sample program that uses FONTS.TPU and DRIVERS.TPU
grlink.exe: drivers.tpu fonts.tpu
  tpc grlink /m

# Build unit with all fonts linked in
fonts.tpu: fonts.pas goth.obj litt.obj sans.obj trip.obj
  tpc fonts
goth.obj: goth.chr
  binobj goth.chr goth GothicFontProc
litt.obj: litt.chr
  binobj litt.chr litt SmallFontProc
sans.obj: sans.chr
  binobj sans.chr sans SansSerifFontProc
trip.obj: trip.chr
  binobj trip.chr trip TriplexFontProc


# Build unit with all drivers linked in
drivers.tpu: drivers.pas cga.obj egavga.obj herc.obj pc3270.obj att.obj
  tpc drivers
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