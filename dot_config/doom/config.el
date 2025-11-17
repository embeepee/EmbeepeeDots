(setq user-full-name "Markoh Buela Pabellano"
      user-mail-address "markohblpabellano@gmail.com")
(setq doom-theme 'doom-gruvbox)
(setq x-cursor-theme "Kitty")
(setq doom-font (font-spec :family "JetbrainsMono Nerd Font Mono" :size 16 :weight 'bold)
      doom-variable-pitch-font (font-spec :family "JetbrainsMono Nerd Font Mono" :size 16 :weight 'bold)
      doom-big-font (font-spec :family "JetbrainsMono Nerd Font Mono" :size 20 :weight 'Extrabold))

(setq display-line-numbers-type t)
(setq confirm-kill-emacs nil)
(setq bookmark-default-file "~/.config/doom/bookmarks")
(setq tab-bar-new-tab-choice "*doom*")

(after! doom-themes
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t))

(custom-set-faces!
  '(font-lock-comment-face :slant italic)
  '(font-lock-keyword-face :slant italic))

;;; Org Modern & Appearance
;; Set custom fonts for headings
(custom-theme-set-faces! 'doom-gruvbox
  '(org-level-8 :inherit outline-3 :height 1.0)
  '(org-level-7 :inherit outline-3 :height 1.0)
  '(org-level-6 :inherit outline-3 :height 1.1)
  '(org-level-5 :inherit outline-3 :height 1.2)
  '(org-level-4 :inherit outline-3 :height 1.3)
  '(org-level-3 :inherit outline-3 :height 1.4)
  '(org-level-2 :inherit outline-2 :height 1.5)
  '(org-level-1 :inherit outline-1 :height 1.6)
  '(org-document-title :height 1.8 :bold t :underline t))

;; Configure org-modern bullets
(after! org-modern
  ;; Ensure that org-modern is set to *replace* the stars, not just fold them
  (setq org-modern-star 'replace)
  ;; Set the custom bullets for the first few heading levels
  (setq org-modern-replace-stars '("󰓥" "󰣈" "" "✿" "󰴺" "" "󰄛" "󰏒")))

;;; Package Configurations
(use-package! org-auto-tangle
  :defer t
  :hook (org-mode . org-auto-tangle-mode)
  :config
  (setq org-auto-tangle-default t))

(use-package! websocket
  :after org-roam)

(use-package! org-roam-ui
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

;; NOTE: For org-noter, make sure you have (package! org-noter)
;; in your ~/.doom.d/packages.el file and have run `doom sync`.
;; The manual `load-path` is not needed.
(use-package! org-noter
  :after org)

;; NOTE: org-download is included in Doom's org module (+dragndrop flag)
;; This `after!` block ensures your custom settings are loaded.
(after! org-download
  (add-hook 'dired-mode-hook 'org-download-enable)
  (setq org-download-method 'directory
        org-download-image-dir "/run/media/embeepee/HDD_1/myorg/attachments/"
        org-download-heading-lvl nil
        org-download-timestamp "%Y%m%d-%H%M%S_"
        org-image-actual-width 300))

;;; Custom Functions
(defun org-roam-node-insert-immediate (arg &rest args)
  "Insert an org-roam node with immediate finish."
  (interactive "P")
  (let ((args (cons arg args))
        (org-roam-capture-templates (list (append (car org-roam-capture-templates)
                                                  '(:immediate-finish t)))))
    (apply #'org-roam-node-insert args)))

(defun marks/org-download-paste-clipboard (&optional use-default-filename)
  "Paste image from clipboard and prompt for filename."
  (interactive "P")
  (let ((file
         (if (not use-default-filename)
             (read-string (format "Filename [%s]: "
                                  org-download-screenshot-basename)
                          nil nil org-download-screenshot-basename)
           nil)))
    (org-download-clipboard file)))

(defun my/org-roam-filter-by-tag (tag-name)
  "Return a lambda predicate to filter org-roam nodes by TAG-NAME."
  (lambda (node)
    (member tag-name (org-roam-node-tags node))))

(defun my/org-roam-list-notes-by-tag (tag-name)
  "Return a list of file paths for org-roam notes tagged with TAG-NAME."
  (mapcar #'org-roam-node-file
          (seq-filter
           (my/org-roam-filter-by-tag tag-name)
           (org-roam-node-list))))

(defun my/org-roam-refresh-agenda-list ()
  "Refresh `org-agenda-files` to only include notes tagged 'Project'."
  (interactive)
  (setq org-agenda-files (my/org-roam-list-notes-by-tag "Project"))
  (org-agenda-list)
  (message "Agenda reloaded with 'Project' files."))

;;; Core Org Settings
(after! org
  ;; --- Main Setup ---
  (setq org-directory "/run/media/embeepee/HDD_1/myorg/"
        org-default-notes-file (expand-file-name "notes.org" org-directory))

  ;; Point `org-agenda-files` to your main org directory.
  ;; Org will scan it and all subdirectories for .org files.
  (setq org-agenda-files (list org-directory))

  ;; --- Org Roam Setup ---
  (setq org-roam-directory org-directory
        org-roam-completion-everywhere t
        org-roam-db-autosync-mode t
        org-roam-capture-templates
        '(("d" "default" plain "%?"
           :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                            "#+title: ${title}\n#+date: %U\ \n#+filetags: \n#+category:")
           :unnarrowed t)))

  ;; --- Appearance & Behavior ---
  (global-org-modern-mode) ; Enable org-modern globally
  (add-hook 'org-mode-hook #'hl-todo-mode)
  (setq org-ellipsis " ⮷ "
        org-modern-table-vertical 1
        org-modern-table t
        org-hide-emphasis-markers t
        org-pretty-entities t
        org-log-done 'time
        org-startup-folded t
        org-return-follows-link t
        org-use-speed-commands t
        org-table-convert-region-max-lines 20000)

  ;; --- TODO Keywords ---
  (setq org-todo-keywords
        '((sequence
           "TODO(t)"      ; A task that is ready to be tackled
           "NEXT(n)"      ; Task Ready Soon
           "ONPROGRESS(o!)" ; Task is on progress
           "WAITING(w@/!)"  ; Waiting something for the task
           "HOLD(h@/!)"    ; Task on Hold
           "|"            ; Separator
           "DONE(d!)"      ; Task has been completed
           "CANCELLED(c@/!)" ))) ; Task has been cancelled

  ;; --- Priorities ---
  (setq org-priority-faces
        '((?A :foreground "#ff6c6b" :weight bold)
          (?B :foreground "#98be65" :weight bold)
          (?C :foreground "#c678dd" :weight bold)))

  ;; --- Links ---
  (setq org-link-abbrev-alist ; This overwrites the default Doom org-link-abbrev-list
        '(("google" . "http://www.google.com/search?q=")
          ("arch-wiki" . "https://wiki.archlinux.org/index.php/")
          ("ddg" . "https://duckduckgo.com/?q=")
          ("wiki" . "https://en.wikipedia.org/wiki/")))

  ;; --- Agenda Settings ---
  (setq org-deadline-warning-days 30
        org-agenda-span 90
        org-agenda-tags-column 7
        org-agenda-start-day nil
        org-agenda-block-separator 8411
        org-refile-targets '((org-agenda-files :maxlevel . 4)))

  ;; --- Custom Agenda ---
  (setq org-agenda-custom-commands
        '((" " "Agenda"
           ((agenda ""
                    ((org-agenda-span 'day)))
            (todo "TODO"
                  ((org-agenda-overriding-header "Unscheduled tasks")
                   (org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled 'deadline 'timestamp))))
            (todo "TODO"
                  ((org-agenda-overriding-header "Unscheduled project tasks")
                   (org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled 'deadline 'timestamp))))
            (todo "TODO"
                  ((org-agenda-overriding-header "Goals")
                   ;; FIXED PATH: Use your org-roam-directory variable
                   (org-agenda-files (list (expand-file-name "favorites/20230325182525-marks_purpose_goals.org" org-roam-directory))))))))))

(map! :leader
      :desc "Comment Line" "-" #'comment-line)
(map! :leader
      :desc "Load new theme" "h t" #'load-theme)
(map! :leader
      :desc "Org babel tangle" "m B" #'org-babel-tangle)
(map! :leader
      (:prefix ("d" . "org-download")
       :desc "clipboard image" "c" #'marks/org-download-paste-clipboard))

(map! :leader
      (:prefix ("n r" . "org-roam")
       :desc "Graph-UI" "G" #'org-roam-ui-open
       :desc "org-noter" "N" #'org-noter
       :desc "Insert Immediate Node" "I" #'org-roam-node-insert-immediate))

;; Here is a new keybinding for your custom function
(map! :leader
      :desc "Agenda for 'Project' files" "m a p" #'my/org-roam-refresh-agenda-list)
