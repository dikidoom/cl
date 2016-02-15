;; (format t "Hello World!~%")

(defstruct screen chars colors width height)

(defun terminal-escape (code)
  (format t "~C[~a" #\Esc code))

(defun place-char (screen x y char)
  (let ((index (+ x (* y (screen-width screen)))))
    (setf (elt (screen-chars screen) index) char)))

(defun place-color (screen x y color)
  (let ((index (+ x (* y (screen-width screen)))))
    (setf (elt (screen-colors screen) index) color)))

(defun print-screen (screen &optional (index 0))
  (when (< index (* (screen-width screen)
                    (screen-height screen)))
    (let ((color (elt (screen-colors screen) index))
          (char (elt (screen-chars screen) index))
          ;;(last-color (if (= index 0) nil (elt (screen-colors screen) (1- index))))
          )
      (when (and (> index 0)
                 (= 0 (mod index
                           (screen-width screen))))
        (format t "~C" #\Newline))
      (terminal-escape (format nil "~dm" (+ 30 color)))
      (format t "~C" char)
      ;; recur
      (print-screen screen (1+ index)))))

;; (do ((temp 0 (1+ temp)))
;;     ((> temp 3))
;;     (terminal-escape "31m") ; color red
;;     (format t "bing!~%")
;;     )

;; (terminal-escape "5A") ; 5 lines up
;; (terminal-escape "12C") ; 12 columns right
;; (format t "backstabba!")
(defun fill-screen (screen)
  (labels ((alternate (n oddc evenc)
             (if (> n 0)
                 (cons oddc (alternate (1- n) evenc oddc))
                 '())))
    (let* ((line1 (concatenate 'string (alternate (screen-width screen) #\+ #\-)))
           (line2 (concatenate 'string (alternate (screen-width screen) #\| #\Space)))
           (lines (apply #'concatenate 'string (alternate (screen-height screen) line1 line2))))
      (setf (screen-chars screen) lines))))

(defvar *screen*)
(setf *screen* (make-screen :chars (make-string (* 9 9) :initial-element #\x)
                            :colors (make-array (* 9 9) :initial-element 4)
                            :width 9
                            :height 9))

(fill-screen *screen*)
(place-char *screen* 0 8 #\o)
(place-char *screen* 8 0 #\/)
(place-color *screen* 0 8 3)

;;(format t "~3%")
(print-screen *screen*)
;;(format t "~3%")

