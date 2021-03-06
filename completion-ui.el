;;; completion-ui.el --- In-buffer completion user interface


;; Copyright (C) 2006-2015  Free Software Foundation, Inc

;; Version: 0.12
;; Package-Requires: ((auto-overlays "10.8"))
;; Author: Toby Cubitt <toby-predictive@dr-qubit.org>
;; Maintainer: Toby Cubitt <toby-predictive@dr-qubit.org>
;; Keywords: convenience, abbrev, completion, ui, user interface
;; URL: http://www.dr-qubit.org/emacs.php
;; Repository: http://www.dr-qubit.org/git/predictive.git

;; This file is NOT part of Emacs.
;;
;; This file is free software: you can redistribute it and/or modify it under
;; the terms of the GNU General Public License as published by the Free
;; Software Foundation, either version 3 of the License, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
;; more details.
;;
;; You should have received a copy of the GNU General Public License along
;; with this program.  If not, see <http://www.gnu.org/licenses/>.


;;; Commentary:
;;
;; Overview
;; ========
;;
;; The goal of Completion-UI is to be the swiss-army knife of in-buffer
;; completion. It doesn't do the work of finding the completions
;; itself. Instead, anything that can find completions, be it a built-in Emacs
;; function or an external Elisp package, can be hooked up to Completion-UI.
;;
;; However, Completion-UI does ship with a number of pre-defined completion
;; sources: standard Emacs dabbrevs, etags, Elisp completion and file-name
;; completion, as well as (if installed) CEDET's Semantic completion,
;; nxml-mode, and the Predictive completion package. It's also easy to add new
;; completion sources (see below).
;;
;; Completion-UI provides the following user-interfaces and features:
;;
;; * Dynamic completion
;;     provisionally display the first available completion candidate in the
;;     buffer
;;
;; * Cycling
;;     cycle through completion candidates.
;;
;; * Completion hotkeys
;;     single-key selection of a completion candidate
;;
;; * Tab-completion
;;     "traditional" expansion to the longest common substring
;;
;; * Echoing
;;     display a list of completion candidates in the echo-area
;;
;; * Tooltip
;;     display a list of completion candidates in a tool-tip located below the
;;     point, from which completions can be selected
;;
;; * Pop-up tip
;;     just like tooltips, only they display faster and don't flicker when the
;;     contents are updated
;;
;; * Pop-up frame
;;     display a list of completion candidates in a pop-up frame located below
;;     the point, which can be toggled between displaying some or all
;;     completions, and from which completions can be selected
;;
;; * Completion menu
;;     allow completion candidates to be selected from a drop-down menu
;;     located below the point
;;
;; * Completion browser
;;     browse through all possible completion candidates in a hierarchical
;;     deck-of-cards menu located below the point
;;
;; * `auto-completion-mode'
;;     automatically complete words as you type
;;
;;
;;
;; For Emacs users:
;; ================
;;
;; INSTALLING
;; ----------
;; To install this package, save this and all the other accompanying
;; "completion-ui-*.el" files to a directory in your `load-path' (you can view
;; the current `load-path' using "C-h v load-path" within Emacs), then add the
;; following line to your .emacs startup file:
;;
;;    (require 'completion-ui)
;;
;;
;; USING
;; -----
;; For each source of completions, Completion-UI provides an interactive
;; command that completes the word next to the point using that source, e.g:
;; `complete-dabbrev' to complete using dabbrevs, `complete-etags' to complete
;; using etags, `complete-elisp' to complete Elisp symbols, `complete-files'
;; to complete file names, `complete-semantic' to use Semantic completion,
;; `complete-nxml' and `complete-predictive' to use nxml-mode and
;; predictive-mode completion, respectively.
;;
;; The `complete-<name>' commands are not bound to any key by default. As with
;; any Emacs command, you can run them via "M-x complete-<name>", or you can
;; bind them to keys. E.g. to globally bind "M-/" to `complete-dabbrev', you
;; would put the following line in your .emacs file:
;;
;;   (global-set-key [?\M-/] 'complete-dabbrev)
;;
;; To bind "M-<tab>" to `complete-elisp' in `emacs-lisp-mode', you would bind
;; the command in the `emacs-lisp-mode-map' keymap:
;;
;;   (define-key emacs-lisp-mode-map [M-tab] 'complete-elisp)
;;
;; You're free to bind the `complete-<name>' commands to any keys of your
;; choosing, though "M-<tab>" or "M-/" fit best with the default Completion-UI
;; key bindings that are enabled whilst you're completing a word. These are:
;;
;; M-<tab>  M-/
;;   Cycle through completions.
;;
;; M-S-<tab>  M-?
;;   Cycle backwards through completions.
;;
;; C-<ret>
;;   Accept the current completion.
;;
;; C-<del>
;;    Reject the current completion.
;;
;; <tab>
;;    Traditional tab-completion, i.e. insert longest common substring.
;;
;; C-<tab>
;;    Accept current completion and re-complete the resulting word.
;;
;; S-<down>
;;    Display the completion tooltip (then use <up> and <down> to cycle).
;;
;; M-<down>
;;    Display the completion menu.
;;
;; C-<down>
;;    Display the completion pop-up frame.
;;
;; S-<up> C-<up> M-<up> (in pop-up frame)
;;    Dismiss the completion pop-up frame.
;;
;; M-/ (in pop-up frame)
;;    Toggle between displaying all completions.
;;
;;
;; Completion-UI also provides a minor-mode, `auto-completion-mode', which
;; automatically completes words as you type them using any one of the
;; completion sources. You can select the source to use for
;; `auto-completion-mode' by customizing `auto-completion-at-point-functions'
;; (the default is dabbrev).
;;
;; To enable and disable `auto-completion-mode', use:
;;
;;   M-x auto-completion-mode
;;
;; Note that `auto-completion-mode' is not very useful if the completion
;; source takes a long time to find completions.
;;
;; <shameless-plug>
;; The Predictive completion package (available separately from the above URL)
;; is designed from the ground up to be extremely fast, even when a very large
;; number of completion candidates are available. It also learns as you type
;; to predict which completion is the most likely. So it's particularly well
;; suited to being used as the `auto-completion-mode' source for typing plain
;; text.
;; </shameless-plug>
;;
;;
;; CUSTOMIZING
;; -----------
;; The completion user-interfaces can be heavily customized and tweaked to
;; suit your every desire, via the `completion-ui' customization group, (and
;; subgroups thereof):
;;
;;   M-x customize-group <ret> completion-ui <ret>
;;
;; All the customization options and settings are well documented via the
;; usual built-in Emacs documentation features.
;;
;;
;;
;; For Elisp coders:
;; =================
;;
;; In fact, Completion-UI is even better than a swiss-army knife, because it's
;; also extensible: it's easy to add new user-interfaces, as well as new
;; completion sources.
;;
;; The philosophy of Completion-UI is that customization of the user-interface
;; should be left up to USERS. They know what they want better than you do!
;; By providing a universal user-interface that can be used by all completion
;; packages, Completion-UI lets users customize their in-buffer completion
;; user interface once-and-for-all to suit their tastes, rather than having to
;; learn how to customize each new package separately. All you have to do (as
;; a completion package writer) is supply the completions.
;;
;;
;; Adding new sources
;; ------------------
;; See `completion-ui-register-source'.
;;
;; One call to `completion-ui-register-source' is all there is to it!
;; Registering a new source will define a new interactive command,
;; `complete-<name>' (where <name> is the supplied source name) which
;; completes whatever is at the point using the new completion source. It will
;; also add the new source to the list of choices for the
;; `auto-completion-at-point-functions' customization option.
;;
;;
;; Adding new interfaces
;; ---------------------
;; See `completion-ui-register-interface'.
;;
;; A number of Completion-UI functions are intended for use in creating new
;; user-interfaces. These all start with the prefix `completion-ui-' (as
;; opposed to `completion-', which are user commands plus a few general
;; purpose utility functions, or `completion--', which are internal functions
;; that are NOT intended for external use).


;;; Code:

