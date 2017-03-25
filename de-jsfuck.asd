;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-

(defpackage #:de-jsfuck-asd
  (:use :cl :asdf))

(in-package :de-jsfuck-asd)

(defsystem de-jsfuck
  :name "de-jsfuck"
  :version "0.0.1"
  :author "Asutosh Palai"
  :licence "MIT"
  :description "Deobfuscate JSFuck"
  :long-description "It deobfuscates JSFuck into readable js"
  :components ((:file "jsfuck-map"
                      :depends-on ("package"))
               (:file "de-jsfuck"
                      :depends-on ("package"
                                   "jsfuck-map"))
               (:file "package"))
  :depends-on (:cl-ppcre))
