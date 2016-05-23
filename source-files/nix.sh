if [[ -n "$IN_NIX_SHELL" ]]; then
  return
fi
# Include these manpaths so that installed packages have manpages.
export MANPATH=~/.nix-profile/share/man/:$MANPATH
export MANPATH=/run/current-system/sw/share/man:$MANPATH

# This is where python package libs get dropped
export PYTHONPATH=~/.nix-profile/lib/python2.7/site-packages:$PYTHONPATH

alias nsp="nix-shell --pure"

get_nixos_version() {
    local version=$(nixos-version)
    python <<EOF
import re, sys
print(re.match("^(\d+\.\d+)\.", "$version").group(1))
EOF
}

if which nixos-version >/dev/null 2>&1 && [[ -z $USE_NIXPKGS ]]; then
  NIX_CHANNEL_FOLDER=$HOME/.nix-defexpr/channels/nixos
  NIXPKGS=$NIX_CHANNEL_FOLDER
  NIX_CHANNEL_URL=https://nixos.org/channels/nixos-$(get_nixos_version)
  NIX_CHANNEL_NAME=nixos
else
  NIX_CHANNEL_FOLDER=$HOME/.nix-defexpr/channels/nixpkgs
  NIXPKGS=${NIXPKGS:-$NIX_CHANNEL_FOLDER}
  NIX_CHANNEL_URL=https://nixos.org/channels/nixpkgs-unstable
  NIX_CHANNEL_NAME=nixpkgs
fi

nixi () {
    nix-channel-update || true
    nix-env -f $NIXPKGS -iA pkgs.$1
    rm -f ~/.cache/dmenu_run 2>/dev/null 1>/dev/null
}
pixi () {
    nixi "pythonPackages.$1"
}
hixi () {
    nixi "haskellPackages.$1"
}

alias ncg='nix-collect-garbage -d'
pyrm () {
  nix-env -e "python2.7-$1"
}
alias nb='nix-build'
alias lsp='PAGER= nix-env -q'

tmpnix() {
    local chan="$1"
    if [ ! -e ~/.nix-defexpr/channels_root/$chan ]; then
	echo "No such channel: $chan" >&2
        return 1
    fi
    local dir=$(tempdir make)
    cp -r ~/.nix-defexpr/channels_root/$chan/* $dir
    chmod -R +w $dir
    echo $dir
}

update_nixos() {
  sudo sh $SH_CONFIG/scripts/update_nixos.sh "$@"
}

push_nixos_config() (
  cd /etc/nixos
  sudo git push origin master
)

update_channels() {
    nix-channel --update
    nixlist -r >/dev/null
}

export PATH="$HOME/.nix-profile/bin:$PATH"
export NIX_PATH="$HOME/.nix-defexpr/channels:$NIX_PATH"
alias nixpkgs="cd $HOME/nixpkgs"

# Print the hash of the current nixpkgs hash installed to stdout.
current_nixpkgs() {
  local nixpkgs_link=$(readlink -f $NIX_CHANNEL_FOLDER)
  local nixpkgs_folder=$(basename $(dirname $nixpkgs_link))
  echo $nixpkgs_folder | command grep -Po '.*?\K(\w+$)'
}

# Follow the nixpkgs channel url to the latest.
latest_nixpkgs() {
  local res=$(curl -Ls -o /dev/null -w %{url_effective} $NIX_CHANNEL_URL)
  python -c "import re; print(re.match(r'.*?(\w+)/$', '$res').group(1))"
}

nix-channel-update() {
  if [ $(latest_nixpkgs) != $(current_nixpkgs) ]; then
    nix-channel --update
  else
    echo "Already up-to-date at $(current_nixpkgs)"
  fi
}

alias ncg='nix-collect-garbage -d'
pyrm() {
  nix-env -e "python2.7-$1"
}
alias nb='nix-build'
alias lsp='PAGER= nix-env -q'
nixrm() {
    lsp | egrep $1 | xargs nix-env -e
}
alias nse='nix-shell --pure -A env'

# Print all of the result symlinks that are floating around on the hard drive.
nix_result_links() {
  nix-store --gc --print-roots | awk '{print $1}' | grep result
}

rm_nix_result_links() {
  nix_result_links | xargs rm
}

findnix () {
    if [[ $# < 1 ]]; then
        echo "Need at least one argument." >&2
        return 1
    fi
    command="grep -r '$1' $NIXPKGS"
    shift
    for arg in $@; do
        command+=" | grep '$arg'"
    done
    eval "$command"
}
