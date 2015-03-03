;;; helm-features -*- lexical-binding: t; coding: utf-8; -*-

;;; Code:

(require 'cl-lib)
(require 'seq)

(defvar helm-features-candidates nil)

(cl-defun helm-features-init ()
  (setq helm-features-candidates
        (helm-features-create-candidates)))

(cl-defun helm-features-create-candidates ()
  (seq-map
   (lambda (f)
     (cons (helm-stringify f)
           f))
   features))

(defclass helm-features-source (helm-source-sync)
  ((init :initform helm-features-init)
   (candidates :initform helm-features-candidates)
   (action :initform
           (helm-make-actions
            "Open library file" 'helm-features-action-open
            "Unload feature" 'helm-features-action-unload))))

(cl-defun helm-features-action-open (candidate)
  (cl-letf ((library-file (find-library-name
                           (helm-stringify candidate))))
    (switch-to-buffer
     (find-file
      library-file))))

(cl-defun helm-features-action-unload (candidate)
  (cl-letf ((library candidate))
    (unload-feature library)))

(defvar helm-source-features
  (helm-make-source "Features"
      'helm-features-source))

;;;###autoload
(cl-defun helm-features ()
  "helm source for loaded features"
  (interactive)
  (helm :sources '(helm-source-features)
        :buffer "*helm features*"
        :prompt "Feature: "))

(provide 'helm-features)

;;; helm-features.el ends here
