#lang racket

(provide interp-bril)

(require "lang.rkt")
(require ffi/unsafe
         ffi/unsafe/define)

(struct CFFIEntry (clib cfuncs) #:transparent)

(define (has-name fun func-name)
  (match fun
    [(Function name _ _ _)
     (equal? name func-name)]))

(define (interp-bril program entry-point-name)
  (match program
    [(Program functions clibraries)
     (begin
       (define entry-point (findf 
                            (lambda (f) 
                                (has-name f entry-point-name))
                            functions))
       (if (eq? entry-point #f)
           (error "no entry point named ~a" entry-point-name)
           '())
       (if (not (equal? (Function-args entry-point) '()))
           (error "entry point must not accept arguments")
           '())
       (define cffi-entries (validate-cffi-info clibraries))
       (define env (make-immutable-hash))
       (interp-bril-func entry-point '() env 0 cffi-entries))]))

(define (validate-cffi-info clibraries)
  (list->vector (map create-cffi-entry clibraries)))

(define (create-cffi-entry clibrary)
  (match clibrary
    [(CLibrary abspath functions)
     (begin
       (define clib (ffi-lib (abspath-to-racket-ffi-path abspath)))
       (CFFIEntry clib
                  (make-immutable-hash (map (create-cffi-func-assoc clib) functions))))]))

(define (create-cffi-func-assoc clib)
  (lambda (func)
    (match func
       [(CFunction name args return-type)
        `(,name .
          ,(get-ffi-obj name clib (signature-to-racket-ffi args return-type)))])))
       
(define (signature-to-racket-ffi args return-type)
  (_cprocedure (map (compose Argument-type bril-type-to-racket-ffi)
                    args)
               (bril-type-to-racket-ffi return-type)))

(define (bril-type-to-racket-ffi type)
   (cond
      [(eq? type 'int) _int64]
      [(eq? type 'bool) _stdbool]
      [(empty? type) _void]))
       

(define (abspath-to-racket-ffi-path path) path)

(define (interp-bril-func func actual-args env pc cffi-entries)
  (match func
    [(Function name args return-type instrs)
     (if (< pc (length instrs))
       (let ([instr (list-ref instrs pc)])
         (match instr
            [(Label _) 
             (interp-bril-func func actual-args env (+ pc 1) cffi-entries)]
            [(ConstantInstr dest type value)
             (begin
              (define new-env (hash-set env dest (list type value)))
              (define new-pc (+ pc 1))
              (interp-bril-func func actual-args new-env new-pc cffi-entries))]
            [(ValueInstr op dest type args funcs labels)
             (begin
              (define result (interp-bril-value-op op type (eval-args args env)))
              (define new-env (hash-set env dest (list type result)))
              (define new-pc (+ pc 1))
              (interp-bril-func func actual-args new-env new-pc cffi-entries))]
            [(EffectInstr op args funcs labels)
             (begin
              (define-values (new-env new-pc ret-value)
                  (match op
                   ['nop
                    (values env (+ pc 1) '())]
                   ['print
                    (display-bril-var (hash-ref env (car args)))
                    (values env (+ pc 1) '())]
                   ['ccall
                    (define lib-index (car args))
                    (define func-name (cadr args))
                    (call-cffi-func lib-index func-name
                                    (eval-args (cddr args) env)
                                    cffi-entries)
                    (values env (+ pc 1) '())]
                   ['return
                    (values env pc (hash-ref env (car args)))])))
                    
             (if (null? ret-value)
                 (interp-bril-func func actual-args new-env new-pc cffi-entries)
                 ret-value)]))
       env)]))

(define (eval-args args env)
   (map 
     (lambda (arg) (cadr (hash-ref env arg)))
     args))

(define (display-bril-var var)
  (let ([type (Type-type (car var))]
        [val  (cadr var)])
      (match type
         ['int (displayln val)]
         [_ (error "Unknown type ~a" type)])))

(define (call-cffi-func lib-index name args cffi-entries)
  (begin
    (define cffi-entry (vector-ref cffi-entries lib-index))
    (define cfuncs-hash (CFFIEntry-cfuncs cffi-entry))
    (apply (hash-ref cfuncs-hash name) args)))

(define (interp-bril-value-op op type args)
   (match op
      ['id (car args)]
      ['add (+ (car args) (cadr args))]
      ['sub (- (car args) (cadr args))]))
