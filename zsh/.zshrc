# Powerlevel10k instant prompt (must stay near top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Oh My Zsh ───────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
DISABLE_AUTO_TITLE="true"
COMPLETION_WAITING_DOTS="true"

plugins=(
    fzf-tab
    zsh-autosuggestions
    git
    zsh-syntax-highlighting
    web-search
    colorize
    copyfile
    dirhistory
)
source $ZSH/oh-my-zsh.sh

# ── Terminal title ──────────────────────────────────────────
# Show running command in title, fall back to "zsh"
precmd()  { print -Pn "\e]0;${LAST_CMD:-zsh}\a"; }
preexec() { LAST_CMD="$1"; print -Pn "\e]0;$1\a" }

# ── Environment ─────────────────────────────────────────────
export EDITOR=nvim
export VISUAL=nvim
export AWS_REGION=eu-central-1

export PATH="$HOME/.local/bin:$HOME/Projects/scripts:$HOME/.opam/default/bin:$HOME/.dotnet:$HOME/.local/share/gem/ruby/3.3.0/bin:$HOME/.bun/bin:$HOME/.opencode/bin:$HOME/.lmstudio/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"

# ── Aliases ─────────────────────────────────────────────────
# ls -> eza
unalias ls ll la l lsa 2>/dev/null
alias ls='eza --icons --group-directories-first'
alias ll='eza -lah --icons --git --group-directories-first'
alias la='eza -lah --icons --group-directories-first'
alias l='eza -lah --icons --git --group-directories-first'

alias cat='bat'
alias vim='nvim'
alias python='uv run python'
alias py='python'
alias sudo='sudo '
alias sc='systemctl'
alias o='open'
alias op='open ./'
alias p='grc ifconfig'
alias ff='fastfetch'
alias wez='wezterm'
alias nf='neofetch'
alias k='claude --dangerously-skip-permissions'
alias kk='ANTHROPIC_BASE_URL=http://100.89.86.29:11434 ANTHROPIC_AUTH_TOKEN=ollama ANTHROPIC_API_KEY="" ANTHROPIC_DEFAULT_SONNET_MODEL=qwen3.5:27b claude --dangerously-skip-permissions'
alias wonsz='python'
alias wonsz3='python3'
alias msf='sudo service postgresql start && msfconsole'

# ── GRC (colorizer) ────────────────────────────────────────
[[ -s "/etc/grc.zsh" ]] && source /etc/grc.zsh

# ── GNOME icon theme (suppress output for p10k) ────────────
gsettings set org.gnome.desktop.interface icon-theme 'kora' 2>/dev/null &!

# ── Copilot inline suggest (Ctrl+F) ────────────────────────
copilot_cmd_only() {
  local out
  out="$(copilot -p "Return ONLY a single shell command. You can add explanations inline with # after command. The output will be cut co don't use any multi line wrappers like '''bash or anything that ends with \n:  Task: $BUFFER" 2>/dev/null \
    | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  if [[ -n "$out" ]]; then
    BUFFER="$out"
    CURSOR=${#BUFFER}
  fi
  zle redisplay
}
zle -N copilot_cmd_only
bindkey '^f' copilot_cmd_only

# ── NVM ─────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ── p10k ────────────────────────────────────────────────────
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
