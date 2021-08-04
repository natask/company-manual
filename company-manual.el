;;; company-manual.el --- completely manual company completion completely  -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2021 Natnael Kahssay
;;
;; Author: Natnael Kahssay <https://github.com/natask>
;; Maintainer: Natnael Kahssay <thisnkk@gmail.com>
;; Created: July 31, 2021
;; Modified: July 31, 2021
;; Version: 0.0.1
;; Homepage: https://github.com/savnkk/company-manual
;; Package-Requires: ((emacs "24.3") (company "0.6.13"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;; This
;;
;;  Description
;;  Unhooks company from pre-command-hook and post-command-hook, until the user manually uses company functions (company-complete, helm-company (through company-complete), company-complete-manual-begin, company-complete-common).
;;; Requirements:
(require 'company)
;;; Code:

(defun company-manual-start (&optional args)
  "Prepare company. Pass through ARGS."
  (add-hook 'pre-command-hook 'company-pre-command nil t)
  (add-hook 'post-command-hook 'company-post-command nil t)
  args)

(defun company-manual-end (&optional args)
  "Disassemble company. Pass through ARGS."
  (remove-hook 'pre-command-hook 'company-pre-command t)
  (remove-hook 'post-command-hook 'company-post-command t)
  args)

(defun company-manual-helm-end (&optional args)
  "Disassemble company. Pass through ARGS."
  (company-manual-end)
  (company-abort)
  args)

(defun company-manual-start-fn ()
  "Make company-mode functions execute only manually."
  (remove-hook 'pre-command-hook 'company-pre-command t)
  (remove-hook 'post-command-hook 'company-post-command t)
  (remove-hook 'yas-keymap-disable-hook 'company--active-p t)
  (company-manual-mode-enable))

(defun company-manual-mode-enable ()
  "Enable company manual mode."
  (advice-add 'company-manual-begin :after #'company-manual-start)
  (advice-add 'company-complete-common :after #'company-manual-start)
  (advice-add 'company-complete-selection :before #'company-manual-start)
  (advice-add 'company--insert-candidate :after #'company-manual-end)
  (advice-add 'company-cancel :after #'company-manual-end)
  (advice-add 'helm-company :after #'company-manual-helm-end))

(defun company-manual-mode-disable ()
  "Disable company manual mode."
  (advice-remove 'company-manual-begin #'company-manual-start)
  (advice-remove 'company-complete-common #'company-manual-start)
  (advice-remove 'company-complete-selection #'company-manual-start)
  (advice-remove 'company--insert-candidate #'company-manual-end)
  (advice-remove 'company-cancel #'company-manual-end)
  (advice-remove 'helm-company #'company-manual-helm-end))

(defun company-manual-mode-on ()
  "For use of `global-company-manual-mode'.
Enables `company-manual-mode' where `company-mode' would be enabled through `company-global-modes'."
  (when (and (not (or noninteractive (eq (aref (buffer-name) 0) ?\s)))
             (cond ((eq company-global-modes t)
                    t)
                   ((eq (car-safe company-global-modes) 'not)
                    (not (memq major-mode (cdr company-global-modes))))
                   (t (memq major-mode company-global-modes))))
    (company-manual-mode 1)))

;;;###autoload
(define-minor-mode company-manual-mode
  "`company-manual-mode' to operate `company-mode' manually."
  :lighter nil
  (if company-manual-mode
      (progn
        (add-hook 'company-mode-hook
                  #'company-manual-start-fn nil 't)
        (company-mode))
    (remove-hook 'company-mode-hook
                 #'company-manual-start-fn 't)
    (company-manual-mode-disable)
    (company-mode 0)))

(define-globalized-minor-mode global-company-manual-mode company-manual-mode company-manual-mode-on)

(provide 'company-manual)
;;; company-manual.el ends here
