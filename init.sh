#!/usr/bin/env bash
set -e

case "$PREFIX" in
    *com.termux*) termux=true ;;
    *) termux=false ;;
esac

if [ "$termux" != true ]; then
    echo "Error: 418.\nI cannot brew your coffee because I'm a teapot."
    exit 1
else
    main
fi

main() {
    pkg install git

    git clone https://github.com/bbooxx/termux-init --depth=1
    cp termux-init/.termux/colors.properties $HOME/.termux
    cp termux-init/.termux/font.ttf $HOME/.termux
    termux-reload-settings

    pkg update -y
    pkg install -y termux-api zsh wget vim-python jq cmake build-essential libjansson automake pkg-config
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    omz theme set avit
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    omz plugin enable zsh-autosuggestions
    git clone https://github.com/bbooxx/vimrc
    ./vimrc/install.sh
    cat >> $HOME/.zshrc <<EOF
HIST_STAMPS="yyyy-mm-dd"
export LANG=en_US.UTF-8

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
export ZSH_AUTOSUGGEST_USE_ASYNC=1
bindkey '^f' autosuggest-accept
bindkey '^h' forward-word
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste accept-line)

export PYTHONBREAKPOINT="pudb.set_trace"
export COLORTERM="truecolor"
export PIPENV_SKIP_LOCK=True

zstyle -e ':completion::*:*:*:hosts' hosts 'reply=($(grep -v "HostName\|\*" ~/.ssh/config | grep Host | cut -d" " -f2))'

_pipenv() {
    eval $(env COMMANDLINE="${words[1,$CURRENT]}" _PIPENV_COMPLETE=complete-zsh pipenv)
}

compdef _pipenv pipenv
EOF
}
