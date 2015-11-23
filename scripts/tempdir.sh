# Makes a tempdir and records it.
mktempdir() {
  local tdir=$(mktemp -d /tmp/tempdir-XXXXX)
  echo $tdir >> ~/.current_tempdirs
  echo $tdir
}

tempdir() {
  cd $(mktempdir)
}

retempdir() {
  cd $(latest_tempdir)
}

latest_tempdir() {
  tail -n 1 ~/.current_tempdirs
}

rmtempdirs() {
  for d in $(cat ~/.current_tempdirs); do
    echo "Removing $d"
    chmod -R +w $d
    rm -rf $d
  done
  cat /dev/null > ~/.current_tempdirs
}
