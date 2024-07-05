;; DRAGON.L FOR PC-LISP V2.13
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~ 
;;     Draw an Nth order Dragon Curve requires Turtle.l routines to run.
;; Taken From Byte April 1986. Try (DragonCurve 16) then put on supper,
;; watch the news and come back in an hour and see the results. It takes 
;; about 1/2 hour on my machine so on a normal IBM-PC it should take about
;; an 1.5 hours.
;;
;;              Peter Ashwood-Smith.
;;              August 1986
;;
;;              P.S - This dragon is nicknamed "spot"

(load 'turtle)

(defun Dragon(sign level)
       (cond  ((zerop level) (TurtleForward Global_Step_Size))
	      (t (setq level (1- level))
		 (TurtleRight (times 45 sign))
		 (Dragon -1 level)
		 (TurtleLeft (times 90 sign))
		 (Dragon 1 level)
		 (TurtleRight (times 45 sign))
	      )         
       )
)

(defun DragonCurve (n)
       (setq Global_Step_Size 1)                  ; StepSize is global variable
       (TurtleGraphicsUp)
       (TurtleCenter)
       (TurtleGoTo 330 50)
       (TurtleRight 30)                           ; angle the serpent a bit
       (Dragon 1 n)
       (gc)
)

    

