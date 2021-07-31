# Chapter 4 Metalinguistic Abstraction

<p style="color:#FF6666; font-weight: bold; font-style: italic"> All the codes and some sentences in 
this note are from the book: SICP <p>

`Metalinguistic abstraction` -- establishing new languages -- plays an important
role in all branches of engineering design. It is particularly important to
computer programming, because in programming not only can we formulate new
languages but we can also implement these languages by constructing evaluators.

An _`evaluator`_ (or _`interpreter`_) for a programming language is a procedure
that, when applied to an expression of the language, performs the actions
required to evaluate that expression.

The evaluator, which determines the meaning of expressions in a programming
language, is just another program.

# Chapter 4.1 The Metacircular Evaluator

- An evaluator that is written in the same language that it evaluates is said to
  be _`metacircular`_.

  - The `metacircular evaluator` is essentially a Scheme formulation of the
    `environment model`, and the model has two parts:
    - To evaluate a combination (a compound expression other than a special
      form), evaluate the subexpressions and then apply the value of the
      operator subexpression to the values of the operand subexpressions.
    - To apply a compound procedure to a set of arguments, evaluate the body of
      the procedure in a new environment. To construct this environment, extend
      the environment part of the procedure object by a frame in which the
      formal parameters of the procedure are bound to the arguments to which the
      procedure is applied.

- The implementation of the evaluator will depend upon procedures that define
  the _`syntax`_ of the expressions to be evaluated.

## 4.1.1 The Core of the Evaluator

- The evaluation process can be described as the interplay between two
  procedures: _`eval`_ and _`apply`_.

### Eval

- `Eval` takes as arguments an expression and an environment. It classifies the
  expression and directs its evaluation. `Eval` is structured as a case analysis
  of the syntactic type of the expression to be evaluated.

- The _`abstract syntax`_ makes it easy to see how we can change the syntax of
  the language by using the same evaluator, but with a different collection of
  syntax procedures.

#### Primitive expression

- For self-evaluating expressions, such as numbers, `eval` returns the
  expression itself.

- `Eval` must look up variables in the environment to find their values.

#### Special forms

#### Combinations

- For a procedure application, `eval` must recursively evaluate the operator
  part and the operands of the combination. The resulting procedure and
  arguments are passed to `apply`, which handles the actual procedure
  application.

- The definition of `eval`:

  ```scheme
  (define (eval exp env)
      (cond ((self-evaluating? exp) exp)
              ((variable? exp) (lookup-variable-value exp env))
              ((quoted? exp) (text-of-quotation exp))
              ((assignment? exp) (eval-assignment exp env))
              ((definition? exp) (eval-definition exp env))
              ((if? exp) (eval-if exp env))
              ((lambda? exp)
              (make-procedure (lambda-parameters exp)
                              (lambda-body exp)
                              env))
              ((begin? exp)
              (eval-sequence (begin-actions exp) env))
              ((cond? exp) (eval (cond->if exp) env))
              ((application? exp)
              (apply (eval (operator exp) env)
                      (list-of-values (operands exp) env)))
              (else
              (error "Unknown expression type -- EVAL" exp))))
  ```

  _For clarity, eval has been implemented as a case analysis using cond._

### Apply

- `Apply` classifies procedures into two kinds: It calls
  `apply-primitive-procedure` to apply primitives; it applies compound
  procedures by sequentially evaluating the expressions that make up the body of
  the procedure.

- The definition of `apply`:

  ```scheme
  (define (apply procedure arguments)
      (cond ((primitive-procedure? procedure)
              (apply-primitive-procedure procedure arguments))
            ((compound-procedure? procedure)
              (eval-sequence
                  (procedure-body procedure)
                  (extend-environment
                      (procedure-parameters procedure)
                      arguments
                      (procedure-environment procedure))))
              (else
                  (error
                  "Unknown procedure type -- APPLY" procedure))))
  ```

### Procedure arguments

```scheme
(define (list-of-values exps env)
  (if (no-operands? exps)
      '()
      (cons (eval (first-operand exps) env)
            (list-of-values (rest-operands exps) env))))
```

### Conditionals

```scheme
(define (eval-if exp env)
  (if (true? (eval (if-predicate exp) env))
      (eval (if-consequent exp) env)
      (eval (if-alternative exp) env)))
```

### Sequences

`Eval-sequence` is used by `apply` to evaluate the sequence of expressions in a
procedure body and by `eval` to evaluate the sequence of expressions in a
`begin` expression.

```scheme
(define (eval-sequence exps env)
  (cond ((last-exp? exps) (eval (first-exp exps) env))
        (else (eval (first-exp exps) env)
              (eval-sequence (rest-exps exps) env))))
```

### Assignments and definitions

The following procedures handles assignments to variables. It calls `eval` to
find the value to be assigned and transmits the variable and the resulting value
to set-variable-value! to be installed in the designated environment.

```scheme
(define (eval-assignment exp env)
  (set-variable-value! (assignment-variable exp)
                       (eval (assignment-value exp) env)
                       env)
  'ok)
```

```scheme
(define (eval-definition exp env)
  (define-variable! (definition-variable exp)
                    (eval (definition-value exp) env)
                    env)
  'ok)
```

_This implementation of define ignores a subtle issue in the handling of
internal definitions, although it works correctly in most cases._