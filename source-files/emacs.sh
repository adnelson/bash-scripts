function restart_emacs() {
  if [[ -e ~/.config/systemd/user/emacs-daemon.service ]]; then
    systemctl --user restart emacs-daemon
  else
    local pid=$(ps aux | grep 'emacs --daemon' | awk '{print $2;}')
    if [[ -z "$pid" ]]; then
      return 1
    fi
    echo "PID $pid"
    kill -15 "$pid"
  fi
}
