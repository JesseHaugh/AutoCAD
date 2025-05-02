(defun c:SDDouble (/)
  (setq ent (car (entsel "\nSelect a line to offset: "))) ;Select the Polyline
  (setq offsetDist 0.5) ;Set up variables for the design
  (setq textBackground 5)
  (setq pathDistance 40)
  (setq textStyle "General Notes")
  (setq textMessage "SD")
  (setq polylineData (entget ent)) ; Convert layers for current layer and line types
  (setq polylineData (append polylineData '((6 . "Continuous"))))
  (setq currentLayer (getvar "CLAYER"))
  (setq changeLayer (cdr (assoc 8 polylineData)))
  (command "-LAYER" "S" changeLayer "")
  (entmod polylineData)
  (entupd ent)
  (setq leftMost nil) ; Find the starting point on the left- lines reverse based on the direction they are drawn in
  (setq rightMost nil)
  (if (eq (cdr (assoc 0 (entget ent))) "LWPOLYLINE") ;Check if polyline
  (progn
    (if (< (car (cdr (assoc 10 polylineData))) (car (cdr (assoc 10 (reverse polylineData))))) 
      (progn
        (setq leftMost (cdr (assoc 10 polylineData)))
        (setq reverseResult polylineData))
    (if (and (<= (car (cdr (assoc 10 polylineData))) (car (cdr (assoc 10 (reverse polylineData))))) (< (car (cdr (cdr (assoc 10 polylineData)))) (car (cdr (cdr (assoc 10 (reverse polylineData)))))))
      (progn
        (setq leftMost (cdr (assoc 10 polylineData)))
        (setq reverseResult polylineData))
      (progn
        (setq leftMost (cdr (assoc 10 (reverse polylineData))))
        (setq reverseResult (reverse polylineData)))
    ))
  (while (= rightMost nil) ; Find the next in line point for angles
    (foreach point reverseResult
      (progn 
        (if (= (car point) 10)
          (progn
            (if (/= (cdr point) leftMost)
              (if (= rightMost nil)
                (setq rightMost (cdr point))
  )))))))))
  (if (eq (cdr (assoc 0 (entget ent))) "LINE") ;check if line
    (if (< (car (cdr (assoc 10 polylineData))) (car (cdr (assoc 11  polylineData)))) 
      (progn
        (setq leftMost (cdr (assoc 10 polylineData)))
        (setq rightMost (cdr (assoc 11 polylineData))))
      (if (< (car (cdr (cdr (assoc 10 polylineData)))) (car (cdr (cdr (assoc 11 polylineData)))))
        (progn
          (setq leftMost (cdr (assoc 10 polylineData)))
          (setq rightMost (cdr (assoc 11 polylineData))))
        (progn
          (setq leftMost (cdr (assoc 11 polylineData)))
          (setq rightMost (cdr (assoc 10 polylineData))))
      )))
  (setq revAngle (angtos (angle leftmost rightMost))) ; offet the line above and below the set distance
  (setq obj (vlax-ename->vla-object ent)); end vlax-...
  (progn
    (vla-offset obj offsetDist)
    (vla-offset obj (- offsetDist)))
  (progn ; create the MTEXT to be copied on the line
    (command "-MTEXT" leftMost "R" revAngle "J" "MC" "S" textStyle "W" textBackground textMessage "")
    (progn
      (setq ent2 (entlast))
      (if (and ent2 (eq (cdr (assoc 0 (entget ent2))) "MTEXT"))
        (progn
          (setq entData (entget ent2))
          (setq entData (append entData '((90 . 3) (63 . 256) (45 . 1.0))))
          (entmod entData)
          (entupd ent2)
      ))))
  (command "ARRAYPATH" ent2 "" ent "O" "" "" "f" pathDistance "" "x") ; Create the array to shoot the MTEXT down the line
  (command "_.LAYER" "_SET" currentLayer "") ; Set the current layer back to the origional
  (setq polylineData (append polylineData '((8 . "Defpoints")))) ; Change the origional line layer to no plot
  (entmod polylineData)
  (entupd ent)
)