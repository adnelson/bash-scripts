# WeJ-related

alias wej='cd ~/workspace/wej'
alias wejb='cd ~/workspace/wej/hs-backend'
alias wejf='cd ~/workspace/wej/frontend'
alias wbs='wejb && python3 gencabal.py > wej.cabal && cabal2nix . > default.nix && nix-shell'
