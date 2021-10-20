#lang racket

(require rackunit)

(require "bril.rkt")
(require "interp-bril.rkt")
(require/expose "bril.rkt" (type-to-jsexpr arg-to-jsexpr instr-to-jsexpr program-to-jsexpr))

(provide all-tests)

(define all-tests
    (test-suite
     "bril-racket test suite"
     jsexpr-conversion-testsuite
     json-output-testsuite
     bril-interp-testsuite))

(define program-listing-1
   (Program (list
             (Function "main" '() '()
                       (list
                         (Label "start")
                         (ValueInstr 'add "a" (Type 'int)
                                   '("z" "w") '() '()))))))

(define program-listing-2
   (Program (list
             (Function "main" '() '()
                       (list
                         (Label "start")
                         (ConstantInstr "z" (Type 'int) 3)
                         (ValueInstr 'id "w" (Type 'int) '(5) '() '())
                         (ValueInstr 'add "a" (Type 'int)
                                   '("z" "w") '() '())
                         (EffectInstr 'print '("a") '() '()))))))

(define json-output-testsuite
    (test-suite
     "bril to json conversion"
     (test-case
        "program listing to json"
        (check-equal? (with-output-to-string 
                          (lambda () (write-bril program-listing-1)))
                      (string-join (list "{\"functions\":[{\"name\":\"main\",\"instrs\":"
                                         "[{\"label\":\"start\"},{\"labels\":[],\"type\":"
                                         "\"int\",\"funcs\":[],\"args\":[\"z\",\"w\"],\""
                                         "op\":\"add\",\"dest\":\"a\"}],\"args\":[]}]}")
                                   "")))))
     

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
        (check-equal? (instr-to-jsexpr (EffectInstr 'print '("Hello" "World") '() '()))
                 '#hash([op . "print"]
                        [args . ("Hello" "World")]
                        [funcs . ()] 
                        [labels . ()]))
        (check-equal? (program-to-jsexpr program-listing-1)
                      '#hash((functions 
                              .
                              [#hash((args .())
                                     (name . "main")
                                     (instrs .
                                             [#hash((label . "start"))
                                              #hash([op . "add"]
                                                    [dest . "a"]
                                                    [type . "int"]
                                                    [args . ("z" "w")]
                                                    [funcs . ()] 
                                                    [labels . ()])]))]))))))

(define bril-interp-testsuite
    (test-suite "simple program with addition"
        (interp-bril program-listing-2 "main")))
