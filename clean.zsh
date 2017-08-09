
# turns seconds into human readable time
# 165392 => 1d 21h 56m 32s
# https://github.com/sindresorhus/pretty-time-zsh
prompt_human_time_to_var() {
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

# stores (into prompt_pure_cmd_exec_time) the exec time of the last command if set threshold was exceeded
prompt_check_cmd_exec_time() {
	integer elapsed
	(( elapsed = EPOCHSECONDS - ${cmd_timestamp:-$EPOCHSECONDS} ))
	prompt_pure_cmd_exec_time=
	(( elapsed > ${CMD_MAX_EXEC_TIME:=5} )) && {
		prompt_pure_human_time_to_var $elapsed "prompt_pure_cmd_exec_time"
	}
}

prompt_chwd() {
    (git fetch &)
}

prompt_preexec() {
    cmd_timestamp=$EPOCHSECONDS
}

prompt_precmd() {
    vcs_info
    cmd_exec_time=`prompt_check_cmd_exec_time`
    unset cmd_timestamp
}

prompt_init() {
	setopt localoptions noshwordsplit
    # Set required options
    setopt prompt_subst

    # Load required modules
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable hg bzr git
    zstyle ':vcs_info:*' unstagedstr '*'
    zstyle ':vcs_info:*' stagedstr '+'
    zstyle ':vcs_info:*:*' formats "%s/%b" "%u%c"
    zstyle ':vcs_info:*:*' actionformats "%s/%b" "%u%c" "(%a)"
    zstyle ':vcs_info:git:*' formats "%b" "%u%c"
    zstyle ':vcs_info:git:*' actionformats "%b" "%u%c" "(%a)"



    add-zsh-hook precmd prompt_precmd
	add-zsh-hook preexec prompt_preexec
}




