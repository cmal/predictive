
;;; predictive-setup-html.el --- predictive mode HTML setup function


;; Copyright (C) 2005 Toby Cubitt

;; Author: Toby Cubitt
;; Version: 0.2
;; Keywords: predictive, setup function, html

;; This file is part of the Emacs Predictive Completion package.
;;
;; The Emacs Predicive Completion package is free software; you can
;; redistribute it and/or modify it under the terms of the GNU
;; General Public License as published by the Free Software
;; Foundation; either version 2 of the License, or (at your option)
;; any later version.
;;
;; The Emacs Predicive Completion package is distributed in the hope
;; that it will be useful, but WITHOUT ANY WARRANTY; without even the
;; implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;; PURPOSE.  See the GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with the Emacs Predicive Completion package; if not, write
;; to the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
;; Boston, MA 02111-1307 USA


;;; Change Log:
;;
;; Version 0.2
;; * modified to use the new auto-overlays package
;;
;; Version 0.1
;; * initial release



;;; Code:

(require 'predictive)
(provide 'predictive-html)

;; variable to store identifier from call to `auto-overlay-init'
(defvar predictive-html-regexps nil)
(make-local-variable 'predictive-html-regexps)


(defun predictive-setup-html ()
  "Sets up predictive mode for use with html major modes."
  (interactive)
  
  ;; load the dictionaries
  (predictive-load-dict 'dict-english)
  (predictive-load-dict 'dict-html)
  ;; general attributes
  (predictive-load-dict 'dict-html-common)
  (predictive-load-dict 'dict-html-core)
  (predictive-load-dict 'dict-html-events)
  (predictive-load-dict 'dict-html-international)
  ;; tag-specific attributes
  (predictive-load-dict 'dict-html-a)
  (predictive-load-dict 'dict-html-area)
  (predictive-load-dict 'dict-html-base)
  (predictive-load-dict 'dict-html-quote)
  (predictive-load-dict 'dict-html-body)
  (predictive-load-dict 'dict-html-button)
  (predictive-load-dict 'dict-html-col)
  (predictive-load-dict 'dict-html-del)
  (predictive-load-dict 'dict-html-form)
  (predictive-load-dict 'dict-html-head)
  (predictive-load-dict 'dict-html-img)
  (predictive-load-dict 'dict-html-input)
  (predictive-load-dict 'dict-html-ins)
  (predictive-load-dict 'dict-html-label)
  (predictive-load-dict 'dict-html-legend)
  (predictive-load-dict 'dict-html-link)
  (predictive-load-dict 'dict-html-map)
  (predictive-load-dict 'dict-html-meta)
  (predictive-load-dict 'dict-html-object)
  (predictive-load-dict 'dict-html-optgroup)
  (predictive-load-dict 'dict-html-option)
  (predictive-load-dict 'dict-html-param)
  (predictive-load-dict 'dict-html-script)
  (predictive-load-dict 'dict-html-select)
  (predictive-load-dict 'dict-html-style)
  (predictive-load-dict 'dict-html-table)
  (predictive-load-dict 'dict-html-td)
  (predictive-load-dict 'dict-html-textarea)
  (predictive-load-dict 'dict-html-tr)

  
  ;; setup regexps defining switch-dict regions
  (setq predictive-html-regexps
	(auto-overlay-init
	 '(
	   ;; "<!--" and "-->" delimit comments
	   (stack
	    (start "<!--" (dict . predictive-main-dict) (priority . 2))
	    (end "-->" (dict . predictive-main-dict) (priority . 2)))
	   
	   ;; "<" starts an HTML tag, which ends at the next non-letter
	   ;; character
	   (word ("</?\\([[:alnum:]]*?\\)\\([^[:alnum:]]\\|$\\)" . 1)
		 (dict . dict-html))
	   
	   ;; "<a" starts an anchor, ended by ">". "<" makes sure all other
	   ;; ">"s are matched
	   (stack
	    (start "<a " (dict . (list dict-html-a  dict-html-common))
		   (priority . 1))
	    (start "<area " (dict . (list dict-html-area dict-html-common))
		   (priority . 1))
	    (start "<base " (dict . dict-html-base) (priority . 1))
	    (start "<bdo "
		   (dict . (list dict-html-international dict-html-core))
		   (priority . 1))
	    (start "<\\(blockquote\\|q\\) "
		   (dict . (list dict-html-quote dict-html-common))
		   (priority . 1))
	    (start "<body " (dict . (list dict-html-body dict-html-common))
		   (priority . 1))
	    (start "<br " (dict . dict-html-core) (priority . 1))
	    (start "<button " (dict . (list dict-html-button dict-html-common))
		   (priority . 1))
	    (start "<col " (dict . (list dict-html-col dict-html-common))
		   (priority . 1))
	    (start "<colgroup " (dict . (list dict-html-col dict-html-common))
		   (priority . 1))
	    (start "<del " (dict . (list dict-html-del dict-html-common))
		   (priority . 1))
	    (start "<form " (dict . (list dict-html-form dict-html-common))
		   (priority . 1))
	    (start "<head "
		   (dict . (list dict-html-head dict-html-international))
		   (priority . 1))
	    (start "<hr " (dict . (list dict-html-core dict-html-events))
		   (priority . 1))
	    (start "<html " (dict . dict-html-international) (priority . 1))
	    (start "<img " (dict . (list dict-html-img dict-html-common))
		   (priority . 1))
	    (start "<input " (dict . (list dict-html-input dict-html-common))
		   (priority . 1))
	    (start "<ins " (dict . (list dict-html-ins dict-html-common))
		   (priority . 1))
	    (start "<label " (dict . (list dict-html-label dict-html-common))
		   (priority . 1))
	    (start "<legend " (dict . (list dict-html-legend dict-html-common))
		   (priority . 1))
	    (start "<link " (dict . (list dict-html-link dict-html-common))
		   (priority . 1))
	    (start "<map " (dict . (list dict-html-map dict-html-common))
		   (priority . 1))
	    (start "<meta "
		   (dict . (list dict-html-meta dict-html-international))
		   (priority . 1))
	    (start "<object " (dict . (list dict-html-object dict-html-common))
		   (priority . 1))
	    (start "<optgroup "
		   (dict . (list dict-html-optgroup dict-html-common))
		   (priority . 1))
	    (start "<option " (dict . (list dict-html-option dict-html-common))
		   (priority . 1))
	    (start "<param " (dict . dict-html-param) (priority . 1))
	    (start "<script " (dict . dict-html-script) (priority . 1))
	    (start "<select " (dict . (list dict-html-select dict-html-common))
		   (priority . 1))
	    (start "<style "
		   (dict . (list dict-html-style dict-html-international))
		   (priority . 1))
	    (start "<table " (dict . (list dict-html-table dict-html-common))
		   (priority . 1))
	    (start "<t\\(r\\|body\\|head\\|foot\\) "
		   (list dict-html-tr dict-html-common) (priority . 1))
	    (start "<t[dh] " (dict . (list dict-html-td dict-html-common))
		   (priority . 1))
	    (start "<textarea "
		   (dict . (list dict-html-textarea dict-html-common))
		   (priority . 1))
	    (start "<title " (dict . dict-html-international) (priority . 1))
	    (start "<[[:alnum:]]+? " (dict . dict-html-common) (priority . 1))
	    (end ">" (priority . 1)))
	   )))
  
  ;; make "<" and ">" do the right thing
  (setq predictive-override-syntax-alist
	(list
	 (cons ?< (lambda () (interactive)
		    (predictive-reject-and-insert)
		    (predictive-complete "")))
	 (cons ?> 'predictive-accept-and-insert)))
  
  t  ; indicate succesful setup
)

;;; predictive-setup-html.el ends here
