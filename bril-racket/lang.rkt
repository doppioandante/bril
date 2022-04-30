#lang racket

(provide 
   Program Function Argument Label ConstantInstr ValueInstr EffectInstr 
   Type Bool Int effect-ops value-ops write-bril
   Function-args Type-type)

(require json)

(struct Program (functions))
(struct Function (name args return-type instrs))
(struct Argument (name type))
(struct Label (label))
(struct ConstantInstr (dest type value))
(struct ValueInstr (op dest type args funcs labels))
(struct EffectInstr (op args funcs labels))
(struct Type (type))
(struct Int (value))
(struct Bool (value))

(define effect-ops
  '(jump branch call return print nop))

(define value-ops
  '(add sub mul div eq lt gt le ge not and or call id))

(define (write-bril program)
  (write-json (program-to-jsexpr program)))

(define (program-to-jsexpr p)
  (match p
    [(Program functions)
     (let ([h (make-immutable-hash)])
         (hash-set h 'functions (map function-to-jsexpr functions)))]))

(define (function-to-jsexpr function)
  (match function
    [(Function name args return-type instrs)
     (let ([h (hash-set* (make-immutable-hash)
                 'name name
                 'args (map arg-to-jsexpr args)
                 'instrs (map instr-to-jsexpr instrs))])
          (if (empty? return-type)
             h
             (hash-set h 'type (type-to-jsexpr return-type))))]))

(define (arg-to-jsexpr arg)
  (match arg
    [(Argument name type)
     (make-immutable-hash `([name . ,name] [type . ,(type-to-jsexpr type)]))]))

; TODO: check that the type is valid
(define (type-to-jsexpr type)
  (match type
    [(Type type)
     (symbol->string type)]))

(define (instr-to-jsexpr instr)
  (match instr
    [(Label label)
     `#hash((label . ,label))]
    [(ConstantInstr dest type value)
     (make-immutable-hash 
      `([op . "const"]
        [dest . ,dest]
        [type . ,(type-to-jsexpr type)]
        [value . ,value]))]
    [(ValueInstr op dest type args funcs labels)
     (make-immutable-hash 
      `([op . ,(symbol->string op)]
        [dest . ,dest]
        [type . ,(type-to-jsexpr type)]
        [args . ,args]
        [funcs . ,funcs]
        [labels . ,labels]))]
    [(EffectInstr op args funcs labels)
     (make-immutable-hash 
      `([op . ,(symbol->string op)]
        [args . ,args]
        [funcs . ,funcs]
        [labels . ,labels]))]))
