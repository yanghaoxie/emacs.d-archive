(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:complete-on-dot t)
(setq jedi:server-command '("~/.emacs.d/elpa-24.5/jedi-core-20170121.610/jediepcserver.py"))
(provide 'init-jedi)
