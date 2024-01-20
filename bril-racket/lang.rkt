#lang racket

(provide 
   Program Function Argument Label ConstantInstr ValueInstr EffectInstr 
   Type Bool CLibrary CFunction Int effect-ops value-ops write-bril 
   program-to-jsexpr Function-args Type-type Argument-type)

(require json)

(struct Program (functions clibraries) #:transparent)
(struct Function (name args return-type instrs) #:transparent)
(struct Argument (name type) #:transparent)
(struct Label (label) #:transparent)
(struct ConstantInstr (dest type value) #:transparent)
(struct ValueInstr (op dest type args funcs labels) #:transparent)
(struct EffectInstr (op args funcs labels) #:transparent)
(struct Type (type) #:transparent)
(struct Int (value) #:transparent)
(struct Bool (value) #:transparent)

(struct CLibrary (abspath functions) #:transparent)
(struct CFunction (name args return-type) #:transparent)

(define effect-ops
  '(jump branch call ccall return print nop))

(define value-ops
  '(add sub mul div eq lt gt le ge not and or call ccall id))

(define bril-types
  '(int bool))

(define (write-bril program)
  (write-json (program-to-jsexpr program)))

(define (program-to-jsexpr p)
  (match p
    [(Program functions clibraries)
     (let ([h (make-immutable-hasheq)])
         (hash-set h 'functions (map function-to-jsexpr functions)))]))

(define (function-to-jsexpr function)
  (match function
    [(Function name args return-type instrs)
     (let ([h (hash-set* (make-immutable-hasheq)
                 'name name
                 'args (map arg-to-jsexpr args)
                 'instrs (map instr-to-jsexpr instrs))])
          (if (empty? return-type)
             h
             (hash-set h 'type (type-to-jsexpr return-type))))]))

(define (arg-to-jsexpr arg)
  (match arg
    [(Argument name type)
     (make-immutable-hasheq `([name . ,name] [type . ,(type-to-jsexpr type)]))]))

; TODO: check that the type is valid
(define (type-to-jsexpr type)
  (match type
    [(Type type)
     (symbol->string type)]))

(define (instr-to-jsexpr instr)
  (match instr
    [(Label label)
     `#hasheq((label . ,label))]
    [(ConstantInstr dest type value)
     (make-immutable-hasheq
      `([op . "const"]
        [dest . ,dest]
        [type . ,(type-to-jsexpr type)]
        [value . ,value]))]
    [(ValueInstr op dest type args funcs labels)
     (make-immutable-hasheq
      `([op . ,(symbol->string op)]
        [dest . ,dest]
        [type . ,(type-to-jsexpr type)]
        [args . ,args]
        [funcs . ,funcs]
        [labels . ,labels]))]
    [(EffectInstr op args funcs labels)
     (make-immutable-hasheq
      `([op . ,(symbol->string op)]
        [args . ,args]
        [funcs . ,funcs]
        [labels . ,labels]))]))
