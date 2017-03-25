# de-jsfuck

It deobfuscates JSFuck into readable JavaScript.

## Quick use guide

- Install sbcl

- Install quicklisp (https://www.quicklisp.org/beta/#installation) 

- Run

      $ sbcl --noinform --non-interactive --eval "(ql:quickload '(:cl-ppcre :de-jsfuck))"  --eval '(princ (de-jsfuck:to-js "<JSFuck Code>"))'

## Background details

  [Blog post](http://blog.asutoshpalai.in/2017/03/jsfuck-is-bad-security-barrier.html)
