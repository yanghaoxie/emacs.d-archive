;; settings

;; replace "yes" and "no" by "y" and "n"
(defalias 'yes-or-no-p 'y-or-n-p)
;; save desktop
(desktop-save-mode t)
(setq desktop-restore-eager 5
      desktop-lazy-verbose nil)
;;display-time-mode
(setq display-time-24hr-format t
      display-time-default-load-average nil
      display-time-day-and-date t)
;; (display-time-mode t)
;;
(column-number-mode t)
(size-indication-mode t)
(blink-cursor-mode 0)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
;; auto save
(auto-save-visited-mode t)
(setq  auto-save-default t
       auto-save-timeout 20
       auto-save-interval 20)
(defvar emacs-autosave-directory
  (concat user-emacs-directory "autosaves/"))

(unless (file-exists-p emacs-autosave-directory)
  (make-directory emacs-autosave-directory))

(setq auto-save-file-name-transforms
      `((".*" ,emacs-autosave-directory t)))
;; backup
(setq backup-directory-alist '(("." . "~/.emacs.d/backups"))
      kept-new-versions 10
      kept-old-versions 0
      delete-old-versions t
      backup-by-copying t
      vc-make-backup-files t)
;; font
(set-face-attribute 'default nil :font "Hack")
(global-hl-line-mode t)
;; text-scale
(defhydra hydra-text-scale ()
  "text-scale"
  ("i" text-scale-increase "in")
  ("o" text-scale-decrease "out")
  ("0" (text-scale-set 0) "resert")
  ("q" nil "quit"))
(my/leader-keys
  "xz" 'hydra-text-scale/body)

;; window-scale
(defhydra hydra-window-scale ()
  "window-scale"
  ("i" (lambda () (interactive) (enlarge-window-horizontally 10)) "in")
  ("o" (lambda () (interactive) (shrink-window-horizontally 10)) "out")
  ("I" (lambda () (interactive) (enlarge-window 5)) "IN")
  ("O" (lambda () (interactive) (shrink-window 5)) "OUT")
  ("r" balance-windows "resert")
  ("q" nil "quit"))
(my/leader-keys
  "wz" 'hydra-window-scale/body)

;; build-in modes
(use-package eldoc
  :defer t
  :diminish eldoc-mode
  :init
  (progn
    (add-hook 'emacs-lisp-mode-hook 'eldoc-mode)
    (add-hook 'lisp-interaction-mode-hook 'eldoc-mode)
    (add-hook 'ielm-mode-hook 'eldoc-mode)
    (add-hook 'eval-expression-minibuffer-setup-hook 'eldoc-mode)))

(use-package electric-pair-mode
  :defer t
  :init
  (progn
    (electric-pair-mode t)))

(use-package display-line-numbers
  :if (version<= "26.1" emacs-version)
  :init
  (setq display-line-numbers-type 'visual)
  (global-display-line-numbers-mode 1)
  (defun my/toggle-line-numbers-type ()
    (interactive)
    (if (eq display-line-numbers t)
	(progn
	  (setq display-line-numbers 'visual)
	  (message "show visual line numbers"))
      (progn
	(setq display-line-numbers t)
	(message "Show absolute line numbers"))))
  (my/leader-keys
    "tl" 'my/toggle-line-numbers-type))

(use-package prettify-symbols-mode
  :defer t
  :init
  (setq prettify-symbols-unprettify-at-point 'right-edge)
  (global-prettify-symbols-mode))

(use-package recentf
  :commands recentf-mode
  :config
  (progn
    (setq recentf-max-saved-items 25)
    (recentf-mode 1)))

(use-package autorevert
  :defer t
  :diminish auto-revert-mode
  :init
  (setq auto-revert-interval 0.5)
  (add-hook 'pdf-view-mode-hook 'auto-revert-mode)
  )

(use-package server
  :commands server-running-p
  :init
  (server-mode 1)
  :config
  (unless (server-running-p)
    (server-start)))

(use-package winner
  :init
  (my/leader-keys
    "wu" 'winner-undo
    "wU" 'winner-redo)
  :config
  (winner-mode))

(use-package savehist
  :defer 5
  :config
  (progn
    (setq savehist-autosave-interval 10)
    (savehist-mode 1)
    ;; save shell history https://oleksandrmanzyuk.wordpress.com/2011/10/23/a-persistent-command-history-in-emacs/
    (defun comint-write-history-on-exit (process event)
      "Write comint history of PROCESS when EVENT happened to a file specified in buffer local var 'comint-input-ring-file-name' (defined in turn-on-comint-history)."
      (comint-write-input-ring)
      (let ((buf (process-buffer process)))
	(when (buffer-live-p buf)
	  (with-current-buffer buf
	    (insert (format "\nProcess %s %s" process event))))))
    (defun turn-on-comint-history ()
      "Setup comint history.
When comint process started set buffer local var
'comint-input-ring-file-name', so that a file name is specified to write
and read from comint history.

That 'comint-input-ring-file-name' is buffer local is determined by the
4th argument to 'add-hook' below.  And localness is important, because
otherwise 'comint-write-input-ring' will find mentioned var nil."
      (let ((process (get-buffer-process (current-buffer))))
	(when process
	  (setq comint-input-ring-file-name
		(format "~/.emacs.d/inferior-%s-history"
			(process-name process)))
	  (comint-read-input-ring)
	  (set-process-sentinel process
				#'comint-write-history-on-exit))))
    (defun mapc-buffers (fn)
      (mapc (lambda (buffer)
	      (with-current-buffer buffer
		(funcall fn)))
	    (buffer-list)))
    (defun comint-write-input-ring-all-buffers ()
      (mapc-buffers 'comint-write-input-ring))
    (add-hook 'inferior-python-mode-hook 'turn-on-comint-history nil nil)
    (add-hook 'kill-buffer-hook 'comint-write-input-ring)
    (add-hook 'kill-emacs-hook 'comint-write-input-ring-all-buffers)))
;; key bindings
(my/all-states-keys
  "C-e" 'move-end-of-line)

(my/leader-keys
  "!" 'shell-command)

;; applications --------------------------------------------------------------
(my/leader-keys
  "au" 'undo-tree-visualize
  "ac" 'calendar
  "at" 'my/show-current-time)
;; buffer --------------------------------------------------------------------
(my/leader-keys
  "bd" 'my/kill-this-buffer
  "bn" 'next-buffer
  "bp" 'previous-buffer
  "br" 'revert-buffer
  "TAB" 'my/alternate-buffer
  "bx" 'kill-buffer-and-window
  )
;; file ----------------------------------------------------------------------
(my/leader-keys
  "fs" 'save-buffer)
;; frame
(my/leader-keys
  "Fd" 'delete-frame
  "Fn" 'make-frame
  "Fo" 'other-frame)
;; help ----------------------------------------------------------------------
(my/leader-keys
  "hdb" 'describe-bindings
  "hdc" 'describe-char
  "hdf" 'describe-function
  "hdk" 'describe-key
  "hdm" 'describe-mode
  "hdp" 'describe-package
  "hdt" 'describe-theme
  "hdv" 'describe-variable
  "hn"  'view-emacs-news
  )
;; quit ---------------------------------------------------------------------
(my/leader-keys
  "qs" 'save-buffers-kill-emacs
  "qr" 'restart-emacs
  "qd" 'my/restart-emacs-debug-init)
;; window -------------------------------------------------------------------
(my/leader-keys
  "wv" 'split-window-right
  "wV" 'split-window-right-and-focus
  "ws" 'split-window-below
  "wS" 'split-window-below-and-focus
  "w=" 'balance-windows-area
  "wb" 'balance-windows
  "wm" 'my/toggle-maximize-buffer
  "wd" 'delete-window)
;; text
(my/leader-keys
  "xp" 'clipboard-yank
  "xy" 'clipboard-kill-ring-save
  "xc" 'clipboard-kill-region)
;; frequently accessed files
(defhydra hydra-frequently-accessed-files (:exit t)
  "files"
  ("o" (lambda () (interactive) (find-file "~/Dropbox/document/org/main.org")) "main.org")
  ("n" (lambda () (interactive) (find-file "~/Dropbox/document/org/references/ref-notes.org")) "ref-noter.org")
  ("i" (lambda () (interactive) (find-file "~/.emacs.d/init.el")) "init.el")
  ("l" (lambda () (interactive) (find-file "~/Dropbox/document/ledger/ledger.ledger")) "ledger.ledger")
  ("d" (lambda () (interactive) (find-file "~/.dotfiles/README.md")) "dotfiles")
  ("M-d" (lambda () (interactive) (deer "~/Dropbox/")) "Dropbox")
  ("c" (lambda () (interactive) (find-file "~/Dropbox/document/org/capture/capture.org")) "capture.org")
  ("q" nil "quit"))
(my/leader-keys
  "fo" 'hydra-frequently-accessed-files/body)
(provide 'init-defaults)
