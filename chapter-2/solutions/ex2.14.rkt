#lang racket

(define (make-interval a b)
  (cons a b))

(define (lower-bound itvl)
  (car itvl))

(define (upper-bound itvl)
  (cdr itvl))

(define (add-interval x y)
  (make-interval (+ (lower-bound x) (lower-bound y))
                 (+ (upper-bound x) (upper-bound y))))

(define (sub-interval x y)
  (make-interval (- (lower-bound x) (lower-bound y))
                 (- (upper-bound x) (upper-bound y))))

(define (mul-interval x y)
  (let ((p1 (* (lower-bound x) (lower-bound y)))
        (p2 (* (lower-bound x) (upper-bound y)))
        (p3 (* (upper-bound x) (lower-bound y)))
        (p4 (* (upper-bound x) (upper-bound y))))
    (make-interval (min p1 p2 p3 p4)
                   (max p1 p2 p3 p4))))

(define (div-interval x y)
  (if (or (= (upper-bound y) 0)
          (= (lower-bound y) 0))
      (display "error")
      (mul-interval x 
                    (make-interval (/ 1.0 (upper-bound y))
                                   (/ 1.0 (lower-bound y))))))

(define (revised-mul x y)
  (define (positive? i)
    (>= (lower-bound i) 0))
  (define (negative? i)
    (< (upper-bound i) 0))
  (define (case i)
    (cond ((positive? i) 1)
          ((negative? i) -1)
          (else 0)))
  (let ((case-x (case x))
        (case-y (case y))
        (xl (lower-bound x))
        (xu (upper-bound x))
        (yl (lower-bound y))
        (yu (upper-bound y)))
    (cond ((and (= case-x 1) (= case-y 1)) (make-interval (* xl yl) (* xu yu)))
          ((and (= case-x 1) (= case-y 0)) (make-interval (* xu yl) (* xu yu)))
          ((and (= case-x 1) (= case-y -1)) (make-interval (* xu yl) (* xl yu)))
          ((and (= case-x -1) (= case-y 1)) (make-interval (* xl yu) (* xu yl)))
          ((and (= case-x -1) (= case-y 0)) (make-interval (* xl yu) (* xl yl)))
          ((and (= case-x -1) (= case-y -1)) (make-interval (* xu yu) (* xl yl)))
          ((and (= case-x 0) (= case-y 1)) (make-interval (* xl yu) (* xu yu)))
          ((and (= case-x 0) (= case-y -1)) (make-interval (* yl xu) (* xl yl)))
          (else (make-interval (min (* xl yu) (* xu yl)) (max (* xl yl) (* xu yu)))))))

(define (make-center-width c w)
  (make-interval (- c w) (+ c w)))

(define (make-center-percent center percentage)
  ;   (make-interval (- center (* center percentage)) (+ center (* center percentage))))
  (make-center-width center (* center percentage)))

(define (center i)
  (/ (+ (lower-bound i) (upper-bound i)) 2))

(define (width i)
  (/ (- (upper-bound i) (lower-bound i)) 2))

(define (percent i)
  (/ (width i) (center i)))

(define (mul-percent x y)
  (percent (revised-mul x y)))

(define (print-interval-c-p i)
  (display "(")
  (display (center i))
  (display ",")
  (display (percent i))
  (display ")")
  (newline))

(define (par1 r1 r2)
  (div-interval (mul-interval r1 r2)
                (add-interval r1 r2)))

(define (par2 r1 r2)
  (let ((one (make-interval 1 1))) 
    (div-interval one
                  (add-interval (div-interval one r1)
                                (div-interval one r2)))))
    
(define a (make-interval 2 10))
(define b (make-interval 4 8))


;; to be finished...
