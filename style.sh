# Show the exit status, if it's non-zero.
SHOW_STATUS="\$(stat=\$?; if [[ \$stat != 0 ]]; then echo \"\[\033[01;37m\]\$stat\" \"\[\033[01;31m\];( \"; fi)"

# Show the current git branch, if we're on one.
SHOW_GIT="\$(git status >/dev/null 2>&1 && echo \" (git:\$(git rev-parse --abbrev-ref HEAD))\")"

# Show the current directory, truncated to two directories. (WIP)
SHOW_DIR="\$(cur=\$(pwd | sed \"s|\$HOME|~|\"); echo $cur)"

# Will show up if we're in nix shell
SHOW_NIX_SHELL="\$([[ -n \"\$IN_NIX_SHELL\" ]] && echo '(nix-shell) ')"

export PS1="${SHOW_STATUS}${SHOW_NIX_SHELL}$(if [[ ${EUID} == 0 ]]; then echo '\[\033[01;31m\]\h'; else echo '\[\033[01;32m\]\u@\h'; fi)\[\033[01;34m\]${SHOW_GIT} \$(basename \$PWD)>\[\033[00m\] "
