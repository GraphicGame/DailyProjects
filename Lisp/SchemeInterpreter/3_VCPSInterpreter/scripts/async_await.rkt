;------------------------------
(define (async f)
  (lambda args
    (let* ([main-k false]
           [iter-k false]
           [callback (last args)]
           [await 
             (lambda (f . args)
               (apply f 
                      (append args 
                              (list (lambda (value)
                                      (call/cc 
                                        (lambda (k)
                                          (set! main-k k)
                                          (iter-k value)))))))
               (call/cc 
                 (lambda (k)
                   (set! iter-k k)
                   (main-k))))])
      (call/cc 
        (lambda (k)
          (set! main-k k)
          (callback (apply f (append (drop-right args 1) (list await))))
          (main-k)))))
  )
;------------------------------
(define (when-all tasks callback)
  (let* ([n (length tasks)]
         [task-callback (lambda (v)
                          (set! n (- n 1))
                          (if (zero? n)
                            (callback empty)
                            'ok))])
    (do ([rest tasks (cdr rest)])
      ((empty? rest))
      ((car rest) task-callback)))
  )
;------------------------------
(define _now 0)
(define _events empty)
(define (time)
  _now
  )
(define (dispatch-event)
  (if (empty? _events)
    false
    (let ([e (car _events)])
      (set! _events (cdr _events))
      (set! _now (car e))
      ((cdr e))
      true))
  )
(define (insert-event d callback)
  (set! _events 
    (let insert ([finish (+ d (time))][events _events])
      (cond
        [(or (empty? events) (< finish (caar events))) (cons (cons finish callback) events)]
        [else (cons (car events) (insert finish (cdr events)))])))
  )
;------------------------------
(define (random-range a b)
  (+ a (random (- b a)))
  )
(define (connect host port callback)
  (insert-event (random-range 5 10) (lambda () (callback "conn")))
  )
(define (send conn data)
  data)
(define (receive conn callback)
  (insert-event (random-range 1 4) (lambda () (callback (string-append "response " (number->string (time))))))
  )
(define (close conn)
  conn)
;------------------------------
(define request-url 
  (async (lambda (url port await)
           (let ([conn (await connect url port)])
             (printf "[~a]~a: connected\n" (time) url)
             (send conn "GET / HTTP/1.0")
             (do ([i 1 (+ 1 i)][tmp (await receive conn) (await receive conn)])
               ((> i 10))
               (printf "[~a]~a: receive => ~a\n" (time) url tmp) (send conn tmp))
             (let ([html (await receive conn)])
               (printf "[~a]~a: receive html => ~a\n" (time) url html)
               (close conn)
               (printf "[~a]~a: close\n" (time) url)
               html))
           ))
  )
(define request-urls-sync 
  (async (lambda (urls await)
           (do ([_urls urls (cdr _urls)])
             ((empty? _urls))
             (await request-url (car _urls) 80))
           ))
  )
(define request-urls-async
  (async (lambda (urls await)
           (await when-all (map (lambda (url) 
                                  (lambda (callback) (request-url url 80 callback))) urls))))
  )
;------------------------------
(define urls '("www.baidu.com" "www.qq.com" "www.taobao.com" "www.sina.com"))
;(request-urls-sync urls (lambda (v) (printf "finish all\n")))
(request-urls-async urls (lambda (v) (printf "finish all\n")))
(do ([e (dispatch-event) (dispatch-event)]) ((not e)))
