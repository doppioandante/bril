#!/usr/bin/env racket
#lang racket

(require rackunit/text-ui)
(require "tests.rkt")
(require "ffi-tests.rkt")

(void
 (begin
    (system "gcc -fPIC -shared cffitest.so -o cffitest.o")

    (run-tests all-tests)
    (run-tests ffi-tests)))
