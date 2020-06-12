"$HOME"/.first_run.sh
# Antigen
source /usr/local/bin/antigen.zsh

# Antigen Bundles
antigen use oh-my-zsh
antigen bundle git
antigen bundle pip
antigen bundle lein
antigen bundle command-not-found
antigen bundle zsh-users/zsh-syntax-highlighting
antigen apply

# AutoCompletion
autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit

# AWS CLI AutoCompletion
complete -C '/usr/bin/aws_completer' aws

# fly AutoCompletion
_fly_compl() {
	args=("${COMP_WORDS[@]:1:$COMP_CWORD}")
	local IFS=$'\n'
	COMPREPLY=($(GO_FLAGS_COMPLETION=1 ${COMP_WORDS[0]} "${args[@]}"))
	return 0
}
complete -F _fly_compl fly

# kubectl AutoCompletion
source <(/usr/local/bin/kubectl completion zsh)

# kops AutoCompletion
source <(/usr/local/bin/kops completion zsh)

# cw AutoCompletion
# Using the below method breaks autocompletion
# source <(/usr/local/bin/cw --completion-script-zsh)
_cw_bash_autocomplete() {
    local cur prev opts base
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    opts=$( ${COMP_WORDS[0]} --completion-bash ${COMP_WORDS[@]:1:$COMP_CWORD} )
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}
complete -F _cw_bash_autocomplete cw

# terraform AutoCompletion
complete -o nospace -C /usr/local/bin/terraform terraform

# ZSH History
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

export PATH=$HOME/.local/bin:$PATH

eval "$(starship init zsh)"