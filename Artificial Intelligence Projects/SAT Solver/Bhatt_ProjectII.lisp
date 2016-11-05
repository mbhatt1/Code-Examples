;Submitted By: Manish Bhatt --- Student ID: 2451137
;;; A global variable that keeps track of how many calls are made to #'satisfiable.
(defvar *calls* 0)

;;; Defines how many calls are allowed to #'satisfiable before an error is thrown.
(defvar *max-calls* 10)

(defmacro defun-limited (name args &body body)
  "Defines a function which can only be called *max-calls* number of times."
  `(defun ,name ,args
     (let ((result nil))
       (progn (setq *calls* (1+ *calls*))
              (when (> *calls* *max-calls*)
                (error "Call limit exceeded."))
              (setq result ,@body)
              (setq *calls* (1- *calls*))
              result))))

(defun grade (problem)
  "A function for grading an individual problem instance."
  (let ((number (first problem))
        (expression (second problem))
        (correct-answer (third problem))
        (your-answer 'error))
    (unwind-protect
        (setq your-answer (satisfiable (second problem)))
      (format t "Expression ~S: ~S~%  Correct Answer: ~S~%  Your Answer:    ~S~%" number expression correct-answer your-answer))))

;;; ---------- BEGIN STUDENT CODE ----------
;;; Your code will be pasted in starting here.

;;; Students enrolled in CSCI 4525 should modify this function to return the
;;; correct value, rather than nil every time.  You should comment out the
;;; limited definition of this function below.
;(defun satisfiable (cnf)
;  nil)

;;; Students enrolled in CSCI 5525 should modify this function to return the
;;; correct value, rather than nil every time.  You should comment out the
;;; unlimited definition of this function above.
(defun-limited satisfiable (cnf)
    (if (symbolp cnf)
        (if (eq cnf t)
            t
            (if (eq cnf nil) 
                nil
                (unit-propagate cnf)
            )
        
        )
        (do-unit-propagation (pure-literal-elimination cnf (get-literals-from-cnf cnf)))
        
    
    )
      
)


(defun do-unit-propagation (cnf)
    
        (let ((reduced (unit-propagate cnf)))
            (if (symbolp  reduced)
                reduced
                (if (equal cnf reduced)
                     cnf
                
                    (do-unit-propagation reduced)
            
                )
            
            )
            
        
        )
    
)

(defun find-unit-literal (cnf)
   (if (symbolp cnf)
        cnf
        (dolist (element (conjuncts cnf))
   
            (if (symbolp element)
                
                (return element)
                
                (if (eq 'not (first element)) 
                
                    (return element) 
                    
                    (if (and (eq 'or (first element)) (eq (list-length element) 2) ) 
                    
                        (return (second element))
                        
                    )
                
                )
              )
      
      )
   )                                        
 
 )
        

        
        
(defun sub (cnf variable value)
(if (symbolp cnf)
(if (eq cnf variable) value cnf)
(if (equal variable cnf) value (mapcar (lambda (part)
(sub part variable value))
cnf))))



(defun simplify (cnf)
 (if (symbolp cnf)
    cnf
    (let ((simplified (mapcar #'simplify cnf)))
        (cond ((eq 'not (first simplified))
                (cond ((eq t (second simplified))
                        nil)
                        ((eq nil (second simplified))
                        t)
                        (t simplified)))
                    ((eq 'and (first simplified))
                     (let ((shorter (remove t simplified)))
                        (cond ((equal '(and) shorter)
                               t)
                            ((member nil shorter)
                             nil)
                             (t shorter))))    
                    ((eq 'or (first simplified))
                     (let ((shorter (remove nil simplified)))
                          (cond ((equal '(or) shorter)
                                nil)
                                ((member t shorter)
                                 t)
                                 (t shorter))))))))
          
(defun conjuncts (conjunction) (rest conjunction))

(defun unit-propagate (cnf)
        (if (symbolp (find-unit-literal cnf))
            (if (eq (find-unit-literal cnf) t)
            t
            (if (eq (find-unit-literal cnf) nil) 
                nil
                (simplify (sub cnf (find-unit-literal cnf) t))
            )
        
            )
            
            (if (eq 'not (first (find-unit-literal cnf)))
                ;(or (simplify (sub cnf (find-unit-literal cnf) nil)) (simplify (sub cnf (find-unit-literal cnf) t)))
                (let ((shorter (second (find-unit-literal cnf))))
                    
                    (simplify (sub cnf shorter nil))
                    
                )
                
                
                
            )
        
        )
)


(defun is-pure-literal (cnf variable)
    (if (symbolp variable)
        (if (symbolp cnf)
            (if (eq cnf variable)
                variable
                cnf
            )
            (if (and (eq 'not (first cnf)) (eq variable (second cnf)))
                nil
                (if (member 'nil (mapcar (lambda (part)
                    (is-pure-literal part variable))
                cnf))
                nil
                variable
                )
            
            )
        )
        
        (if (symbolp cnf)
            (if (eq cnf (second variable))
                nil
                cnf
            )
            (if (equal cnf variable)
                variable
                (if (member 'nil (mapcar (lambda (part)
                    (is-pure-literal part variable)
                ) cnf)) 
                nil
                variable
                )


            )
                
        
        )
        
    )
)

(defun get-literals-from-cnf (cnf)
    (let ((shorter (cond ((symbolp cnf)
            (list cnf))
         ((eq 'not (first cnf)) (list cnf))
        ; (t ( remove 'or (remove 'nil (remove 'and (append (get-literals-from-cnf (first cnf)) (get-literals-from-cnf (rest cnf)))))))
            (t (append (get-literals-from-cnf (first cnf)) (get-literals-from-cnf (rest cnf))))
    )))
       
       (cond ((member 'and shorter) (remove 'and shorter))
             ((member 'or shorter) (remove 'or shorter))
             ((member 'nil shorter) (remove 'nil shorter))
             (t shorter)
       
       )
        
    )
  
)

(defun pure-literal-elimination (cnf literals)
    (if (> (list-length literals) 0)
        (if (equal (first literals) (is-pure-literal cnf (first literals)))
                (pure-literal-elimination (simplify (sub cnf (first literals) t)) (rest literals))
                (pure-literal-elimination cnf (rest literals))
        )
        cnf
    )
)
  

;;; Feel free to define other functions here if you want.
  
;;; ---------- END STUDENT CODE ----------

;;; Test the #'satisfiable function on various different CNF expressions.
;;; Some examples are provided here, but the actual problems that you will be
;;; graded on will be different from these.  However, if you can solve all of
;;; these correctly and (for those in CSCI 5525, without exceeding the call
;;; limit), then you will probably pass all the graded tests.
;;; The format of a test is: (number expression expected-value).
;;; For example, expression #6 is (and a b) and it is satisfiable, so the
;;; expected return value of #'satisfiable is t.
(mapcar #'grade '((1 t t)
                  (2 nil nil)
                  (3 a t)
                  (4 (and t) t)
                  (5 (and nil) nil)
                  (6 (and a b) t)
                  (7 (or t) t)
                  (8 (or nil) nil)
                  (9 (or a b) t)
                  (10 (and a (not a)) nil)
                  (11 (and a (or (not a) b)) t)
                  (12 (and a b (or (not a) (not b))) nil)
                  (13 (and (or a b c) (not b) (or (not a) c) (or a d) (not c)) nil)
                  (14 (and (not a) (not b) (not c) (not d) (not e) (not f) (not g) (not h) (not i) (not j) (or a b c d e f g h i j k)) t)))