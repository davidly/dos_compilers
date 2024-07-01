;       brkctl command values

BR_ARGSEG=      1                       ; specified segment
BR_NEWSEG=      2                       ; new segment
BR_IMPSEG=      3                       ; last or new segment

MAXSEG= 20                              ; maximum brkctl segments

segrec          struc                   ; defines brkctl segment offsets
  sz            dw      ?
  sg            dw      ?
segrec          ends

heaprec         struc                   ; defines heap descriptor offsets
  bottom        dw      ?
  roveroff      dw      ?
  last          dw      ?
  top           dw      ?
  nextseg       dw      ?
heaprec         ends
