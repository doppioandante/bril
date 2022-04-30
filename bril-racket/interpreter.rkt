#lang racket

(provide interp-bril)

(require "lang.rkt")

(define (has-name fun func-name)
  (match fun
    [(Function name _ _ _)
     (equal? name func-name)]))

(define (interp-bril program entry-point-name)
  (match program
    [(Program functions)
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
       (define env (make-immutable-hash))
       (interp-bril-func entry-point '() env 0))]))


(define (interp-bril-func func actual-args env pc)
  (match func
    [(Function name args return-type instrs)
     (if (< pc (length instrs))
       (let ([instr (list-ref instrs pc)])
         (match instr
            [(Label _) 
             (interp-bril-func func actual-args env (+ pc 1))]
            [(ConstantInstr dest type value)
             (begin
              (define new-env (hash-set env dest (list type value)))
              (define new-pc (+ pc 1))
              (interp-bril-func func actual-args new-env new-pc))]
            [(ValueInstr op dest type args funcs labels)
             (begin
              (define result (interp-bril-value-op op type (eval-args args env)))
              (define new-env (hash-set env dest (list type result)))
              (define new-pc (+ pc 1))
              (interp-bril-func func actual-args new-env new-pc))]
            [(EffectInstr op args funcs labels)
             (begin
              (define-values (new-env new-pc) 
                  (match op
                   ['nop
                    (values env (+ pc 1))]
                   ['print
                    (display-bril-var (hash-ref env (car args)))
                    (values env (+ pc 1))])))
             (interp-bril-func func actual-args new-env new-pc)]))
                     
       env)]))

(define (eval-args args env)
   (map (lambda (arg)
             (if (string? arg)
                 (cadr (hash-ref env arg))
                 arg))
        args))
    
(define (display-bril-var var)
  (let ([type (Type-type (car var))]
        [val  (cadr var)])
      (match type
         ['int (displayln val)]
         [_ (error "Unknown type ~a" type)])))

(define (interp-bril-value-op op type args)
   (match op
      ['id (car args)]
      ['add (+ (car args) (cadr args))]))
