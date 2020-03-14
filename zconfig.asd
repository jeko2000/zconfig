;;;; zconfig.asd

(asdf:defsystem #:zconfig
  :description "A configuration library written in Common-Lisp."
  :author "Johnny Ruiz <jeko2000@yandex.com>"
  :depends-on (:alexandria)
  :version "0.0.1"
  :serial t
  :components ((:file "package")
               (:file "zconfig")))
