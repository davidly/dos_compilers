# Build sample program that uses BGIFONT.TPU and BGIDRIV.TPU

# Change the following macro to point to your \BGI directory:
BGI = ..\..\bgi

bgilink.exe: bgidriv.tpu bgifont.tpu
  tpc /m bgilink

# Build unit with all fonts linked in
bgifont.tpu: bgifont.pas goth.obj litt.obj sans.obj trip.obj
  tpc bgifont
goth.obj: $(BGI)\goth.chr
  binobj $(BGI)\goth.chr goth GothicFontProc
litt.obj: $(BGI)\litt.chr
  binobj $(BGI)\litt.chr litt SmallFontProc
sans.obj: $(BGI)\sans.chr
  binobj $(BGI)\sans.chr sans SansSerifFontProc
trip.obj: $(BGI)\trip.chr
  binobj $(BGI)\trip.chr trip TriplexFontProc


# Build unit with all drivers linked in
bgidriv.tpu: bgidriv.pas cga.obj egavga.obj herc.obj pc3270.obj att.obj
  tpc bgidriv
cga.obj: $(BGI)\cga.bgi
  binobj $(BGI)\cga.bgi cga CGADriverProc
egavga.obj: $(BGI)\egavga.bgi
  binobj $(BGI)\egavga.bgi egavga EGAVGADriverProc
herc.obj: $(BGI)\herc.bgi
  binobj $(BGI)\herc.bgi herc HercDriverProc
pc3270.obj: $(BGI)\pc3270.bgi
  binobj $(BGI)\pc3270.bgi pc3270 PC3270DriverProc
att.obj: $(BGI)\att.bgi
  binobj $(BGI)\att.bgi att ATTDriverProc
