set -x EDITOR nano
set -x TERMINAL termite
set -x PATH ~/.cargo/bin:$PATH

# Fish loses its color when reset is executed
alias reset="clear && printf '\e[3J'"
# Copy to clipboard
alias cbcopy="xclip -sel clip"
# Downlaod mp4 format videos
alias yoump4="youtube-dl -f mp4"
