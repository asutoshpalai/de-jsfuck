(in-package :de-jsfuck)

(defparameter *parens-map* '((#\( . #\))
                            (#\[ . #\])))

(defun detect-nums (str pos)
  "Numbers are in form of [!+[]+!+[]] for 2, [!+[]+!+[]] for 3, [+!+[]] for 1"
  (first (all-matches-as-strings "^\\[(((!\\+\\[])?(\\+!\\+\\[])+)|\\+\\[])]" str :start pos)))

(defun to-num-sym (str)
  "Convert the string for nums to the actual number"
  (digit-char (floor (/ (- (length str) 1) 5))))

(defmacro assoc-val (key lst)
  "My regular assoc helper"
  `(cdr (assoc ,key ,lst)))

(defun prefix-match (str prefix &optional (start 0))
  "To check if one string is prefix of the other"
  (let ((res (mismatch prefix str :start2 start)))
    (or
     (not res) ; When both are euqal
     (= res (length prefix)))))

(defmacro paren-match (paren)
  `(assoc-val ,paren *parens-map*))

(defun match-parse (str start-pos)
  "Given a string a starting pos where a bracket starts, it return
   where the position of the corresponding closing bracket in a
   nested bracket string, e.g. ([(()[])])"
  (let* ((start-pos (if (paren-match (char str start-pos))
                        start-pos
                        (min (or (position #\[ str :start start-pos)
                                 (length str))
                             (or (position #\( str :start start-pos)
                                 (length str)))))
         (init-paren (char str start-pos))
         (close-paren (paren-match init-paren)))
    (print init-paren)
    (loop
       for cur-pos = (+ 1 start-pos) then (+ 1 (match-parse str next-init))
       for next-close = (position close-paren str :start cur-pos)
       for next-init = (position init-paren str :start cur-pos :end next-close)
       while next-init
       finally (return next-close))))

(defun segmentize (str)
  "One of my initial analysis function. Not used latter in the code"
  (loop with size = (length str)
     for i = 0 then (+ 1 e)
     for e = (match-parse str i)
       while (< e (- size 1))
     collect (subseq str i e)))

(defun test-others (str pos)
  "Test for the strings in the token-map"
  (loop for (sym val) on *token-map* by #'cddr
     for res = (prefix-match str val pos)
     until res
      ; do (print sym)
     finally (return (and res (cons sym val)))))

(defun test-func (str pos)
  (loop for val in *function*
     for res = (prefix-match str val pos)
     until res
     ; do (print val)
     finally (return (and res val))))

(defun tokenize (str &optional (pos 0))
  "Convert the string into corresponding recognisable entities. This does
   the actual deobfuscation."
  ;(print (subseq str pos (min (length str) (+ 30 pos))))
  (when (prefix-match str "()(" pos)
    (let ((paren-end (match-parse str (+ 2 pos))))
      ;(print "funcall with paren")
      (return-from tokenize
          `(funcall \( ,@(tokenize (subseq str (+ 3 pos) paren-end)) \)
            ,@(tokenize str (+ 1 paren-end))))))
  (when (prefix-match str "()" pos)
    ;(print "funcall")
    (return-from tokenize
      `(funcall ,(tokenize str (+ 2 pos)))))
  (let ((s (detect-nums str pos)))
    (when s
      (return-from tokenize (cons
                             (to-num-sym s)
                             (tokenize str (+ pos (length s)))))))
  (let ((res (test-others str pos)))
    (when res
     ; (print sym)
      (return-from tokenize (cons
                             (car res)
                             (tokenize str (+ pos (length (cdr res))))))))
  (let ((f-str (test-func str pos)))
    (when f-str
      (let* ((end (+ pos (length f-str)))
             (paren-end (match-parse str end)))
        ; (print "func")
        (return-from tokenize
          `((func
             ,(tokenize (subseq str (+ 1 end) paren-end)))
            ,@(tokenize str (+ 1 paren-end)))))))
  (loop
     for next = pos then (+ 1 (match-parse str next))
     while (and (< next (length str))
                (not (eq #\+ (char str next))))
     finally (return  (cons (if (not (= pos next))
                                (progn
                                  (princ (concatenate 'string "\"" (subseq str pos next) "\","))
                                  `(unknown ,(subseq str pos next))))
                            (when (< next (length str))
                              (tokenize str next))))))

(defun tokens-to-string-list (tokens)
  "Convert the token list from tokenizer into a list of strings that
   can be concatenated to get the actual JS code"
  (let ((start (first tokens)))
    (cond ((not start)
           (if (cdr tokens)
               (tokens-to-string-list (cdr tokens))))
          ((listp start)
           (cond ((eq (car start) 'func)
                  `("Function(\""
                    ,@(tokens-to-string-list (cadr start))
                    "\")"
                    ,@(tokens-to-string-list (cdr tokens))))
                 ((eq (car start) 'unknown)
                  `("<unknown: " ,(cadr start) ">"
                                 ,@(tokens-to-string-list (cdr tokens))))))
          ((eq start '+)
           (tokens-to-string-list (cdr tokens)))
          ((eq start 'funcall)
           (cons "()" (tokens-to-string-list (cdr tokens))))
          ((or (symbolp start) (characterp start))
           (cons (string start) (tokens-to-string-list (cdr tokens))))
          (t (print (type-of start))))))

(defun to-JS (str)
  "The wrapper function"
  (let ((parts (tokens-to-string-list (tokenize str))))
    (apply #'concatenate 'string parts)))
