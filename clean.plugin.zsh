# Add this folder to the fpath if it is not
function clean_plugin_zsh() {
    local folder="${0:A:h}"
    if [[ -z "${fpath[(r)$folder]}" ]]; then
        fpath+=( folder )
    fi
}
clean_plugin_zsh()
# Legacy support for those already using antigen
autoload -Uz promptinit
promptinit
# Check if the terminal supports 256 bit color
prompt clean

