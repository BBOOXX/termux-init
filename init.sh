#!/usr/bin/env bash
set -e

FMT_RED=$(printf '\033[31m')
FMT_GREEN=$(printf '\033[32m')
FMT_YELLOW=$(printf '\033[33m')
FMT_BLUE=$(printf '\033[34m')
FMT_BOLD=$(printf '\033[1m')
FMT_RESET=$(printf '\033[0m')

case "$PREFIX" in
    *com.termux*) termux=true ;;
    *) termux=false ;;
esac

fmt_text(){
  printf '%s%s%s\n' "${FMT_BOLD}${FMT_GREEN}" "$*" "$FMT_RESET" >&2
}

fmt_error() {
  printf '%sError: %s%s\n' "${FMT_BOLD}${FMT_RED}" "$*" "$FMT_RESET" >&2
}

main() {
    fmt_text "PKG Update ..."
    yes | pkg update

    fmt_text "Install Git ..."
    pkg install git

    fmt_text "Clone termux-init ..."
    git clone https://github.com/bbooxx/termux-init --depth=1

    fmt_text "Set termux color ..."
    cp termux-init/.termux/colors.properties $HOME/.termux

    fmt_text "Set termux font ..."
    cp termux-init/.termux/font.ttf $HOME/.termux

    fmt_text "🪄 Magic!"
    termux-reload-settings

    fmt_text "Install common tools ..."
    pkg install -y termux-api zsh wget vim-python jq cmake build-essential libjansson automake pkg-config

    fmt_text "Install ohmyzsh ..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    fmt_text "Set omz theme ..."
    SET_ZSH_THEME=avit
    sed -i 's/^\s*ZSH_THEME=.*$/ZSH_THEME=\"'$SET_ZSH_THEME'\"/' $HOME/.zshrc

    fmt_text "Clone zsh-autosuggestions ..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    fmt_text "Enable omz plugins ..."
    SET_ZSH_PLUGINS=zsh-autosuggestions
    sed -i 's/\(^plugins=([^)]*\)/\1 '$SET_ZSH_PLUGINS'/' $HOME/.zshrc

    fmt_text "Set default shell ..."
    chsh -s zsh

    fmt_text "Setup .zshrc ..."
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
EOF

    fmt_text "Setup VIM ..."
    git clone https://github.com/bbooxx/vimrc
    ./vimrc/install.sh

}

if [ "$termux" != true ]; then
    fmt_error "418. I cannot brew your coffee because I'm a teapot."
    exit 1
else
    main
fi

