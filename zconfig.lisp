;;;; zconfig.lisp

(in-package #:zconfig)

(defclass zconfig () ())

(defgeneric zconfig/empty? (zconfig))
(defgeneric zconfig/size (zconfig))
(defgeneric zconfig/contains-key? (zconfig key))
(defgeneric zconfig/get (zconfig key &optional default))
(defgeneric zconfig/keys (zconfig &optional prefix))
(defgeneric zconfig/values (zconfig))
(defgeneric zconfig/subconfig (zconfig prefix))
(defgeneric zconfig/add! (zconfig key value))
(defgeneric zconfig/set! (zconfig key value))
(defgeneric zconfig/clear! (zconfig key))
(defgeneric zconfig/reset! (zconfig))
(defgeneric zconfig/map (zconfig function-designator))
(defmethod zconfig/dump! ((zconfig zconfig) &optional (stream *standard-output*))
  (zconfig/map zconfig (lambda (k v) (format stream "~a: ~{~a~^, ~}~%" k (if (atom v) (list v) v)))))

(defmethod print-object ((zconfig zconfig) stream)
  (print-unreadable-object (zconfig stream :type t :identity t)
    (format stream "size ~d" (zconfig/size zconfig))))

(defclass zconfig-hash (zconfig)
  ((table
    :initform (make-hash-table :test 'equal)
    :reader zconfig-hash/table)))

(defun zconfig ()
  (make-instance 'zconfig-hash))

(defmethod zconfig/empty? ((zconfig zconfig-hash))
  (zerop (zconfig/size zconfig)))

(defmethod zconfig/size ((zconfig zconfig-hash))
  (hash-table-count (zconfig-hash/table zconfig)))

(defmethod zconfig/contains-key? ((zconfig zconfig-hash) key)
  (nth-value 1 (gethash key (zconfig-hash/table zconfig))))

(defmethod zconfig/get ((zconfig zconfig-hash) key &optional default)
  (gethash key (zconfig-hash/table zconfig) default))

(defmethod zconfig/keys ((zconfig zconfig-hash) &optional prefix)
  (if prefix
      (loop for key being the hash-keys of (zconfig-hash/table zconfig)
            when (starts-with-subseq prefix key)
              collect key)
      (loop for key being the hash-keys of (zconfig-hash/table zconfig)
            collect key)))

(defmethod zconfig/values ((zconfig zconfig-hash))
  (loop for value being the hash-values of (zconfig-hash/table zconfig)
        collect value))

(defmethod zconfig/subconfig ((zconfig zconfig-hash) prefix)
  (let ((subconfig (zconfig)))
    (maphash
     (lambda (key value)
       (when-let ((suffix (nth-value 1 (starts-with-subseq prefix key :return-suffix t))))
         (setf (gethash suffix (zconfig-hash/table subconfig)) value)))
     (zconfig-hash/table zconfig))
    subconfig))

(defmethod zconfig/add! ((zconfig zconfig-hash) key value)
  (symbol-macrolet ((%val (gethash key (zconfig-hash/table zconfig))))
    (multiple-value-bind (current exists) %val
      (cond ((not exists)
             (setf %val value))
            ((listp current)
             (push value current))
            (t
             (setf %val (list value current)))))))

(defmethod zconfig/set! ((zconfig zconfig-hash) key value)
  (setf (gethash key (zconfig-hash/table zconfig)) value))

(defmethod zconfig/clear! ((zconfig zconfig-hash) key)
  (remhash key (zconfig-hash/table zconfig)))

(defmethod zconfig/reset! ((zconfig zconfig-hash))
  (let ((table (zconfig-hash/table zconfig)))
    (maphash (lambda (key _)
               (declare (ignorable _))
               (remhash key table))
             table)))

(defmethod zconfig/map ((zconfig zconfig-hash) function-designator)
  (maphash function-designator (zconfig-hash/table zconfig)))
