
;;; predictive-latex-cleveref.el --- predictive mode LaTeX cleveref
;;;                                  package support


;; Copyright (C) 2004-2007 Toby Cubitt

;; Author: Toby Cubitt <toby-predictive@dr-qubit.org>
;; Version: 0.4
;; Keywords: predictive, latex, package, cleveref, cref
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
;; Version 0.4
;; * renamed to "cleveref" to match package name change
;;
;; Version 0.3
;; * updated for new version of smartref package
;;
;; Version 0.2.1
;; * updated `completion-override-syntax-alist' settings to reflect changes in
;;   predictive-latex.el
;; 
;; Version 0.2
;; * added overlay-local `completion-override-syntax-alist' bindings
;;
;; Version 0.1
;; * initial version


;;; Code:

(require 'predictive-latex)
(provide 'predictive-latex-cleveref)

;; add load and unload functions to alist
;;(assoc-delete-all "cleveref" predictive-latex-usepackage-functions)
(push '("cleveref" predictive-latex-load-cleveref
	predictive-latex-unload-cleveref)
      predictive-latex-usepackage-functions)


;; set up 'predictive-latex-cleveref-label-word to be a `thing-at-point'
;; symbol
(put 'predictive-latex-cleveref-label-word 'forward-op
     'predictive-latex-cleveref-label-forward-word)



(defun predictive-latex-load-cleveref ()
  ;; Load cref regexps
  (auto-overlay-load-compound-regexp
   `(start "\\\\cref{" (dict . predictive-latex-label-dict) (priority . 2)
	   (completion-menu . predictive-latex-construct-browser-menu)
	   (completion-word-thing . predictive-latex-cleveref-label-word)
	   (completion-dynamic-syntax-alist . ((?w . (add t word))
					       (?_ . (add t word))
					       (?  . (accept t none))
					       (?. . (add t word))
					       (t  . (reject t none))))
	   (completion-dynamic-override-syntax-alist
	    . ((?: . ((lambda ()
			(predictive-latex-completion-add-to-regexp ":"))
		      t word))
	       (?_ . ((lambda ()
			(predictive-latex-completion-add-to-regexp "\\W"))
		      t word))
	       (?, . (accept t none))
	       (?} . (accept t none))))
	   (face . (background-color . ,predictive-overlay-debug-color)))
   'predictive 'brace t 'cref)
  (auto-overlay-load-compound-regexp
   `(start "\\\\Cref{" (dict . predictive-latex-label-dict) (priority . 2)
	   (completion-menu . predictive-latex-construct-browser-menu)
	   (completion-word-thing . predictive-latex-cleveref-label-word)
	   (completion-dynamic-syntax-alist . ((?w . (add t word))
					       (?_ . (add t word))
					       (?  . (accept t none))
					       (?. . (add t word))
					       (t  . (reject t none))))
	   (completion-dynamic-override-syntax-alist
	    . ((?: . ((lambda ()
			(predictive-latex-completion-add-to-regexp ":"))
		      t word))
	       (?_ . ((lambda ()
			(predictive-latex-completion-add-to-regexp "\\W"))
		      t word))
	       (?, . (accept t none))
	       (?} . (accept t none))))
	   (face . (background-color . ,predictive-overlay-debug-color)))
   'predictive 'brace t 'Cref)
)



(defun predictive-latex-unload-cleveref ()
  ;; Unload cref regexps
  (auto-overlay-unload-regexp 'predictive 'brace 'cref)
  (auto-overlay-unload-regexp 'predictive 'brace 'Cref)
)



(defun predictive-latex-cleveref-label-forward-word (&optional n)
  (let (m)
    ;; going backwards...
    (if (and n (< n 0))
	(unless (bobp)
	  (setq m (- n))
	  (when (= ?\\ (char-before))
	    (while (= ?\\ (char-before)) (backward-char))
	    (setq m (1- m)))
	  (dotimes (i m)
	    (backward-word 1)  ; argument not optional in Emacs 21
	    (while (and (char-before)
			(or (= (char-syntax (char-before)) ?w)
			    (= (char-syntax (char-before)) ?_)
			    (and (= (char-syntax (char-before)) ?.)
				 (/= (char-before) ?,))))
	      (backward-char))))
      ;; going forwards...
      (unless (eobp)
	(setq m (if n n 1))
	(dotimes (i m)
	  (if (re-search-forward "\\(\\w\\|\\s_\\|\\s.\\)+" nil t)
	      (when (= (char-before) ?,) (backward-char))
	    (goto-char (point-max)))))
      ))
)

;;; predictive-latex-cleveref ends here