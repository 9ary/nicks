function pr_fg() {
    echo -n "%{[38;5;${1}m%}"
}
pr_nofg='%{[39m%}'
pr_bg='%{[48;5;0m%}'
pr_nobg='%{[49m%}'
pr_bold='%{[1m%}'
pr_nobold='%{[21m%}'
pr_reset='%{[0m%}'

if [[ -n "$SSH_CLIENT" || -n "$SSH2_CLIENT" ]]; then
    pr_host="$(pr_fg 5)@$HOST"
else
    pr_host="$(pr_fg 4)@$HOST"
fi

if [[ $UID -eq 0 ]]; then
    pr_user="$(pr_fg 1)$USERNAME"
else
    pr_user="$(pr_fg 2)$USERNAME"
fi

function pr_pwd() {
    echo -n "${pr_nofg}:"
    # Format pwd like so:
    # - $HOME becomes ~
    # - slashes are colored red
    # - the last component of the path is colored green
    # TODO get rid of Perl?
    pwd | perl -p -e "s|^${HOME}|${pr_nofg}~|;" \
        -e "s|/|$(pr_fg 1)/${pr_nofg}|g;" \
        -e "s|([^/%{}\n]*)\$|$(pr_fg 2)\1${pr_nofg}|"
}

# We enable PROMPT_SUBST and use single quotes here so that the prompt gets expanded at runtime
setopt PROMPT_SUBST
PROMPT='${pr_bg}${pr_user}${pr_host}$(pr_pwd)$(${GITPROMPT_BIN} zsh)%E
${pr_reset}${pr_bold}$ ${pr_reset}'
