# Detect the default remote to use. Order of preference is
# adnelson, narrsci and origin. This is useful for forks.
default_remote() {
  local remotes=$(git remote)
  if [[ -n $REMOTE ]]; then
    echo $REMOTE
  elif echo "$remotes" | grep -q '^adnelson'; then
    echo "Using remote adnelson" 1>&2
    echo adnelson
  elif echo "$remotes" | grep -q '^narrsci'; then
    echo "Using remote narrsci" 1>&2
    echo narrsci
  else
    echo "Using remote origin" 1>&2
    echo origin
  fi
}

# Simple git aliases.
alias gs='git status'
alias gf='git fetch'
alias gb='git branch'

# Creates a new branch.
alias gcb='git checkout -b'

# Delete a branch
gbd() {
  local response
  if [[ -z "$1" ]]; then
    echo "Please enter a branch name." >&2
    return 1
  fi
  echo -n "Enter to delete branch $1, anything else not to: "
  read response
  if [[ -z $response ]]; then
    git branch -D $1
  else
    echo "Not deleting $1."
  fi
}

# Delete the current branch
delete_current_branch() {
  local branch_name=$(cur)
  if [[ -z "$1" ]]; then
    git checkout master
  else
    git checkout $1
  fi
  gbd $branch_name || git checkout $branch_name
}

# Checkouts
alias gco='git checkout'
alias master='git checkout master'
alias develop='git checkout develop'
alias gsui='git submodule update --init'

###### Committing ########

# Commits with a message
alias gcm='git commit -m'

# Adds a file or folder. The --all is for folders.
alias ga='git add --all'

# Redoes the commit using the same message but the latest files.
alias gcan='git commit --amend --no-edit'

# Adds a file to the previous commit (as if you had commited it then).
function gam() {
    git add --all $1 && git commit --amend --no-edit
}

# Reperforms the last commit, letting you modify the commit message, and

# possibly add/change the files committed.
alias gamm='git commit --amend'

######## Pushing ########

# Push to $(default_remote) (provide the branch name).
alias gpo='git push $(default_remote)'

# Push to $(default_remote), current branch.
gpoc() {
  if [[ $(cur) == "master" ]]; then
    echo "Current branch is master; use gpom" >&2
  else
    git push $(default_remote) $(git rev-parse --abbrev-ref HEAD) $@
  fi
}

# Push to $(default_remote) master. Use with caution! :)
gpom() {
  if [[ $(cur) != "master" ]]; then
    echo "Not on master branch" >&2
  else
    git push $(default_remote) master $@
  fi
}

# Forces a commit, when you've done rebases or --ammend commits.
alias gpf='git push --force'

# Forces a commit to `$(default_remote)`.
alias gpfo='gpo --force'

# Force a commit to current branch.
alias gpfoc='gpoc --force'

alias gpfom='gpom --force'

######### Rebasing #########

# Grab the latest from a branch, and then apply the commits in your branch

# on top of those.
alias rebo='git pull --rebase $(default_remote)'

# Same as above, but for the `master` branch.
alias reb='git pull --rebase $(default_remote) master'

# Same as above, but uses `develop` branch.
alias rebd='git pull --rebase $(default_remote) develop'

# Continue a rebase, after doing a diff.
alias grc='git rebase --continue'

# Abort a rebase.
alias gra='git rebase --abort'

# Skip a file in a rebase.
alias grs='git rebase --skip'

# Interactive rebase of the last `n` files, to collapse multiple commits
# into a single commit.
rebi() {
    git rebase -i "HEAD~$1"
}

########## Staging files and reverting changes ###########

# Removes a file from the set of files to be committed.
alias unstage='git reset HEAD'

# Resets the repo to the state of the last commit.
alias greset='git reset --hard HEAD'

# Resets the repo to the state of the one before the last commit.
alias goback='git reset --hard HEAD~1'

# Undoes a commit, but doesn't revert the files.
alias gundo='git reset --soft HEAD~1'

############# Other #############

# Adds a file to your gitignore.
function ignore() {
    for pth in "$@"; do
        echo $pth >> .gitignore
        git add .gitignore
        git rm -rf --cached $pth >/dev/null 2>&1 || true
    done
}

# Adds a file to your git excludes file.
function exclude() {
    local toplevel=$(git rev-parse --show-toplevel)
    local pycmd="import os; print(os.path.relpath('$PWD', '$toplevel'))"
    local rel=$(python -c "$pycmd")
    for pth in "$@"; do
        echo $rel/$pth >> $toplevel/.git/info/excludes
        git rm -rf --cached $pth >/dev/null 2>&1 || true
    done
}


# Return the name of the current branch.
cur() {
  git rev-parse --abbrev-ref HEAD
}

# Return the commit hash of the head of the current branch.
curcommit() {
  git rev-parse HEAD
}

# Pulling
alias gl='git pull'

# Push to $(default_remote), current branch.
alias gloc='git pull $(default_remote) $(cur) && git submodule update --init'

# Stashes currently staged files.
alias stash='git stash'

# Pops off the top of the stash stack.
alias unstash='git stash apply'

# Adds a file to the current commit.
function ninja() {
    ga $1; gcan
}

# Ninjas a file and pushes.
function ninjap() {
    ninja $1; gpfoc
}

aclone() {
    for repo in "$@"; do
        git clone ssh://git@github.com/adnelson/$repo || return 1
    done
}

# Add an alias to this git file
addgit() {
  local aname=$1
  local acmd=$2
  echo "alias $aname='$acmd'" >> $SH_CONFIG/git.sh
  reload
}
alias grv='git remote -v'


# Remove a tag
rmtag() {
  local tag=$1
  git tag -d $tag
  git push $(default_remote) :refs/tags/$tag
}

# Set global gitignore
if [[ -e $SH_CONFIG/gitignore.global ]]; then
  git config --global core.excludesfile $SH_CONFIG/gitignore.global
fi
