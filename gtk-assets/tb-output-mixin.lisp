(in-package :gtk-tagged-streams)

;;==============================================================================
;; An output-stream mixin for a tb
;;
;; Mixing this in makes sense as there is only one cursor output stream.
;;

(defclass tb-output-mixin
    (trivial-gray-streams:fundamental-character-output-stream)
  ((charbuf :accessor charbuf :initform " ")))

(defmethod trivial-gray-streams:stream-write-char ((stream tb-output-mixin)
						   char)
  (with-slots (charbuf) stream
    (setf (char charbuf 0) char)
    (gtb-insert-at-cursor stream charbuf -1)))

;;-----------------------------------------------------------------------------
(defmethod trivial-gray-streams:stream-write-string ((stream tb-output-mixin)
						     string
						     &optional start end)
  (let ((s (if (or start end)
	       (subseq string start end )
	       string)))
    (gtb-insert-at-cursor stream s -1)))
;;-----------------------------------------------------------------------------
(defmethod trivial-gray-streams:stream-start-line-p ((stream tb-output-mixin))
  (gti-starts-line (tb-cursor-iter stream)))
;;-----------------------------------------------------------------------------
(defmethod trivial-gray-streams:stream-line-column ((stream tb-output-mixin))
  (gti-get-line-offset (tb-cursor-iter stream)))

;;-----------------------------------------------------------------------------
(defmethod trivial-gray-streams:stream-file-position ((stream tb-output-mixin))
  (gtb-cursor-position stream))

(defmethod (setf trivial-gray-streams:stream-file-position)
    (newval (stream tb-output-mixin))
  (with-slots (iter0) stream
    (%gtb-get-iter-at-offset stream iter0 (case newval
					    (:start 0)
					    (:end -1)
					    (t newval)))
    (gtb-move-mark stream "insert" iter0))
  t)

