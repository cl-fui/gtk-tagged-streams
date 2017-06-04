(in-package :gtk-tagged-streams)

;;==============================================================================
;; mark-in-stream
;;
;; A general-purpose input stream, using a mark to keep position.
;;
(defclass mark-in-stream
    (buffer-stream trivial-gray-streams:fundamental-character-input-stream)
  ())

;;===========================================================================
(defmethod trivial-gray-streams:stream-read-char
    ((stream mark-in-stream))
  (with-slots (buffer iter mark) stream
    (%gtb-get-iter-at-mark buffer iter mark); current position
    (let ((c (gti-get-char iter)))
      (if (char= c #\nul)
	  :eof
	  (progn
	    (gti-forward-char iter)
	    (gtb-move-mark buffer mark iter)
	    c)))))
;;===========================================================================
(defmethod trivial-gray-streams:stream-unread-char
    ((stream mark-in-stream) char)
  (with-slots (buffer iter mark) stream
    (prognil
      (%gtb-get-iter-at-mark buffer iter mark); current position
      (gti-backward-char iter)
      (gtb-move-mark buffer mark iter))))


