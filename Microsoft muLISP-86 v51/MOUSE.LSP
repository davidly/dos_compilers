; File:  MOUSE.LSP		12/29/85	Soft Warehouse, Inc.

;		Microsoft Mouse Interface Functions

; This file requires that the Microsoft Mouse hardware and device driver
; software be properly installed.
; The functions automatically update the following global variables:

; *MOUSE-ROW*       the vertical mouse position
; *MOUSE-COL*       the horizontal mouse position
; *LEFT-BUTTON*     T if and only if left button pressed
; *RIGHT-BUTTON*    T if and only if right button pressed
; *BUTTON-PRESSES*  the number of button presses
; *BUTTON-RELEASES* the number of button releases

(DEFUN SHOW-MOUSE ()			;Display mouse cursor
  (REGISTER 0 1)
  (INTERRUPT 51) )

(DEFUN HIDE-MOUSE ()			;Hide mouse cursor
  (REGISTER 0 2)
  (INTERRUPT 51) )

(DEFUN POSITION-MOUSE (ROW COL)		;Current mouse position
  ((AND (INTEGERP ROW) (INTEGERP COL))
    (REGISTER 0 4)
    (REGISTER 2 COL)
    (REGISTER 3 ROW)
    (INTERRUPT 51) )
  (REGISTER 0 3)
  (INTERRUPT 51)
  (SETQ *MOUSE-ROW* (REGISTER 3))
  (SETQ *MOUSE-COL* (REGISTER 2)) )

(DEFUN STATUS-MOUSE ()			;Current button status
  (REGISTER 0 3)
  (INTERRUPT 51)
  (SETQ *LEFT-BUTTON* (ODDP (REGISTER 1)))
  (SETQ *RIGHT-BUTTON* (ODDP (SHIFT (REGISTER 1) -1))) )

(DEFUN BUTTON-PRESS (BUTTON)		;Mouse status at last button press
  (REGISTER 0 5)
  (SETQ *BUTTON-PRESSES* (BUTTON-INFO)) )

(DEFUN BUTTON-RELEASE (BUTTON)		;Mouse status at last button release
  (REGISTER 0 6)
  (SETQ *BUTTON-RELEASES* (BUTTON-INFO)) )

(DEFUN BUTTON-INFO ()
  (REGISTER 1 (IF (EQ BUTTON 'LEFT) 0 1))
  (INTERRUPT 51)
  (SETQ *LEFT-BUTTON* (ODDP (REGISTER 0)))
  (SETQ *RIGHT-BUTTON* (ODDP (SHIFT (REGISTER 0) -1)))
  (SETQ *MOUSE-ROW* (REGISTER 3))
  (SETQ *MOUSE-COL* (REGISTER 2))
  (REGISTER 1) )

(RDS)
