(in-package :gtk-tagged-streams)
;;=============================================================================
;; tag-input-stream
;;
;; Treat the text at cursor, tagged with the specified tag, as an input
;; stream.
;;
;; Only a single run is considered to be the entire stream here.  Thus,
;; position routines are limited.

(defclass tag-in-stream
    (buffer-tag-stream trivial-gray-streams:fundamental-character-input-stream)
  ())


;;===========================================================================
(defmethod trivial-gray-streams:stream-read-char
    ((stream tag-in-stream))
  (with-slots (buffer iter tag mark) stream
    (%gtb-get-iter-at-mark buffer iter mark); current position
 ;;   (format t "TAGS AT ~A ~A~&" (gti-offset iter) (gti-get-tags iter))
    (if (gti-has-tag iter tag)
	(prog1
	    (gti-get-char iter)
	  (gti-forward-char iter)
	  (gtb-move-mark buffer mark iter))
	:eof)))

;;===========================================================================
;;
(defmethod (setf trivial-gray-streams:stream-file-position)
    (newval (us tag-in-stream))
  (with-slots (buffer iter  mark tag) us
    (%gtb-get-iter-at-mark buffer iter mark) ;mark -> iter
    (and
     (case newval
       (:start
	(or (gti-starts-tag iter tag)
	    (gti-backward-to-tag-toggle iter tag)))
       (:end
	(or (gti-ends-tag iter tag)
	    (gti-forward-to-tag-toggle iter tag)))
       (t nil))
     (progt (%gtb-move-mark buffer mark iter)))))
