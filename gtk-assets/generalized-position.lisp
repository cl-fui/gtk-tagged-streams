(in-package :gtk-tagged-streams)
;;=============================================================================
;; Position in a buffer may be described with one of the following:
;; - integer index of a unicode character;
;; - iterator
;; - mark
;; - caret
(defun new-iter-at-position (buffer position)
  "create an iter at generalized position"
   (typecase position
     (integer
      (gtb-get-iter-at-offset buffer (gtb-cursor-position buffer)))
     (gtk-text-iter
      (gti-copy position))
     (gtk-text-mark
      (gtb-get-iter-at-mark buffer  position))
     (string
      (gtb-get-iter-at-mark buffer
			    (gtb-get-mark buffer position)))
     (null
      (gtb-get-iter-at-mark buffer (gtb-get-insert buffer))))
   )
