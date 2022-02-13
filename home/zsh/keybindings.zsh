function terminfo-bindkey() {
    [[ -n "${terminfo[$1]}" ]] && bindkey "${terminfo[$1]}" $2
}
terminfo-bindkey khome beginning-of-line
bindkey '[H' beginning-of-line
terminfo-bindkey kend end-of-line
bindkey '[F' end-of-line
# Insert
terminfo-bindkey kich1 overwrite-mode
# Delete
terminfo-bindkey kdch1 delete-char
# Up
terminfo-bindkey kcuu1 history-substring-search-up
bindkey '[A' history-substring-search-up
# Down
terminfo-bindkey kcud1 history-substring-search-down
bindkey '[B' history-substring-search-down
bindkey  history-substring-search-up
bindkey  history-substring-search-down
# shift+enter in foot
bindkey '[27;2;13~' accept-line
# ctrl+enter in foot
bindkey '[27;5;13~' accept-line
unset -f terminfo-bindkey

# Foreground suspended program
# Taken from grml
function grml-zsh-fg () {
    if (( ${#jobstates} )); then
        zle .push-input
        [[ -o hist_ignore_space ]] && BUFFER=' ' || BUFFER=''
        BUFFER="${BUFFER}fg"
        zle .accept-line
    fi
}
zle -N grml-zsh-fg
bindkey  grml-zsh-fg
