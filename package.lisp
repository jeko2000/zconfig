;;;; package.lisp

(defpackage #:zconfig
  (:use #:cl #:alexandria)
  (:export
   #:zconfig
   #:zconfig/empty?
   #:zconfig/size
   #:zconfig/contains-key?
   #:zconfig/get
   #:zconfig/keys
   #:zconfig/values
   #:zconfig/subconfig
   #:zconfig/add!
   #:zconfig/set!
   #:zconfig/clear!
   #:zconfig/reset!
   #:zconfig/map
   #:zconfig/dump!))
