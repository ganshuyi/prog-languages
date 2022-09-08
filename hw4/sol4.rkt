#lang racket
(provide (all-defined-out))

(define (check_bst BST)
  (if (null? BST) #t
      (letrec ([ROOT (car BST)]
               [checkLeftChild (lambda(bst)
                          (if (null? bst) #t
                              (> ROOT (car bst))))]
               [checkRightChild (lambda(bst)
                          (if (null? bst) #t
                              (< ROOT (car bst))))])
               (and (checkLeftChild (cadr BST)) (checkRightChild (caddr BST)) (check_bst (cadr BST)) (check_bst (caddr BST))))))


(define (apply f BST)
  (if (null? BST) null
      (list (f (car BST)) (apply f (cadr BST)) (apply f (caddr BST)))))

(define (equals BST1 BST2)
  (letrec ([exists (lambda(val ROOT)
                     (if (null? ROOT) #f
                         (or (= val (car ROOT)) (exists val (cadr ROOT)) (exists val (caddr ROOT)))))]
           [compare (lambda (ROOT1 ROOT2)
                      (if (null? ROOT1) #t
                          (and (exists (car ROOT1) ROOT2) (compare (cadr ROOT1) ROOT2) (compare (caddr ROOT1) ROOT2))))])
           (and (compare BST1 BST2) (compare BST2 BST1))))