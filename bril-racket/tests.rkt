#lang racket

(require rackunit)

(require "bril.rkt")
(require/expose "bril.rkt" (type-to-jsexpr arg-to-jsexpr instr-to-jsexpr))

(provide all-tests)

(define all-tests
    (test-suite
     "bril-racket test suite"
     jsexpr-conversion-testsuite))

(define jsexpr-conversion-testsuite
    (test-suite
     "bril to jsexrp conversion"
     (test-case
        "type to jsexpr conversion"
        (check-equal? (type-to-jsexpr (Type 'bool)) "bool")
        (check-equal? (type-to-jsexpr (Type 'int)) "int"))
     (test-case
        "argument to jsexpr conversion"
        (check-equal? (arg-to-jsexpr (Argument 'a (Type 'int)))
                      '#hash((name . a) (type . "int"))))
     (test-case
        "instr to jsexpr conversion"
        (check-equal? (instr-to-jsexpr (Label "x"))
                      '#hash((label . "x")))
        (check-equal? (instr-to-jsexpr (ConstantInstr "a" (Type 'int) 2))
                      '#hash([op . "const"]
                             [dest . "a"]
                             [type . "int"]
                             [value . 2]))
        (check-equal? (instr-to-jsexpr (ValueInstr 'add "a" (Type 'int) 
                                                   '("z" "w") '() '()))
                      '#hash([op . "add"]
                             [dest . "a"]
                             [type . "int"]
                             [args . ("z" "w")]
                             [funcs . ()] 
                             [labels . ()]))
        (check-equal? (instr-to-jsexpr (ValueInstr 'add "a" (Type 'int) 
                                                   '("z" "w") '() '()))
                      '#hash([op . "add"]
                             [dest . "a"]
                             [type . "int"]
                             [args . ("z" "w")]
                             [funcs . ()] 
                             [labels . ()])))))