(eval-when-compile (require 'cl))
(require 'auto-overlay-common)
(require 'thingatpt)


(defvar completion-ui-interface-definitions nil
  "Completion-UI user-interface definitions.")




;;; ============================================================
;;;          Dynamically updated customization types

;; list of customization variables that can be customized per source
(defvar completion-ui-per-source-defcustoms nil)


(defmacro completion-ui-defcustom-per-source (symbol standard doc &rest args)
  "Declare SYMBOL as a customization variable.
Value of SYMBOL can either be set globally, or it can be set to a
different value for each completion source."
  (declare (indent defun) (debug (name body)) (doc-string 3))
  ;; NOTE: we're assuming type is a quoted symbol or sexp
  (let ((type (cadr (plist-get args :type))))
    (plist-put
     args :type
     `(quote
       (alist :key-type
	      (choice (const :tag "Default" t)
		      (symbol :tag "Other"))
	      :value-type ,type))))
              ;;,(if (listp type) (copy-sequence type) type)))))))
  ;; construct defcustom definition
  `(progn
     (add-to-list 'completion-ui-per-source-defcustoms ',symbol)
     (defcustom ,symbol '((t . ,(eval standard))) ,doc ,@args)))


(defun completion-ui-get-value-for-source
  (source value-list &optional no-default)
  ;; Extract value that applies to SOURCE from VALUE-LIST. Falls back to
  ;; default value unless NO-DEFAULT is non-nil.
  (when (symbolp value-list) (setq value-list (symbol-value value-list)))
  (when (overlayp source)
    (setq source (or (overlay-get source :name)
		     (overlay-get source 'collection))))
  (or (cdr (assq source value-list))
      (and (not no-default) (cdr (assq t value-list)))))


(defun completion-ui-update-per-source-defcustoms (source &optional del)
  ;; add SOURCE to choices in all per-source defcustoms, or delete it if
  ;; DEL is non-nil.
  (let (choices)
    (dolist (var completion-ui-per-source-defcustoms)
      (setq choices (nth 2 (get var 'custom-type)))
      (if del (delete '(const ,name) choices)
	(unless (member `(const ,source) choices)
	  (delete nil choices)
	  (nconc choices `((const ,source))))))))




;;; ============================================================
;;;                    Customization variables

(defgroup completion-ui nil
  "Completion user interface."
  :group 'convenience)


(completion-ui-defcustom-per-source completion-max-candidates 10
  "Maximum number of completion candidates to offer."
  :group 'completion-ui
  :type '(choice integer (const :tag "all" nil)))


(completion-ui-defcustom-per-source completion-accept-or-reject-by-default
  'accept
  "Default action for the current completion:

  'accept:        automatically accept the completion
  'accept-common: automatically accept the common part of the completion
  'reject:        automatically reject the completion"
  :group 'completion-ui
  :type '(choice (const accept) (const reject) (const accept-common)))


(defcustom completion-how-to-resolve-old-completions 'accept
  "What to do with unfinished and abandoned completions
left behind in the buffer:

  'leave:         leave the old completions pending
  'accept:        automatically accept the old completions
  'reject:        automatically reject the old completions
  'ask:           ask what to do with the old completions"
  :group 'completion-ui
  :type '(choice (const leave) (const accept) (const reject) (const ask)))


(defcustom completion-overwrite t
  "When non-nil, completing in the middle of a word over-writes
the rest of the word. By default, (thing-at-point 'word)
determines what is considered a word, but this can be overridden
by individual completion sources."
  :group 'completion-ui
  :type 'boolean)


(completion-ui-defcustom-per-source completion-auto-update t
  "When non-nil, completion candidates are updated automatically
when characters are added to the current completion prefix.
\(Effectively, it is as though `auto-completion-mode' is
temporarily enabled for the duration of the completion.\)"
  :group 'completion-ui
  :type 'boolean)


(completion-ui-defcustom-per-source completion-auto-show
  'completion-show-popup-tip
  "Function to call to display a completion user-interface.
When null, nothing is auto-displayed.

The function is called after a completion command, possibly after
a delay of `completion-auto-show-delay' seconds if one is set. It
is passed one argument, a completion overlay."
  :group 'completion-ui
  :type '(choice (const :tag "none" nil) function))


(completion-ui-defcustom-per-source completion-auto-show-delay 3
  "Number of seconds to wait after completion is invoked
before the `completion-auto-show' interface is activated."
  :group 'completion-ui
  :type '(choice (const :tag "Off" nil) (float :tag "On")))


(defface completion-highlight-face
  '((((class color) (background dark))
     (:background "blue" :foreground "white"))
    (((class color) (background light))
     (:background "orange" :foreground "black")))
  "Face used to highlight completions in various user-interfaces."
  :group 'completion-ui)




;;; ===== Auto-completion customizations =====

(defgroup auto-completion-mode nil
  "auto-completion-mode"
  :group 'completion-ui)


(defcustom auto-completion-at-point-functions ;nil ;'(dabbrev-completion-at-point)
  "Special hook to find the completion table for the thing at point.

Used instead of `completion-at-point-functions' by
`auto-completion-mode'.

Definition is exactly as for
`completion-at-point-functions' (which see)."
  :group 'auto-completion-mode
  :type 'hook)
;; FIXME: use :options defcustom keyword to specify list of recommendations,
;;        auto-updated via `define-completion-at-point-functions'


;; (defcustom auto-completion-source-regexps nil
;;   "An alist associating regexps with completion sources.

;; Used to automatically select a completion source for
;; `auto-completion-mode' and `complete-word-at-point' based on
;; regexp matches.

;; Each entry must be a list of at least three elements: a regexp, a
;; completion source (symbol), and one of the symbols `before-point'
;; or `looking-at'. A `looking-at' entry can optionally contain a
;; fourth element: an integer specifying the regexp group within
;; which the completion source should apply.

;; The regexps are tried in order to see if they match in the
;; current line. If `before-point' is specified, the regexp must
;; match text strictly before point. If `looking-at' is specified,
;; the regexp must match text around the point. If a regexp group is
;; specified, the regexp will only match if point is within the text
;; matching that group.

;; If a regexp matches, its associated completion source is returned
;; and no further regexps are tried.

;; This only takes effect if the `auto-completion-regexp-source'
;; function is included in `auto-completion-source-functions' (the
;; default setting) ."
;;   :group 'auto-completion-mode
;;   :type '(repeat (list regexp
;; 		       (choice :tag "Where " :value before-point
;; 			      (const before-point)
;; 			      (const looking-at))
;; 		       (symbol :tag "Source"))))


;; (defcustom auto-completion-source-faces nil
;;   "An alist associating faces with completion sources (symbols).

;; Used to automatically select a completion source for
;; `auto-completion-mode' and `complete-word-at-point' based on the
;; current face (typically a face set by `font-lock-mode').

;; Faces are compared in order with the `face' text property of the
;; text at point. If a face matches (see below), its associated
;; completion source is returned and no further faces are compared.

;; Instead of a single face, the `face' text property often contains
;; a list of faces. In this case, if an alist key specifies a single
;; face symbol, it matches if it is one of the faces in the list. If
;; an alist key specifies a list of faces, it matches only if the
;; entire list matches. To specify a face that should only match if
;; it is the unique face at point, use a singleton list.

;; This only takes effect if the `auto-completion-face-source'
;; function is included in `auto-completion-source-functions' (as in
;; the default setting) ."
;;   :group 'auto-completion-mode
;;   :type '(alist :key-type (choice face (repeat face))
;; 		:value-type (symbol :tag "source")))


(completion-ui-defcustom-per-source auto-completion-min-chars nil
  "Minimum number of characters before completions are offered."
  :group 'auto-completion-mode
  :type '(choice (const :tag "Off" nil) (integer :tag "On")))


(completion-ui-defcustom-per-source auto-completion-delay nil
  "Number of seconds to wait before activating completion mechanisms
in auto-completion mode."
  :group 'auto-completion-mode
  :type '(choice (const :tag "Off" nil) (float :tag "On")))


(defcustom auto-completion-backward-delete-delay 0.1
  "Number of seconds to wait before activating completion mechanisms
after deleting backwards in `auto-completion-mode'."
  :group 'auto-completion-mode
  :type 'float)


(completion-ui-defcustom-per-source auto-completion-syntax-alist
  '(reject . word)
  "Associates character syntax with completion behaviour.
Used by the `auto-completion-self-insert' function to decide what
to do based on a typed character's syntax.

When customizing this variable, predefined choices can be used to
configure two separate syntax-dependent completion behaviours:
how provisional completions are accepted, and how the prefix is
chosen when characters are typed. The first choice is between
\"type normally\" or \"punctuation accepts\", and controls how
completions are accepted. The second is between \"word\" or
\"string\", and controls how the prefix is chosen.

If \"type normally\" is selected, the provisional completions
that appear as you type are only accepted if you call
`completion-accept' manually. You are free to ignore them
entirely and type normally. If \"punctuation accepts\" is
selected, the provisional completions are automatically accepted
whenever you type any punctuation or whitespace character (as
defined by the buffers' syntax table). For example, hitting SPC
will usually accept the current provisional completion and insert
a space after it. Once your fingers get used to it, this can
allow you to type faster as you can quickly accept a completion
and move onto the next word. However, you can no longer entirely
ignore the completions and type normally, since you may
accidentally accept a completion you didn't want.

If \"word\" is selected, typing a word-constituent character (as
defined by a buffer's syntax table) will cause the part of the
word before point to be completed. That is,
`auto-completion-mode' will first find the word at or next to the
point, and then complete that part of it that comes before the
point (the word defaults to whatever (thing-at-point 'word)
finds, though individual completion sources can override
this). If \"string\" is selected, typing a word-constituent
character will complete the string that has been built up by
typing consecutive characters. That is, the prefix will consist
of all the characters you've typed in the buffer since the last
time you did something other than typing a word-constituent
character.

Although they sound quite different, the two behaviours usually
only differ if you move the point to the middle or end of an
existing word and type a character. The \"word\" setting will
delete the part of the word after point, add the new character to
the part of the word before point, and complete the result. The
\"string\" setting will simply insert the new character and
complete it.


Customizing the behaviour for each syntax individually gives more
fine-grained control over the syntax-dependent completion
behaviour. In this case, the value of
`auto-completion-syntax-alist' must be an alist associating
syntax descriptors (characters) with behaviours (two-element
lists).

The first element of the behaviour list must be one of symbols
'accept, 'reject or 'add. The first two have the same meaning as
the predefined behaviours \"punctuation accepts\" and \"type
normally\", though they now apply only to one syntax
descriptor. 'add causes characters with that syntax to be added
to the current completion prefix (this is the usual setting for
word-constutuent characters).

The second element of the list must be one of the symbols 'word,
'string or 'none. 'word and 'string have the same meaning as the
predefined behaviours, though they now apply only to one syntax
descriptor, whereas 'none prevents characters with that syntax
from invoking auto-completion.


When `auto-completion-syntax-alist' is set from Lisp code, in
addition to the symbol values described above the behaviour list
entries can also be functions which return one of those
symbols. The list can also have an additional third element,
which determines whether or not the typed character is inserted
into the buffer: the character is inserted if it is non-nil, not
if it is nil. (Note that, perhaps confusingly, a non-existent
third element is equivalent to setting the third element to
t). If the third element of the list is a function, its return
value again determines the insertion behaviour. This allows a
function to take over the job of inserting characters (e.g. in
order to make sure parentheses are inserted in pairs), and is
probably the only time it makes sense to use/return a null third
element."
  :group 'auto-completion-mode
  :type '(choice
          (cons :tag "Predefined"
                (choice :tag "Acceptance behaviour"
                        (const :tag "type normally" reject)
                        (const :tag "punctuation accepts" accept))
                (choice :tag "Completion behaviour"
                        (const word)
                        (const string)))
          (alist :tag "Custom"
                 :key-type (character :tag "Syntax descriptor")
                 :value-type (list
                              (choice (const accept)
                                      (const reject)
                                      (const add))
                              (choice (const word)
                                      (const string)
                                      (const none))))))


(completion-ui-defcustom-per-source auto-completion-override-syntax-alist
  '((?0 . (reject none))
    (?1 . (reject none))
    (?2 . (reject none))
    (?3 . (reject none))
    (?4 . (reject none))
    (?5 . (reject none))
    (?6 . (reject none))
    (?7 . (reject none))
    (?8 . (reject none))
    (?9 . (reject none))
    (?' . (add word)))
  "Alist associating characters with completion behaviour.
Overrides the default behaviour defined by the character's syntax
in `auto-completion-syntax-alist'. The format is the same as for
`auto-completion-syntax-alist', except that the alist keys are
characters rather than syntax descriptors."
  :group 'auto-completion-mode
  :type '(alist :key-type (choice character (const :tag "default" t))
                :value-type (list (choice (const :tag "accept" accept)
                                          (const :tag "reject" reject)
                                          (const :tag "add" add))
                                  (choice (const :tag "string" string)
                                          (const :tag "word" word)
                                          (const :tag "none" none)))))




;;; ============================================================
;;;               Other configuration variables

(defvar completion-accept-functions nil
  "Hook run after a completion is accepted.

Completions are accepted by calling `completion-accept',
selecting one with a hotkey, or selecting one from a
menu. Functions are passed three arguments: the prefix, the
complete string that was accepted (including the prefix), and any
prefix argument supplied by the user if the accept command was
called interactively.")


(defvar completion-reject-functions nil
  "Hook run after a completion is rejected.

Completions are rejected by calling
`completion-reject'. Functions are passed three arguments: the
prefix, the complete string that was rejected \(including the
prefix\), and any prefix argument supplied by the user if the
reject command was called interactively.")



(defvar completion-overlay-map nil
  "Keymap active in a completion overlay.")

(defvar auto-completion-overlay-map nil
  "Keymap active in a completion overlay when
`auto-completion-mode' is enabled.")

(defvar completion-auto-update-overlay-map nil
  "Keymap active in a completion overlay when
`completion-auto-update' is enabled.")

(defvar completion-map nil
  "Keymap active when a Completion-UI is loaded.")

(defvar auto-completion-map nil
  "Keymap active when `auto-completion-mode' is enabled.")




;;; ============================================================
;;;                     Internal variables

(defvar completion-ui--activated nil
  "Non-nil when Completion-UI is activated in a buffer.

This variable enables the global `completion-map' keymap, which
contains hacks to work-around poor overlay keymap support in
older versions of Emacs.

It should only ever be disabled when debugging Completion-UI and
the `completion-map' bindings are causing problems.")

(make-variable-buffer-local 'completion-ui--activated)


(defvar completion--overlay-list nil
  "List of overlays used during completion")
(make-variable-buffer-local 'completion--overlay-list)


(defvar completion--auto-timer (timer-create)
  "Timer used to postpone auto-completion or auto-show
until there's a pause in typing.")


(defvar completion--backward-delete-timer nil
  "Timer used to postpone completion until finished deleting.")


(defvar completion--trap-recursion nil
  "Used to trap infinite recursion errors
in calls to certain completion functions, for which infinite
recursion can result from incorrectly configured key bindings set
by the Emacs user.")



;;; =================================================================
;;;            Set properties for delete-selection-mode

(put 'auto-completion-self-insert 'delete-selection t)
(put 'completion-accept-and-newline 'delete-selection t)
(put 'completion-backward-delete-char 'delete-selection 'supersede)
(put 'completion-backward-delete-char-untabify
     'delete-selection 'supersede)
(put 'completion-delete-char 'delete-selection 'supersede)




;;; ===============================================================
;;;                  Keybinding functions

(defun completion-activate-overlay-keys (overlay keymap)
  "Enable KEYMAP key bindings in OVERLAY."
  (map-keymap
   (lambda (key binding)
     (define-key (overlay-get overlay 'keymap) (vector key) binding))
   keymap))


(defun completion-deactivate-overlay-keys (overlay keymap)
  "Disable KEYMAP key bindings in OVERLAY."
  (map-keymap
   (lambda (key binding)
     (define-key (overlay-get overlay 'keymap) (vector key) nil))
   keymap))


(defun completion-define-word-constituent-binding
  (key char &optional syntax no-syntax-override)
  "Setup key binding for KEY so that it inserts character CHAR as
though it's syntax were SYNTAX. SYNTAX defaults to
word-constituent, ?w, hence the name of the function, but it can
be used to set up any syntax.

If NO-SYNTAX-OVERRIDE is non-nil, this binding will cause
`auto-completion-override-syntax-alist' to be ignored when this
key binding is used, so that the behaviour is determined only by
SYNTAX."

  (when (null syntax) (setq syntax ?w))
  (let ((doc (concat "Insert \"" (string char) "\" as though it were a\
 word-constituent.")))

    ;; create `auto-completion-overlay-map' binding
    (define-key auto-completion-overlay-map key
      `(lambda () ,doc
         (interactive)
         (auto-completion-self-insert ,char ,syntax
                                      ,no-syntax-override)))

    ;; if emacs version doesn't support overlay keymaps properly, create
    ;; binding in `completion-map' to simulate it via
    ;; `completion--run-if-within-overlay' hack
    (when (<= emacs-major-version 21)
      (define-key completion-map key
        `(lambda () ,doc
           (interactive)
           (completion--run-if-within-overlay
            (lambda () (interactive)
              (auto-completion-self-insert ,char ,syntax ,no-syntax-override))
            'completion-ui--activated))))))


(defun completion--remap-delete-commands (map)
  "Remap deletion commands to completion-UI versions
\(or substitute existing bindings, if remapping is not supported\)."

  ;; If command remapping is supported, remap delete commands
  (if (fboundp 'command-remapping)
      (progn
        (define-key map [remap delete-char]
          'completion-delete-char)
        (define-key map [remap delete-forward-char]
          'completion-delete-char)
        (define-key map [remap backward-delete-char]
          'completion-backward-delete-char)
        (define-key map [remap delete-backward-char]
          'completion-backward-delete-char)
        (define-key map [remap backward-delete-char-untabify]
          'completion-backward-delete-char-untabify)
        (define-key map [remap kill-word]
          'completion-kill-word)
        (define-key map [remap backward-kill-word]
          'completion-backward-kill-word)
        (define-key map [remap kill-sentence]
          'completion-kill-sentence)
        (define-key map [remap backward-kill-sentence]
          'completion-backward-kill-sentence)
        (define-key map [remap kill-sexp]
          'completion-kill-sexp)
        (define-key map [remap backward-kill-sexp]
          'completion-backward-kill-sexp)
        (define-key map [remap kill-line]
          'completion-kill-line)
        (define-key map [remap kill-paragraphs]
          'completion-kill-paragraph)
        (define-key map [remap backward-kill-paragraph]
          'completion-backward-kill-paragraph)
	(define-key map [remap kill-region]
	  'completion-kill-region))

    ;; Otherwise, can't do better than define bindings for the keys
    ;; that are currently bound to them
    (dolist (key '([delete] [deletechar] [backspace] "\d"
                   [(control delete)] [(control deletechar)]
                   [(meta delete)] [(meta deletechar)]
                   [(control backspace)] [(meta backspace)] "\M-\d"))
      (catch 'rebound
        (dolist (binding '((delete-char . completion-delete-char)
                           (kill-word . completion-kill-word)
                           (kill-sentence . completion-kill-sentence)
                           (kill-sexp . completion-kill-sexp)
			   (kill-line . completion-kill-line)
                           (kill-paragraph . completion-kill-paragraph)
			   (kill-region . completion-kill-region)
                           (backward-delete-char
                            . completion-backward-delete-char)
                           (delete-backward-char
                            . completion-backward-delete-char)
                           (backward-delete-char-untabify
                            . completion-backward-delete-char-untabify)
                           (backward-kill-word
                            . completion-backward-kill-word)
                           (backward-kill-sentence
                            . completion-backward-kill-sentence)
                           (backward-kill-sexp
                            . completion-backward-kill-sexp)
                           (backward-kill-paragraph
                            . completion-backward-kill-paragraph)))
          (when (eq (key-binding key) (car binding))
            (define-key map key (cdr binding))
            (throw 'rebound t)))))))



(defun completion--bind-printable-chars (map command)
  "Manually bind printable characters to COMMAND.
Command remapping is a far better way to do this, so it should only be
used if the current Emacs version lacks command remapping support."
  (define-key map "A" command)
  (define-key map "a" command)
  (define-key map "B" command)
  (define-key map "b" command)
  (define-key map "C" command)
  (define-key map "c" command)
  (define-key map "D" command)
  (define-key map "d" command)
  (define-key map "E" command)
  (define-key map "e" command)
  (define-key map "F" command)
  (define-key map "f" command)
  (define-key map "G" command)
  (define-key map "g" command)
  (define-key map "H" command)
  (define-key map "h" command)
  (define-key map "I" command)
  (define-key map "i" command)
  (define-key map "J" command)
  (define-key map "j" command)
  (define-key map "K" command)
  (define-key map "k" command)
  (define-key map "L" command)
  (define-key map "l" command)
  (define-key map "M" command)
  (define-key map "m" command)
  (define-key map "N" command)
  (define-key map "n" command)
  (define-key map "O" command)
  (define-key map "o" command)
  (define-key map "P" command)
  (define-key map "p" command)
  (define-key map "Q" command)
  (define-key map "q" command)
  (define-key map "R" command)
  (define-key map "r" command)
  (define-key map "S" command)
  (define-key map "s" command)
  (define-key map "T" command)
  (define-key map "t" command)
  (define-key map "U" command)
  (define-key map "u" command)
  (define-key map "V" command)
  (define-key map "v" command)
  (define-key map "W" command)
  (define-key map "w" command)
  (define-key map "X" command)
  (define-key map "x" command)
  (define-key map "Y" command)
  (define-key map "y" command)
  (define-key map "Z" command)
  (define-key map "z" command)
  (define-key map "'" command)
  (define-key map "-" command)
  (define-key map "<" command)
  (define-key map ">" command)
  (define-key map " " command)
  (define-key map "." command)
  (define-key map "," command)
  (define-key map ":" command)
  (define-key map ";" command)
  (define-key map "?" command)
  (define-key map "!" command)
  (define-key map "\"" command)
  (define-key map "0" command)
  (define-key map "1" command)
  (define-key map "2" command)
  (define-key map "3" command)
  (define-key map "4" command)
  (define-key map "5" command)
  (define-key map "6" command)
  (define-key map "7" command)
  (define-key map "8" command)
  (define-key map "9" command)
  (define-key map "~" command)
  (define-key map "`" command)
  (define-key map "@" command)
  (define-key map "#" command)
  (define-key map "$" command)
  (define-key map "%" command)
  (define-key map "^" command)
  (define-key map "&" command)
  (define-key map "*" command)
  (define-key map "_" command)
  (define-key map "+" command)
  (define-key map "=" command)
  (define-key map "(" command)
  (define-key map ")" command)
  (define-key map "{" command)
  (define-key map "}" command)
  (define-key map "[" command)
  (define-key map "]" command)
  (define-key map "|" command)
  (define-key map "\\" command)
  (define-key map "/" command))



(defun completion--simulate-overlay-bindings
  (source dest variable &optional no-parent)
  ;; Simulate SOURCE overlay keybindings in DEST using the
  ;; `completion--run-if-within-overlay' hack. DEST should be a symbol whose
  ;; value is a keymap, SOURCE should be a keymap.
  ;;
  ;; VARIABLE should be a symbol that deactivates DEST when its value is
  ;; (temporarily) set to nil. Usually, DEST will be a minor-mode keymap and
  ;; VARIABLE will be the minor-mode variable with which it is associated in
  ;; `minor-mode-map-alist'.
  ;;
  ;; NO-PARENT will prevent this recursing into the parent keymap of SOURCE,
  ;; if it has one.

  ;; if NO-PARENT is specified, remove parent keymap if there is one
  (when (and no-parent (memq 'keymap (cdr source)))
    (setq source
          (completion--sublist
           source 0 (1+ (completion--position 'keymap (cdr source))))))

  ;; map over all bindings in SOURCE
  (map-keymap
   (lambda (key binding)
     ;; don't simulate remappings, and don't simulate parent keymap's bindings
     (unless (eq key 'remap)
       ;; usually need to wrap key in an array for define-key
       (unless (stringp key) (setq key (vector key)))
       ;; bind key in DEST to simulated overlay keymap binding
       (define-key dest key
         (completion--construct-simulated-overlay-binding binding variable))))
   source))



(defun completion--construct-simulated-overlay-binding (binding variable)
  ;; Return a binding that simulates assigning BINDING to KEY in an overlay
  ;; keymap, using the `completion--run-if-within-overlay' hack.
  ;;
  ;; VARIABLE should be a symbol that deactivates BINDING when its value is
  ;; (temporarily) set to nil. Typically, BINDING will be bound in a
  ;; minor-mode keymap and VARIABLE will be the minor-mode variable with which
  ;; it is associated in `minor-mode-map-alist'.
  ;;
  ;; The return value is a command if BINDING was a command, or a keymap if
  ;; BINDING was a keymap. Any other type of BINDING (e.g. a remapping)
  ;; returns nil, since there is no easy way to simulate this.

  (cond
   ;; don't simulate command remappings or keyboard macros
   ((or (eq binding 'remap) (stringp binding))
    nil)

   ;; if BINDING is a keymap, call ourselves recursively to construct a keymap
   ;; filled with bindings that simulate an overlay keymap
   ((keymapp binding)
    (let ((map (make-sparse-keymap)))
      (map-keymap
       (lambda (key bind)
         ;; usually need to wrap key in an array for define-key
         (unless (stringp key) (setq key (vector key)))
         (define-key map key
           (completion--construct-simulated-overlay-binding bind variable)))
       binding)
      map))

   ;; if BINDING is a command, construct an anonymous command that simulates
   ;; binding that command in an overlay keymap
   ((or (commandp binding) (and (symbolp binding) (symbol-function binding)))
    (let (funcdef arglist docstring interactive args)
      ;; get function definition of command
      (cond
       ((symbolp binding) (setq funcdef (symbol-function binding)))
       ((functionp binding) (setq funcdef binding)))
      ;; extract argument list
      (cond
       ;; compiled function
       ((byte-code-function-p funcdef)
	(setq arglist (aref funcdef 0)))
       ;; uncompiled function
       ((and (listp funcdef) (eq (car funcdef) 'lambda))
	(setq arglist (nth 1 funcdef))))
      ;; extract docstring and interactive definition
      (setq docstring (documentation binding))
      (setq interactive (interactive-form binding))
      ;; construct docstring for new binding
      (setq docstring
            (concat "Do different things depending on whether point is "
                    "within a provisional completion.\n\n"
                    "If point is within a provisional completion,\n"
                    (downcase (substring docstring 0 1))
                    (substring docstring 1)
                    "\n\n"
                    "If point is not within a provisional completion,\n"
                    "run whatever would normally be bound to "
                    "this key sequence."))
      ;; construct list of argument variable names, removing &optional and
      ;; &rest
      (setq args '(list))
      (mapc (lambda (a)
              (unless (or (eq a '&optional) (eq a '&rest))
                (setq args (append args (list a)))))
            arglist)
      ;; construct and return command to simulate overlay keymap binding
      `(lambda ,(copy-sequence arglist)
         "" ;,docstring
         ,(copy-sequence interactive)
         (completion--run-if-within-overlay
          (lambda ,(copy-sequence arglist) ,(copy-sequence interactive)
            (apply ',binding ,args))
          ',variable))
      ))

   ;; anything else is an error
   (t (error (concat "Unexpected binding in "
                     "`completion--construct-simulated-overlay-binding': %s")
             binding))))




;;; =================================================================
;;;                     Setup default keymaps

;; Set the default bindings for the keymap assigned to the completion
;; overlays, if it hasn't been defined already (most likely in an init file).
(unless completion-overlay-map
  ;; Note: rebinding printable characters here is redundant if
  ;;       `auto-completion-mode' is enabled, since they are also bound in
  ;;       `auto-completion-map', but we still need to ensure that provisional
  ;;       completions are correctly dealt with even if `auto-completion-mode'
  ;;       is disabled.

  (let ((map (if (fboundp 'command-remapping)
		 (make-sparse-keymap) (make-keymap))))
    ;; if we can remap commands, remap `self-insert-command' to
    ;; `completion-self-insert'
    (if (fboundp 'command-remapping)
	(define-key map [remap self-insert-command] 'completion-self-insert)

      ;; otherwise, create a great big keymap and rebind all printable
      ;; characters to `completion-self-insert' manually
      (setq map (make-keymap))
      (completion--bind-printable-chars map 'completion-self-insert))

    ;; M-<tab> and M-/ cycle word at point
    (define-key map [M-tab] 'completion-cycle)
    (define-key map "\M-/" 'completion-cycle)
    ;; M-<shift>-<tab> and M-? (usually M-<shift>-/) cycle backwards
    (define-key map "\M-?" 'completion-cycle-backwards)
    (define-key map [(meta shift iso-lefttab)]
      'completion-cycle-backwards)
    ;; C-RET accepts, C-DEL and C-q reject
    (define-key map [(control return)] 'completion-accept)
    (define-key map "\t" 'completion-accept)
    (define-key map [(control backspace)] 'completion-reject)
    (define-key map "\C-q" 'completion-reject)
    ;; <tab> does traditional tab-completion
    ;; (define-key map "\t" 'completion-tab-complete)
    ;; C-<tab> scoots ahead
    (define-key map [(control tab)] 'completion-extend-prefix)
    ;; C-<space> abandons (C-<space> produces C-@ in terminals)
    (define-key map [?\C- ] 'completion-reject)
    (define-key map "\C-@" 'completion-reject)
    ;; ;; remap the deletion commands
    (completion--remap-delete-commands map)

    (setq completion-overlay-map map)))


;; Set the default bindings for the keymap assigned to the completion overlays
;; in `auto-completion-mode', if it hasn't been defined already (most likely
;; in an init file).
(unless auto-completion-overlay-map
  (let ((map (make-sparse-keymap)))
    ;; inherit all keybindings from completion-overlay-map, then add
    ;; auto-completion specific ones below
    (set-keymap-parent map completion-overlay-map)

    ;; ;; M-<space> abandons and inserts a space
    ;; (define-key map "\M- "
    ;;   (lambda (&optional arg)
    ;;     "Reject any current provisional completion and insert a space."
    ;;     (interactive "P")
    ;;     (completion-reject arg)
    ;;     (insert " ")))

    ;; Note: The only reason we don't use
    ;;       `completion-define-word-constituent-binding' here is that the
    ;;       lambda expressions it creates wouldn't be byte-compiled. Anywhere
    ;;       else, `completion-define-word-constituent-binding' should be
    ;;       used.

    ;; M-<space> inserts a space as a word-constituent
    (define-key map [?\M- ]
      (lambda ()
	"Insert a space as though it were a word-constituent."
	(interactive)
	(auto-completion-self-insert ?\  ?w t)))

    ;; M-. inserts "." as a word-constituent
    (define-key map "\M-."
      (lambda ()
	"Insert \".\" as though it were a word-constituent."
	(interactive)
	(auto-completion-self-insert ?. ?w t)))

    ;; M-- inserts "-" as a word-constituent
    (define-key map "\M--"
      (lambda ()
	"Insert \"-\" as though it were a word-constituent."
	(interactive)
	(auto-completion-self-insert ?- ?w t)))

    ;; M-\ inserts "\" as a word-constituent
    (define-key map "\M-\\"
      (lambda ()
	"Insert \"\\\" as though it were a word-constituent."
	(interactive)
	(auto-completion-self-insert ?\\ ?w t)))

    ;;   ;; M-/ inserts "/" as a word-constituent
    ;;   (define-key map "\M-/"
    ;;     (lambda ()
    ;;       "Insert \"/\" as though it were a word-constituent."
    ;;       (interactive)
    ;;       (auto-completion-self-insert ?/ ?w t)))

    ;; ;; M-( inserts "(" as a word-constituent
    ;; (define-key map "\M-("
    ;;   (lambda ()
    ;;     "Insert \"(\" as though it were a word-constituent."
    ;;     (interactive)
    ;;     (auto-completion-self-insert ?\( ?w t)))

    ;; ;; M-( inserts ")" as a word-constituent
    ;; (define-key map "\M-)"
    ;;   (lambda ()
    ;;     "Insert \")\" as though it were a word-constituent."
    ;;     (interactive)
    ;;     (auto-completion-self-insert ?\) ?w t)))

    ;; ;; M-{ inserts "{" as a word-constituent
    ;; (define-key map "\M-{"
    ;;   (lambda ()
    ;;     "Insert \"{\" as though it were a word-constituent."
    ;;     (interactive)
    ;;     (auto-completion-self-insert ?{ ?w t)))

    ;; ;; M-} inserts "}" as a word-constituent
    ;; (define-key map "\M-}"
    ;;   (lambda ()
    ;;     "Insert \"}\" as though it were a word-constituent."
    ;;     (interactive)
    ;;     (auto-completion-self-insert ?} ?w t)))

    ;; if we can remap commands, remap `self-insert-command'
    (if (fboundp 'command-remapping)
	(define-key map [remap self-insert-command]
	  'auto-completion-self-insert)
      ;; otherwise, rebind all printable characters to
      ;; `auto-completion-self-insert' manually
      (completion--bind-printable-chars
       map 'auto-completion-self-insert))

    (setq auto-completion-overlay-map map)))



;; Set the default bindings for the keymap assigned to the completion overlays
(unless completion-auto-update-overlay-map
  (let ((map (make-sparse-keymap)))
    ;; inherit all keybindings from completion-overlay-map, then add
    ;; completion-auto-update specific ones below
    (set-keymap-parent map completion-overlay-map)
    ;; if we can remap commands, remap `self-insert-command'
    (if (fboundp 'command-remapping)
	(define-key map
	  [remap self-insert-command]
	  'completion-auto-update-self-insert)
      ;; otherwise, rebind all printable characters to
      ;; `auto-completion-self-insert' manually
      (completion--bind-printable-chars
       map 'completion-auto-update-self-insert))

    ;; bind dummy events used after backwards-delete
    (define-key map
      (vector 'completion-dummy-update-event)
      'completion--update-after-backward-delete)
    (define-key map
      (vector 'completion-dummy-activate-event)
      'completion--activate-after-backward-delete)

    (setq completion-auto-update-overlay-map map)))



;; Set the default keymap if it hasn't been defined already (most likely in an
;; init file). This keymap is active whenever `completion-ui--activated' is
;; non-nil.
(unless completion-map
  ;; If the current Emacs version doesn't support overlay keybindings
  ;; half decently and doesn't support command remapping, we're going to
  ;; have to bind all printable characters in this keymap, so we might as
  ;; well create a full keymap
  (let ((map (if (fboundp 'command-remapping)
		 (make-sparse-keymap)
	       (make-keymap))))

    ;; ;; M-<tab> and M-/ cycle or complete word at point
    ;; (define-key map [M-tab] 'complete-or-cycle-word-at-point)
    ;; (define-key map "\M-/" 'complete-or-cycle-word-at-point)
    ;; ;; M-<shift>-<tab> and M-? (usually M-<shift>-/) cycle backwards
    ;; (define-key map [(meta shift iso-lefttab)]
    ;;   'complete-or-cycle-backwards-word-at-point)
    ;; (define-key map "\M-?"
    ;;   'complete-or-cycle-backwards-word-at-point)

    ;; RET deals with any pending completion candidate, then runs
    ;; whatever is usually bound to RET.
    ;; Note: although this uses `completion--run-if-within-overlay', it is not
    ;;       a hack to work-around poor overlay keybinding support. Rather, we
    ;;       are using it to run `completion--resolve-current' and then run
    ;;       the normal RET keybinding. We bind it here instead of in the
    ;;       overlay keymap because it's easier to disable this keymap.
    (dolist (key '("\r" "\n" [return]))
      (define-key map key 'completion-resolve-then-run-command))

  ;; remap the deletion commands
  (completion--remap-delete-commands map)

  ;; remap `fill-paragraph', or rebind M-q if we can't remap
  (if (fboundp 'command-remapping)
      (progn
	(define-key map [remap fill-paragraph] 'completion-fill-paragraph)
	(define-key map [remap yank] 'completion-yank))
    (define-key map "\M-q" 'completion-fill-paragraph)
    (define-key map "\C-y" 'completion-yank))

  ;; if we can remap commands, remap `self-insert-command' to
  ;; `completion-self-insert'
  (if (fboundp 'command-remapping)
      (define-key map [remap self-insert-command]
	'completion-self-insert)
    ;; otherwise, rebind all printable characters to
    ;; `completion-self-insert' manually
    (completion--bind-printable-chars map 'completion-self-insert))

  (setq completion-map map)))


;; make sure completion-map is associated with `completion-ui--activated' in
;; the minor-mode-keymap-alist, so that the bindings are enabled whenever
;; Completion-UI is loaded
(let ((existing (assq 'completion-ui--activated minor-mode-map-alist)))
  (if existing
      (setcdr existing completion-map)
    (push (cons 'completion-ui--activated completion-map)
          minor-mode-map-alist)))



;; Set the default auto-completion-mode keymap if it hasn't been defined
;; already (most likely in an init file). This keymap is active when
;; `auto-completion-mode' is enabled.
(unless auto-completion-map
  (let (map)
    ;; if we can remap commands, remap `self-insert-command' and
    ;; `mouse-yank-at-click'
    (if (fboundp 'command-remapping)
	(progn
	  (setq map (make-sparse-keymap))
	  (define-key map [remap self-insert-command]
	    'auto-completion-self-insert)
	  (define-key map [remap mouse-yank-at-click]
	    'auto-completion-mouse-yank-at-click))
      ;; otherwise, create a great big keymap where all printable characters
      ;; run `auto-completion-self-insert', which decides what to do based on
      ;; the character's syntax
      (setq map (make-keymap))
      (completion--bind-printable-chars map 'auto-completion-self-insert)
      (define-key map [mouse-2]
	'auto-completion-mouse-yank-at-click)
      (define-key map [left-fringe mouse-2]
	'auto-completion-mouse-yank-at-click)
      (define-key map [right-fringe mouse-2]
	'auto-completion-mouse-yank-at-click))

    ;; remap the deletion commands
    (completion--remap-delete-commands map)
    ;; remap `fill-paragraph', or rebind M-q if we can't remap
    (if (fboundp 'command-remapping)
	(define-key map [remap fill-paragraph]
	  'completion-fill-paragraph)
      (define-key map "\M-q" 'completion-fill-paragraph))
    ;; bind dummy events used after backwards-delete
    (define-key map
      (vector 'completion-dummy-update-event)
      'completion--update-after-backward-delete)
    (define-key map
      (vector 'completion-dummy-activate-event)
      'completion--activate-after-backward-delete)

    (setq auto-completion-map map)))




;;; ================================================================
;;;           Replacements for CL and other functions

(defun completion--sublist (list start &optional end)
  "Return the sub-list of LIST from START to END.
If END is omitted, it defaults to the length of the list
If START or END is negative, it counts from the end."
  (let (len)
    ;; sort out arguments
    (if end
        (when (< end 0) (setq end (+ end (setq len (length list)))))
      (setq end (or len (setq len (length list)))))
    (when (< start 0)
      (setq start (+ start (or len (length list)))))
    ;; construct sub-list
    (let (res)
      (while (< start end)
        (push (nth start list) res)
        (setq start (1+ start)))
      (nreverse res))))


(defun completion--position (item list)
  "Find the first occurrence of ITEM in LIST.
Return the index of the matching item, or nil of not found.
Comparison is done with 'equal."
  (let ((i 0))
    (catch 'found
      (while (progn
	       (when (equal item (car list)) (throw 'found i))
	       (setq i (1+ i))
	       (setq list (cdr list))))
      nil)))


(defun completion-ui--merge (seq1 seq2 predicate)
  "Destructively merge two lists to produce a new list.
SEQ1 and SEQ2 are the two argument lists, and PREDICATE is a
`less-than' predicate on the elements.
\n(fn SEQ1 SEQ2 PREDICATE)"
  (or (listp seq1) (setq seq1 (append seq1 nil)))
  (or (listp seq2) (setq seq2 (append seq2 nil)))
  (let ((res nil))
    (while (and seq1 seq2)
      (if (funcall predicate (car seq2) (car seq1))
	  (push (pop seq2) res)
	  (push (pop seq1) res)))
    (nconc (nreverse res) seq1 seq2)))


(defun completion-ui-filter-plist (plist keywords)
  "Remove KEYWORDS from PLIST."
  (setq plist (cons nil plist))
  (let ((p plist))
    (while (cdr p)
      (if (memq (cadr p) keywords)
	  (setcdr p (nthcdr 3 p))
	(setq p (cddr p)))))
    (cdr plist))  ; drop leading nil



;;; =======================================================
;;;         Compatibility functions and aliases

(unless (fboundp 'characterp)
  (defalias 'characterp 'char-valid-p))




;;; =======================================================
;;;         Auto-completion minor-mode definition

(define-minor-mode auto-completion-mode
  "Toggle auto-completion mode.
With no argument, this command toggles the mode.
A positive prefix argument turns the mode on.
A negative prefix argument turns it off.

In auto-completion-mode, Emacs will try to complete words as you
type, using whatever completion method has been set up (either by the
major mode, or by another minor mode).

`auto-completion-default-source' must be set for `auto-completion-mode'
to work."
  nil                   ; init-value
  " Complete"           ; lighter
  auto-completion-map   ; keymap

  (cond
   ;; refuse to enable if no source is defined
   ((and auto-completion-mode (null auto-completion-at-point-functions))
    (setq auto-completion-mode nil)
    (message (concat "`auto-completion-at-point-functions' is not set; "
		     "auto-completion-mode NOT enabled")))

   ;; run appropriate hook when `auto-completion-mode' is enabled/disabled
   (auto-completion-mode
    (add-hook 'before-change-functions 'completion-resolve-before-undo nil t)
    (run-hooks 'auto-completion-mode-enable-hook))
   ((not auto-completion-mode)
    (remove-hook 'before-change-functions 'completion-resolve-before-undo t)
    (run-hooks 'auto-completion-mode-disable-hook))))


(defun turn-on-auto-completion-mode ()
  "Turn on auto-completion mode. Useful for adding to hooks."
  (unless auto-completion-mode (auto-completion-mode)))


(defvar auto-completion-mode-enable-hook nil
  "Hook run when `auto-completion-mode' is enabled.")

(defvar auto-completion-mode-disable-hook nil
  "Hook run when `auto-completion-mode' is disabled.")




;;; =======================================================
;;;              Modularized user interfaces

(defmacro completion-ui--interface-name (def)
  `(car ,def))

(defmacro completion-ui--interface-variable (def)
  `(cadr ,def))

(defmacro completion-ui--interface-activate-function (def)
  `(nth 2 ,def))

(defmacro completion-ui--interface-deactivate-function (def)
  `(nth 3 ,def))

(defmacro completion-ui--interface-update-function (def)
  `(plist-get ,def :update))

(defmacro completion-ui--interface-auto-show (def)
  `(plist-get ,def :auto-show))

(defmacro completion-ui--interface-auto-show-helper (def)
  `(plist-get ,def :auto-show-helper))



(defmacro* completion-ui-register-interface
    (name &key activate deactivate
	  variable update auto-show auto-show-helper first)
  "Register a Completion-UI user-interface.

\(Note that none of the arguments should be quoted.\)

NAME is the name (a symbol) of the new user-interface, which will
appear in customization options.

The following two keyword arguments are mandatory:

:activate FUNCTION
        The function called to activate the user-interface. It
        should take one argument, a completion overlay, and do
        whatever is necessary to activate the user-interface for
        that completion. The return value is ignored. (See below
        for details of the data passed in a completion overlay.)

:deactivate FUNCTION
        The function called to deactivate the user-interface. It
        should take one argument, a completion overlay, and do
        whatever is necessary to deactivate the user-interface
        for that completion. The return value is ignored. (See
        below for details of the data passed in a completion
        overlay.)

The following optional keywords are also meaningful:

:variable SYMBOL
        The name of the customization variable used to enable the
        interface. Defaults to `completion-ui-use-<name>'. It is
        good practice to follow this naming convention if
        supplying your own variable name explicitly.

        A defcustom is created automatically with the default
        variable name if no :variable argument is supplied.
        *No* defcustom is created if a variable name is is
        supplied.

:first BOOLEAN
        A non-nil value causes the new user-interface to be added
        at the beginning of the list of interfaces. The default
        is to add it at the end. Interfaces functions are called
        in the order they appear in the list of definitions.

        Note that this has no effect if an interface called NAME
        is already defined, in which case the new definition
        replaces the old one at the same location in the list as
        before.


The remaining optional keyword arguments specify functions to
call in various circumstances that might require updating the
user-interface. They are all passed a single argument: a
completion overlay for the completion being updated.

:update FUNCTION
        A function to call to update the user-interface after a
        change to that completion. If it is not specified, the
        interface is updated by calling the :deactivate function,
        updating the overlay, then calling the :activate
        function.

:auto-show FUNCTION
        A function to call to activate a this user-interface as
        an auto-show interface. The auto-show interface is chosen
        by setting the `completion-auto-show' customization
        option. Only one auto-show interface can be displayed at
        any one time.

:auto-show-helper FUNCTION
        A function to call whenever any auto-show interface is
        activated for a completion.


All data relevant to the current completion are stored in
properties of the completion overlay, which can be retrieved
using `overlay-get'. The following overlay properties store
completion-related data:

prefix
        The prefix or string being completed.

prefix-length
        Length of the prefix or string currently being completed.

completions
        A list of completion candidates.

completion-num
        Index of currently selected completion candidate, or nil
        if completions list is empty.

completion-overlay
        Always t for a completion overlay.

collection
        The collection (see `all-completions') used to obtain the
        completion candidates.

completion-at-point-function
        The `completion-at-point-functions' hook function that
        returned the information used for this completion.

non-prefix-completion
        Nil if doing standard prefix completion, non-nil if doing
        something other than prefix completion (see
        `completion-ui-register-source').

prefix-replaced
        Non-nil if buffer string being completed (stored in
        prefix overlay property) has been replaced with new text
        in the buffer.

common-substring
        If set, an overlay marking the longest common substring
        of the provisional completion currently inserted in the
        buffer.

keymap
        Keymap active within the completion overlay. Usually derived from
        `completion-overlay-map' or `auto-completion-overlay-map'.

auto-show
       Name of auto-show interface (symbol) currently being
       displayed, or nil if no auto-show interface is active.

Any other properties returned by the completion-at-point-function
in its PROPS return value are also stored as overlay properties."

  ;; remove `quote' from arguments
  (when (and (listp name) (eq (car name) 'quote))
    (setq name (cadr name)))
  (when (and (listp variable) (eq (car variable) 'quote))
    (setq variable (cadr variable)))
  (when (and (listp activate) (eq (car activate) 'quote))
    (setq activate (cadr activate)))
  (when (and (listp deactivate) (eq (car deactivate) 'quote))
    (setq deactivate (cadr deactivate)))
  (when (and (listp update) (eq (car update) 'quote))
    (setq update (cadr update)))
  (when (and (listp auto-show) (eq (car auto-show) 'quote))
    (setq auto-show (cadr auto-show)))
  (when (and (listp auto-show-helper) (eq (car auto-show-helper) 'quote))
    (setq auto-show-helper (cadr auto-show-helper)))

  ;; sanity-check arguments
  (unless (symbolp name)
    (error "completion-ui-register-interface: invalid name %s" name))
;; (unless (functionp activate)
  ;;   (error "completion-ui-register-interface: invalid activate function %s"
  ;; 	   activate))
  ;; (unless (functionp activate)
  ;;   (error "completion-ui-register-interface: invalid deactivate function %s"
  ;; 	   deactivate))

  ;; construct interface definiton
  (let* ((var (or variable
		  (intern (concat "completion-ui-use-" (symbol-name name)))))
	 (interface-def
	  (cons name (nconc
		      (list var activate deactivate)
		      (when update (list :update update))
		      (when auto-show (list :auto-show auto-show))
		      (when auto-show-helper
			(list :auto-show-helper auto-show-helper))))))

    ;; construct code to add interface definition to list (or replace existing
    ;; definition)
    `(progn
       (let ((existing (assq ',name completion-ui-interface-definitions)))
	 (if (not existing)
	     (add-to-list 'completion-ui-interface-definitions
			  ',interface-def ,(not first))
	   (message ,(concat
		      "Completion-UI interface named "
		      (symbol-name name)
		      " already registered - replacing existing definition"))
	   (setcdr existing ',(cdr interface-def))))

       ;; generate defcustom for variable used to enable interface
       ,(unless variable
	  `(completion-ui-defcustom-per-source ,var nil
	     ,(concat "When non-nil, enable the " (symbol-name name)
		      " Completion-UI interface.")
	     :group 'completion-ui
	     :type 'boolean))

       ;; update choices in `completion-auto-show' defcustom
       ,(if auto-show
	    `(let* ((type (get 'completion-auto-show 'custom-type))
		    (source-choices (plist-get (cdr type) :value-type)))
	       (unless (member '(const :tag ,(symbol-name name) ,auto-show)
			       source-choices)
		 (nconc source-choices
			'((const :tag ,(symbol-name name) ,auto-show)))))
	  `(let* ((type (get 'completion-auto-show 'custom-type))
		  (source-choices (plist-get (cdr type) :value-type)))
	     (delete '(const :tag ,(symbol-name name) ,auto-show)
		   source-choices)))
       )))


(defalias 'define-completion-ui-interface 'completion-ui-register-interface)



(defmacro completion-ui-interface-enabled-p (interface-def source)
  ;; Returns non-nil when interface defined by INTERFACE-def is enabled,
  ;; nil otherwise
  `(completion-ui-get-value-for-source
    overlay (completion-ui--interface-variable ,interface-def)))


(defmacro completion-ui-interface-activate (interface-def overlay)
  ;; Activate interface defined by INTERFACE-DEF for completion OVERLAY
  `(let ((func (completion-ui--interface-activate-function ,interface-def)))
     (when (functionp func) (funcall func ,overlay))))


(defmacro completion-ui-interface-deactivate (interface-def overlay)
  ;; Activate interface defined by INTERFACE-DEF for completion OVERLAY
  `(let ((func (completion-ui--interface-deactivate-function ,interface-def)))
     (when (functionp func) (funcall func ,overlay))))


(defun completion-ui-activate-interfaces (overlay)
  ;; Activate all enabled user-interfaces for current completion OVERLAY
  (dolist (interface-def completion-ui-interface-definitions)
    (when (completion-ui-interface-enabled-p interface-def overlay)
      (completion-ui-interface-activate interface-def overlay))))


(defun completion-ui-deactivate-interfaces (overlay)
  ;; Deactivate all enabled user-interfaces for current completion OVERLAY.
  (dolist (interface-def completion-ui-interface-definitions)
    (when (completion-ui-interface-enabled-p interface-def overlay)
      (completion-ui-interface-deactivate interface-def overlay))))


(defun completion-ui-deactivate-interfaces-pre-update (overlay)
  ;; Deactivate all non-updatable interfaces
  (dolist (interface-def completion-ui-interface-definitions)
    (when (and (completion-ui-interface-enabled-p interface-def overlay)
	       (not (completion-ui--interface-update-function
		     interface-def)))
      (completion-ui-interface-deactivate interface-def overlay))))


(defun completion-ui-update-interfaces (overlay)
  ;; Run update interfaces, falling back to activating them
  (let (func)
    (dolist (interface-def completion-ui-interface-definitions)
      (when (completion-ui-interface-enabled-p interface-def overlay)
	(if (setq func (completion-ui--interface-update-function
			interface-def))
	    (when (functionp func) (funcall func overlay))
	  (completion-ui-interface-activate interface-def overlay))))))


(defun completion-ui-activate-auto-show-interface (overlay)
  ;; Activate auto-show interface for current completion OVERLAY.
  (funcall
   (completion-ui--interface-auto-show
    (assq (completion-ui-get-value-for-source
	   overlay completion-auto-show)
	  completion-ui-interface-definitions))
   overlay))


(defun completion-ui-call-auto-show-interface-helpers (overlay)
  ;; Call auto-show-helpers
  (let (func)
     (dolist (interface-def completion-ui-interface-definitions)
       (when (and (completion-ui-interface-enabled-p interface-def overlay)
		  (setq func (completion-ui--interface-auto-show-helper
			      interface-def)))
	 (funcall func overlay)))))


(defun completion-ui-deactivate-auto-show-interface (overlay)
  ;; Deactivate auto-show interface for current completion OVERLAY.
  (completion-ui-interface-deactivate
   (assq (overlay-get overlay :auto-show)
	 completion-ui-interface-definitions)
   overlay)
  (overlay-put overlay :auto-show nil))




;;; =======================================================
;;;      Easy completion-at-point-function definition

(defmacro completion-ui--construct-source-name (completion-function)
  `(let ((name (setq name (symbol-name ,completion-function))))
     (when (or (string-match "^completion-ui-+" name)
	       (string-match "^completion-+" name)
	       (string-match "^complete-+" name))
       (setq name (substring name (match-end 0))))
     (intern name)))

(defmacro completion-ui--frequency-hash-table-name (name sort-by-frequency)
  (cond
   ((eq sort-by-frequency 'global) "completion-ui--frequency-data")
   (t `(concat "completion-ui--" (symbol-name ,name) "-frequency-data"))))


(defvar define-completion-at-point-function-functions nil
  "Hook called after registering a new completion source.

All arguments to the
`define-completion-at-point-function-functions' call are passed
on to the hook functions.")


(defvar completion-ui--frequency-data (make-hash-table :test 'equal))


(defmacro* define-completion-at-point-function
    (function-name completion-function &rest args
     &key name completion-args other-args
     sort-by-frequency non-prefix-completion
     prefix-function word-thing allow-empty-prefix
     activate-function
     command-name no-command no-auto-completion
     accept-functions reject-functions
     tooltip-function popup-tip-function popup-frame-function menu browser
     &allow-other-keys)
  "Define FUNCTION-NAME as a `completion-at-point-functions' function.

\(Note that none of the arguments should be quoted.\)

COMPLETION-FUNCTION should be a function that takes either zero
arguments, one argument, or one mandatory and one optional
argument.

If COMPLETION-FUNCTION takes zero arguments, it should return a
list of completion candidates for whatever is at point. In this
case, you will almost certainly need to supply a :prefix-function
or :word-thing (see below).

If COMPLETION-FUNCTION takes one argument, it is passed the
prefix to complete, and should return a list of completion
candidates for that prefix.

If COMPLETION-FUNCTION takes two arguments, the second one must
be an optional argument. It is passed the prefix to complete in
the first argument. The second argument is used to specify the
maximum number of completion candidates to return. If it is nil,
all possible candidates should be returned.

The following keyword arguments are useful when using a
COMPLETION-FUNCTION that takes additional arguments that should
be ignored.

:completion-args NUMBER|LIST
         If set to 0, 1 or 2, COMPLETION-FUNCTION will be passed
         that many arguments, as described above, and as many
         null values will be added to the end of the argument
         list as necessary to fill any remaining mandatory
         arguments (but see :other-args, below).

         If set to a list of integers, it specifies *which*
         arguments of COMPLETION-FUNCTION to use. The argument
         list will be padded with null values as necessary to
         fill the missing arguments and any remaining mandatory
         arguments (but see :other-args, below).

:other-args LIST
         Can be used to pass something other than nil to the
         other arguments of COMPLETION-FUNCTION not being used. The values are
         taken sequentially from the list.


The following keyword arguments are also meaningful:

:no-command BOOLEAN
         Don't define a new interactive command for completing
         using the new function. Default is to automatically
         define a new interactive command called
         `complete-<name>' which completes the prefix at point
         using the new source.

:command-name SYMBOL
         Override the default interactive command
         name (cf. :no-command keyword, above).

:sort-by-frequency SYMBOL
        A non-nil value causes completions from this source to be
        sorted by frequency. Completion-UI will record usage
        frequency data for this source, and automatically sort
        its completions by frequency. If set to the symbol
        `global', frequency data will be pooled with data from
        other completion sources. If set to the symbol `source',
        frequency data will be accumulated separately for this
        source. (Any other non-nil value defaults to `source'.)

:non-prefix-completion BOOLEAN
        A non-nil value specifies that this completion source
        does something other than prefix completion
        \(e.g. searching for regular expression matches\), so
        that the \"prefix\" is instead interpreted as some kind
        of pattern used to find matches, and the completions
        should *replace* that prefix when selected. Completion-UI
        will adapt the completion user-interfaces accordingly.

:activate-function FUNCTION
         Function to call to determine whether completion source
         is applicable at point. Non-nil return value indicates
         this source is applicable. Default is for the source to
         always be applicable if :prefix-function finds a prefix
         at point to complete \(see :prefix-function, below\).

:prefix-function FUNCTION
         Function to call to return the prefix to complete at
         point. It should either return nil, to indicate there's
         nothing to complete at point, or a cons cell containing
         the bounds of the buffer text to complete, which should
         include point. Defaults to using
         `bounds-of-thing-at-point' to find the
         prefix (see :word-thing keyword, below).

:word-thing SYMBOL
         The `thing-at-point' \"thing\" to use when determining
         the prefix to complete. Ignored if :prefix-function is
         supplied \(see :prefix-function keyword,
         above\). Defaults to `word'.

:allow-empty-prefix
         If t, return empty string instead of nil if
         `thing-at-point' fails to find a :word-thing at point
         \(see above\). Ignored if :prefix-function is supplied.


The following keyword arguments can be used to integrate the new
completion-at-point function into the completion user-interface.

:name SYMBOL
         Give a name (symbol) to this completion function, which
         will appear in customization options. The default is to
         construct the name from COMPLETION-FUNCTION, removing
         \"completion-\", \"complete-\" or \"completion-ui-\"
         from the front if present.

:no-auto-completion BOOLEAN
         Don't make this source available as a possible
         `auto-completion-default-source' customization
         choice. Default is to add the new source to the
         available choices.

:accept-functions FUNCTION|LIST
        A function or list of functions to call when a completion
        obtained using this source is accepted. The functions are
        passed three arguments: the prefix, the completion
        candidate that was accepted or rejected, and any prefix
        argument supplied by the user if the accept command was
        called interactively.

:reject-functions FUNCTION|LIST
        A function or list of functions to call when a completion
        obtained using this source is rejected. The functions are
        passed three arguments: the prefix, the completion
        candidate that was rejected, and any prefix argument
        supplied by the user if the accept command was called
        interactively.

:syntax-alist ALIST
        If specified, entries in the alist override those in
        `auto-completion-syntax-alist' for the source. The format
        of the alist entries is that same as that in
        `auto-completion-syntax-alist'.

:override-syntax-alist ALIST
        If specified, entries in the alist override those in
        `auto-completion-override-syntax-alist' for the source. The format of
        the alist entries is that same as that in
        `auto-completion-override-syntax-alist'.


The remaining optional keyword arguments override the default
methods for constructing the completion tooltip, popup-tip,
pop-up frame, menu, and browser menu.

:tooltip-function FUNCTION
        Function to call to construct the completion tooltip for
        this source. It is passed one argument, a completion
        overlay, and should return the text to display in the
        tooltip as a string.

:popup-tip-function  FUNCTION
        As for :tooltip-function, but used to construct the
        popup-tip.

:popup-frame-function FUNCTION
        Function to call to construct the completion tooltip for
        this source. It is passed one argument, a completion
        overlay, and should return a list of strings, each a line
        of text for the pop-up frame.

:menu KEYMAP|FUNCTION
        Either a fixed menu keymap, or a function to call to
        construct the completion menu for this source. The
        function is passed one argument, a completion overlay,
        and should return a menu keymap.

:browser KEYMAP|FUNCTION
        As for :menu, but used to construct the completion
        browser.


The special hook `define-completion-at-point-function-functions'
is called after registering the completion source. The hook
functions are called with exactly the same arguments as passed to
`define-completion-at-point-function'.

Arbitrary additional keyword arguments can be passed in the
argument list. These have no effect in
`define-completion-at-point-function', but they are passed on to
the functions called from the
`define-completion-at-point-function-functions' hook."

  ;; make ACCEPT-FUNCTIONS and REJECT-FUNCTIONS into lists
  (when accept-functions
    (unless (and (listp accept-functions)
  		 (not (eq (car accept-functions) 'lambda))
  		 (not (eq (car accept-functions) 'function)))
      (setq accept-functions (list accept-functions))))
  (when reject-functions
    (unless (and (listp reject-functions)
  		 (not (eq (car reject-functions) 'lambda))
  		 (not (eq (car reject-functions) 'function)))
      (setq reject-functions (list reject-functions))))


  ;; construct source name from completion-function if not defined explicitly
  (unless name
    (setq name (completion-ui--construct-source-name completion-function)))
  ;; construct command name from source name if not defined explicitly
  (unless command-name
    (setq command-name (intern (concat "complete-" (symbol-name name)))))


  ;; sort out COMPLETION-ARGS
  (cond
   ;; no COMPLETION-ARGS: infer arguments from function definition
   ((null completion-args)
    (let* ((funcdef (cond
		     ((symbolp completion-function)
		      (symbol-function completion-function))
		     ((functionp completion-function)
		      completion-function)))
 	   (arglist (cond
 		     ;; compiled function
 		     ((byte-code-function-p funcdef)
 		      (aref funcdef 0))
 		     ;; uncompiled function
 		     ((and (listp funcdef) (eq (car funcdef) 'lambda))
 		      (nth 1 funcdef))
 		     (t (error "completion-ui-register-source:\
 missing :completion-args or invalid completion function, %s"
 			       completion-function)))))
      (cond
       ((= (length arglist) 0) (setq completion-args '()))
       ((= (length arglist) 1) (setq completion-args '(0)))
       ((and (= (length arglist) 3) (eq (nth 1 arglist) '&optional))
 	(setq completion-args '(0 1)))
       (t (error "completion-ui-register-source: missing :completion-args\
 or invalid completion function, %s" completion-function)))))
   ;; numerical COMPLETION-ARGS: convert to list
   ((numberp completion-args)
    (cond
     ((= completion-args 0) (setq completion-args '()))
     ((= completion-args 1) (setq completion-args '(0)))
     ((= completion-args 2) (setq completion-args '(0 1)))))
   ;; COMPLETION-ARGS list: sanity check
   ((and (listp completion-args)
 	 (>= (length completion-args) 0)
 	 (<= (length completion-args) 2)))
   ;; anything else: we're too confused to carry on!
   (t (error "completion-ui-register-source: invalid :completion-args, %s"
 	     completion-args)))


  ;; construct argument list for COMPLETION-FUNCTION
  (let ((cmplfun completion-function)
	(pfxfun prefix-function)
	(argnames '(prefix maxnum))
  	(cmplstack completion-args)
  	(otherstack other-args)
  	(arg 0) arglist)
    (while cmplstack
      (dotimes (i (- (car cmplstack) arg 1))
  	(push (when otherstack (pop otherstack)) arglist))
      (push (pop argnames) arglist)
      (setq arg (pop cmplstack)))
    (while otherstack (push (pop otherstack) arglist))
    (setq arglist (nreverse arglist))


    ;; contruct completion function
    ;; FIXME: Deal with maxnum argument more elegantly?
    ;; FIXME: Honour PREDICATE argument?
    (if (null sort-by-frequency)
	;; if we're NOT recording and sorting by frequency data, construct
	;; wrapper around COMPLETION-FUNCTION if necessary
	(cond
	 ;; no maxnum argument
	 ((or (= (length completion-args) 0)
	      (= (length completion-args) 1))
	  (setq cmplfun
		`(lambda (prefix &optional predicate ignored)
		   (let ((completions (,completion-function ,@arglist))
			 (maxnum (completion-ui-get-value-for-source
				  ',name completion-max-candidates)))
		     (if maxnum
			 (butlast completions (- (length completions) maxnum))
		       completions)))))
	 (t  ;; maxnum argument present (with or without additional args)
	  (setq cmplfun
		`(lambda (prefix &optional predicate ignored)
		   (let ((maxnum (completion-ui-get-value-for-source
				 ',name completion-max-candidates)))
		     (,completion-function ,@arglist))))))

      ;; if we ARE recording and sorting by frequency data...
      (let ((hash-table-name
	     (intern (completion-ui--frequency-hash-table-name
		      name sort-by-frequency))))
	;; construct wrapper around COMPLETION-FUNCTION
	(cond
	 ;; no maxnum argument
	 ((or (= (length completion-args) 0)
	      (= (length completion-args) 1))
	  (setq cmplfun
		`(lambda (prefix &optional predicate ignored)
		   (let ((completions
			  (sort (,completion-function ,@arglist)
				(lambda (a b)
				  (> (gethash a ,hash-table-name 0)
				     (gethash b ,hash-table-name 0)))))
			 (maxnum (completion-ui-get-value-for-source
				  ',name completion-max-candidates)))
		     (if maxnum
			 (butlast completions (- (length completions) maxnum))
		       completions)))))
	 (t  ;; maxnum argument present (with or without additional args)
	  (setq cmplfun
		`(lambda (prefix &optional predicate ignored)
		   (let ((maxnum (completion-ui-get-value-for-source
				  ',name completion-max-candidates)))
		     (sort (,completion-function ,@arglist)
			   (lambda (a b)
			     (> (gethash a ,hash-table-name 0)
				(gethash b ,hash-table-name 0)))))))))
	;; add an accept function that increments the frequency
	(push `(lambda (prefix completion arg)
		 (puthash completion
			  (1+ (gethash completion ,hash-table-name 0))
			  ,hash-table-name))
	      accept-functions)
	))


    ;; construct prefix function from WORD-THING unless already specified
    ;; in PREFIX-FUNCTION
    (unless prefix-function
      (setq pfxfun
	    `(lambda ()
	       (completion-prefix ,(or word-thing 'word)
				  ,allow-empty-prefix))))


    `(progn
       ;; define the completion source
       ,(completion-ui--define-source function-name name
				      cmplfun activate-function pfxfun
				      (copy-sequence args)
				      (unless no-command command-name)
				      no-auto-completion)
       ;; if gathering separate frequency data for this source, create hash table
       ;; to store frequency data
       ,(when (and sort-by-frequency (not (eq sort-by-frequency 'global)))
	  (let ((hash-table-name
		 (intern (completion-ui--frequency-hash-table-name
			  name sort-by-frequency))))
	    `(defvar ,hash-table-name (make-hash-table :test 'equal))))

       ;; run hooks
       ,(progn
	  (setq args (copy-sequence args))
	  (let ((elt args))
	    (while (cadr elt)
	      (setf (cadr elt) `(quote ,(cadr elt))
		    elt (cddr elt))))
	  `(run-hook-with-args 'completion-ui-register-source-functions
			       ',completion-function ,@args)))))


(defun completion-ui--define-source
  (function-name name cmplfun activefun pfxfun keyargs
		 &optional command-name no-auto-completion)
  ;; construct completion source definiton
  ;; drop keywords that are only meaningful for constructing the definition
  (setq keyargs
	(completion-ui-filter-plist
	 keyargs '(:completion-args :other-args
		   :command-name :no-command :no-auto-completion
		   :sort-by-frequency :prefix-function :word-thing)))
    `(progn
       ;; construct code to define `completion-at-point-functions' function
       ,(if activefun
	    `(defun ,function-name ()
	       ,(concat "Function used in `completion-at-point-functions' to "
			"complete words using " (symbol-name name) ".")
	       (when (,activefun)
		 (let ((res (,pfxfun)))
		   (when res (nconc (list (car res) (cdr res) ',cmplfun)
				    ',keyargs)))))
	  `(defun ,function-name ()
	     ,(concat "Function used in `completion-at-point-functions' to "
		      "complete words using " (symbol-name name) ".")
	     (let ((res (,pfxfun)))
	       (when res (nconc (list (car res) (cdr res) ',cmplfun)
				',keyargs)))))

       ;; construct code to define completion command
       ,(when command-name
	  `(defun ,command-name
	     (&optional n)
	     ,(concat "Complete or cycle word at point using "
		      (symbol-name name) " source.")
	     (interactive "p")
	     (complete-or-cycle-word-at-point n)))

       ;; ;; update list of choices in `auto-completion-default-source'
       ;; ;; defcustom
       ;; ,(if no-auto-completion
       ;; 	    `(delete '(const ,name)
       ;; 		     (get 'auto-completion-default-source 'custom-type))
       ;; 	  `(let ((choices (get 'auto-completion-default-source 'custom-type)))
       ;; 	     (unless (member '(const ,name) choices)
       ;; 	       (nconc (cdr choices) '((const ,name))))))

       ;; update list of choices in other per-source defcustoms
       (completion-ui-update-per-source-defcustoms ',name)
       ))




;;; ==========================================================================
;;;       Utility functions for retrieving completion source properties

(defsubst completion-ui-source-get-prop (source prop)
  ;; return property PROP stored in property list or overlay PROPS
  (or (and (overlayp source) (overlay-get source prop))
      (plist-get source prop)))


(defun completion-ui-source-get-val
  (source prop default &optional auto-overlay-symbol type-predicate)
  ;; Return value of property PROP for SOURCE, defaulting to DEFAULT.
  ;; If AUTO-OVERLAY-SYMBOL is non-nil, corresponding auto-overlay property at
  ;; point can override value. If TYPE-PREDICATE is supplied, and the value
  ;; found is a symbol, the value is repeatedly evaluated until it evals to
  ;; something that is not a symbol or to something that matches
  ;; TYPE-PREDICATE.
  (let ((val
	 (or
	  ;; try overlay-local binding
	  (and auto-overlay-symbol
	       (fboundp 'auto-overlay-local-binding)
	       (auto-overlay-local-binding
		auto-overlay-symbol nil 'only-overlay))
	  ;; source definition
	  (completion-ui-source-get-prop source prop))))
    ;; evaluate result until we get a function
    (while (and val
		(not (funcall type-predicate val))
		(symbolp val)
		(boundp val))
      (setq val (symbol-value val)))
    ;; default fall-back
    (or val default)))


(defsubst completion-ui-source-accept-functions (source)
  ;; return :accept-functions property stored in SOURCE property list or
  ;; overlay
  (completion-ui-source-get-prop source :accept-functions))


(defsubst completion-ui-source-reject-functions (source)
  ;; return :reject-functions property stored in SOURCE property list or
  ;; overlay
  (completion-ui-source-get-prop source :reject-functions))


(defun completion-ui-run-accept-functions
  (source prefix completion &optional arg)
  ;; Run accept functions for SOURCE, passing the accepted COMPLETION of
  ;; PREFIX and any user-supplied ARG.
  (let ((funcs (completion-ui-source-accept-functions source)))
    (run-hook-with-args 'funcs prefix completion arg))
  (run-hook-with-args 'completion-accept-functions
		      prefix completion arg))


(defun completion-ui-run-reject-functions
  (overlay prefix completion &optional arg)
  ;; run reject functions for completion OVERLAY, passing the rejected
  ;; COMPLETION of PREFIX and any user-supplied ARG
  (let ((funcs (completion-ui-source-reject-functions overlay)))
    (run-hook-with-args 'funcs prefix completion arg))
  (run-hook-with-args 'completion-reject-functions
		      prefix completion arg))


(defun completion-ui-source-syntax-alist (source)
  ;; return :syntax-alist property stored in SOURCE property list or overlay
  (let ((syntax-alist (completion-ui-source-get-prop
		       source :syntax-alist)))
    ;; evaluate result until we get a value
    (while (and syntax-alist
		(symbolp syntax-alist)
		(boundp syntax-alist))
      (setq syntax-alist (symbol-value syntax-alist)))
    syntax-alist))


(defun completion-ui-source-override-syntax-alist (source)
  ;; return :override-syntax-alist property stored SOURCE in property list or
  ;; overlay
  (let ((override-alist (completion-ui-source-get-prop
			 source :override-syntax-alist)))
    ;; evaluate result until we get a value
    (while (and override-alist
		(symbolp override-alist)
		(boundp override-alist))
      (setq override-alist (symbol-value override-alist)))
    override-alist))




;;; =======================================================
;;;             The core completion functions

(defun complete-in-buffer (start end collection &rest props)
  "Complete text in buffer between START and END using COLLECTION.

PROPS is a property list specifying addition information.
Currently, the following properties are supported:

:predicate FUNCTION
         A predicate that completion candidates need to satisfy.

TODO: implement :annotation-function support
TODO: list keywords meaningful to Completion-UI"
  (complete-in-buffer-1 collection start end props))



(defun complete-in-buffer-1
  (collection &optional start end props auto update pos)
  "Complete text in buffer between START and END using COLLECTION.

PROPS is a property list specifying addition information (see
`complete-in-buffer' for a list of supported properties).

If AUTO is 'auto-complete, assume we're auto-completing and
respect settings of `auto-completion-min-chars' and (unless AUTO
is 'timer) `auto-completion-delay'. If AUTO is 'auto-update,
assume we're auto-updating.

If POS is non-nil, assume we're running ourselves from a timer
and only complete if point is at POS.

If UPDATE is non-nil, update the user-interfaces rather than than
activating them from scratch."

  ;; cancel any timer so that we don't have two running at once
  (cancel-timer completion--auto-timer)
  ;; only complete if point is at POS (only used when called from timer)
  (unless (and pos (/= (point) pos))
    (let (overlay prefix completions min-chars delay capf)

      ;; if not updating a completion overlay, get prefix
      (if (not (overlayp collection))
	  (setq prefix (or (buffer-substring-no-properties start end) "")
		capf (plist-get props 'completion-at-point-function))
	;; otherwise, use overlay properties
	(setq overlay collection
	      prefix (overlay-get collection 'prefix)
	      collection (overlay-get collection 'collection))
	;; resolve any provisional completions
	(completion-ui-resolve-old overlay))

      ;; create/update completion overlay (need to create overlay irrespective
      ;; of `auto-completion-min-chars' and `auto-completion-delay', to mark
      ;; end of prefix in case point is immediately before a word)
      (setq overlay (move-overlay
		     (completion-ui-setup-overlay prefix
		      :prefix-length t
		      :collection collection
		      :completion-at-point-function capf
		      :auto-completion auto
		      :overlay overlay
		      :props props)
		     (point) (point))
	    min-chars (completion-ui-get-value-for-source
		       overlay auto-completion-min-chars)
	    delay (completion-ui-get-value-for-source
		   overlay auto-completion-delay))

      ;; only auto-complete if prefix has requisite number of characters
      (if (and auto min-chars (< (length prefix) min-chars))
	  (if update (completion-ui-deactivate-interfaces overlay))
	;; if auto-completing and `auto-completion-delay' is set, delay
	;; completing by setting a timer to call ourselves later
	(if (and auto delay (null pos))
	    (setq completion--auto-timer
		  (run-with-idle-timer
		   delay nil 'complete-in-buffer-1
		   overlay start end props auto update (point)))
	  ;; otherwise, get completions and update overlay
	  (setq completions
		(all-completions prefix collection
				 (plist-get props :predicate)))
	  (completion-ui-setup-overlay prefix
	   :prefix-length 'unchanged
	   :completions completions
	   :auto-completion auto
	   :overlay overlay)

	  ;; if running from an `auto-completion-delay' or
	  ;; `completion-backward-delete' timer, generate dummy keyboard event
	  ;; to force keymap update, and bind that event to a function that
	  ;; activates the interfaces
	  ;; (Note: this is a hack to work around limitation that Emacs
	  ;;        already computed the set of active keymaps before overlay
	  ;;        existed, so overlay keymap gets ignored)
	  (if pos
	      (progn
		;; dummy binding used to force keymap refresh
		(push (if update
			  'completion-dummy-update-event
			'completion-dummy-activate-event)
		      unread-command-events))

	    ;; otherwise, activate completion user-interfaces directly
	    (if update
		(completion-ui-update-interfaces overlay)
	      (completion-ui-activate-interfaces overlay))
	    (when (completion-ui-get-value-for-source
		   overlay completion-auto-show)
	      (completion-ui-auto-show overlay))))
	;; set `completion-ui--activated' (buffer-locally) to enable
	;; `completion-map' work-around hacks
	(setq completion-ui--activated t))
      )))


(defun completion--update-after-backward-delete ()
  (interactive)
  (let ((overlay (completion-ui-overlay-at-point)))
    (completion-ui-update-interfaces overlay)
    (when (completion-ui-get-value-for-source
	   overlay completion-auto-show)
      (completion-ui-auto-show overlay))))

(defun completion--activate-after-backward-delete ()
  (interactive)
  (let ((overlay (completion-ui-overlay-at-point)))
    (completion-ui-activate-interfaces overlay)
    (when (completion-ui-get-value-for-source
	   overlay completion-auto-show)
      (completion-ui-auto-show overlay))))



(defun completion-ui-auto-show (&optional overlay point)
  "Display list of completions for OVERLAY in auto-show interface.
The point had better be within OVERLAY or your hair will fall
out.

Which one is shown depends on the setting of
`completion-auto-show'. If `completion-auto-show-delay' is
non-nil, the auto-show interface will only be displayed after a
delay.

If OVERLAY is not supplied, tries to find one at point.

If POINT is supplied, the auto-show interface will be displayed
immediately, but only if point is at POINT (used internally when
called from timer)."
  (interactive)

  ;; if no overlay supplied, try to find one at point
  (unless overlay (setq overlay (completion-ui-overlay-at-point)))
  ;; cancel any running timer so we don't end up being called twice
  (cancel-timer completion--auto-timer)

  ;; make sure things are still in a sensible state (might not be if
  ;; displaying after a delay)
  (let (auto-show auto-show-delay)
    (when (and overlay
	       (setq auto-show
		     (completion-ui-get-value-for-source
		      overlay completion-auto-show))
	       (overlay-buffer overlay)
	       (or (null point) (= (point) point)))
      (setq auto-show-delay (completion-ui-get-value-for-source
			     overlay completion-auto-show-delay))
      (cond
       ;; ;; if auto-show interface is already active for overlay, update it
       ;; ((overlay-get overlay :auto-show)
       ;;  (completion-ui-call-auto-show-interface-helpers overlay)
       ;;  (funcall (overlay-get overlay :auto-show) overlay))

       ;; if delaying, setup timer to call ourselves later
       ((and auto-show-delay (null point))
	(setq completion--auto-timer
	      (run-with-timer auto-show-delay nil
			      'completion-ui-auto-show
			      overlay (point))))

       ;; otherwise, display whatever we're displaying
       (t
	(overlay-put overlay :auto-show auto-show)
	(completion-ui-call-auto-show-interface-helpers overlay)
	(funcall auto-show overlay))))))



(defmacro completion-ui-cancel-auto-show ()
  "Cancel any pending auto-show."
  `(when (timerp completion--auto-timer)
     (cancel-timer completion--auto-timer)))




;;; ============================================================
;;;                  Interactive commands

(defun completion-ui-at-point ()
  "Perform completion on the text around point.

The completion method is determined by
`completion-at-point-functions'."
  (interactive)

  ;; get completion overlay at point, if any
  (let ((overlay (completion-ui-overlay-at-point))
	update)

    ;; if point is at start of an existing overlay, delete old completion
    ;; before completing, preserving overlay so its prefix can be reused
    (when overlay
      (if (= (point) (overlay-start overlay))
	  (progn
	    (delete-region (overlay-start overlay) (overlay-end overlay))
	    (setq update t))
	;; if there's a completion at point but point is not at start, delete
	;; overlay (effectively accepting old completion) and behave as if no
	;; completion was in progress
	(completion-ui-delete-overlay overlay)
	(setq overlay nil)))
    (completion-ui-resolve-old overlay)

    ;; get completion source at point
    (pcase (if overlay
	       (completion--capf-wrapper
		(overlay-get overlay 'completion-at-point-function) 'all)
	     (run-hook-wrapped 'completion-at-point-functions
			       #'completion--capf-wrapper 'all))

      ;; standard `completion-at-point-function' return value
      (`(,hookfun . (,start ,end ,collection . ,props))

       ;; --- completion-overwrite ---
       ;; if point is in middle of a word, delete rest of word before
       ;; completing
       (when (and completion-overwrite
		  (> end (point)))
	 (delete-region (point) end)
	 (setq end (point))
	 ;; if there's now a completion overlay at point, delete it
	 (when (setq overlay (completion-ui-overlay-at-point))
	   (completion-ui-delete-overlay overlay)
	   (setq overlay nil)))

       ;; setup completion overlay and do completion
       (setq overlay
	     (move-overlay
	      (completion-ui-setup-overlay
	       (buffer-substring-no-properties start end)
	       :collection collection
	       :completion-at-point-function hookfun
	       :overlay overlay
	       :props props)
	      end end))
       (complete-in-buffer-1 overlay nil nil nil nil update))

      ;; FIXME: handle non-standard return val case?
      (`(,_ . ,(and (pred functionp) f)))

      ;; FIXME: should this case throw error?
      (_))))


(defun complete-or-cycle-word-at-point (&optional n)
  "Cycle through available completions if there are any,
otherwise complete the word at point."
  (interactive "p")
  (if (completion-ui-overlay-at-point)
      (completion-cycle n)
    (completion-ui-at-point)))


(defun complete-or-cycle-backwards-word-at-point (&optional n)
  "Cycle backwards through available completions if there are any,
otherwise complete the word at point."
  (interactive "p")
  (if (completion-ui-overlay-at-point)
      (completion-cycle (- n))
    (completion-ui-at-point)))


(defun completion-accept (&optional arg overlay)
  "Accept current provisional completion.

The value of ARG is passed as the third argument to any functions
called from the `completion-accept-functions' hook or from the
completion source's own accept-functions. Interactively, ARG is
the prefix argument.

If optional argument OVERLAY is supplied, it is used instead of
looking for an overlay at the point. The point had better be
within OVERLAY or else your hair will fall out.

If a completion was accepted, returns a cons cell containing the
prefix and the entire accepted completion \(the concatenation of
the prefix and the completion string\). Otherwise returns nil."
  (interactive "P")

  ;; if we haven't been passed one, get completion overlay at point
  (unless overlay (setq overlay (completion-ui-overlay-at-point)))

  ;; ;; resolve any other old provisional completions
  ;; (completion-ui-resolve-old overlay)

  ;; if we ain't found an overlay, can't accept nuffink!
  (when overlay
    (let ((prefix (overlay-get overlay 'prefix))
	  cmpl)
      ;; if there's no selected completion, then we're effectively accepting
      ;; the prefix as a completion
      (if (null (overlay-get overlay 'completion-num))
	  (progn
	    ;; delete the overlay, effectively accepting the prefix
	    (completion-ui-delete-overlay overlay)
	    (completion-ui-deactivate-interfaces overlay)
	    ;; run accept hooks
	    (completion-ui-run-accept-functions
	     overlay prefix prefix arg)
	    ;; return prefix and accepted completion (the prefix itself)
	    (cons prefix prefix))

	;; otherwise, deactivate the interfaces and accept the completion
	;; deactivate the interfaces
	(setq cmpl (nth (overlay-get overlay 'completion-num)
			(overlay-get overlay 'completions)))
	(unless (stringp cmpl) (setq cmpl (car cmpl)))
	(completion-ui-deactivate-interfaces overlay)
	;; delete the original prefix and insert the completion
	(delete-region (- (point) (length prefix)) (point))
	(let ((overwrite-mode nil)) (insert cmpl))
	;; run accept hooks
	(completion-ui-run-accept-functions overlay prefix cmpl arg)
	;; delete overlay
	(completion-ui-delete-overlay overlay)
	;; return prefix and accepted completion
	(cons prefix cmpl)))))



(defun completion-reject (&optional arg overlay)
  "Reject current provisional completion.

The value of ARG is passed as the third argument to any functions
called from the `completion-reject-functions' hook. Interactively,
ARG is the prefix argument.

If optional argument OVERLAY is supplied, it is used instead of
looking for an overlay at the point. The point had better be
within OVERLAY or else your hair will fall out.

If a completion was rejected, returns a cons cell containing the
prefix and the entire rejected completion \(the concatenation of
the prefix and the completion string\). Otherwise returns nil."
  (interactive "P")

  ;; if we haven't been passed one, get completion overlay at point
  (unless overlay (setq overlay (completion-ui-overlay-at-point)))

  ;; ;; resolve any other old provisional completions
  ;; (completion-ui-resolve-old overlay)

  ;; if we ain't found no overlay, we can't reject nuffink!
  (unless (or (null overlay)
	      (and (null (overlay-get overlay 'completion-num))
		   (progn (completion-ui-delete-overlay overlay) t)))
    ;; otherwise, deactivate the interfaces and reject the completion
    (let ((prefix (overlay-get overlay 'prefix))
	  (cmpl (nth (overlay-get overlay 'completion-num)
		     (overlay-get overlay 'completions))))
      ;; deactivate the interfaces
      (completion-ui-deactivate-interfaces overlay)
      ;; run reject hooks
      (completion-ui-run-reject-functions overlay prefix cmpl arg)
      ;; delete overlay
      (completion-ui-delete-overlay overlay)
      ;; return prefix and rejected completion
      (cons prefix cmpl))))



(defun completion-resolve-then-run-command ()
 "Resolve current completion, then run command
that would normally be bound to this key."
 (interactive)
 (completion--run-if-within-overlay
  (lambda () (interactive) (completion--resolve-current nil nil ? ))
  'completion-ui--activated 'before))



(defun completion-select (n &optional overlay)
  "Select N'th completion candidate for current completion.

Interactively, N is the prefix argument.

If OVERLAY is supplied, use that instead of finding one at
point. The point had better be within OVERLAY or a meteorite will
crash through your ceiling."
  (interactive "P")

  ;; resolve any other old provisional completions
  (completion-ui-resolve-old overlay)
  ;; if we haven't been passed one, get completion overlay at point
  (unless overlay (setq overlay (completion-ui-overlay-at-point)))

  ;; if we ain't found an overlay, can't select nuffink!
  ;; if we ain't found an overlay, can't accept nuffink!
  (if (null overlay)
      (message "No completion to select")

    (let ((completions (overlay-get overlay 'completions))
	  (non-prefix-completion
	   (overlay-get overlay :non-prefix-completion))
	  prefix cmpl len)

      ;; if there are too few completions, display message
      (if (>= n (length completions))
	  (progn
	    (beep)
	    (if (= (length completions) 1)
		(message "Only 1 completion available")
	      (message "Only %d completions available" (length completions))))

	;; otherwise, deactivate interfaces and select completion
	(setq prefix (overlay-get overlay 'prefix)
	      cmpl (nth n (overlay-get overlay 'completions))
	      len (length (overlay-get overlay 'prefix)))
	(unless (stringp cmpl) (setq cmpl (car cmpl)))
	;; deactivate the interfaces
	(completion-ui-deactivate-interfaces overlay)
	;; delete the original prefix and insert the completion
	(delete-region (- (point) len) (point))
	(let ((overwrite-mode nil)) (insert cmpl))
	;; run accept hooks
	(completion-ui-run-accept-functions overlay prefix cmpl)
	;; delete overlay
	(completion-ui-delete-overlay overlay)
	;; return prefix and accepted completion
	(cons prefix cmpl)))))



(defun completion-extend-prefix (&optional n overlay)
  "Extend the current prefix by N characters from the current completion,
and recomplete the resulting string.

If N is null, extend the prefix to the entire current
completion. If N is negative, remove that many characters from
the current prefix, and recomplete the resulting string.

When called from Lisp programs, OVERLAY is used if supplied
instead of finding one. The point had better be within OVERLAY or
the oceans will boil away."
  (interactive "P")

  ;; look for completion overlay at point if none was specified
  (unless overlay (setq overlay (completion-ui-overlay-at-point)))

  ;; if there are no characters to accept, do nothing
  (if (or (null overlay) (null (overlay-get overlay 'completion-num)))
      (message "No characters with which to extend prefix")

    ;; otherwise
    (let ((prefix (overlay-get overlay 'prefix))
	  (len (overlay-get overlay 'prefix-length))
	  (cmpl (nth (overlay-get overlay 'completion-num)
		     (overlay-get overlay 'completions)))
	  str)
      (unless (stringp cmpl) (setq cmpl (car cmpl)))
      (setq str (if (and n (< (+ len n) (length cmpl)) (> (+ len n) 0))
		    (substring cmpl 0 (+ len n))
		  cmpl))
      ;; deactivate interfaces pending update
      (completion-ui-deactivate-interfaces-pre-update overlay)
      ;; delete the original prefix
      (delete-region (- (point) (length prefix)) (point))

      ;; if prefix has been contracted down to nothing, stop completing
      (if (and n (<= (+ len n) 0))
	  (progn
	    (completion-ui-delete-overlay overlay)
	    (completion-ui-deactivate-interfaces overlay))
	;; otherwise, insert the characters, update the overlay, and
	;; recomplete
	(let ((overwrite-mode nil)) (insert str))
	(move-overlay overlay (point) (point))
	(completion-ui-setup-overlay str :overlay overlay)
	(complete-in-buffer-1 overlay nil nil nil nil 'update)
	;; reposition point at start of completion, so that user can continue
	;; extending or contracting the prefix
	(goto-char (overlay-start overlay))))))



(defun completion-cycle (&optional n overlay)
  "Cycle through available completions.

Optional argument N specifies the number of completions to cycle
forwards \(backwards if negative\). Default is 1. Interactively,
N is the prefix argument.

If OVERLAY is supplied, use that instead of finding one. The
point had better be within OVERLAY or you'll be struck by
lightening."
  (interactive "p")
  (unless (numberp n) (setq n 1))

  ;; if we haven't been passed one, get completion overlay at point
  (unless overlay (setq overlay (completion-ui-overlay-at-point)))

  ;; if there are no completions, can't cycle
  (if (or (null overlay) (null (overlay-get overlay 'completions)))
      (message "No completions to cycle")

    ;; otherwise, cycle away!
    (let* ((completions (overlay-get overlay 'completions))
	   (prefix (overlay-get overlay 'prefix))
	   (non-prefix-completion
	    (overlay-get overlay :non-prefix-completion))
	   (i (mod (+ (or (overlay-get overlay 'completion-num) -1) n)
		   (length completions)))
	   (cmpl (nth i completions))
	   (len (if (stringp cmpl)
		    (length prefix)
		  (prog1 (cdr cmpl) (setq cmpl (car cmpl))))))
      ;; run pre-cycle interface functions
      (completion-ui-deactivate-interfaces-pre-update overlay)
      ;; update overlay properties
      (overlay-put overlay 'prefix-length len)
      (overlay-put overlay 'completion-num i)
      ;; run post-cycle interface functions
      (completion-ui-update-interfaces overlay))))



(defun completion-cycle-backwards (&optional n)
  "Cycle backwards through available completions.

Optional argument N specifies the number of completions to cycle
backwards \(forwards if negative\). Default is 1. Interactively,
N is the prefix argument."
  (interactive "p")
  (completion-cycle (- n)))



(defun completion-tab-complete (&optional overlay)
  "Tab-complete completion at point.
\(I.e. insert longest common prefix of all the completion
candidates.\)"
  (interactive)
  ;; look for completion overlay at point if none was specified
  (unless overlay (setq overlay (completion-ui-overlay-at-point)))
  ;; if within a completion overlay
  (when overlay
    (let* ((prefix (overlay-get overlay 'prefix))
	   (completions (overlay-get overlay 'completions))
	   (str (try-completion
		 "" (mapcar
		     (lambda (cmpl)
		       (if (stringp cmpl)
			   (substring cmpl (length prefix))
			 (substring (car cmpl) (cdr cmpl))))
		     completions))))
      ;; try-completion returns t if there's only one completion
      (when (eq str t)
	(setq str (car (overlay-get overlay 'completions)))
	(if (stringp str)
	    (setq str (substring str (length prefix)))
	  (setq str (substring (car str) (cdr str)))))

      ;; do tab-completion
      (unless (or (null str) (string= str ""))
	;; add prefix (which might have been modified) to front of
	;; tab-completion
	(setq str
	      (concat (buffer-substring-no-properties
		       (- (overlay-start overlay)
			  (overlay-get overlay 'prefix-length))
		       (overlay-start overlay))
		      str))
	;; run pre-update interface functions
	(completion-ui-deactivate-interfaces-pre-update overlay)
	;; delete the original prefix and insert the tab-completion
	(delete-region (- (point) (length prefix)) (point))
        (let ((overwrite-mode nil)) (insert str))
	;; update overlay properties
        (move-overlay overlay (point) (point))
	(completion-ui-setup-overlay str :overlay overlay)
        ;; when auto-completing, do so
        (if (and auto-completion-mode
		 (eq (overlay-get overlay 'auto-completion) 'auto-complete))
            (complete-in-buffer-1 overlay nil nil nil
				  'auto-complete 'update)
	  (when (completion-ui-get-value-for-source
		 overlay completion-auto-update)
	    (complete-in-buffer-1 overlay nil nil nil
				  'auto-update 'update))
	  ;; otherwise, update completion interfaces
	  (completion-ui-update-interfaces overlay))))))


(defun completion-accept-or-cycle (&optional n overlay)
  "Accept current completion if there's only one candidate.
Otherwise, cycle through the completion candidates.

Optional argument N specifies the number of completions to cycle
forwards \(backwards if negative\). Default is 1. Interactively,
N is the prefix argument."
  (interactive)
  (unless overlay (setq overlay (completion-ui-overlay-at-point)))
  (when overlay
    (if (= (length (overlay-get overlay 'completions)) 1)
	(completion-accept nil overlay)
      (completion-cycle n overlay))))




;;; ===============================================================
;;;                   Self-insert functions

(defun auto-completion-lookup-behaviour (&optional char syntax source)
  "Return syntax-dependent behaviour
of character CHAR and/or syntax-class SYNTAX.

At least one of these must be supplied. If both are supplied,
SYNTAX overrides the syntax-class of CHAR.

If the SOURCE plist or overlay is supplied, :syntax-alist
and :override-syntax-alist properties specify alists in which to
lookup the behaviour. The formats are the same as those of
`auto-completion-syntax-alist' and
`auto-completion-override-syntax-alist'.

A :name property specifies the name of the completion source to
lookup in `auto-completion-syntax-alist' and
`auto-completion-override-syntax-alist'.

The return value is a three-element list:

  (RESOLVE COMPLETE INSERT)

containing the resolve-behaviour, completion-behaviour and
insert-behaviour.

If any \"overlay-local\" bindings of `auto-completion-syntax-alist'
and `auto-completion-override-syntax-alist' exist at point, any
behaviour they specify for CHAR and SYNTAX takes precedence over
those variables, unless NO-OVERLAY-LOCAL is non-nil."

  ;; SYNTAX defaults to syntax-class of CHAR
  (when (and char (not syntax)) (setq syntax (char-syntax char)))

  ;; get syntax alists
  (let* ((name (or (completion-ui-source-get-prop source :name)
		   (completion-ui-source-get-prop source 'collection)))
	 (overlay-syntax-alist nil)
         ;; (or (and (fboundp 'auto-overlay-local-binding)
	 ;; 	  (not no-overlay-local)
	 ;; 	  (auto-overlay-local-binding
	 ;; 	   'auto-completion-syntax-alist nil 'only-overlay))
	 ;;     nil)
	(custom-syntax-alist (completion-ui-get-value-for-source
			      name auto-completion-syntax-alist
			      'no-default))
	(source-syntax-alist (completion-ui-source-syntax-alist source))
	(default-syntax-alist (completion-ui-get-value-for-source
			       name auto-completion-syntax-alist))
        (override-alist
         (append ;; (or (and (fboundp 'auto-overlay-local-binding)
		 ;; 	  (not no-overlay-local)
		 ;; 	  (auto-overlay-local-binding
		 ;; 	   'auto-completion-override-syntax-alist nil t))
		 ;;     nil)
		 (completion-ui-get-value-for-source
		  name auto-completion-override-syntax-alist 'no-default)
		 (completion-ui-source-override-syntax-alist source)
		 (completion-ui-get-value-for-source
		  name auto-completion-override-syntax-alist)))
	behaviour)

    ;; if `auto-completion-syntax-alist' is a predefined behaviour (a
    ;; cons cell), convert it to an alist
    (dolist (alist '(overlay-syntax-alist custom-syntax-alist
		     source-syntax-alist default-syntax-alist))
      (unless (listp (car (symbol-value alist)))
	(set alist
	     `(;; word constituents add to current completion and complete
	       ;; word or string, depending on VALUE
	       (?w . (add ,(cdr (symbol-value alist))))
	       ;; symbol constituents, whitespace and punctuation characters
	       ;; either accept or reject, depending on VALUE, and don't
	       ;; complete
	       (?_ .  (,(car (symbol-value alist)) none))
	       (?  .  (,(car (symbol-value alist)) none))
	       (?. .  (,(car (symbol-value alist)) none))
	       (?\( . (,(car (symbol-value alist)) none))
	       (?\) . (,(car (symbol-value alist)) none))
	       ;; anything else rejects and does't complete
	       (t . (reject none)))
	     )))
    (setq source-syntax-alist (append overlay-syntax-alist custom-syntax-alist
				      source-syntax-alist default-syntax-alist))

    ;; extract behaviours from syntax alists
    (setq behaviour
	  (or
	   ;; if char is specified, check override-alist
	   (and char (cdr (assq char override-alist)))
	   ;; check syntax-alist
	   (cdr (assq syntax source-syntax-alist))
	   ;; fall back to default
	   (cdr (assq t source-syntax-alist))))
    ;; return behaviour, converting any variables to values
    (if (= (length behaviour) 2) (setq behaviour (append behaviour '(t))))
    (let ((valid '((accept reject add) (word string none) (t nil))))
      (dotimes (i 3)
	(while (and (not (or (memq (nth i behaviour) (nth i valid))
			     (functionp (nth i behaviour))))
		    (boundp (nth i behaviour)))
	  (setf (nth i behaviour) (symbol-value (nth i behaviour))))))
    behaviour))



;; (defmacro completion-get-resolve-behaviour (behaviour)
;;   "Extract syntax-dependent resolve behaviour from BEHAVIOUR.
;; BEHAVIOUR should be the return value of a call to
;; `auto-completion-lookup-behaviour'."
;;   `(nth 0 ,behaviour))


;; (defmacro completion-get-completion-behaviour (behaviour)
;;   "Extract syntax-dependent completion behaviour from BEHAVIOUR.
;; BEHAVIOUR should be the return value of a call to
;; `auto-completion-lookup-behaviour'."
;;   `(nth 1 ,behaviour))


;; (defmacro completion-get-insertion-behaviour (behaviour)
;;   "Extract syntax-dependent insertion behaviour from BEHAVIOUR.
;; BEHAVIOUR should be the return value of a call to
;; `auto-completion-lookup-behaviour'."
;;   `(nth 2 ,behaviour))



(defun completion-self-insert ()
  "Deal with completion-related stuff, then insert last input event."
  (interactive)
  ;; FIXME: whether to keep or delete provisional completion should
  ;;        depend on point's location relative to it

  ;; if we're auto-completing, hand over to `auto-completion-self-insert'
  (if auto-completion-mode
      (auto-completion-self-insert)
    ;; otherwise, resolve old and current completions, and insert last input
    ;; event
    (let ((overlay (completion-ui-overlay-at-point)))
      (completion-ui-resolve-old overlay)
      (completion--resolve-current overlay))
    (self-insert-command 1)))



(defun auto-completion-self-insert
  (&optional char syntax no-syntax-override)
  "Execute a completion function based on syntax of the character
to be inserted.

Decide what completion function to execute by looking up the
syntax of the character corresponding to the last input event in
`auto-completion-syntax-alist'. The syntax-derived function can
be overridden for individual characters by
`auto-completion-override-syntax-alist'.

If CHAR is supplied, it is used instead of the last input event
to determine the character typed. If SYNTAX is supplied, it
overrides the character's syntax, and is used instead to lookup
the behaviour in the alists. If NO-SYNTAX-OVERRIDE is non-nil,
the behaviour is determined only by syntax, even if it is
overridden for the character in question
\(i.e. `auto-completion-override-syntax-alist' is ignored\).

The default actions in `auto-completion-syntax-alist' all
insert the last input event, in addition to taking any completion
related action \(hence the name,
`auto-completion-self-insert'\). Therefore, unless you know what
you are doing, only bind `auto-completion-self-insert' to
printable characters.

The Emacs `self-insert-command' is remapped to this command when
`auto-completion-mode' is enabled."
  (interactive)

  ;; if CHAR or SYNTAX were supplied, use them; otherwise get character
  ;; and syntax from last input event (which relies on sensible key
  ;; bindings being used for this command)
  (when (null char)
    (if (characterp last-input-event)
	(setq char last-input-event)
      ;; if `last-input-event' is not a character, look at
      ;; `this-single-command-keys' instead in case we get a character after
      ;; translation (as e.g. for "\S- ")
      (setq char (this-single-command-keys))
      (if (= (length char) 1) (setq char (aref char 0))
	(error "`auto-completion-self-insert'\
 bound to non-printable character"))))
  (when (null syntax) (setq syntax (char-syntax char)))

  (let ((overlay (completion-ui-overlay-at-point))
	resolve-behaviour complete-behaviour insert-behaviour
	wordstart prefix capf-function pos)


    ;; ----- resolve behaviour -----
    (completion-ui-resolve-old overlay)
    (if (not overlay)
	(setq prefix (string char))

      (destructuring-bind
	  (resolve-behaviour complete-behaviour insert-behaviour)
	  (if no-syntax-override
	      (auto-completion-lookup-behaviour nil syntax overlay)
	    (auto-completion-lookup-behaviour char syntax overlay))
	(completion-ui-resolve-old overlay)
	;; if behaviour alist entry is a function, call it
	(when (and (functionp resolve-behaviour)
		   (not (memq complete-behaviour
			      '(accept reject add))))
	  (setq resolve-behaviour (funcall resolve-behaviour)))

	(cond
	 ;; ;; no-op
	 ;; ((null resolve-behaviour))

	 ;; accept
	 ((eq resolve-behaviour 'accept)
	  ;; CHAR might not be a character if `last-input-event' included a
	  ;; modifier (e.g. S-<space>)
	  (setq prefix (string char))
	  (setq wordstart t)
	  ;; if point is at start of overlay, accept completion
	  (if (= (point) (overlay-start overlay))
	      (completion-accept nil overlay)
	    ;; otherwise, delete overlay (effectively accepting old
	    ;; completion but without running hooks)
	    (completion-ui-delete-overlay overlay)
	    (completion-ui-deactivate-interfaces overlay))
	  (setq overlay nil))

	 ;; reject
	 ((eq resolve-behaviour 'reject)
	  ;; CHAR might not be a character if `last-input-event' included a
	  ;; modifier (e.g. S-<space>)
	  (setq prefix (string char))
	  (setq wordstart t)
	  ;; if there is a completion at point...
	  (when overlay
	    ;; if point is at start of overlay, reject completion
	    (if (= (point) (overlay-start overlay))
		(completion-reject nil overlay)
	      ;; otherwise, delete overlay and everything following point
	      (delete-region (point) (overlay-end overlay))
	      (completion-ui-delete-overlay overlay)
	      (completion-ui-deactivate-interfaces overlay))
	    (setq overlay nil)))

	 ;; add to prefix
	 ((eq resolve-behaviour 'add)
	  ;; if point is at start of overlay, update prefix and prevent
	  ;; adjacent words being deleted
	  (if (= (point) (overlay-start overlay))
	      (progn
		(setq prefix (concat (overlay-get overlay 'prefix)
				     (string char))
		      wordstart t)
		(completion-ui-deactivate-interfaces-pre-update overlay)
		(completion-ui-setup-overlay prefix :overlay overlay))
	      ;; otherwise, delete overlay (effectively accepting the old
	      ;; completion) and behave as if no completion was in progress
	      (completion-ui-delete-overlay overlay)
	      (completion-ui-deactivate-interfaces overlay)
	      (setq overlay nil)))

	 ;; error
	 (t (error "Invalid entry in `auto-completion-syntax-alist'\
 or `auto-completion-override-syntax-alist', %s"
		   (prin1-to-string resolve-behaviour))))))


    ;; ----- insersion behaviour -----
    ;; Note: if a completion source is found *before* character is inserted,
    ;;       it also determines source to use for completing
    (pcase (if overlay
	       (completion--capf-wrapper
		(overlay-get overlay 'completion-at-point-function)
		'all)
	     (run-hook-wrapped 'auto-completion-at-point-functions
			       #'completion--capf-wrapper 'all))

      ;; `completion-at-point-functions' found a completion source...
      (`(,hookfun . (,start ,end ,collection . ,props))
       (setq capf-function hookfun)
       ;; if we're at the start of a word, prevent adjacent word from being
       ;; deleted below if `completion-overwrite' is non-nil
       (when (= start (point)) (setq wordstart t))
       (setq pos (move-marker (make-marker) end))
       (set-marker-insertion-type pos t)
       ;; lookup syntax-derived behaviour
       (destructuring-bind (rslv cmpl ins)
	   (auto-completion-lookup-behaviour
	    (if no-syntax-override nil char) syntax (or overlay props))
	 (setq resolve-behaviour rslv
	       complete-behaviour cmpl
	       insert-behaviour ins))

       ;; if behaviour alist entry is a function, call it
       (when (functionp insert-behaviour)
	 (setq insert-behaviour (funcall insert-behaviour)))
       ;; if we're inserting...
       (when (or insert-behaviour (null hookfun))
	 ;; use `self-insert-command' if possible, since `auto-fill-mode'
	 ;; depends on it
	 (if (eq char last-input-event)
	     (self-insert-command 1)
	   (insert char))
	 (when overlay (move-overlay overlay (point) (point)))))

      ;; no completion source: just call `self-insert-command'
      (_ (if (eq char last-input-event)
	     (self-insert-command 1)
	   (insert char))))


    ;; ----- completion behaviour -----
    (pcase (if capf-function
	       (completion--capf-wrapper capf-function 'all)
	     (run-hook-wrapped 'auto-completion-at-point-functions
			       #'completion--capf-wrapper 'all))
      (`(,hookfun . (,start ,end ,collection . ,props))
       (unless complete-behaviour
	 (setq complete-behaviour
	       (nth 1 (auto-completion-lookup-behaviour
		       (if no-syntax-override nil char)
		       syntax props))))

       ;; if behaviour alist entry is a function, call it
       (when (and (functionp complete-behaviour)
		  (not (memq complete-behaviour      ; `string' is a function!
			     '(string word none))))
	 (setq complete-behaviour (funcall complete-behaviour)))

       (cond
	;; no-op
	((null complete-behaviour))

	;; not completing; clear up any overlay left lying around
	((eq complete-behaviour 'none)
	 (when overlay
	   (completion-ui-deactivate-interfaces overlay)
	   (completion-ui-delete-overlay overlay)))

	;; completing...
	((or (eq complete-behaviour 'word)
	     (eq complete-behaviour 'string))
	 ;; --- completion-overwrite ---
	 ;; if point is in middle of a word, `completion-overwrite' is set,
	 ;; and overwriting hasn't been disabled, delete rest of word prior
	 ;; to completing
	 (unless pos (setq pos end))
	 (when (and completion-overwrite
		    (null wordstart)
		    (> pos (point)))
	   (delete-region (point) pos))
	 ;; if doing basic string completion prefix is typed string,
	 ;; otherwise it's string found by `completion-at-point-function'
	 (unless (eq complete-behaviour 'string)
	   (setq prefix (buffer-substring-no-properties start (point))))
	 (if prefix
	     (progn
	       (setq overlay
		     (move-overlay
		      (completion-ui-setup-overlay prefix
		       :collection collection
		       :completion-at-point-function hookfun
		       :auto-completion 'auto-complete
		       :overlay overlay
		       :props props)
		      (point) (point)))
	       (complete-in-buffer-1 overlay nil nil nil 'auto-complete))
	   ;; didn't find anything to complete
	   (when overlay
	     (completion-ui-deactivate-interfaces overlay)
	     (completion-ui-delete-overlay overlay))))

	;; error
	(t (error "Invalid entry in `auto-completion-syntax-alist'\
 or `auto-completion-override-syntax-alist', %s"
		  (prin1-to-string complete-behaviour)))
	))

      ;; no prefix to complete; clear up any overlay left lying around
      (_ (when overlay
	   (completion-ui-deactivate-interfaces overlay)
	   (completion-ui-delete-overlay overlay)))
      )))




(defun completion-auto-update-self-insert ()
  "Add character to current prefix and recomplete
based on current syntax table."
  (interactive)

  (let ((char last-input-event)
	(syntax (char-syntax last-input-event))
	(overlay (completion-ui-overlay-at-point))
	prefix dont-complete)
    (when overlay
      (cond

       ;; word- or symbol-constituent: add to prefix
       ;; Note: disabled for non-prefix-completion, unless
       ;;       `completion-accept-or-reject-by-default' is set to 'reject,
       ;;       because otherwise the prefix being added to is hidden
       ((and (or (eq syntax ?w) (eq syntax ?_))
	     (or (not (overlay-get overlay :non-prefix-completion))
		 (eq (completion-ui-get-value-for-source
		      overlay completion-accept-or-reject-by-default)
		     'reject)))
	;; add characters up to point and new character to prefix
	(setq prefix
	      (concat (buffer-substring-no-properties
		       (- (overlay-start overlay)
			  (if (overlay-get overlay 'prefix-replaced)
			      0 (overlay-get overlay 'prefix-length)))
		       (point))
		      (string char)))
	(delete-region (point) (overlay-end overlay))
	(overlay-put overlay 'prefix-replaced nil)
	(completion-ui-delete-overlay overlay)
	(completion-ui-deactivate-interfaces-pre-update overlay)
	;; insert character
	(if (eq char last-input-event)
	    (self-insert-command 1)
	  (insert char))
	;; re-complete new prefix
	(unless dont-complete
	  (move-overlay overlay (point) (point))
	  (completion-ui-setup-overlay prefix :overlay overlay)
	  (complete-in-buffer-1 overlay nil nil nil
				'auto-update 'update)))


       ;; anything else: accept up to point, reject rest
       (t
	;; if point is at start of overlay, reject completion
	(if (= (point) (overlay-start overlay))
	    (completion-reject nil overlay)
	  ;; otherwise, delete everything following point, and delete overlay
	  (delete-region (point) (overlay-end overlay))
	  (completion-ui-delete-overlay overlay)
	  (completion-ui-deactivate-interfaces overlay))
	;; insert character
	(if (eq char last-input-event)
	    (self-insert-command 1)
	  (insert char)))))))





;;; ============================================================
;;;                          Undo

(defun completion-resolve-before-undo (beg end)
  "Resolve completions before undoing.
Added to `before-change-functions' hook."
  ;; check if current command is an undo
  (when undo-in-progress
    ;; replace 'leave behaviour by 'accept, since we have to get rid of the
    ;; completion overlay before the undo
    (let ((completion-how-to-resolve-old-completions
	   (if (eq completion-how-to-resolve-old-completions 'leave)
	       'accept
	     completion-how-to-resolve-old-completions)))
      ; (completion-ui-resolve-old nil beg end)
      (completion-ui-resolve-old))))



;;; ============================================================
;;;                      Fill commands

(defun completion-fill-paragraph (&optional justify region)
  "Fill paragraph at or after point.
This command first sorts out any provisional completions, before
calling `fill-paragraph', passing any arguments straight through."
  ;; interactive spec copied from `fill-paragraph'
  (interactive (progn
		 (barf-if-buffer-read-only)
		 (list (if current-prefix-arg 'full) t)))
  (completion-ui-resolve-old)
  (fill-paragraph justify region))



;;; ============================================================
;;;                      Yank Commands

(defun completion-yank (&optional arg)
  "Reinsert (\"paste\") the last stretch of killed text.
This command first sorts out any provisional completions, before
calling `yank', passing any argument straight through."
  (interactive "*P")
  (completion-ui-resolve-old)
  (yank arg))


(defun auto-completion-mouse-yank-at-click (click arg)
  "Insert the last stretch of killed text at the position clicked on.
Temporarily disables `auto-completion-mode', then calls
`mouse-yank-at-click'."
  (interactive "e\nP")
  (let ((auto-completion-mode nil))
    (mouse-yank-at-click click arg)))




;;; ============================================================
;;;                    Deletion commands

(defun completion-backward-delete (command &rest args)
  "Call backward-delete COMMAND, passing it ARGS.
Any provisional completion at the point is first rejected. If
COMMAND deletes into a word and `auto-completion-mode' is
enabled, complete what remains of that word."

  (let* ((overlay (completion-ui-overlay-at-point))
	 (accept-or-reject
	  (completion-ui-get-value-for-source
	   overlay completion-accept-or-reject-by-default))
	 (auto (or (and auto-completion-mode 'auto-complete)
		   (completion-ui-get-value-for-source
		    overlay completion-auto-update)))
         update wordboundary pos)
    ;(combine-after-change-calls

      ;; ----- not auto-completing or auto-updating -----
      (if (not auto)
          (progn
            ;; if within a completion...
            (when overlay
              (cond
	       ;; if rejecting old completions, delete everything after the
	       ;; point
	       ((eq accept-or-reject 'reject)
                (delete-region (point) (overlay-end overlay)))

	       ;; if accepting longest common substring...
	       ((eq accept-or-reject 'accept-common)
		;; find the end of the longest common substring, using
		;; common-substring overlay if it exists, otherwise searching
		;; for it ourselves
		(if (overlayp (overlay-get overlay 'common-substring))
		    (setq pos (overlay-end
			       (overlay-get overlay 'common-substring)))
		  (let* ((prefix (overlay-get overlay 'prefix))
			 (completions
			  (mapcar
			   (lambda (c)
			     (if (stringp c)
				 (substring c (length prefix))
			       (substring (car c) (cdr c))))
			   (overlay-get overlay 'completions)))
			 (str (try-completion "" completions)))
		    ;; (try-completion returns t if there's only one completion)
		    (when (eq str t) (setq str (car completions)))
		    (setq pos (+ (overlay-start overlay) (length str)))))
		;; if point is before end of common substring, delete
		;; everthing after common substring, otherwise delete
		;; everything after point
		(delete-region (if (< (point) pos) pos (point))
			       (overlay-end overlay))))
	      ;; delete overlay, effectively accepting (rest of) the
              ;; completion at point
              (completion-ui-delete-overlay overlay)
	      (completion-ui-deactivate-interfaces overlay))

            ;; resolve old provisional completions and delete backwards
            (completion-ui-resolve-old)
            (apply command args))


	;; skip completion and just delete backwards if we're auto-updating,
	;; dynamic completion is enabled, and we're not rejecting by default
	;; (otherwise backward deletion effectively becomes impossible)
	(if (and (not auto-completion-mode)
		 (and (boundp 'completion-ui-use-dynamic)
		      (completion-ui-get-value-for-source
		       overlay completion-ui-use-dynamic))
		 (eq (completion-ui-get-value-for-source
		      overlay completion-accept-or-reject-by-default)
		     'accept))
	    (apply command args)


	  ;; ----- auto-completing or auto-updating -----

	  ;; --- resolve previous completion ---
	  (completion-ui-resolve-old overlay)
	  ;; if point is in a completion...
	  (when overlay
	    ;; delete provisional completion characters after point
	    ;; FIXME: should this depend on
	    ;; `completion-accept-or-reject-by-default'?
	    (delete-region (point) (overlay-end overlay))
	    ;; store position of beginning of prefix
	    (completion-ui-deactivate-interfaces-pre-update overlay)
	    (setq pos (- (overlay-start overlay)
			 (overlay-get overlay 'prefix-length)))
	    ;; delete the overlay, effectively accepting (rest of) completion
	    (completion-ui-delete-overlay overlay))


	  ;; --- check if we're at the start of a word ---
	  (pcase (if overlay
		     (completion--capf-wrapper
		      (overlay-get overlay 'completion-at-point-function)
		      'all)
		   (run-hook-wrapped 'auto-completion-at-point-functions
				     #'completion--capf-wrapper 'all))
	    ;; standard `completion-at-point-functions' return value...
	    (`(,hookfun . (,start ,end ,collection . ,props))
	     (setq wordboundary (or (= start (point)) (= end (point)))))
	    ;; FIXME: handle non-standard return val case?
	    (_))

	  ;; --- delete backwards ---
	  (apply command args)


	  ;; --- do auto-completion or auto-updating ---
	  (when
	      (catch 'cancel-completion
		;; if we're auto-updating rather than auto-completing and
		;; we've deleted beyond current completion, cancel completing
		(if (and (not (eq auto 'auto-complete))
			 (or (not overlay) (<= (point) pos)))
		    (throw 'cancel-completion t))

		;; otherwise, get completion source at point
		(pcase (if (and overlay (> (point) pos))
			   (completion--capf-wrapper
			    (overlay-get
			     overlay 'completion-at-point-function) 'all)
			 (run-hook-wrapped 'auto-completion-at-point-functions
					   #'completion--capf-wrapper 'all))

		  ;; standard `completion-at-point-functions' return value...
		  (`(,hookfun . (,start ,end ,collection . ,props))
		   ;; if there's nothing before point to complete, cancel
		   ;; completing
		   (when (>= start (point)) (throw 'cancel-completion t))

		   ;; if we're still within original prefix, update interfaces
		   ;; rather than activating from scratch
		   (when (and overlay (> (point) pos)) (setq update t))

		   ;; if point was not at start of completion or start of word
		   ;; before deleting, respect `completion-overwrite' setting
		   (unless (or overlay wordboundary (null completion-overwrite))
		     (delete-region (point) end))

		   ;; setup completion overlay
		   (setq overlay
			 (move-overlay
			  (completion-ui-setup-overlay
			   (buffer-substring-no-properties start (point))
			   :collection collection
			   :completion-at-point-function hookfun
			   :auto-completion auto
			   :overlay overlay
			   :props props)
			  (point) (point)))

		   ;; set up timer to re-complete after some idle time
		   (when (timerp completion--backward-delete-timer)
		     (cancel-timer completion--backward-delete-timer))
		   (if auto-completion-backward-delete-delay
		       (setq completion--backward-delete-timer
			     (run-with-idle-timer
			      auto-completion-backward-delete-delay nil
			      (lambda (overlay auto update pos)
				(setq completion--backward-delete-timer nil)
				(complete-in-buffer-1 overlay nil nil nil
						      auto update pos))
			      overlay auto update (point)))
		     ;; if completing with no delay, do so
		     (complete-in-buffer-1 overlay nil nil nil
					   auto update (point)))

		   ;; return nil to prevent `catch' cancelling completion
		   nil)


		  ;; FIXME: handle non-standard return val case?
		  ;; (`(,_ . ,(and (pred functionp) f)))

		  ;; if we didn't find anything to complete at point,
		  ;; deactivate any user-interfaces and cancel any timer
		  ;; that's been set up
		  (_ (throw 'cancel-completion t))))

	      (when (timerp completion--backward-delete-timer)
		(cancel-timer completion--backward-delete-timer))
	      (setq completion--backward-delete-timer nil))
	  ))))



(defun completion-delete (command &rest args)
  "Call forward-delete COMMAND, passing it ARGS.
If there is a provisional completion at point after deleting, reject
it."
  ;; delete any completion overlay at point (effectively accepting it, but
  ;; without running any hook functions)
  (let ((overlay (completion-ui-overlay-at-point)))
    (when overlay
      (completion-ui-delete-overlay overlay)
      (completion-ui-deactivate-interfaces overlay)))
  ;; now resolve any old completions
  (completion-ui-resolve-old)
  ;; call the deletion command
  (apply command args)
  ;; if there's a completion overlay at point after deleting, delete it
  ;; (effectively rejecting it, but without calling any hook functions)
  (let ((overlay (completion-ui-overlay-at-point)))
    (when overlay
      (delete-region (overlay-start overlay) (overlay-end overlay))
      (completion-ui-delete-overlay overlay)
      (completion-ui-deactivate-interfaces overlay))))


(defun completion-delete-char (n &optional killflag)
  "Delete the following N characters (previous if N is negative).

Non-nil optional second arg KILLFLAG means kill instead (save in
kill ring). Interactively, N is the prefix arg (default 1), and
KILLFLAG is set if n was explicitly specified. \(If N is
negative, behaviour is instead as for
`completion-backward-delete-char'.\)

If there is a provisional completion at point after deleting, it
is rejected. "
  (interactive "P")
  (when (and (called-interactively-p 'any) n) (setq killflag t))
  (setq n (prefix-numeric-value n))
  ;; if deleting backwards, call `completion-backward-delete' instead
  (if (< n 0)
      (completion-backward-delete 'backward-delete-char (- n) killflag)
    (completion-delete 'delete-char n killflag)))


(defun completion-backward-delete-char (n &optional killflag)
  "Delete the previous N characters.

Optional second arg KILLFLAG non-nil means kill instead (save in
kill ring). Interactively, N is the prefix arg (default 1), and
KILLFLAG is set if N was explicitly specified. \(If N is
negative, behaviour is instead as for `completion-delete-char'.\)

Any provisional completion at point is first rejected. If
deleting backwards into a word, and `auto-completion-mode' is
enabled, complete what remains of that word."
  (interactive "P")
  (when (and (called-interactively-p 'any) n) (setq killflag t))
  (setq n (prefix-numeric-value n))
  ;; if deleting forwards, call `completion-delete' instead
  (if (< n 0)
      (completion-delete 'delete-char (- n) killflag)
    (completion-backward-delete 'backward-delete-char n killflag)))


(defun completion-backward-delete-char-untabify (n &optional killflag)
  "Delete N characters backward, changing tabs into spaces.

Optional second arg KILLFLAG non-nil means kill instead (save in
kill ring). Interactively, N is the prefix arg (default 1), and
KILLFLAG is set if N was explicitly specified. \(If N is
negative, behaviour is instead as for `completion-delete-char'.\)

The exact behavior depends on `backward-delete-char-untabify-method'.

Any provisional completion at point is first rejected. If
deleting backwards into a word, and `auto-completion-mode' is
enabled, complete what remains of that word."
  (interactive "P")
  (when (and (called-interactively-p 'any) n) (setq killflag t))
  (setq n (prefix-numeric-value n))
  ;; if deleting forwards, call `completion-delete' instead
  (if (< n 0)
      (completion-delete 'delete-char (- n) killflag)
    (completion-backward-delete 'backward-delete-char-untabify n killflag)))


(defun completion-kill-word (&optional n)
  "Kill characters forward until encountering the end of a word.
With argument, do this that many times. \(If N is negative,
behaviour is instead as for `completion-backward-kill-word'.\)

If there is a provisional completion at point after deleting, it
is rejected."
  (interactive "p")
  ;; if deleting backwards, call `completion-backward-delete' instead
  (if (< n 0)
      (completion-backward-delete 'backward-kill-word (- n))
    (completion-delete 'kill-word n)))


(defun completion-backward-kill-word (&optional n)
  "Kill characters backward until encountering the end of a word.
With argument, do this that many times. \(If N is negative,
behaviour is instead as for `completion-kill-word'.\)

Any provisional completion at point is first rejected. If
deleting backwards into a word, and `auto-completion-mode' is
enabled, complete what remains of that word."
  (interactive "p")
  ;; if deleting forwards, call `completion-delete' instead
  (if (< n 0)
      (completion-delete 'kill-word (- n))
    (completion-backward-delete 'backward-kill-word n)))


(defun completion-kill-sentence (&optional n)
  "Kill from point to end of sentence.
With argument, do this that many times. \(If N is negative,
behaviour is instead as for
`completion-backward-kill-sentence'.\)

If there is a provisional completion at point after deleting, it
is rejected."
  (interactive "p")
  ;; if deleting backwards, call `completion-backward-delete' instead
  (if (< n 0)
      (completion-backward-delete 'backward-kill-sentence (- n))
    (completion-delete 'kill-sentence n)))


(defun completion-backward-kill-sentence (&optional n)
  "Kill back from point to start of sentence.
With argument, do this that many times. \(If N is negative,
behaviour is instead as for `completion-kill-sentence'.\)

Any provisional completion at point is first rejected. If
deleting backwards into a word, and `auto-completion-mode' is
enabled, complete what remains of that word."
  (interactive "p")
  ;; if deleting forwards, call `completion-delete' instead
  (if (< n 0)
      (completion-delete 'kill-sentence (- n))
    (completion-backward-delete 'backward-kill-sentence n)))


(defun completion-kill-sexp (&optional n)
  "Kill the sexp (balanced expression) following point.
With argument, do this that many times. \(If N is negative,
behaviour is instead as for `completion-backward-kill-sexp'.\)

If there is a provisional completion at point after deleting, it
is rejected."
  (interactive "p")
  ;; if deleting backwards, call `completion-backward-delete' instead
  (if (< n 0)
      (completion-backward-delete 'backward-kill-sexp (- n))
    (completion-delete 'kill-sexp n)))


(defun completion-backward-kill-sexp (&optional n)
  "Kill the sexp (balanced expression) before point.
With argument, do this that many times. \(If N is negative,
behaviour is instead as for `completion-kill-sexp'.\)

Any provisional completion at point is first rejected. If
deleting backwards into a word, and `auto-completion-mode' is
enabled, complete what remains of that word."
  (interactive "p")
  ;; if deleting forwards, call `completion-delete' instead
  (if (< n 0)
      (completion-delete 'kill-sexp (- n))
    (completion-backward-delete 'backward-kill-sexp n)))



(defun completion-kill-line (&optional n)
  "Kill the line following point.
With argument, do this that many times. \(If N is negative,
behaviour is instead as for `completion-backward-kill-line'.\)

If there is a provisional completion at point after deleting, it
is rejected."
  (interactive "P")
  (let ((kill-cmd (if visual-line-mode 'kill-visual-line 'kill-line)))
    ;; if deleting backwards, call `completion-backward-delete' instead
    (if (and (integerp n) (< n 0))
	(completion-backward-delete kill-cmd (- n))
      (completion-delete kill-cmd n))))



(defun completion-backward-kill-line (&optional n)
  "Kill the line before point.
With argument, do this that many times. \(If N is negative,
behaviour is instead as for `completion-kill-line'.\)

Any provisional completion at point is first rejected. If
deleting backwards into a word, and `auto-completion-mode' is
enabled, complete what remains of that word."
  (interactive "p")
  (let ((kill-cmd (if visual-line-mode 'kill-visual-line 'kill-line)))
    ;; if deleting forwards, call `completion-delete' instead
    (if (< n 0)
	(completion-delete kill-cmd (- n))
      (completion-backward-delete kill-cmd n))))


(defun completion-kill-paragraph (&optional n)
  "Kill forward to end of paragraph.
With argument, do this that many times. \(If N is negative,
behaviour is instead as for
`completion-backward-kill-paragraph'.\)

If there is a provisional completion at point after deleting,
reject it."
  (interactive "p")
  ;; if deleting backwards, call `completion-backward-delete' instead
  (if (< n 0)
      (completion-backward-delete 'backward-kill-paragraph (- n))
    (completion-delete 'kill-paragraph n)))


(defun completion-backward-kill-paragraph (&optional n)
  "Kill backward to start of paragraph.
With argument, do this that many times. \(If N is negative,
behaviour is instead as for `completion-kill-paragraph'.\)

Any provisional completion at point is first rejected. If
deleting backwards into a word, and `auto-completion-mode' is
enabled, complete what remains of that word."
  (interactive "p")
  ;; if deleting forwards, call `completion-delete' instead
  (if (< n 0)
      (completion-delete 'kill-paragraph (- n))
    (completion-backward-delete 'backward-kill-paragraph n)))


(defun completion-kill-region (beg end)
  "Kill (\"cut\") text between point and mark.
This deletes the text from the buffer and saves it in the kill ring.
The command \\[yank] can retrieve it from there.
\(If you want to save the region without killing it, use \\[kill-ring-save].)

If you want to append the killed region to the last killed text,
use \\[append-next-kill] before \\[kill-region].

If the buffer is read-only, Emacs will beep and refrain from deleting
the text, but put the text in the kill ring anyway.  This means that
you can use the killing commands to copy text from a read-only buffer.

If there is a provisional completion at point after deleting, it
is rejected."
  (interactive (list (point) (mark)))
  (completion-delete 'kill-region beg end))




;;; ==============================================================
;;;                    Miscelaneous utility functions

(defun completion-prefix (&optional thing allow-empty-prefix)
  (unless thing (setq thing 'word))
  (let ((bounds (bounds-of-thing-at-point thing))
	bounds1)
    (cond
     ((null bounds)
      (when allow-empty-prefix (cons (point) (point))))
     ;; favour thing before point rather than after
     ((and (= (car bounds) (point))
	   (not (bobp))
	   (setq bounds1
		 (save-excursion
		   (backward-char)
		   (bounds-of-thing-at-point thing)))
	   (= (cdr bounds1) (point))
	   bounds1))
     (t bounds))))


;; (defun auto-completion-text-property-source ()
;;   "Return completion source specified by text properties at point.

;; When used in `auto-completion-source-functions' (as in the
;; default setting), this allows the auto-completion source to be
;; changed in a buffer region by setting the `completion-source'
;; text property in the region."
;;   (get-text-property (point) 'completion-source))


;; (defun auto-completion-overlay-source ()
;;   "Return completion source specified by any overlays at point.

;; When used in `auto-completion-source-functions' (as in the
;; default setting), this allows the auto-completion source to be
;; changed in a buffer region by setting the `completion-source'
;; property of an overlay spanning the region."
;;   (auto-overlay-local-binding 'completion-source nil 'only-overlay))


(defun completion-ui-regexp-match (regexp &optional type group)
  "Return non-nil if REGEXP matches at point.

TYPE can be one of the symbols `looking-at' or `before-point'
\(defaulting to the former if omitted\).

If `before-point' is specified, the regexp must match text
strictly before point.

If `looking-at' is specified, the regexp must match text around
the point. In this case, if a regexp GROUP is specified, the
regexp will only match if point is within the text matching that
group."
  (let ((pos (point))
	(bound (line-end-position)))
    (catch 'match
      (save-excursion
	(cond
	 ((or (eq type 'looking-at) (null type)) ; default to `looking-at'
	  (unless group (setq group 0))
	  ;; search repeatedly, starting from last match, until we find
	  (forward-line 0)
	  (while (re-search-forward regexp bound t)
	    (when (and (<= (match-beginning group) pos)
		       (>= (match-end group) pos))
	      (throw 'match t))
	    (goto-char (1+ (match-beginning 0)))))

	 ((eq type 'before-point)
	  (goto-char (line-beginning-position))
	  (when (re-search-forward regexp pos t)
	    (throw 'match t)))
	 )))))


(defun completion-ui-face-match (face)
  "Return non-nil if FACE matches at point."
  (let* ((face0 (get-text-property (point) 'face))
	 (face1 (if (eq (point) (point-min))
		    face0
		  (get-text-property (1- (point)) 'face))))
    (and (completion-ui-face-matches-p face face0)
	 (completion-ui-face-matches-p face face1))))


(defun completion-ui-face-matches-p (f face)
  (or (eq f face)  ; might as well check easy case first
      (and (symbolp f) (listp face) (memq f face))
      (and (listp f) (listp face)
	   (catch 'no-match
	     (dolist (el f)
	       (unless (memq el face) (throw 'no-match nil)))
	     t))))





;;; ==============================================================
;;;                    Internal functions

(defun* completion-ui-setup-overlay
    (prefix &key prefix-length completions num
	    completion-at-point-function collection
	    auto-completion overlay props)
  "Set completion overlay properties according to the arguments.

If OVERLAY isn't supplied, look for one at point, and create a
new one if none exists.

If PREFIX-LENGTH is null, it defaults to the length of PREFIX. If
NUM is null, it defaults to 1. To leave these properties
unchanged, use any non-numeric non-null value.

The COLLECTION, COMPLETION-PREFIX-FUNCTION and
NON-PREFIX-COMPLETION properties are ignored and the
corresponding properties left unchanged if an existing overlay's
properties are being set.

Any additional keyword arguments specified in the PROPS plist are
transferred to the overlay as properties of the same name."

  ;; sort out PROPS argument
  (setq props (completion-ui-filter-plist
	       props '(completion-overlay face priority keymap
		       completion-at-point-function auto-completion
		       prefix collection prefix-length completions num)))

  ;; if overlay does not already exists, create one
  (unless overlay
    (setq overlay (make-overlay (point) (point) nil nil t))
    ;; set permanent overlay properties
    (overlay-put overlay 'completion-overlay t)
    (overlay-put overlay 'face 'completion-highlight-face)
    (overlay-put overlay 'priority 100)
    (overlay-put overlay 'completion-at-point-function
		 completion-at-point-function)
    (overlay-put overlay 'auto-completion auto-completion)
    ;; set overlay keymap
    (let ((map (make-sparse-keymap)))
      (overlay-put overlay 'keymap map)
      (set-keymap-parent
       map
       (cond
	((and auto-completion-mode (eq auto-completion 'auto-complete))
	 auto-completion-overlay-map)
	((completion-ui-get-value-for-source
	  (or (plist-get props :name) collection)
	  completion-auto-update)
	 completion-auto-update-overlay-map)
	(t completion-overlay-map)))))

  ;; add overlay to list
  (add-to-list 'completion--overlay-list overlay)

  ;; update modifiable overlay properties
  (overlay-put overlay 'prefix prefix)
  (when collection (overlay-put overlay 'collection collection))
  (cond
   ((numberp prefix-length)
    (overlay-put overlay 'prefix-length prefix-length))
   ((and prefix-length (overlay-get overlay 'prefix-length)))
   (t (overlay-put overlay 'prefix-length (length prefix))))
  (overlay-put overlay 'completions completions)
  (cond
   ((null num) (overlay-put overlay 'completion-num (if completions 0 nil)))
   ((numberp num) (overlay-put overlay 'completion-num num)))
  ;; set any remaining PROPS
  (let ((p props)) (while p (overlay-put overlay (pop p) (pop p))))

  ;; return the new overlay
  overlay)



(defun completion-ui-delete-overlay (overlay &optional keep-popup)
  "Delete completion overlay, and clean up after it.
If KEEP-POPUP is non-nil, prevent deletion of any pop-up frame
associated with OVERLAY."
  (when (overlayp (overlay-get overlay 'common-substring))
    (delete-overlay (overlay-get overlay 'common-substring)))
  (delete-overlay overlay)
  (setq completion--overlay-list (delq overlay completion--overlay-list)))



(defun completion-ui-overlay-at-point (&optional point)
  "Return completion overlay overlapping point.
\(There should only be one; if not, one is returned at random\)"
  (setq point (or point (point)))

  ;; and overlays starting at POINT
  (let (overlay-list)
    (catch 'found
      ;; check overlays overlapping POINT (including zero-length)
      (setq overlay-list (overlays-in point point))
      (dolist (o overlay-list)
        (when (overlay-get o 'completion-overlay)
          (throw 'found o)))

      ;; check overlays ending at POINT
      (setq overlay-list (overlays-in (1- point) point))
      (dolist (o overlay-list)
        (when (and (overlay-get o 'completion-overlay)
                   (= (overlay-end o) point))
          (throw 'found o)))

      ;; check overlays starting at POINT
      (setq overlay-list (overlays-in point (1+ point)))
      (dolist (o overlay-list)
        (when (and (overlay-get o 'completion-overlay)
                   (= (overlay-start o) point))
          (throw 'found o)))
      )))



(defun completion-overlays-in (start end)
  "Return list of completion overlays between START and END."
  ;; get overlays between START and END
  (let ((o-list (overlays-in start end))
        overlay-list)
    ;; filter overlay list
    (dolist (o o-list)
      (when (overlay-get o 'completion-overlay)
        (push o overlay-list)))
    ;; return the overlay list
    overlay-list))



(defun completion-ui-resolve-old (&optional overlay beg end)
  "Resolve old completions according to the setting of
`completion-how-to-resolve-old-completions'.

Any completion overlay specified by OVERLAY will be left alone,
and completions near the point are dealt with specially, so as
not to modify characters around the point.

If BEG and END are specified, only completions between BEG and
END are resolved. If only one of BEG or END is specified, the
other defaults to `point-max' or `point-min', respectively."
  (cond
   ((and beg (not end)) (setq end (point-max)))
   ((and (not beg) end) (setq beg (point-min))))

  (let (overlay-list)
    ;; ignore OVERLAY and any overlays not between BEG and END (if specified)
    (if beg
	(dolist (o completion--overlay-list)
	  (unless (or (eq o overlay)
		      (< (overlay-end o) beg)
		      (> (overlay-start o) end))
	    (push o overlay-list)))
      (setq overlay-list (delq overlay completion--overlay-list)))


    (save-excursion
      (cond
       ;; leave old completions (but accept zero-length ones)
       ((eq completion-how-to-resolve-old-completions 'leave)
	(mapc (lambda (o)
		(when (= (overlay-start o) (overlay-end o))
		  (completion-accept nil o)))
	      overlay-list))

       ;; accept old completions
       ((eq completion-how-to-resolve-old-completions 'accept)
	(mapc (lambda (o)
		;; if completion is nowhere near point, accept it
		(if (or (> (point) (overlay-end o))
			(< (point)
			   (- (overlay-start o)
			      (if (and (overlay-get o :non-prefix-completion)
				       (overlay-get o 'prefix-replaced))
				  0 (overlay-get o 'prefix-length)))))
		    (completion-accept nil o)
		  ;; otherwise, completion overlaps point, so just delete
		  ;; overlay, effectively accepting whatever is there
		  (completion-ui-delete-overlay o)
		  (completion-ui-deactivate-interfaces o)))
	      overlay-list))

       ;; reject old completions
       ((eq completion-how-to-resolve-old-completions 'reject)
	(mapc (lambda (o)
		;; if completion is nowhere near point, reject it
		(if (or (> (point) (overlay-end o))
			(< (point)
			   (- (overlay-start o)
			      (if (and (overlay-get o :non-prefix-completion)
				       (overlay-get o 'prefix-replaced))
				  0 (overlay-get o 'prefix-length)))))
		    (completion-reject nil o)
		  ;; otherwise, completion overlaps point, so just delete
		  ;; provisional completion characters and overlay
		  (delete-region (overlay-start o) (overlay-end o))
		  (completion-ui-delete-overlay o)
		  (completion-ui-deactivate-interfaces o)))
	      overlay-list))

       ;; ask 'em
       ((eq completion-how-to-resolve-old-completions 'ask)
	(save-excursion
	  (mapc (lambda (o)
		  (goto-char (overlay-end o))
		  ;; FIXME: remove hard-coded face
		  (overlay-put o 'face '(background-color . "red"))
		  (if (y-or-n-p "Accept completion? ")
		      (completion-accept nil o)
		    (completion-reject nil o)))
		overlay-list))))))

  (when (null completion--overlay-list)
    (setq completion-ui--activated nil)))



(defun completion--resolve-current (&optional overlay char syntax)
  "Resolve current completion according to customization settings.

If OVERLAY is supplied, use that instead of trying to find one at
point. The point had better be within OVERLAY or your pet
mosquito will suffer an untimely death.

If CHAR and/or SYNTAX are supplied and `auto-completion-mode' is
enabled, resolve current completion as though the character CHAR
with syntax class SYNTAX was inserted at point (without actually
inserting anything)."

  ;; if no overlay was supplied, try to find one at point
  (unless overlay (setq overlay (completion-ui-overlay-at-point)))
  ;; resolve provisional completions not at point
  (completion-ui-resolve-old overlay)

  ;; if there's a completion at point...
  (when overlay
    (let ((accept-or-reject
	   (completion-ui-get-value-for-source
	    overlay completion-accept-or-reject-by-default))
	  resolve)
      ;; if `auto-completion-mode' is enabled, and at least one of CHAR or
      ;; SYNTAX was supplied, lookup behaviour for CHAR and SYNTAX
      (if (and auto-completion-mode
	       (eq (overlay-get overlay 'auto-completion) 'auto-complete)
	       (or char syntax))
	  (setq resolve (car (auto-completion-lookup-behaviour
			      char syntax overlay)))

	;; otherwise, `completion-accept-or-reject-by-default' determines the
	;; behaviour
	;; note: setting resolve to 'reject causes characters between point
	;;       and end of overlay to be deleted, which accepts longest
	;;       common substring in the case of 'accept-common because of
	;;       where point is positioned
	(cond
	 ((or (eq accept-or-reject 'reject)
	      (eq accept-or-reject 'accept-common))
	  (setq resolve 'reject))
	 (t (setq resolve 'accept))))


      (cond
       ;; if rejecting...
       ((eq resolve 'reject)
        ;; if point is at the start of a completion, reject normally
        (if (= (point) (overlay-start overlay))
            (completion-reject nil overlay)
          ;; otherwise, delete everything after point but keep whatever
          ;; comes before it
          (delete-region (point) (overlay-end overlay))
          (completion-ui-delete-overlay overlay)))

       ;; if accepting, do so
       ((eq resolve 'accept) (completion-accept nil overlay))

       ;; anything else effectively accepts the completion but without
       ;; running accept hooks
       (t (completion-ui-delete-overlay overlay)))
      )))



(defun completion--run-if-condition
  (command variable condition &optional when)
  "Run COMMAND if CONDITION is non-nil.

If WHEN is null or 'instead, run whatever would normally be bound
to the key sequence used to invoke this command if not within a
completion overlay. If WHEN is 'before or 'after, run the normal
binding before or after COMMAND.

VARIABLE should be a symbol that deactivates the keymap in which
COMMAND is bound when its value is set to nil. It is reset at the
end of this function.

Intended to be invoked (directly or indirectly) via a key
sequence in a keymap."

  ;; throw and error if executing recursively
  (when completion--trap-recursion
    (error "Recursive call to `completion--run-if-condition';\
 supplied variable probably doesn't disable keymap"))

  ;; run command if running before, or if running instead and CONDITION
  ;; is non-nil
  (when (or (eq when 'before)
            (and (or (null when) (eq when 'instead))
                 condition))
    (command-execute command))

  ;; run whatever would normally be bound to the key sequence,
  ;; unless running instead and CONDITION is non-nil
  (unless (and (or (null when) (eq when 'instead)) condition)
    (let ((completion--trap-recursion t)
          (restore (symbol-value variable))
          command)
      (set variable nil)
      ;; we add (this-command-keys) to `unread-command-events' and then
      ;; re-read it in order to ensure key sequence translation takes place
      (setq unread-command-events (listify-key-sequence (this-command-keys)))
      (setq command (key-binding (read-key-sequence nil) t))
      (unwind-protect
          (when (commandp command)
            (command-execute command)
            (setq last-command command))  ; doesn't work - clobbered later :(
        (set variable restore))))

  ;; run command if running after
  (when (eq when 'after) (command-execute command)))



(defun completion--run-if-within-overlay
  (command variable &optional when)
  "Run COMMAND if within a completion overlay.

If WHEN is null or 'instead, run whatever would normally be bound
to the key sequence used to invoke this command if not within a
completion overlay. If WHEN is 'before or 'after, run the normal
binding before or after COMMAND.

VARIABLE should be a symbol that deactivates the keymap in which
COMMAND is bound when its value is set to nil. It is reset at the
end of this function.

Intended to be (invoked directly or indirectly) via a key
sequence in a keymap."
  (completion--run-if-condition
   command variable (completion-ui-overlay-at-point) when))



(defun completion-ui-source-at-point ()
  "Return best guess for source at point, according to current
`completion-at-point-functions' or
`auto-completion-at-point-functions'."
  (or (completion-ui-overlay-at-point)
      (pcase (run-hook-wrapped
	      (if auto-completion-mode
		  'auto-completion-at-point-functions
		'completion-at-point-functions)
	      #'completion--capf-wrapper 'all)
	(`(,hookfun . (,start ,end ,collection . ,props))
	 props))))


(defun completion-ui-word-at-point ()
  "Return best guess for word at point, according to current
`completion-at-point-functions' or
`auto-completion-at-point-functions'."
  (pcase (run-hook-wrapped
	  (if auto-completion-mode
	      'auto-completion-at-point-functions
	    'completion-at-point-functions)
	  #'completion--capf-wrapper 'all)
    (`(,hookfun . (,start ,end ,collection . ,props))
     (or (and (plist-get props :word-thing)
	      (thing-at-point (plist-get props :word-thing)))
	 (buffer-substring-no-properties start end)))
    ;; default to `word-at-point'
    (_ (word-at-point))))


(defun completion-beginning-of-word-p (thing &optional point)
  "Return non-nil if POINT is at beginning of a THING.
\(POINT defaults to the point\)."
  (unless point (setq point (point)))
  (save-excursion
    (goto-char point)
    (let (bounds)
      (and (< point (point-max))
           (setq bounds (bounds-of-thing-at-point thing))
           (= point (car bounds))))))


(defun completion-within-word-p (thing &optional point)
  "Return non-nil if POINT is within or at end of a THING.
\(POINT defaults to the point\)."
  (unless point (setq point (point)))
  (save-excursion
    (goto-char point)
    (let (bounds)
      (and (setq bounds (bounds-of-thing-at-point thing))
           (> point (car bounds))
           (< point (cdr bounds))))))


(defun completion-end-of-word-p (thing &optional point)
  "Return non-nil if POINT is at end of a THING.
\(POINT defaults to the point\)"
  (unless point (setq point (point)))
  (save-excursion
    (goto-char point)
    (let (bounds)
      (and (> point (point-min))
           (setq bounds (bounds-of-thing-at-point thing))
           (= point (cdr bounds))))))


(defun completion-posn-at-point-as-event
  (&optional position window dx dy)
  "Return pixel position of top left corner of glyph at POSITION,
relative to top left corner of WINDOW, as a mouse-1 click
event (identical to the event that would be triggered by clicking
mouse button 1 at the top left corner of the glyph).

POSITION and WINDOW default to the position of point in the
selected window.

DX and DY specify optional offsets from the top left of the glyph."

  (unless window (setq window (selected-window)))
  (unless position (setq position (window-point window)))

  (let* ((pos (posn-at-point position window))
         (x-y (posn-x-y pos))
         (edges (window-inside-pixel-edges window))
         (win-x-y (window-pixel-edges window)))
    ;; adjust for window edges
    (setcar (nthcdr 2 pos)
            (cons (+ (car x-y) (car  edges) (- (car win-x-y))  (or dx 0))
                  (+ (cdr x-y) (cadr edges) (- (cadr win-x-y)) (or dy 0))))
    (list 'mouse-1 pos 1)))


(defun completion-window-posn-at-point
  (&optional position window dx dy)
  "Return pixel position of top left of corner glyph at POSITION,
relative to top left corner of WINDOW. Defaults to the position
of point in the selected window.

DX and DY specify optional offsets from the top left of the glyph.

See also `completion-window-inside-posn-at-point' and
`completion-frame-posn-at-point'."

  (unless window (setq window (selected-window)))
  (unless position (setq position (window-point window)))

  (let ((x-y (posn-x-y (posn-at-point position window)))
        (edges (window-inside-pixel-edges window))
        (win-x-y (window-pixel-edges window)))
    (cons (+ (car x-y) (car  edges) (- (car win-x-y)) (or dx 0))
          (+ (cdr x-y) (cadr edges) (- (cadr win-x-y)) (or dy 0)))))


(defun completion-window-inside-posn-at-point
  (&optional position window dx dy)
  "Return pixel position of top left corner of glyph at POSITION,
relative to top left corner of the text area in WINDOW. Defaults
to the position of point in the selected window.

DX and DY specify optional offsets from the top left of the glyph.

See also `completion-window-posn-at-point' and
`completion-frame-posn-at-point'.."

  (unless window (setq window (selected-window)))
  (unless position (setq position (window-point window)))
  (let ((x-y (posn-x-y (posn-at-point position window))))
    (cons (+ (car x-y) (or dx 0)) (+ (cdr x-y) (or dy 0)))))


(defun completion-frame-posn-at-point
  (&optional position window dx dy)
  "Return pixel position of top left corner of glyph at POSITION,
relative to top left corner of frame containing WINDOW. Defaults
to the position of point in the selected window.

DX and DY specify optional offsets from the top left of the glyph.

See also `completion-window-posn-at-point' and
`completion-window-inside-posn-at-point'."

  (unless window (setq window (selected-window)))
  (unless position (setq position (window-point window)))

  (let ((x-y (posn-x-y (posn-at-point position window)))
        (edges (window-inside-pixel-edges window)))
    (cons (+ (car x-y) (car  edges) (or dx 0))
          (+ (cdr x-y) (cadr edges) (or dy 0)))))




;;; ===============================================================
;;;                     Compatibility Hacks

;; prevent bogus compiler warnings
(eval-when-compile
  (defun completion--compat-window-offsets (dummy))
  (defun completion--compat-frame-posn-at-point
    (&optional arg1 arg2 arg3 arg4)))



(unless (fboundp 'posn-at-point)

  (defun completion--compat-frame-posn-at-point
    (&optional position window dx dy)
    "Return pixel position of top left corner of glyph at POSITION,
relative to top left corner of frame containing WINDOW. Defaults
to the position of point in the selected window.

DX and DY specify optional offsets from the top left of the
glyph."
    (unless window (setq window (selected-window)))
    (unless position (setq position (window-point window)))

    ;; get window-relative position in units of characters
    (let* ((x-y (compute-motion (window-start) '(0 . 0)
                                position
                                (cons (window-width) (window-height))
                                (window-width)
                                ; prob. shouldn't be 0
                                (cons (window-hscroll) 0)
                                window))
           (x (nth 1 x-y))
           (y (nth 2 x-y))
           (offset (completion--compat-window-offsets window))
           (restore (mouse-pixel-position))
           pixel-pos)

      ;; move and restore mouse position using position in units of
      ;; characters to get position in pixels
      (set-mouse-position (window-frame window)
                          (+ x (car offset)) (+ y (cdr offset)))
      (setq pixel-pos (cdr (mouse-pixel-position)))
      (set-mouse-pixel-position (car restore) (cadr restore)
                                (cddr restore))

      ;; return pixel position
      (setf (car pixel-pos) (+ (car pixel-pos) (or dx 0))
	    (cdr pixel-pos)
	    (+ (- (cdr pixel-pos)
		  (/ (frame-char-height (window-frame window)) 2))
	       (or dy 0)))
      pixel-pos))



  (defun completion--compat-posn-at-point-as-event
    (&optional position window dx dy)
    "Return pixel position of top left corner of glyph at POSITION,
relative to top left corner of WINDOW, as a mouse-1 click
event (identical to the event that would be triggered by clicking
mouse button 1 at the top left corner of the glyph).

POSITION and WINDOW default to the position of point in the
selected window.

DX and DY specify optional offsets from the top left of the
glyph."

    (unless window (setq window (selected-window)))
    (unless position (setq position (window-point window)))

    ;; get window-relative position in units of characters
    (let* ((x-y (compute-motion (window-start) '(0 . 0)
                                position
                                (cons (window-width) (window-height))
                                (window-width)
                                        ; prob. shouldn't be 0
                                (cons (window-hscroll) 0)
                                window))
           (x (nth 1 x-y))
           (y (nth 2 x-y))
           (offset (completion--compat-window-offsets window))
           (restore (mouse-pixel-position))
           (frame (window-frame window))
           (edges (window-edges window))
           pixel-pos)

      ;; move and restore mouse position using position in units of
      ;; characters to get position in pixels
      (set-mouse-position (window-frame window)
                          (+ x (car offset)) (+ y (cdr offset)))
      (setq pixel-pos (cdr (mouse-pixel-position)))
      (set-mouse-pixel-position (car restore) (cadr restore)
                                (cddr restore))

      ;; convert pixel position from frame-relative to window-relative
      ;; (this is crude and will fail e.g. if using different sized
      ;; fonts)
      (setcar pixel-pos (- (car pixel-pos) 1
                           (* (frame-char-width frame) (car edges))))
      (setcdr pixel-pos (- (cdr pixel-pos) 1
                           (* (frame-char-height frame) (nth 1 edges))
                           (/ (frame-char-height frame) 2)))

      ;; return a fake event containing the position
      (setcar pixel-pos (+ (car pixel-pos) (or dx 0)))
      (setcdr pixel-pos (+ (cdr pixel-pos) (or dy 0)))
      (list 'mouse-1 (list window position pixel-pos))))



  (defun completion--compat-window-posn-at-point
    (&optional position window dx dy)
    "Return pixel position of top left corner of glyph at POSITION,
relative to top left corner of WINDOW. Defaults to the position
of point in the selected window.

DX and DY specify optional offsets from the top left of the
glyph."
    (let ((x-y (completion--compat-frame-posn-at-point
		position window dx dy))
	  (win-x-y (completion--compat-window-offsets window)))
      (cons (+ (car x-y) (car win-x-y))
	    (+ (cdr x-y) (cdr win-x-y)))))



;;; Borrowed from senator.el (I promise I'll give it back when I'm
;;; finished...)

  (defun completion--compat-window-offsets (&optional window)
    "Return offsets of WINDOW relative to WINDOW's frame.
Return a cons cell (XOFFSET . YOFFSET) so the position (X . Y) in
WINDOW is equal to the position ((+ X XOFFSET) .  (+ Y YOFFSET))
in WINDOW'S frame."
    (let* ((window  (or window (selected-window)))
           (e       (window-edges window))
           (left    (nth 0 e))
           (top     (nth 1 e))
           (right   (nth 2 e))
           (bottom  (nth 3 e))
           (x       (+ left (/ (- right left) 2)))
           (y       (+ top  (/ (- bottom top) 2)))
           (wpos    (coordinates-in-window-p (cons x y) window))
           (xoffset 0)
           (yoffset 0))
      (if (consp wpos)
          (let* ((f  (window-frame window))
                 (cy (/ 1.0 (float (frame-char-height f)))))
            (setq xoffset (- x (car wpos))
                  yoffset (float (- y (cdr wpos))))
            ;; If Emacs 21 add to:
            ;; - XOFFSET the WINDOW left margin width.
            ;; - YOFFSET the height of header lines above WINDOW.
            (if (> emacs-major-version 20)
                (progn
                  (setq wpos    (cons (+ left xoffset) 0.0)
                        bottom  (float bottom))
                  (while (< (cdr wpos) bottom)
                    (if (eq (coordinates-in-window-p wpos window)
                            'header-line)
                        (setq yoffset (+ yoffset cy)))
                    (setcdr wpos (+ (cdr wpos) cy)))
                  (setq xoffset
                        (floor (+ xoffset
                                  (or (car (window-margins window))
                                      0))))))
            (setq yoffset (floor yoffset))))
      (cons xoffset yoffset)))


  (defun completion--compat-line-number-at-pos (pos)
    "Return (narrowed) buffer line number at position POS.
\(Defaults to the point.\)"
    (1+ (count-lines (point-min) pos)))


  (defalias 'completion-posn-at-point-as-event
    'completion--compat-posn-at-point-as-event)
  (defalias 'completion-frame-posn-at-point
    'completion--compat-frame-posn-at-point)
  (defalias 'completion-window-posn-at-point
    'completion--compat-window-posn-at-point)
)



;; If the current Emacs version doesn't support overlay keybindings half
;; decently, have to simulate them using the
;; `completion--run-if-within-overlay' hack. So far, no Emacs version supports
;; things properly for zero-length overlays, so we always have to do this!

(when (<= emacs-major-version 21)
  (completion--simulate-overlay-bindings completion-overlay-map completion-map
                                        'completion-ui)
  (completion--simulate-overlay-bindings auto-completion-overlay-map
                                        auto-completion-map
                                        'auto-completion-mode t))




;;; ================================================================
;;;                Load user-interface modules

(provide 'completion-ui)
(require 'completion-ui-dynamic)
(require 'completion-ui-hotkeys)
(require 'completion-ui-echo)
(require 'completion-ui-tooltip)
(require 'completion-ui-popup-tip)
(require 'completion-ui-menu)
(require 'completion-ui-popup-frame)

;; ;; set default auto-show interface to popup-tip
;; (setq completion-auto-show 'completion-show-popup-tip)

;; ;; (Note: this is kinda ugly, but setting the default in the defcustom seems
;; ;; to conflict with refreshing the defcustom in
;; ;; `compeltion-ui-register-interface'. Since Completion-UI is almost
;; ;; invariably loaded before a user's customization settings, theirs will
;; ;; still take precedence.)



;; Local Variables:
;; eval: (font-lock-add-keywords nil '(("(\\(completion-ui-defcustom-per-source\\)\\>[ \t]*\\(\\sw+\\)?" (1 font-lock-keyword-face) (2 font-lock-variable-name-face))))
;; End:

;;; completion-ui.el ends here
