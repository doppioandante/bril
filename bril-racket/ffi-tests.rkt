#lang racket

(require rackunit)
(require racket/runtime-path) 

(require "lang.rkt")
(require "interpreter.rkt")

(provide ffi-tests)

(define-runtime-path cffitest-so-path "cffitest.so")

(define cffitest-entry
 (CLibrary cffitest-so-path
           (list (CFunction "printhello" '() null)
                 (CFunction "sum" (list 'int 'int) 'int))))

(define program-call-printhello
   (Program (list
             (Function "main" '() '()
                       (list
                         (Label "start")
                         (EffectInstr 'ccall '(0 "printhello") '() '()))))
            (list cffitest-entry)))

(define program-call-sum
   (Program (list
             (Function "main" '() '()
                       (list
                         (Label "start")
                         (ConstantInstr "a" 'int 3)
                         (ConstantInstr "b" 'int (- 4))
                         (ValueInstr 'ccall 
                                     "res"
                                     'int
                                     `(0 "sum" "a" "b") 
                                     '() '()))))
            (list cffitest-entry)))

(define ccall-testsuite
   (test-suite
     "CCall"
     (test-case
      "call sum from cffitest.so"
      (check-equal? 
        (interp-bril program-call-sum "main")
        (make-immutable-hash 
         '(       
           ["a" . (int 3)]
           ["b" . (int -4)]
           ["res" . (int -1)]))))
     (test-case
      "call printhello from cffitest.so"
      (check-equal? 
        (interp-bril program-call-printhello "main")
        (make-immutable-hash)))))

(define ffi-tests
   (test-suite
    "CFFI Testsuite"
     ccall-testsuite))

