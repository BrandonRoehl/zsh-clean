# Add this folder to the fpath if it is not
prompt_clean_folder="${0:A:h}"
if [[ -z "${fpath[(r)$prompt_clean_folder]}" ]]; then
    fpath+=( prompt_clean_folder )
fi

# Legacy support for those already using antigen
autoload -U promptinit
promptinit
prompt clean

