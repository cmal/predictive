;;; auto-overlay-self.el --- self-delimited automatic overlays

;; Copyright (C) 2005 2006 Toby Cubitt

;; Author: Toby Cubitt
;; Version: 0.2.1
;; Keywords: automatic, overlays, self

;; This file is part of the Emacs Automatic Overlays package.
;;
;; The Emacs Automatic Overlays package is free software; you can
;; redistribute it and/or modify it under the terms of the GNU
;; General Public License as published by the Free Software
;; Foundation; either version 2 of the License, or (at your option)
;; any later version.
;;
;; The Emacs Automatic Overlays package is distributed in the hope
;; that it will be useful, but WITHOUT ANY WARRANTY; without even the
;; implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;; PURPOSE.  See the GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with the Emacs Automatic Overlays package; if not, write
;; to the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
;; Boston, MA 02111-1307 USA


;;; Change Log:
;;
;; Version 0.2.1
;; * bug fixes
;;
;; Version 0.2
;; * substantially re-written to postpone cascading until absolutely
;;   necessary, for improved responsiveness
;;
;; Version 0.1
;; * initial version separated off from auto-overlays.el



;;; Code:


(require 'auto-overlays)
(provide 'auto-overlay-self)

(defvar auto-o-pending-self-cascade nil)

;; register self overlay parsing, suicide, initialisation and clear functions
(assq-delete-all 'self auto-overlay-functions)
(push '(self auto-o-parse-self-match auto-o-self-suicide)
      auto-overlay-functions)

;; add initialisation and clear functions to hooks
(add-hook 'auto-overlay-load-hook 'auto-o-self-load)
(add-hook 'auto-overlay-unload-hook 'auto-o-self-unload)



(defun auto-o-self-load ()
  ;; Make sure `auto-o-perform-self-cascades' is in `before-change-functions',
  ;; so that any cascading that is required is performed before anything else
  ;; happens.
  (add-hook 'before-change-functions 'auto-o-perform-self-cascades
	    nil t)
  ;; initialise variables
  (setq auto-o-pending-self-cascade nil)
)


(defun auto-o-self-unload ()
  ;; Remove `auto-o-perform-self-cascades' from `before-change-functions'.
  (remove-hook 'before-change-functions 'auto-o-perform-self-cascades t)
)




(defun auto-o-parse-self-match (o-match)
  ;; perform any necessary updates of auto overlays due to a match for a self
  ;; regexp
  
  (let* ((overlay-list (auto-o-self-list o-match))
	 (o (car overlay-list)))
    
    (cond
     ;; if stack is empty, create a new end-unmatched overlay, adding it to
      ;; the list of unascaded overlays (avoids treating it as a special
      ;; case), and return it
     ((null overlay-list)
      (auto-o-make-self o-match nil))
     
     ;; if new delimiter is inside the first existing overlay and existing one
     ;; is end-unmatched, just match it
     ((and (not (overlay-get o 'end))
	   (>= (overlay-get o-match 'delim-start) (overlay-start o)))
      (auto-o-match-overlay o nil o-match 'no-props)
      ;; remove it from the list of uncascaded overlays
      (setq auto-o-pending-self-cascade (delq o auto-o-pending-self-cascade))
      ;; return nil since haven't created any new overlays
      nil)
     
     
     ;; otherwise...
     (t
      (let (o-new)
	;; if the new match is outside existing overlays...
	(if (< (overlay-get o-match 'delim-end) (overlay-start o))
	    ;; create overlay from new match till start of next match, and add
	    ;; it to the list of uncascaded overlays
	    (setq o-new (auto-o-make-self
			 o-match
			 (overlay-get (overlay-get o 'start) 'delim-start)))
	  
	  ;; if the new match is inside an existing overlay...
	  (setq o (pop overlay-list))
	  ;; create overlay from end of existing one till start of the one
	  ;; after (or end of buffer if there isn't one), and add it to the
	  ;; list of uncascaded overlays
	  (setq o-new (auto-o-make-self
		       (overlay-get o 'end)
		       (when overlay-list
			 (overlay-get (overlay-get (car overlay-list) 'start)
				      'delim-start))))
	  ;; match existing one with the new match
	  (auto-o-match-overlay o nil o-match 'no-props))
      
      ;; return newly created overlay
      o-new))
     ))
)




(defun auto-o-self-suicide (o-self)
  ;; Called when match no longer matches. Unmatch the match overlay O-SELF, if
  ;; necessary deleting its parent overlay or cascading.

  (let ((o-parent (overlay-get o-self 'parent)))
    (cond
     ;; if parent is end-unmatched, delete it from buffer and from list of
     ;; uncascaded overlays
     ((not (auto-o-end-matched-p o-parent))
      (auto-o-delete-overlay o-parent)
      (setq auto-o-pending-self-cascade
	    (delq o-parent auto-o-pending-self-cascade)))

     ;; if we match the end of parent...
     ((eq (overlay-get o-parent 'end) o-self)
      ;; unmatch ourselves from parent and extend parent till next overlay, or
      ;; end of buffer if there is none
      (let ((o (nth 1 (auto-o-self-list o-self))))
	(auto-o-match-overlay
	 o-parent nil (if o (overlay-get (overlay-get o 'start) 'delim-start)
			'unmatched)))
      ;; add parent to uncascaded overlay list
      (push o-parent auto-o-pending-self-cascade))

     ;; if we match the start of parent...
     (t
      (let* ((o-end (overlay-get o-parent 'end))
	     (o (nth 1 (auto-o-self-list o-end))))
	;; unmatch ourselves from parent and "flip"
	(auto-o-match-overlay
	 o-parent o-end
	 (if o (overlay-get (overlay-get o 'start) 'delim-start)
	   'unmatched)))
      ;; add parent to uncascaded overlay list
      (push o-parent auto-o-pending-self-cascade))
     ))
)




(defun auto-o-make-self (o-start &optional end)
  ;; Create a self overlay starting at match overlay O-START.
  ;; If END is a number or marker, the new overlay is end-unmatched and ends
  ;; at the buffer location specified by the number or marker.
  ;; If END is nil, the new overlay is end-unmatched and ends at the end of
  ;; the buffer.
  (let (o-new)
    
    ;; create new overlay (location ensures right things happen when matched)
    (let (pos)
      (cond
       ((overlayp end) (setq pos (overlay-get end 'delim-start)))
       ((number-or-marker-p end) (setq pos end))
       (t (setq pos (point-max))))
      (setq o-new (make-overlay pos pos nil nil 'rear-advance)))
      
    ;; give the new overlay its basic properties
    (overlay-put o-new 'auto-overlay t)
    (overlay-put o-new 'set (overlay-get o-start 'set))
    (overlay-put o-new 'type (overlay-get o-start 'type))
    
    ;; if overlay is end-unmatched, add it to the list of uncascaded overlays
    (unless (overlayp end) (push o-new auto-o-pending-self-cascade))
    
    ;; match the new overlay and return it
    (auto-o-match-overlay o-new o-start (if (overlayp end) end nil))
    o-new)
)




(defun auto-o-perform-self-cascades (beg end)
  ;; Perform any necessary self-overlay cascading before the text in the
  ;; buffer is modified. Called from `before-change-functions'.

  ;; check all overlays waiting to be cascaded, from first in buffer to last
  (dolist (o (sort auto-o-pending-self-cascade
		   (lambda (a b) (< (overlay-start a) (overlay-start b)))))
    ;; if buffer modification occurs after the end of an overlay waiting to be
    ;; cascaded, cascade all overlays between it and the modified text
    (when (and (overlay-end o) (< (overlay-end o) end))
      (auto-o-self-cascade (auto-o-self-list (overlay-get o 'start) end))))
)




(defun auto-o-self-cascade (overlay-list)
  ;; "Flip" overlays down through buffer (assumes first overlay in list is
  ;; end-unmatched).
  (when (> (length overlay-list) 1)
    (let ((o (car overlay-list))
	  (o1 (nth 1 overlay-list)))
      
      ;; match first (presumably end-matched) overlay and remove it from list
      (pop overlay-list)
      (auto-o-match-overlay o nil (overlay-get o1 'start) 'no-props)
      ;; remove it from list of uncascaded overlays
      (setq auto-o-pending-self-cascade (delq o auto-o-pending-self-cascade))
      ;; if we've hit an end-unmatched overlay, we can stop cascading
      (if (not (auto-o-end-matched-p o1))
	  (progn
	    (auto-o-delete-overlay o1 nil 'protect-match)
	    (setq auto-o-pending-self-cascade
		  (delq o1 auto-o-pending-self-cascade)))

	;; otherwise, cascade overlay list till one is left or we hit an
	;; end-unmached overlay
	(unless
	    (catch 'stop
	      (dotimes (i (1- (length overlay-list)))
		(setq o (nth i overlay-list))
		(setq o1 (nth (1+ i) overlay-list))
		(auto-o-match-overlay o (overlay-get o 'end)
				      (overlay-get o1 'start)
				      'no-props nil 'protect-match)
		;; if we hit an end-unmatched overlay, we can stop cascading
		(when (not (auto-o-end-matched-p o1))
		  (throw 'stop (progn
				 ;; delete the end-unmatched overlay
				 (auto-o-delete-overlay o1 nil 'protect-match)
				 ;; remove it from uncascaded overlays list
				 (setq auto-o-pending-self-cascade
				       (delq o1 auto-o-pending-self-cascade))
				 ;; return t to indicate cascading ended early
				 t)))))
	  
	  ;; if there's an overlay left, "flip" it so it's end-unmatched and
	  ;; extends to next overlay in buffer, and add it to the list of
	  ;; unmatched overlays
	  (let (pos)
	    (setq o (car (last overlay-list)))
	    (if (setq o1 (nth 1 (auto-o-self-list (overlay-get o 'end))))
		(setq pos (overlay-get (overlay-get o1 'start) 'delim-start))
	      (setq pos (point-max)))
	    (auto-o-match-overlay o (overlay-get o 'end) pos 'no-props))
	  (push o auto-o-pending-self-cascade)))
      ))
)




(defun auto-o-self-list (o-start &optional end)
  ;; Return list of self overlays ending at or after match overlay O-START and
  ;; starting before or at END, with same type as O-START. If END is null, all
  ;; overlays after O-START are included.

  (when (null end) (setq end (point-max)))
  
  (let (overlay-list)
    ;; create list of all overlays of same type between O-START and END
    (mapc (lambda (o) (when (and (>= (overlay-end o)
				     (overlay-get o-start 'delim-start))
				 (<= (overlay-start o) end))
			(push o overlay-list)))
	  ;; Note: already have list of overlays of same type so no need to
	  ;;       use `auto-o-overlays-in'
	  (nth (overlay-get o-start 'type)
	       (nth (overlay-get o-start 'set) auto-overlay-list)))
    ;; sort the list by start position, from first to last
    (sort overlay-list
	  (lambda (a b) (< (overlay-start a) (overlay-start b)))))
)


;;; auto-overlay-self.el ends here
