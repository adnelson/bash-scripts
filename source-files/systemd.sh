if [[ -z $IN_NIX_SHELL ]] && [[ -d ~/.config/systemd/user ]]; then

# Start up the systemd units (kinda hacky because I feel like this shouldn't be necessary to do here...)

[[ -n $XDG_RUNTIME_DIR ]] || export XDG_RUNTIME_DIR="/run/user/$UID"
[[ -n $DBUS_SESSION_BUS_ADDRESS ]] || export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"
(
  cd ~/.config/systemd/user
  services=()
  for service in *.service; do
    if systemctl --user is-enabled $service >/dev/null; then
      echo "Found enabled service file $service"
      services+=("$service")
    else
      echo "Found disabled service file $service"
    fi
  done
  if [[ -n $services ]]; then
    for service in $services; do
      echo "Starting service $service"
      systemctl --user start $service
    done
  fi
)

fi # if in nix shell
