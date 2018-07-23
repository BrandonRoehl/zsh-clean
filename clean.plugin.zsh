# Legacy support for those already using antigen
autoload -U promptinit
promptinit
# Check if the terminal supports 256 bit color
if [[ $TERM =~ '256color$' ]]; then
    prompt clean 256
else
    prompt clean
fi

