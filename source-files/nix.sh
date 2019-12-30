if [[ -n "$IN_NIX_SHELL" ]]; then
  return
fi
# Include these manpaths so that installed packages have manpages.
export MANPATH=~/.nix-profile/share/man/:$MANPATH
export MANPATH=/run/current-system/sw/share/man:$MANPATH

# This is where python package libs get dropped
# export PYTHONPATH=~/.nix-profile/lib/python2.7/site-packages:$PYTHONPATH

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
elif [[ -e $HOME/.nix-defexpr ]]; then
  NIX_CHANNEL_FOLDER=$HOME/.nix-defexpr/channels/nixpkgs
  NIXPKGS=${NIXPKGS:-$NIX_CHANNEL_FOLDER}
  NIX_CHANNEL_URL=https://nixos.org/channels/nixpkgs-unstable
  NIX_CHANNEL_NAME=nixpkgs
elif [[ -d $NSROOT/quill/ns_nix/nixpkgs ]]; then
  unset NIX_CHANNEL_FOLDER NIX_CHANNEL_URL NIX_CHANNEL_NAME
  NIXPKGS=$NSROOT/quill/ns_nix/nixpkgs
elif [[ -d $HOME/nixpkgs ]]; then
  unset NIX_CHANNEL_FOLDER
  NIX_CHANNEL_URL=https://nixos.org/channels/nixpkgs-unstable
  NIX_CHANNEL_NAME=nixpkgs
  NIXPKGS=$HOME/nixpkgs
fi

update_nixpkgs() {
    cd $NIXPKGS
    git pull channels $(nixpkgs-unstable)
}

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

ncg() {
  nix-collect-garbage -d || ncg
}
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

update_nixpkgs() (
  set -eo pipefail
  cd ~/nixpkgs
  if ! git remote -v | grep -q nixpkgs-channels; then
    echo "No remote for nixpkgs channels, stopping here"
    exit 1
  fi
  cur=$(git rev-parse --abbrev-ref HEAD)
  if [[ "$cur" != nixpkgs-unstable ]]; then
    echo "current branch is $cur, must be on nixpkgs-unstable to update"
    exit 1
  fi

  remote=$(git remote -v | grep nixpkgs-channels | awk '{print $1}' | sort | uniq)
  git pull $remote nixpkgs-unstable
)

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
export NIX_PATH=$HOME
alias nixpkgs="cd $HOME/nixpkgs"

# Print the hash of the current nixpkgs hash installed to stdout.
current_nixpkgs() {
  if [[ -n $NIX_CHANNEL_FOLDER ]]; then
    local nixpkgs_link=$(readlink -f $NIX_CHANNEL_FOLDER)
    local nixpkgs_folder=$(basename $(dirname $nixpkgs_link))
    echo $nixpkgs_folder | command grep -Po '.*?\K(\w+$)'
  else
    (
      cd $NIXPKGS
      commit=$(git rev-parse HEAD)
      echo "${commit:0:7}"
    )
  fi
}

# Follow the nixpkgs channel url to the latest.
latest_nixpkgs() {
  local channel=$1
  if [[ -z $channel ]]; then
    local url=$NIX_CHANNEL_URL
  else
    local url=$(nix-channel --list | grep "^$channel " | awk '{print $2}')
  fi
  [[ -n $url ]] || { echo "Invalid channel '$channel'" >&2; return; }
  local res=$(curl -Ls -o /dev/null -w %{url_effective} $url)
  echo $res >&2
  python -c "import re; print(re.match(r'.*?(\w+)/?$', '$res').group(1))"
}

nix-channel-update() {
  if [[ $(latest_nixpkgs) != $(current_nixpkgs) ]]; then
    if [[ -z $NIX_CHANNEL_FOLDER ]]; then
      (
        cd $NIXPKGS
        git fetch
        git checkout $(latest_nixpkgs)
      )
    else
      nix-channel --update
    fi
  else
    echo "Already up-to-date at $(current_nixpkgs)"
  fi
}

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
  links=$(nix_result_links)
  if [[ -n $links ]]; then
    rm $links
  else
    echo "No symlinks to remove."
  fi
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

build_random() {
  contents=$(uuidgen)
  echo "Building random text $contents"
  nix_file=$(mktemp --suffix=.nix)
  cat <<EOF > $nix_file
with import <nixpkgs> {}; writeText "random" "$contents"
EOF
  cat $nix_file
  nix-build --no-out-link $nix_file
  rm $nix_file
}

# Interactive uninstall of nix stuff
nix_uninstall() {
  for pkg in $(nix-env -q); do
    echo "Uninstall $pkg? [y/n/q]"
    read -n RESPONSE
    if [[ $RESPONSE == y ]]; then
      nix-env -e $pkg
    elif [[ $RESPONSE == q ]]; then
      break
    else
      echo "Not uninstalling $pkg"
    fi
  done
}
