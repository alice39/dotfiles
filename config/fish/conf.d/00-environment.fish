set -x EDITOR nano
set -x TERMINAL termite
set -x PATH ~/.cargo/bin:$PATH

# Fish loses its color when reset is executed
alias reset="clear && printf '\e[3J'"
