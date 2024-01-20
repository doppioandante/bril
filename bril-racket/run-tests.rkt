#!/usr/bin/env racket
#lang racket

(require rackunit/text-ui)
(require "tests.rkt")
(require "ffi-tests.rkt")

(run-tests all-tests)
(run-tests ffi-tests)
