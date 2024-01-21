#lang racket

(require rackunit)

(require "lang.rkt")
(require "interpreter.rkt")
(require/expose "lang.rkt" (type-to-jsexpr arg-to-jsexpr instr-to-jsexpr program-to-jsexpr))

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
                         (ValueInstr 'add "a" 'int
                                   '("z" "w") '() '()))))
            '()))

(define program-listing-2
   (Program (list
             (Function "main" '() '()
                       (list
                         (Label "start")
                         (ConstantInstr "z" 'int 3)
                         (ValueInstr 'id "w" 'int '("z") '() '())
                         (ValueInstr 'add "a" 'int
                                   '("z" "w") '() '())
                         (EffectInstr 'print '("a") '() '()))))
            '()))

(define program-listing-3
   (Program (list
             (Function "main" '() '()
                       (list
                         (Label "start")
                         (ConstantInstr "z" 'int 3)
                         (ValueInstr 'id "w" 'int '("z") '() '())
                         (ValueInstr 'add "a" 'int
                                   '("z" "w") '() '())
                         (EffectInstr 'return '("a") '() '()))))
            '()))

(define program-listing-4
   (Program (list
             (Function "main" '() '()
                       (list
                         (Label "start")
                         (ConstantInstr "z" 'int 3)
                         (ValueInstr 'id "w" 'int '("z") '() '())
                         (ValueInstr 'sub "a" 'int
                                   '("z" "w") '() '())
                         (EffectInstr 'return '("a") '() '()))))
            '()))



(define json-output-testsuite
    (test-suite
     "bril to json conversion"
     (test-case
        "program listing to json"
        (check-equal? (with-output-to-string 
                          (lambda () (write-bril program-listing-1)))
                      (string-join (list "{\"functions\":[{\"args\":[],\"instrs\":[{\"label\":"
                                         "\"start\"},{\"args\":[\"z\",\"w\"],\"dest\":\"a\","
                                         "\"funcs\":[],\"labels\":[],\"op\":\"add\",\"type\""
                                         ":\"int\"}],\"name\":\"main\"}]}")
                                   "")))))
     

(define jsexpr-conversion-testsuite
    (test-suite
     "bril to jsexrp conversion"
     (test-case
        "type to jsexpr conversion"
        (check-equal? (type-to-jsexpr 'bool) "bool")
        (check-equal? (type-to-jsexpr 'int) "int"))
     (test-case
        "argument to jsexpr conversion"
        (check-equal? (arg-to-jsexpr (Argument 'a 'int))
                      '#hasheq((name . a) (type . "int"))))
     (test-case
        "instr to jsexpr conversion"
        (check-equal? (instr-to-jsexpr (Label "x"))
                      '#hasheq((label . "x")))
        (check-equal? (instr-to-jsexpr (ConstantInstr "a" 'int 2))
                      '#hasheq([op . "const"]
                               [dest . "a"]
                               [type . "int"]
                               [value . 2]))
        (check-equal? (instr-to-jsexpr (ValueInstr 'add "a" 'int 
                                                   '("z" "w") '() '()))
                      '#hasheq([op . "add"]
                               [dest . "a"]
                               [type . "int"]
                               [args . ("z" "w")]
                               [funcs . ()] 
                               [labels . ()]))
        (check-equal? (instr-to-jsexpr (EffectInstr 'print '("Hello" "World") '() '()))
                 '#hasheq([op . "print"]
                          [args . ("Hello" "World")]
                          [funcs . ()] 
                          [labels . ()]))
        (check-equal? (program-to-jsexpr program-listing-1)
                      '#hasheq((functions
                                .
                                [#hasheq((args .())
                                         (name . "main")
                                         (instrs .
                                                 [#hasheq((label . "start"))
                                                  #hasheq([op . "add"]
                                                          [dest . "a"]
                                                          [type . "int"]
                                                          [args . ("z" "w")]
                                                          [funcs . ()] 
                                                          [labels . ()])]))]))))))

(define bril-interp-testsuite
    (test-suite "bril interpreter tests"
        (test-case
          "simple program execution "
          (check-equal? (with-output-to-string
                           (lambda ()
                             (interp-bril program-listing-2 "main")))
                        "6\n"))
        (test-case
          "simple program with return value"
          (check-equal? (interp-bril program-listing-3 "main")
                        (list 'int 6)))
        (test-case
          "simple program with return value, using subtraction"
          (check-equal? (interp-bril program-listing-4 "main")
                        (list 'int 0)))))
