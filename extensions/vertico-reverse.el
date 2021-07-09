;;; vertico-reverse.el --- Reverse the Vertico display -*- lexical-binding: t -*-

;; Copyright (C) 2021  Free Software Foundation, Inc.

;; This file is part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package is a Vertico extension, which reverses the list of candidates.

;;; Code:

(require 'vertico)

(defvar vertico-reverse-map
  (let ((map (make-composed-keymap nil vertico-map)))
    (define-key map [remap beginning-of-buffer] #'vertico-last)
    (define-key map [remap minibuffer-beginning-of-buffer] #'vertico-last)
    (define-key map [remap end-of-buffer] #'vertico-first)
    (define-key map [remap scroll-down-command] #'vertico-scroll-up)
    (define-key map [remap scroll-up-command] #'vertico-scroll-down)
    (define-key map [remap next-line] #'vertico-previous)
    (define-key map [remap previous-line] #'vertico-next)
    (define-key map [remap next-line-or-history-element] #'vertico-previous)
    (define-key map [remap previous-line-or-history-element] #'vertico-next)
    (define-key map [remap backward-paragraph] #'vertico-next-group)
    (define-key map [remap forward-paragraph] #'vertico-previous-group)
    map)
  "Vertico keymap adapted to reversed candidate order.")

(defun vertico-reverse--display (lines)
  "Display LINES in reverse."
  (move-overlay vertico--candidates-ov (point-min) (point-min))
  (let ((string (concat
                 (unless (eq vertico-resize t)
                   (make-string (- vertico-count (length lines)) ?\n))
		 (apply #'concat (nreverse lines)))))
    (add-face-text-property 0 (length string) 'default 'append string)
    (overlay-put vertico--candidates-ov 'before-string string))
  (vertico--resize-window (length lines)))

(defun vertico-reverse--setup ()
  "Setup reverse keymap."
  (use-local-map vertico-reverse-map))

;;;###autoload
(define-minor-mode vertico-reverse-mode
  "Reverse the Vertico display."
  :global t
  (cond
   (vertico-reverse-mode
    (advice-add #'vertico--display-candidates :override #'vertico-reverse--display)
    (advice-add #'vertico--setup :after #'vertico-reverse--setup))
   (t
    (advice-remove #'vertico--display-candidates #'vertico-reverse--display)
    (advice-remove #'vertico--setup #'vertico-reverse--setup))))

(provide 'vertico-reverse)
;;; vertico-reverse.el ends here
