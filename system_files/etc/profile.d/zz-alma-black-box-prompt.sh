# Alma Black Box system-wide interactive Bash prompt.
# Keep the standard RHEL-style prompt shape while giving the appliance a
# distinct dark-red user@host identity.

[ -n "${BASH_VERSION:-}" ] || return 0

case $- in
    *i*) ;;
    *) return 0 ;;
esac

PS1='[\[\e[31m\]\u@\h\[\e[0m\] \W]\$ '
