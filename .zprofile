typeset -U path PATH

[[ -f ~/.localrc ]] && source ~/.localrc

# anyenv（rbenv・nodenv）
if (( $+commands[anyenv] )); then
  eval "$(anyenv init - --no-rehash zsh)"
fi

# golang
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"


