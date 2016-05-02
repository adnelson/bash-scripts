# Start up the systemd units (kinda hacky because I feel like this shouldn't be necessary to do here...)

if [[ -d ~/.config/systemd/user ]]; then
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
