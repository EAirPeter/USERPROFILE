eval "$(/opt/homebrew/bin/brew shellenv)"

alias ls='ls --color'
alias ll='ls --color -l'

export PS1="%F{8}%n@%m%f %F{11}%~%f %(0?.%F{2}.%F{1})%(!.#.$)%f "
