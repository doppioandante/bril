#lang racket

(require rackunit)
(require racket/runtime-path) 

(require "lang.rkt")
(require "interpreter.rkt")

(provide ffi-tests)

(define-runtime-path cffitest-so-path "cffitest.so")

(define cffitest-entry
 (CLibrary cffitest-so-path
           (list (CFunction "printhello" '() '()))))

(define program-call-printhello
   (Program (list
             (Function "main" '() '()
                       (list
                         (Label "start")
                         (EffectInstr 'ccall '(0 "printhello") '() '()))))
            (list cffitest-entry)))

(define printhello-testcase
    (test-case
     "call printhello from cffitest.so"
     (check-equal? 
       (interp-bril program-call-printhello "main")
       (make-immutable-hash))))

(define ffi-tests
   (test-suite
    "CFFI Testsuite"
    printhello-testcase))

