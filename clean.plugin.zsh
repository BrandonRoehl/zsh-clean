# For my own and others sanity
# git:
# %b => current branch
# %a => current action (rebase/merge)
# prompt:
# %F => color dict
# %f => reset color
# %~ => current path
# %* => time
# %n => username
# %m => shortname host
# %(?..) => prompt conditional - %(condition.true.false)
# terminal codes:
# \e7   => save cursor position
# \e[2A => move cursor 2 lines up
# \e[1G => go to position 1 in terminal
# \e8   => restore cursor position
# \e[K  => clears everything after the cursor on the current line
# \e[2K => clear everything on the current line


# turns seconds into human readable time
# 165392 => 1d 21h 56m 32s
# https://github.com/sindresorhus/pretty-time-zsh
prompt_human_time_to_var() {
    local human total_seconds=$1
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

#Doesn't work
prompt_check_cmd_exec_time() {
    integer elapsed
    (( elapsed = EPOCHSECONDS - ${cmd_timestamp:-$EPOCHSECONDS} ))
    if (( elapsed > ${CMD_MAX_EXEC_TIME:-5} ))
    then
        print `prompt_human_time_to_var $elapsed`
    fi
}

# From sindresorhus/pure
# https://github.com/sindresorhus/pure/blob/master/pure.zsh#L338
prompt_git_arrows() {
    setopt localoptions noshwordsplit
    local arrows left=${1:-0} right=${2:-0}

    (( right > 0 )) && arrows+=${GIT_DOWN_ARROW:-⇣}
    (( left > 0 )) && arrows+=${GIT_UP_ARROW:-⇡}

    [[ -n $arrows ]] || return
    typeset -g REPLY=$arrows
}

prompt_chpwd() {
    command git rev-parse --is-inside-work-tree &> /dev/null || return
    (git fetch &)
}

prompt_precmd() {
    psvar[4]=`prompt_check_cmd_exec_time`
    unset cmd_timestamp

    vcs_info

    if command git rev-parse --is-inside-work-tree &> /dev/null
    then
        vcs_info_msg_1_=""
        if ! command git diff --quiet &> /dev/null
        then
            vcs_info_msg_1_+="*"
        fi
        if ! command git diff --cached --quiet &> /dev/null
        then
            vcs_info_msg_1_+="+"
        fi
        if [[ -n `git ls-files --other --exclude-standard` ]]
        then
            vcs_info_msg_1_+="."
        fi
        local REPLY
        prompt_git_arrows `command git rev-list --left-right --count HEAD...@'{u}'`
        vcs_info_msg_2_+=$REPLY
    fi
    psvar[1]=$vcs_info_msg_0_
    psvar[2]=$vcs_info_msg_1_
    psvar[3]=$vcs_info_msg_2_
}

prompt_preexec() {
    cmd_timestamp=$EPOCHSECONDS
}

prompt_init() {
    setopt localoptions noshwordsplit
    # Set required options
    setopt prompt_subst

    # Load required modules
    zmodload zsh/datetime
    zmodload zsh/parameter

    autoload -Uz add-zsh-hook
    autoload -Uz vcs_info
    autoload -U promptinit

    zstyle ':vcs_info:*' enable hg bzr git
    zstyle ':vcs_info:*' unstagedstr '*'
    zstyle ':vcs_info:*' stagedstr '+'
    # only export two msg variables from vcs_info
    zstyle ':vcs_info:*' max-exports 3
    zstyle ':vcs_info:*:*' formats "%s/%b" "%u%c"
    zstyle ':vcs_info:*:*' actionformats "%s/%b" "%u%c" "(%a)"
    zstyle ':vcs_info:git:*' formats "%b"
    zstyle ':vcs_info:git:*' actionformats "%b" "" "(%a)"

    promptinit

    add-zsh-hook chpwd prompt_chpwd
    add-zsh-hook precmd prompt_precmd
    add-zsh-hook preexec prompt_preexec

    # show username@host if logged in through SSH
    [[ "$SSH_CONNECTION" != '' ]] && prompt_username=' %F{242}%n@%m%f'

    # show username@host if root, with username in white
    [[ $UID -eq 0 ]] && prompt_username=' %F{255}%n%f%F{242}@%m%f'

    # Construct the new prompt with a clean preprompt.
    local -ah ps1
    ps1=(
        $prompt_newline # Initial newline, for spaciousness.
        '%F{45}%~%f'
        '%(1v. %F{243}%1v%2v%(3v. %F{87}%3v%f.).)'
        '%(4v. %F{215}%4v%f.)'
        $prompt_username
        $prompt_newline # Separate preprompt and prompt.
        '%(?.%F{177}.%F{203})%(!.#.${GIT_PROMPT_SYMBOL:-❯})%f '
    )

    PS1="${(j..)ps1}"
    PS2='%F{242}%_ %F{51}%(!.#.${GIT_PROMPT_SYMBOL:-❯})%f '
}

prompt_init

