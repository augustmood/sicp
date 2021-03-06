# Exercise 3.27

Memoization (also called tabulation) is a technique that enables a procedure to
record, in a local table, values that have previously been computed. This
technique can make a vast difference in the performance of a program. A memoized
procedure maintains a table in which values of previous calls are stored using
as keys the arguments that produced the values. When the memoized procedure is
asked to compute a value, it first checks the table to see if the value is
already there and, if so, just returns that value. Otherwise, it computes the
new value in the ordinary way and stores this in the table. As an example of
memoization, recall from section 1.2.2 the exponential process for computing
Fibonacci numbers:

```scheme
(define (fib n)
  (cond ((= n 0) 0)
        ((= n 1) 1)
        (else (+ (fib (- n 1))
                 (fib (- n 2))))))
```

The memoized version of the same procedure is

```scheme
(define memo-fib
  (memoize (lambda (n)
             (cond ((= n 0) 0)
                   ((= n 1) 1)
                   (else (+ (memo-fib (- n 1))
                            (memo-fib (- n 2))))))))
```

where the memoizer is defined as

```scheme
(define (memoize f)
  (let ((table (make-table)))
    (lambda (x)
      (let ((previously-computed-result (lookup x table)))
        (or previously-computed-result
            (let ((result (f x)))
              (insert! x result table)
              result))))))
```

Draw an environment diagram to analyze the computation of (memo-fib 3). Explain
why memo-fib computes the nth Fibonacci number in a number of steps proportional
to n. Would the scheme still work if we had simply defined memo-fib to be
(memoize fib)?

- `memoize` function can be seen as:

  ```scheme
  (define (memoize f)
    ((lambda (table)
      (lambda (x)
        ((lambda (previously-computed-result)
            (or previously-computed-result
                ((lambda (result)
                  (insert! x result table)
                  result) (f x)))))
        (lookup x table)))
    (make-table)))
  ```

- The diagram: _The diagram needed in Exercise 3.27 is probably the most
  difficult diagram to draw in Chapter 3._

  ![ex3.27](pics/ex3.27/ex3.27.svg)

- The running time is linear, since every number from `1` to `n` are only be
  called by `memo-fib` once. and each `lookup` takes only `O(1)` in the `fib`
  case.

- The scheme will not work, if we define `memo-fib` to the `(memoize fib)`,
  since the fib will not automatically call `memo-fib`, but if we globally set
  `fib` to `(memoize fib)`, then `(memoize fib)` works.
