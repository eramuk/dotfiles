[[ -v WSLENV ]] && export SHELL=/bin/zsh

[ -f ~/.localrc ] && source ~/.localrc

alias ls='ls --color=auto'
alias ll='ls -la'
alias less='less -i -R'

autoload -U compinit
compinit

# ls の色
export LSCOLORS=gxfxcxdxbxegedabagacag
export LS_COLORS='ow=1;34'

# 補完候補もLS_COLORSに合わせる
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# completion
zstyle ':completion:*:default' menu select=1
setopt magic_equal_subst

# git prompt
function __rprompt-git-current-branch__ {
  local branch_name st branch_status

  if ! git rev-parse 2>/dev/null; then
    return
  fi

  branch_name=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
  st=`git status 2> /dev/null`
  if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
    # 全てcommitされてクリーンな状態
    branch_status="%F{green}($branch_name)%f"
  elif [[ -n `echo "$st" | grep "^Untracked files"` ]]; then
    # gitに管理されていないファイルがある状態
    branch_status="%F{red}($branch_name ?)%f"
  elif [[ -n `echo "$st" | grep "^Changes not staged for commit"` ]]; then
    # git addされていないファイルがある状態
    branch_status="%F{red}($branch_name *)%f"
  elif [[ -n `echo "$st" | grep "^Changes to be committed"` ]]; then
    # git commitされていないファイルがある状態
    branch_status="%F{yellow}($branch_name +)%f"
  elif [[ -n `echo "$st" | grep "^rebase in progress"` ]]; then
    # コンフリクトが起こった状態
    echo "%F{red}($branch_name +)%f"
    return
  else
    # 上記以外の状態の場合は青色で表示させる
    branch_status="%F{blue}($branch_name)%f"
  fi
  # ブランチ名を色付きで表示する
  echo " ${branch_status}"
}
# プロンプトが表示されるたびにプロンプト文字列を評価、置換する
setopt prompt_subst
# プロンプトの右側(RPROMPT)にメソッドの結果を表示させる
PROMPT='%* %c`__rprompt-git-current-branch__` $ '

# git completion
case ${OSTYPE} in
  # Mac
  darwin*)
    fpath=($(brew --prefix)/share/zsh/site-functions $fpath)
    autoload -U compinit
    compinit -u
    ;;
esac

# history
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=50000
export SAVEHIST=50000
setopt hist_ignore_dups
setopt EXTENDED_HISTORY

# enable comment in command line
setopt interactivecomments

# coreutils
export PATH=/usr/local/opt/coreutils/libexec/gnubin:${PATH}
export MANPATH=/usr/local/opt/coreutils/libexec/gnuman:${MANPATH}

# anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init - --no-rehash zsh)"

# direnv
export EDITOR=vim
eval "$(direnv hook zsh)"

# nodebrew
export PATH="$HOME/.nodebrew/current/bin:$PATH"

# mysql
export PATH="/usr/local/opt/mysql@5.7/bin/:$PATH"

# golang
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
__fzf_history__() {
  BUFFER=$(history -n -r 1 | fzf +s -e --reverse --border --height 30% --tiebreak=index -q "$LBUFFER")
  CURSOR=$#BUFFER
  zle reset-prompt
}
zle -N __fzf_history__
bindkey '^r' __fzf_history__

# tmux
if [[ ! -n $TMUX && $- == *l* ]]; then
  # get the IDs
  ID="`tmux list-sessions 2>/dev/null`"
  if [[ -z "$ID" ]]; then
    tmux new-session
  fi
  create_new_session="Create New Session"
  ID="$ID\n${create_new_session}:"
  ID="`echo $ID | fzf +s --reverse`"
  ID="`echo $ID | cut -d: -f1`"
  if [[ "$ID" = "${create_new_session}" ]]; then
    tmux new-session
  elif [[ -n "$ID" ]]; then
    tmux attach-session -t "$ID"
  else
    :  # Start terminal normally
  fi
fi

# C-s のスクリーンロックを無効化
if [[ -t 0 ]]; then
  stty stop undef
  stty start undef
fi

rehash

