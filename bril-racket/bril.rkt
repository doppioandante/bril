#lang racket

(require json)

(provide 
   Program Function Argument Label ConstantInstr ValueInstr EffectInstr 
   Type Bool Int effect-ops value-ops)

(struct Program (functions))
(struct Function (name args return-type instrs))
(struct Argument (name type))
(struct Label (label))
(struct ConstantInstr (op dest type value))
(struct ValueInstr (op dest type args funcs labels))
(struct EffectInstr (op args funcs labels))
(struct Type (type))
(struct Int (value))
(struct Bool (value))

(define effect-ops
    '(jump branch call return print nop))

(define value-ops
    '(add sub mul div eq lt gt le ge not and or call id phi))

