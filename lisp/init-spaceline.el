(use-package spaceline
    :ensure t
    :init
    (progn
      (setq spaceline-highlight-face-func 'spaceline-highlight-face-evil-state
	    powerline-default-separator 'slant
	    anzu-cons-mode-line-p nil
	    spaceline-minor-modes-p nil
	    spaceline-purpose-p t
	    spaceline-purpose-hide-if-not-dedicated t
	    spaceline-buffer-encoding-abbrev-p nil
	    spaceline-window-numbers-unicode t
	    spaceline-workspace-numbers-unicode t
	    spaceline-input-method-p nil))
    :config
    (spaceline-spacemacs-theme)
    (spaceline-compile))
(provide 'init-spaceline)
