# different behaviour inside emacs
# courtesy of elken
if [ "${INSIDE_EMACS}" = "vterm" ]; then
  vterm_printf() {
    if [ -n "$TMUX" ]; then
      # Tell tmux to pass the escape sequences through
      printf "\ePtmux;\e\e]%s\007\e\\" "$1"
    elif [ "${TERM%%-*}" = "screen" ]; then
      # GNU screen (screen, screen-256color, screen-256color-bce)
      printf "\eP\e]%s\007\e\\" "$1"
    else
      printf "\e]%s\e\\" "$1"
    fi
  }

  vterm_cmd() {
    local vterm_elisp
    vterm_elisp=""
    while [ $# -gt 0 ]; do
      vterm_elisp="${vterm_elisp}"\"${${1//\\/'\\\\'}//\"/\\\"}\"
      shift
    done
    vterm_printf "51;E$vterm_elisp"
  }

  find_file() {
    vterm_cmd find-file "$(realpath -mq "${@:-.}")"
  }

  woman () {
    vterm_cmd woman $1
  }

  # FIXME invoking dired or dirvish in vterm currently hang emacs
  dired () {
    local patharg
    patharg="$(realpath -eq "${@:-.}")"

    if [ $? -eq 1 ]; then
       printf "No such file or directory\n"
       return 1
    fi

    vterm_cmd dired ${patharg}
  }

  dirvish () {
    local patharg
    patharg="$(realpath -eq "${@:-.}")"

    if [ $? -eq 1 ]; then
       printf "No such file or directory\n"
       return 1
    fi

    if [ -d "${patharg}" ]; then
       patharg="${patharg}/"
    fi

    vterm_cmd dirvish ${patharg}
  }

  alias find-file='find_file'
  alias ff='find_file'
  alias emacs='find_file'
  alias vim='find_file'
  alias nvim='find_file'
  alias clear='vterm_printf "51;Evterm-clear-scrollback";tput clear'
  alias man='woman'
  alias fm='dired'
  alias yazi='dirvish'
fi

# Don't try to open EDITORs inside emacs
if [ -n "${INSIDE_EMACS}" ]; then
  export EDITOR="false"
fi
