((lambda (zero one add mul pow sub1 true false and or)
   ((lambda (sub not zero? two Y)
      ((lambda (less-equal? equal? three four)
         ;------------------------------
         ((lambda (for-each fib)
            (for-each (lambda (i) (print (fib zero one zero i))(newline)) zero (mul four four))
            )
          (Y 
            (lambda (self)
              (lambda (f i n)
                (f i)
                (((equal? i n)
                  (lambda () i)
                  (lambda () (self f (add i one) n))))
                )
              ))
          (Y 
            (lambda (self)
              (lambda (a b i n)
                (((equal? i n)
                  (lambda () a)
                  (lambda () (self b (add a b) (add i one) n))))
                )
              ))
          )
         ;------------------------------
         )
       (lambda (m n) (zero? (sub m n)))
       (lambda (m n) (and (zero? (sub m n)) (zero? (sub n m))))
       (add two one)
       (add two two)
       ))
    (lambda (m n) (n sub1 m))
    (lambda (a) (a false true))
    (lambda (n) (n (lambda (x) false) true))
    (add one one)
    (lambda (f)
      ((lambda (g) (g g))
       (lambda (g) (f (lambda (a) ((g g) a))))))
    ))
 (lambda (f x) x)
 (lambda (f x) (f x))
 (lambda (m n f x) (m f (n f x)))
 (lambda (m n f) (m (n f)))
 (lambda (e b) (e b))
 (lambda (n f x) 
   (((n 
       (lambda (g h) (h (g f)))) 
     (lambda (u) x)) 
    (lambda (u) u)))
 (lambda (a b) a)
 (lambda (a b) b)
 (lambda (a b) (a b a))
 (lambda (a b) (a a b))
 )
