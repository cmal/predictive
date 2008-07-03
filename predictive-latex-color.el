
;;; predictive-latex-color.el --- predictive mode LaTeX color package support


;; Copyright (C) 2008 Toby Cubitt

;; Author: Toby Cubitt <toby-predictive@dr-qubit.org>
;; Version: 0.1.1
;; Keywords: predictive, latex, package, color
;; URL: http://www.dr-qubit.org/emacs.php


;; This file is part of the Emacs Predictive Completion package.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
;; MA 02110-1301, USA.


;;; Change Log:
;;
;; Version 0.1.1
;; * improved regexp definitions
;;
;; Version 0.1
;; * initial version


;;; Code:

(require 'predictive-latex)
(provide 'predictive-latex-color)

;; add load and unload functions to alist
(push '("color" predictive-latex-load-color
	predictive-latex-unload-color)
      predictive-latex-usepackage-functions)



(defun predictive-latex-load-color ()
  ;; Load colour dictionary
  (predictive-load-dict 'dict-latex-colours)
  ;; Load regexps
  (auto-overlay-load-regexp
   'predictive 'brace
   `(("[^\\]\\(\\\\\\\\\\)*\\(\\\\color\\(\\[.*?\\]\\)?{\\)" . 2)
     :edge start
     :id color
     (dict . dict-latex-colours)
     (priority . 40)
     (face . (background-color . ,predictive-overlay-debug-color)))
   t)
  (auto-overlay-load-regexp
   'predictive 'brace
   `(("^\\(\\\\color\\(\\[.*?\\]\\)?{\\)" . 1)
     :edge start
     :id color-bol
     (dict . dict-latex-colours)
     (priority . 40)
     (face . (background-color . ,predictive-overlay-debug-color)))
   t)
  (auto-overlay-load-regexp
   'predictive 'brace
   `(("[^\\]\\(\\\\\\\\\\)*\\(\\\\textcolor\\(\\[.*?\\]\\)?{\\)" . 2)
     :edge start
     :id textcolor
     (dict . dict-latex-colours)
     (priority . 40)
     (face . (background-color . ,predictive-overlay-debug-color)))
   t)
  (auto-overlay-load-regexp
   'predictive 'brace
   `(("^\\(\\\\textcolor\\(\\[.*?\\]\\)?{\\)" . 1)
     :edge start
     :id textcolor-bol
     (dict . dict-latex-colours)
     (priority . 40)
     (face . (background-color . ,predictive-overlay-debug-color)))
   t)
  (auto-overlay-load-regexp
   'predictive 'brace
   `(("[^\\]\\(\\\\\\\\\\)*\\(\\\\pagecolor\\(\\[.*?\\]\\)?{\\)" . 2)
     :edge start
     :id pagecolor
     (dict . dict-latex-colours)
     (priority . 40)
     (face . (background-color . ,predictive-overlay-debug-color)))
   t)
  (auto-overlay-load-regexp
   'predictive 'brace
   `(("^\\(\\\\pagecolor\\(\\[.*?\\]\\)?{\\)" . 1)
     :edge start
     :id pagecolor-bol
     (dict . dict-latex-colours)
     (priority . 40)
     (face . (background-color . ,predictive-overlay-debug-color)))
   t)
)



(defun predictive-latex-unload-color ()
  ;; unload regexps
  (auto-overlay-unload-regexp 'predictive 'brace 'color)
  (auto-overlay-unload-regexp 'predictive 'brace 'color-bol)
  (auto-overlay-unload-regexp 'predictive 'brace 'textcolor)
  (auto-overlay-unload-regexp 'predictive 'brace 'textcolor-bol)
  (auto-overlay-unload-regexp 'predictive 'brace 'pagecolor)
  (auto-overlay-unload-regexp 'predictive 'brace 'pagecolor-bol)
  ;; unload colour dictionary
  (predictive-unload-dict 'dict-latex-colours)
)

;;; predictive-latex-color ends here
