((lambda (yin)
   ((lambda (yang)
      (yin yang))
    ((lambda (c) (print (lambda (f x) x)) c) 
     (call/cc (lambda (k) k)))))
 ((lambda (c) (print (lambda (f x) (f x))) c)
  (call/cc (lambda (k) k))))
