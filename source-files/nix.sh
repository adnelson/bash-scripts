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
m = re.match("^(\d+\.\d+).*", "$version")
print(m.group(1))
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
  if [ $(id -u) -eq 0 ]; then
    $SH_CONFIG/scripts/update_nixos.py "$@"
  else
    sudo $SH_CONFIG/scripts/update_nixos.py "$@"
  fi
}

push_nixos_config() (
  cd /etc/nixos
  sudo git push origin master
)

update_channels() {
    nix-channel --update
    nixlist -r >/dev/null
}

if [[ -d ~/.nix-profile ]]; then
  export PATH="$HOME/.nix-profile/bin:$PATH"
fi

if [[ -e ~/.nix-profile/etc/ssl/certs/ca-bundle.crt ]]; then
  export NIX_SSL_CERT_FILE=$(readlink -f ~/.nix-profile/etc/ssl/certs/ca-bundle.crt)
else
  echo "Warning: no ca-bundle installed in nix profile"
fi

if [[ -d ~/nixpkgs ]]; then
  export NIX_PATH=$HOME:nixpkgs=$HOME/nixpkgs
  alias nixpkgs="cd $HOME/nixpkgs"
fi

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

alias lsp='PAGER= nix-env -q'
nixrm() {
    lsp | egrep $1 | xargs nix-env -e
}
alias nse='nix-shell --pure -A env'

# Print all of the result symlinks that are floating around on the hard drive.
nix_result_links() {
  nix-store --gc --print-roots | awk '{print $1}' | grep $HOME
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

if [[ $(id -u) == 0 ]]; then
  export NIX_PATH=/root/.nix-defexpr/channels:nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=/etc/nixos/configuration.nix:/nix/var/nix/profiles/per-user/root/channels

  commit_nixos_config() (
    if [[ -z "$1" ]]; then
      echo "Need a commit message"
      exit 1
    fi
    cd /etc/nixos
    git add configuration.nix
    git commit -m "$1"
  )

  push_nixos_config() (
    cd /etc/nixos
    if ! git diff-index --quiet HEAD; then
      git status
      echo "Stopping due to uncommitted changes in /etc/nixos."
      exit 1
    fi

    git push origin "${1:-master}"
  )
fi

commit_bash_scripts() (
  if [[ -z "$1" ]]; then
    echo "Need a commit message"
    exit 1
  fi
  cd ~/.bash-scripts
  git add .
  git commit -m "$1"
)

push_bash_scripts() (
  cd ~/.bash-scripts
  if ! git diff-index --quiet HEAD; then
    git status
    echo "Stopping due to uncommitted changes in $PWD."
    exit 1
  fi

  git push origin "${1:-master}"
)

alias edit_packages='enw ~/.bash-scripts/nix/userPackages.nix'
alias install_packages='nix-env -f ~/.bash-scripts/nix/userPackages.nix -i'

# Returns 1 if the package is not in nixpkgs or is not a derivation
is_in_nixpkgs() {
  local isDeriv=$(nix-instantiate --eval --expr "with import <nixpkgs> {}; lib.isDerivation pkgs.$1")
  if [[ $? != 0 ]] || [[ $isDeriv != "true" ]]; then
    return 1
  elif [[ $2 != "--silent" ]]; then
    echo "yes"
  fi
}

# Install a new nix package into the user packages
nixi () (
    if [[ -n "$1" ]] && ! is_in_nixpkgs "$1" --silent; then
      return 1
    fi
    set -x
    update_nixpkgs
    local nixpath=$HOME/.bash-scripts/nix/userPackages.nix
    if [[ $(id -u) == 0 ]]; then
      local user=root
    else
      local user=allen
    fi
    if [[ -n "$IS_DARWIN" ]]; then
      local attr="$user.darwin"
      local jsonpath="$attr.json"
    else
      local attr="$user.nixos"
      local jsonpath="$attr.json"
    fi
    if [[ -n "$1" ]]; then
      python3 <<EOF
import json
with open("$HOME/.bash-scripts/nix/$jsonpath") as f:
    j = json.load(f)
if "$1" not in j:
    print("New package $1")
    j.append("$1")
    with open("$HOME/.bash-scripts/nix/$jsonpath", "w") as f:
        f.write(json.dumps(list(sorted(j)), indent=2))
else:
    print("Already have package $1")
EOF
    fi
    nix-env -f $nixpath -iA $attr
    rm -f ~/.cache/dmenu_run &>/dev/null
)

# Uninstall the user package. This will uninstall everything, so it's
# not normally needed.
# TODO: this should optionally take a package name argument and if so
# should remove the given package from the given json file.
unixi () {
  if [[ $(id -u) == 0 ]]; then
    local user=root
  else
    local user=allen
  fi
  if [[ -n "$IS_DARWIN" ]]; then
    local pkg="$user-user-packages-darwin"
  else
    local pkg="$user-user-packages-nixos"
  fi
   nix-env -e $pkg
}
