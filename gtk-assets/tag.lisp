(in-package :gtk-tagged-streams)
;;
;; Derived from the gtk-text-tag, this is the base class for all tags
;; and contexts.
;;

(defclass tag (gtk-text-tag)
  ()
  (:metaclass gobject-class))

(defmethod initialize-instance :after ((tag tag) &key buffer)
  (unless buffer
    (error "TAG requires a :buffer initializer"))
  (gttt-add (gtb-tag-table buffer) tag))
 
