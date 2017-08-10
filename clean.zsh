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

prompt_clean_setup() {
    setopt localoptions noshwordsplit
    # Set required options
    setopt prompt_subst

    # Load required modules
    zmodload zsh/datetime
    zmodload zsh/parameter

    autoload -Uz add-zsh-hook
    autoload -Uz vcs_info
    autoload -U promptinit

    # zstyle ':vcs_info:*' debug true
    zstyle ':vcs_info:*' enable ALL
    zstyle ':vcs_info:*' unstagedstr '*'
    zstyle ':vcs_info:*' stagedstr '+'
    zstyle ':vcs_info:*' max-exports 3
    zstyle ':vcs_info:*' use-simple true
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*:*' formats " %F{245}%s%F{242}/%b%c%u%f"
    zstyle ':vcs_info:*:*' actionformats " %F{245}%s%F{242}/%b%c%u %F{87}%a%f"
    zstyle ':vcs_info:git:*' formats " %F{242}%b%c%u%f"
    zstyle ':vcs_info:git:*' actionformats " %F{242}%b%c%u %F{87}%a%f"
    # Additional hooks
    zstyle ':vcs_info:git*+post-backend:*' hooks git-arrows
    zstyle ':vcs_info:git*+set-message:*' hooks git-untracked

    promptinit

    add-zsh-hook chpwd prompt_clean_chpwd
    add-zsh-hook precmd prompt_clean_precmd
    add-zsh-hook preexec prompt_clean_preexec

    # show username@host if logged in through SSH
    [[ "$SSH_CONNECTION" != '' ]] && prompt_username=' %F{242}%n@%m%f'

    # Construct the new prompt with a clean preprompt.
    local -ah ps1
    ps1=(
        $prompt_newline # Initial newline, for spaciousness.
        '%F{45}%~%f'
        '${vcs_info_msg_0_}'
        '%(2V. %F{215}%2v%f.)'
        $prompt_username
        $prompt_newline # Separate preprompt and prompt.
        '%(?.%F{135}.%F{160})' # Virtual env
        '%(!.#.${PROMPT_SYMBOL:-❯})%f ' # Prompt symbol
    )

    PS1="${(j..)ps1}"
    PS2='%F{242}%_ %F{51}%(!.#.${GIT_PROMPT_SYMBOL:-❯})%f '
}

prompt_clean_preexec() {
    cmd_timestamp=$EPOCHSECONDS
}

prompt_clean_precmd() {
    psvar[2]=`prompt_clean_check_cmd_exec_time`
    unset cmd_timestamp

    vcs_info

    psvar[1]=$vcs_info_msg_0_
}

prompt_clean_chpwd() {
    command git rev-parse --is-inside-work-tree &> /dev/null || return
    (git fetch &> /dev/null &)
}

+vi-git-untracked() {
    if [[ $1 -eq 0 ]] && \
        [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
        git status --porcelain | grep '??' &> /dev/null ; then
        # This will show the marker if there are any untracked files in repo.
        # If instead you want to show the marker only if there are untracked
        # files in $PWD, use:
        #[[ -n $(git ls-files --others --exclude-standard) ]] ; then
        hook_com[unstaged]+='.'
    fi
}

+vi-git-arrows() {
    local arrows=`git rev-list --left-right --count HEAD...@'{u}'`
    local rev=("${(@z)arrows}")
    local left=$rev[1] right=$rev[2]

    unset arrows
    (( right > 0 )) && arrows+=${GIT_DOWN_ARROW:-⇣}
    (( left > 0 )) && arrows+=${GIT_UP_ARROW:-⇡}

    [[ -n $arrows ]] || return

    hook_com[action]+=$arrows
}

# turns seconds into human readable time
# 165392 => 1d 21h 56m 32s
# https://github.com/sindresorhus/pretty-time-zsh
prompt_clean_human_time_to_var() {
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

prompt_clean_check_cmd_exec_time() {
    integer elapsed
    (( elapsed = EPOCHSECONDS - ${cmd_timestamp:-$EPOCHSECONDS} ))
    if (( elapsed > ${CMD_MAX_EXEC_TIME:-5} ))
    then
        print `prompt_clean_human_time_to_var $elapsed`
    fi
}

prompt_clean_setup

