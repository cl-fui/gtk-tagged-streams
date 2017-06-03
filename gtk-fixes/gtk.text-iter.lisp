;;; ----------------------------------------------------------------------------
(in-package :gtk)

;;; ! stacksmith 13-05-2017 !
;;; ----------------------------------------------------------------------------

(defcfun ("gtk_text_iter_starts_tag" gtk-text-iter-starts-tag) :boolean
  (iter (g-boxed-foreign gtk-text-iter))
  (tag (g-object gtk-text-tag)))

(export 'gtk-text-iter-starts-tag)

