zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _ignored
zstyle ':completion:*' group-name ''
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
# Fancy matcher:
# - behaves like vim's smartcase
# - matches - and _ agnostically
# - fuzzy matching (priority is given to exact matches)
zstyle ':completion:*' matcher-list \
    'm:{[:lower:]-_}={[:upper:]_-}' \
    'r:[[:graph:]]||[[:graph:]]=** r:|=* m:{[:lower:]-_}={[:upper:]_-}'
zstyle ':completion:*' menu select=1
zstyle ':completion:*' original true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.*' insert-sections   true
zstyle ':completion:*' verbose true
zstyle ':completion:*' rehash true
autoload -Uz compinit
compinit
