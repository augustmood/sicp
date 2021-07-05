# Chapter 3.3 Modeling with Mutable Data
<p style="color:#FF6666; font-weight: bold; font-style: italic"> All the codes and some sentences in 
this note are from the book: SICP <p>

- In order to model compound objecs with chaging state, we will design data abstractions to include, 
in addtion to selectors and constructors, operations called `mutators`, which modify data objects.

- Data objects for which mutators are defined are known as `mutable data objects`.

## 3.3.1 Mutable List Structure

- `set-car!` and `set-cdr!` return implementation-dependent values. Like set!, they should be used 
only for their effect.

- The book gives an example of implementing `cons`:
    ```scheme
    (define (cons x y)
        (let ((new (get-new-pair)))
            (set-car! new x)
            (set-cdr! new y)
            new))
    ```

### Sharing and identity

- The mutation operations `set-car!` and `set-cdr!` should be used with care; unless we have a good
understanding of how our data objects are shared, mutation can have unanticipated results.

### Mutation is just assignment

- The book gives an example of implementation of constructors and selectors mutable pair:
    ```scheme
    (define (cons x y)
    (define (set-x! v) (set! x v))
    (define (set-y! v) (set! y v))
    (define (dispatch m)
        (cond ((eq? m 'car) x)
            ((eq? m 'cdr) y)
            ((eq? m 'set-car!) set-x!)
            ((eq? m 'set-cdr!) set-y!)
            (else (error "Undefined operation -- CONS" m))))
    dispatch)
    (define (car z) (z 'car))
    (define (cdr z) (z 'cdr))
    (define (set-car! z new-value)
    ((z 'set-car!) new-value)
    z)
    (define (set-cdr! z new-value)
    ((z 'set-cdr!) new-value)
    z)
    ```

## 3.3.2 Representing Queues

- The book introduces the data structure `queue`:
  - A queue is represented as a pair of pointers, `front-ptr` and `rear-ptr`, which indicate the
  first and last pairs in an ordinary list.

  - To define the queue operations we use the following procedures, which enbale us to select and to
  modify the front and rear pointers of a queue:
    ```scheme
    (define (front-ptr queue) (car queue))
    (define (rear-ptr queue) (cdr queue))
    (define (set-front-ptr! queue item) (set-car! queue item))
    (define (set-rear-ptr! queue item) (set-cdr! queue item))

    (define (empty-queue? queue) (null? (front-ptr queue)))
    (define (make-queue) (cons '() '()))
    (define (front-queue queue)
        (if (empty-queue? queue)
            (error "FRONT called with an empty queue" queue)
            (car (front-ptr queue))))
    (define (insert-queue! queue item)
        (let ((new-pair (cons item '())))
            (cond ((empty-queue? queue)
                    (set-front-ptr! queue new-pair)
                    (set-rear-ptr! queue new-pair)
                    queue)
                (else
                    (set-cdr! (rear-ptr queue) new-pair)
                    (set-rear-ptr! queue new-pair)
                    queue))))
    (define (delete-queue! queue)
        (cond ((empty-queue? queue)
                (error "DELETE! called with an empty queue" queue))
                (else
                (set-front-ptr! queue (cdr (front-ptr queue)))
                queue)))
    ```
  