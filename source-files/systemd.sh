if [[ -z $IN_NIX_SHELL ]]; then

# Start up the systemd units (kinda hacky because I feel like this shouldn't be necessary to do here...)

if [[ -d ~/.config/systemd/user ]]; then
  [[ -n $XDG_RUNTIME_DIR ]] || export XDG_RUNTIME_DIR="/run/user/$UID"
  [[ -n $DBUS_SESSION_BUS_ADDRESS ]] || export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"
  (
    cd ~/.config/systemd/user
    services=()
    for service in *.service; do
      echo "Found service file $service"
      if systemctl --user is-enabled $service >/dev/null; then
        services+=("$service")
      fi
    done
    if [[ -n $services ]]; then
      echo "Enabling service $services[@]"
      systemctl --user start $services[@]
    fi
  )
fi

fi # if in nix shell
