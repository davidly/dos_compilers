'*** OUT statement programming example
'
' Play a scale using speaker and timer
CONST WHOLE=5000!, QRTR=WHOLE/4.
CONST C=523.0, D=587.33, E=659.26, F=698.46, G=783.99, A=880.00
CONST B=987.77, C1=1046.50
CALL Sounds(C,QRTR) : CALL Sounds(D,QRTR)
CALL Sounds(E,QRTR) : CALL Sounds(F,QRTR)
CALL Sounds(G,QRTR) : CALL Sounds(A,QRTR)
CALL Sounds(B,QRTR) : CALL Sounds(C1,WHOLE)

SUB Sounds (Freq!,Length!) STATIC
'Ports 66, 67, and 97 control timer and speaker
'
'Divide clock frequency by sound frequency
'to get number of "clicks" clock must produce
    Clicks%=CINT(1193280!/Freq!)
    LoByte%=Clicks% AND &H00FF
    HiByte%=Clicks%\256
'Tell timer that data is coming
    OUT 67,182
'Send count to timer
    OUT 66,LoByte%
    OUT 66,HiByte%
'Turn speaker on by setting bits 0 and 1 of PPI chip.
    SpkrOn%=INP(97) OR &H03
    OUT 97,SpkrOn%
'Leave speaker on
    FOR I!=1 TO Length! : NEXT I!
'Turn speaker off.
    SpkrOff%=INP(97) AND &HFC
    OUT 97,SpkrOff%
END SUB
