;;; revive-mode-config.el --- Configuration for revive-mode,
;;; so that it can work smoothly with Emacs
;;; Author: Vedang Manerikar
;;; Created on: 16 Jan 2012
;;; Time-stamp: "2012-01-16 22:21:56 vedang"
;;; Copyright (c) 2012 Vedang Manerikar <vedang.manerikar@gmail.com>

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the Do What The Fuck You Want to
;; Public License, Version 2, which is included with this distribution.
;; See the file LICENSE.txt

;;; Commentary:
;; To use revive mode, put the following lines in your .emacs:
;; (define-key ctl-x-map "S" 'emacs-save-layout)
;; (define-key ctl-x-map "F" 'emacs-load-layout)

;; Now, pressing `C-x S` should save the current frame configuration,
;; and pressing `C-x F` should load the last saved frame configuration.

;; Further, if you want to save Emacs' configuration every time you kill emacs,
;; add the following line to your .emacs:
;; (add-hook 'kill-emacs-hook 'emacs-save-layout)

;;; Code:


(autoload 'restore-window-configuration "revive")
(autoload 'current-window-configuration-printable "revive")


;;; From:
;;; http://stormcoders.blogspot.com/2007/11/restoring-emacs-layout.html
(defgroup revive nil
  "Persist windows layout in a file"
  :group 'convenience)

(defcustom revive-directory "."
  "directory to dump the layout description"
  :type 'string
  :group 'revive)

(defcustom revive-filename ".layout"
  "name of the file with the layout description"
  :type 'string
  :group 'revive)

(defun revive-config ()
  (mapconcat 'identity (list revive-directory revive-filename) "/"))

;;;###autoload
(defun emacs-save-layout ()
  "save the frame and window layout to (revive-config). Requires revive.el."
  (interactive)
  (let ((out-name (revive-config))
        (buff-names (mapcar (lambda (b) (buffer-file-name b))
                                (buffer-list)))
        (frames-cfg (mapcar (lambda (f) (progn
                                  (select-frame f)
                                  (current-window-configuration-printable)))
                         (frame-list))))
    (write-region
     (with-output-to-string
       (prin1 (cons
               (remove-if nil buff-names)
               frames-cfg)))
     nil out-name)))


;;;###autoload
(defun emacs-load-layout ()
  "Load the layout saved by emacs-save-layout aka (revive-config). Requires revive.el."
  (interactive)
  (let* ((in-name (revive-config))
         (config-count 0)
         (frames (frame-list))
         (configs nil)
         (frame-count (length frames))
         (buffs nil))
    (with-temp-buffer
      (insert-file-contents-literally in-name)
      (setq buffs (read (current-buffer)))
      (setq configs (rest buffs))
      (setq buffs (first buffs)))
    (dolist (b buffs)
      (find-file-noselect b)
      (message "Loading buffer %s" b))
    (setq config-count (length configs))
    (message "Config count is %s" config-count)
    (unless (>= frame-count config-count)
      (dotimes (i (- config-count frame-count))
        (make-frame))
      (setq frames (frame-list))
      (setq frame-count (length frames))
      (message "frame-count is %s" frame-count))
    (defun it (lconfigs lframes)
      (when (and lconfigs lframes)
        (select-frame (first lframes))
        (restore-window-configuration (first lconfigs))
        (it (rest lconfigs) (rest lframes))))
    (it configs frames)))


(provide 'revive-mode-config)
