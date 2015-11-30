# Simple git aliases.
alias gs='git status'
alias gf='git fetch'
alias gb='git branch'

# Creates a new branch.
alias gcb='git checkout -b'

# Checkouts
alias gco='git checkout'
alias master='git checkout master'
alias develop='git checkout develop'

###### Committing ########

# Commits with a message
alias gcm='git commit -m'

# Call with a message, after adding everything in the folder.
alias gcom="git add --all . && git commit -m"

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

# Push to origin (provide the branch name).
alias gpo='git push origin'

# Push to origin, current branch.
alias gpoc='git push origin $(git rev-parse --abbrev-ref HEAD)'

# Push to origin master. Use with caution! :)
alias gpom='git push origin master'

# Forces a commit, when you've done rebases or --ammend commits.
alias gpf='git push --force'

# Forces a commit to `origin`.
alias gpfo='git push --force origin'

# Force a commit to current branch.
alias gpfoc='git push --force origin $(cur)'

######### Rebasing #########

# Grab the latest from a branch, and then apply the commits in your branch

# on top of those.
alias rebo='git pull --rebase origin'

# Same as above, but for the `master` branch.
alias reb='git pull --rebase origin master'

# Same as above, but uses `develop` branch.
alias rebd='git pull --rebase origin develop'

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

# Pulling
alias gl='git pull'

# Push to origin, current branch.
alias gloc='git pull origin $(cur)'

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
        aclone_ adnelson/$repo || return 1
    done
}

aclone_() {
    for repo in "$@"; do
        git clone ssh://github-adnelson:/$repo || return 1
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
