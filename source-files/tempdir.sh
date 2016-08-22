# Makes a tempdir and records it.
mktempdir() {
  mkdir -p $HOME/tmp
  local tdir=$(mktemp -d $HOME/tmp/XXXXX)
  echo $tdir
}

tempdir() {
  cd $(mktempdir)
}

retempdir() {
  if [[ ! -d $HOME/tmp ]] || \
     [[ -z $(ls $HOME/tmp) ]]; then
    echo "No latest tempdir. Creating one..." >&2
    tempdir
  else
    cd $(latest_tempdir)
  fi
}

latest_tempdir() {
  echo $HOME/tmp/$(ls -t $HOME/tmp | head -n 1)
}
