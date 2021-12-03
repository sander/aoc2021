#lang racket

(struct position (horizontal depth) #:transparent)

(define (position-multiplied position)
  (* (position-horizontal position)
     [position-depth position]))

(define initial-position (position 0 0))

(define (move command start)
  (define h (position-horizontal start))
  (define d (position-depth start))
  (define v (cadr command))
  (case (car command)
    [(forward) (position (+ h v) d)]
    [(down) (position h (+ d v))]
    [(up) (position h (- d v))]))

(define (parse-command string)
  (define match (regexp-match #rx"(forward|down|up) ([1-9][0-9]*)" string))
  (if (pair? match)
      (list (string->symbol (cadr match)) (string->number (caddr match)))
      #f))

(module+ test
  (require rackunit)

  (define example-input '([forward 5]
                          [down 5]
                          [forward 8]
                          [up 3]
                          [down 8]
                          [forward 2]))

  (define example-output (position 15 10))

  (check-equal? (foldl move initial-position example-input) example-output)
  [check-equal? (position-multiplied example-output) 150]

  (check-equal? (parse-command "forward 10") '(forward 10))
  (check-equal? (parse-command "forward") #f))

(define (follow-planned-course-in file)
  (define m (map parse-command (sequence->list (in-lines file))))
  (define result (position-multiplied (foldl move initial-position m)))
  (printf "~a is the final horizontal position multipled by the final depth" result))

(call-with-input-file "02-input.txt" follow-planned-course-in)