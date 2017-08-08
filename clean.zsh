
# turns seconds into human readable time
# 165392 => 1d 21h 56m 32s
# https://github.com/sindresorhus/pretty-time-zsh
function clean_prompt_human_time_to_var() {
	local human total_seconds=$1 var=$2
	local days=$(( total_seconds / 60 / 60 / 24 ))
	local hours=$(( total_seconds / 60 / 60 % 24 ))
	local minutes=$(( total_seconds / 60 % 60 ))
	local seconds=$(( total_seconds % 60 ))
	(( days > 0 )) && human+="${days}d "
	(( hours > 0 )) && human+="${hours}h "
	(( minutes > 0 )) && human+="${minutes}m "
	human+="${seconds}s"

	# store human readable time in variable as specified by caller
	print "${human}"
}

function clean_prompt_init() {
    # Set required options
    setopt prompt_subst

    # Load required modules
    autoload -Uz vcs_info


    zstyle ':vcs_info:*' enable hg bzr git
    zstyle ':vcs_info:*:*' unstagedstr '*'
    zstyle ':vcs_info:*:*' stagedstr '+'
    zstyle ':vcs_info:*:*' formats "%s/%b" "%u%c"
    zstyle ':vcs_info:*:*' actionformats "%s/%b" "%u%c" "(%a)"
    zstyle ':vcs_info:git:*' formats "%b" "%u%c"
    zstyle ':vcs_info:git:*' actionformats "%b" "%u%c" "(%a)"
    zstyle ':vcs_info:*:*' nvcsformats "%~" ""


}

