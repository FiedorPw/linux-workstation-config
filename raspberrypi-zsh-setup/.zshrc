# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

DISABLE_AUTO_TITLE="true"
COMPLETION_WAITING_DOTS="true"

plugins=(
    zsh-autosuggestions
    git
    zsh-syntax-highlighting
    dirhistory
)
source $ZSH/oh-my-zsh.sh

alias sudo='sudo '
alias ll='ls -lah'
alias la='ls -lah'

export PATH="$HOME/.local/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
