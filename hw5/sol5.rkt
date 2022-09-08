#lang racket
(provide (all-defined-out)) ;; exports the defined variables in this file.

;; definition of structures for MUPL programs - Do NOT change
(struct var  (string) #:transparent)  ;; a variable, e.g., (var "foo")
(struct int  (num)    #:transparent)  ;; a constant number, e.g., (int 17)
(struct add  (e1 e2)  #:transparent)  ;; add two expressions
(struct ifgreater (e1 e2 e3 e4)    #:transparent) ;; if e1 > e2 then e3 else e4
(struct fun  (nameopt formal body) #:transparent) ;; a recursive(?) 1-argument function
(struct call (funexp actual)       #:transparent) ;; function call
(struct mlet (var e body) #:transparent) ;; a local binding (let var = e in body) 
(struct apair (e1 e2)     #:transparent) ;; make a new pair
(struct fst  (e)    #:transparent) ;; get first part of a pair
(struct snd  (e)    #:transparent) ;; get second part of a pair
(struct aunit ()    #:transparent) ;; unit value -- good for ending a list
(struct isaunit (e) #:transparent) ;; evaluate to 1 if e is unit else 0

;; for extra requirements
(struct glet (var e body) #:transparent) ;; a global binding that overrides any local binding (let var = e in body)

(struct num-array  (size) #:transparent)  ;; a number array  (initialized to zeroes), e.g., (num-array-var 10)
                                                     ;; e.g. (num-array 4)

(struct num-array-at   (e1 e2) #:transparent) ;; e1 evaluates to num-array and e2 evaluates to racket int (index of the value to access) index starts from 0
                                              ;; (num-array-at (num-array 4) 3)
                                              ;; (num-array-at (num-array 4) 4) ;  this should give a nice error messaeg (like "array access out of bound")
                                              ;; (num-array-at (num-array 4) -1) ;  this should give a nice error messaeg (like "array access out of bound")

(struct num-array-set  (e1 e2 e3) #:transparent) ;; e1 evaluates to num-array-var, e2 evaluates to racket int (index of the value to access), and e3 evaluates to a MUPL int
                                              ;; (num-array-set (num-array 4) 0 (int 42))
                                              ;; (num-array-set (num-array 4) 5 (int 42)) ; this should give a nice error messaeg (like "array access out of bound")
                                              ;; (num-array-set (num-array 4) -1 (int 42)) ; this should give a nice error messaeg (like "array access out of bound")


;; a closure is not in "source" programs; it is what functions evaluate to
(struct closure (env fun) #:transparent) 

(define (make-array length)
    (if (= length 0)
        null
        (mcons (int 0) (make-array (- length 1)))))
;(define (set-array-val array index val)
;  (if (= index 0)
;      (set-mcar! array val)
;      (mcar array)))


;; extra requirements

(define (num-array-object? v) ;; hackish implementation of testing num-array object. We assume that if a value is mpair, it is a num-array object.
  (mpair? v))

(define (array-length array)
  (if (eq? (mcdr array) null)
      1
      (+ 1 (array-length (mcdr array)))))
(define (make-array-object length)  
    (if (= length 0)
        null
        (mcons (int 0) (make-array-object (- length 1)))))
(define (set-array-val array index val)
  (if (= index 0)
      (set-mcar! array val)
      (set-array-val (mcdr array) (- index 1) val)))



;; Problem 1 

;; CHANGE (put your solutions here) 
(define (racketlist->mupllist rl)
  (cond [(null? rl) (aunit)]
        [(pair? rl) (apair (car rl) (racketlist->mupllist (cdr rl)))]
        [#t (error "Error with given Racket list.")]))

(define (mupllist->racketlist ml)
  (cond [(aunit? ml) null]
        [(apair? ml) (cons (apair-e1 ml) (mupllist->racketlist (apair-e2 ml)))]
        [#t (error "Error with given MUPL list.")]))


;; Problem 2 

;; lookup a variable in an environment
;; Do NOT change this function
(define (envlookup env str)
  (cond [(null? env) (error "unbound variable during evaluation" str)]
        [(equal? (car (car env)) str) (cdr (car env))]
        [#t (envlookup (cdr env) str)]))

;; Do NOT change the two cases given to you.  
;; DO add more cases for other kinds of MUPL expressions.
;; We will test eval-under-env by calling it directly even though
;; "in real life" it would be a helper function of eval-exp.
(define (eval-under-env e env)
  (cond [(var? e) 
         (envlookup env (var-string e))]
        [(add? e) 
         (let ([v1 (eval-under-env (add-e1 e) env)]
               [v2 (eval-under-env (add-e2 e) env)])
           (if (and (int? v1)
                    (int? v2))
               (int (+ (int-num v1) 
                       (int-num v2)))
               (error "MUPL addition applied to non-number")))]
        ;; CHANGE add more cases here
        [(int? e) e] 
        [(aunit? e) (aunit)] 
        [(fun? e) (closure env e)] 
        [(closure? e) e] 

        [(ifgreater? e) 
         (let ([v1 (eval-under-env (ifgreater-e1 e) env)]
               [v2 (eval-under-env (ifgreater-e2 e) env)])
            (if (and (int? v1) (int? v2))
                (if (> (int-num v1) (int-num v2))
                    (eval-under-env (ifgreater-e3 e) env)
                    (eval-under-env (ifgreater-e4 e) env))
                (error "Arguments of ifgreater must be integers.")))]

        [(mlet? e) 
         (if (string? (mlet-var e))
           (let ([v (eval-under-env (mlet-e e) env)])
                (eval-under-env (mlet-body e) (append env (list (cons (mlet-var e) v)))))
           (error "First argument of mlet must be a string."))]

        [(call? e) 
         (let ([cl (eval-under-env (call-funexp e) env)]
               [arg (eval-under-env (call-actual e) env)])
           (if (closure? cl)
             (letrec ([s (fun-nameopt (closure-fun cl))]
                      [env-of-c (cons (cons (fun-formal (closure-fun cl)) arg)
                                      (closure-env cl))])
               (eval-under-env (fun-body (closure-fun cl))
                               (cond [(string? s)
                                      (cons (cons s cl) env-of-c)]
                                     [(false? s) env-of-c])))
               (error "Argument of call must be a closure.")))]                

        [(apair? e) 
         (apair (eval-under-env (apair-e1 e) env)
                (eval-under-env (apair-e2 e) env))]
        [(fst? e) (if (apair? (eval-under-env (fst-e e) env)) 
                          (apair-e1 (eval-under-env (fst-e e) env))
                          (error "Argument of fst must be a pair."))]
        [(snd? e) (if (apair? (eval-under-env (snd-e e) env)) 
                          (apair-e2 (eval-under-env (snd-e e) env))
                          (error "Argument of snd must be a pair."))]
        [(isaunit? e) (if (aunit? (eval-under-env (isaunit-e e) env)) 
                          (int 1) (int 0))]

        [(glet? e) 
          (letrec
               ([bind (lambda(env-of-g)
                        (if (null? env-of-g)
                            '()
                            (let ([v1 (car env-of-g)]
                                  [v2 (cdr env-of-g)])
                              (cond [(equal? v1 (glet-var e))
                                     (cons v1 (eval-under-env (glet-e e) env))]
                                    [(closure? v2)
                                     (cons v1 (closure (bind (closure-env v2)) (closure-fun v2)))]
                                    [(pair? v1)
                                     (cons (bind v1) (bind v2))]
                                    [#t (cons v1 (bind v2))]))))])
                (eval-under-env (glet-body e)
                                (cons (cons (glet-var e) (eval-under-env (glet-e e) env)) (bind env))))]

        [(num-array? e) 
           (if (< (num-array-size e) 0)
               (error "Size of given num-array is negative." e)
               (make-array-object (num-array-size e)))]

        [(num-array-at? e) 
         (let* ([num-size (if (num-array-object? (eval-under-env (num-array-at-e1 e) env))
                                 (array-length (eval-under-env (num-array-at-e1 e) env))
                                 (error "Error with given num-array-object." e))])
           (if (or (< (num-array-at-e2 e) 0) (<= num-size (num-array-at-e2 e)))
                 (error "Out of bounds access for num-array-at." e)
                 (letrec ([num-arr-at (lambda (arr i)
                                      (if (= i 0)
                                          (mcar arr)
                                          (num-arr-at (mcdr arr) (- i 1))))])
                 (num-arr-at (eval-under-env (num-array-at-e1 e) env) (num-array-at-e2 e)))))]

        [(num-array-set? e) 
         (let* ([num-size (if (num-array-object? (eval-under-env (num-array-set-e1 e) env))
                                 (array-length (eval-under-env (num-array-set-e1 e) env))
                                 (error "Error with given num-array-object." e))])
           (if (or (< (num-array-set-e2 e) 0) (<= num-size (num-array-set-e2 e)))
               (error "Out of bounds access for num-array-set." e)
               (begin
                 (set-array-val (eval-under-env (num-array-set-e1 e) env)
                                (num-array-set-e2 e)
                                (eval-under-env (num-array-set-e3 e) env))
                 (eval-under-env (num-array-set-e3 e) env))))]

        [#t (error (format "bad MUPL expression: ~v" e))]))
               

;; Do NOT change
(define (eval-exp e)
  (eval-under-env e null))
        
;; Problem 3 

(define (ifaunit e1 e2 e3)
  (ifgreater (isaunit e1) (int 0) e2 e3))

(define (mlet* lstlst en+1)
  (if (null? lstlst)
      en+1
      (mlet (car (car lstlst)) (cdr (car lstlst)) (mlet* (cdr lstlst) en+1))))

(define (ifeq e1 e2 e3 e4)
  (mlet* (list (cons "_x" e1) (cons "_y" e2))
         (ifgreater (var "_x") (var "_y") e4
                    (ifgreater (var "_y") (var "_x") e4 e3))))

;; Problem 4 

(define mupl-map
  (fun #f "fun"
       (fun "map-list" "list"
            (ifaunit (var "list")
                  (aunit)
                  (apair (call (var "fun") (fst (var "list")))
                         (call (var "map-list") (snd (var "list"))))))))

(define mupl-mapAddN 
        (fun #f "a"
                  (call mupl-map (fun #f "b" (add (var "b") (var "a"))))))

