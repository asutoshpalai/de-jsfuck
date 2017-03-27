#!/bin/bash

if [ "$#" -ne 1  ]; then
  echo "Usage: $0 <JSFuck code>";
  exit 1
fi

if [ -x "$(command -v ros)"  ]; then
  LISP="ros"
elif [ -x "$(command -v sbcl)"  ]; then
  LISP="sbcl --noinform  --non-interactive"
else
  echo 'Error: neither roswell non sbcl is installed.' >&2
  exit 1
fi

$LISP  --eval "(push *default-pathname-defaults* asdf:*central-registry*)" --eval "(ql:quickload '(:cl-ppcre :de-jsfuck) :silent t)"  --eval "(princ (de-jsfuck:to-js \"$(printf '%q' $1)\"))"
echo
