(in-package :gtk-tagged-streams)

;;==============================================================================
;; mark-out-stream
;;
;; A general-purpose output stream, using a mark to keep position.
;;
(defclass mark-out-stream
    (buffer-stream trivial-gray-streams:fundamental-character-output-stream)
  ((charbuf :accessor charbuf :initform "a")))

;;==============================================================================
;;
(defmethod trivial-gray-streams:stream-write-char
    ((stream mark-out-stream) char)
  (with-slots (buffer charbuf iter mark) stream
    (setf (char charbuf 0) char)
    (%gtb-get-iter-at-mark buffer iter mark)
    (%gtb-insert buffer iter charbuf -1)))

;;==============================================================================
;; write-string is more efficient than character-by-character, but
;; could be done better if needed.
(defmethod trivial-gray-streams:stream-write-string
    ((stream mark-out-stream)
     string
     &optional start end)
  (let ((s (if (or start end)
	       (subseq string start end )
	       string)))
    (with-slots (buffer iter mark) stream
      (%gtb-get-iter-at-mark buffer iter mark)
      (%gtb-insert buffer iter s -1))))
;;==============================================================================
(defmethod trivial-gray-streams:stream-start-line-p
    ((stream mark-out-stream))
  (with-slots (buffer iter mark) stream
    (%gtb-get-iter-at-mark buffer iter mark)
    (gti-starts-line iter)) )
;;==============================================================================
(defmethod trivial-gray-streams:stream-line-column
    ((stream mark-out-stream))
  (with-slots (buffer iter mark) stream
    (%gtb-get-iter-at-mark buffer iter mark)
    (gti-get-line-offset iter)))

