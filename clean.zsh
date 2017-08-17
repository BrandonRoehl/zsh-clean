# For my own and others sanity
# git:
# %b => current branch
# %a => current action (rebase/merge)
# %c => current changed files
# %u => current staged files
# prompt:
# %F => color dict
# %f => reset color
# %~ => current path
# %* => time
# %n => username
# %m => shortname host
# %1 => vcs branch and vcs
# %2 => vcs dirty
# %3 => vcs action
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
    zstyle ':vcs_info:*' max-exports 3
    zstyle ':vcs_info:*' use-simple true
    zstyle ':vcs_info:*:*' formats "%s/%b" "%c%u"
    zstyle ':vcs_info:*:*' actionformats "%s/%b" "%c%u" "%a"
    zstyle ':vcs_info:git:*' formats "%b" "%c%u"
    zstyle ':vcs_info:git:*' actionformats "%b" "%c%u" "%a"
    # Additional hooks
    zstyle ':vcs_info:git*+post-backend:*' hooks git-arrows
    zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
    # Additional clean specific styles

    # Set other defaults
    zstyle -t ':vcs_info:*' get-revision; if [[ $? -eq 2 ]]; then
        zstyle ':vcs_info:*' get-revision true
    fi
    zstyle -t ':vcs_info:*' check-for-changes; if [[ $? -eq 2 ]]; then
        zstyle ':vcs_info:*' check-for-changes true
    fi
    zstyle -t ':vcs_info:*' unstagedstr; if [[ $? -eq 2 ]]; then
        zstyle ':vcs_info:*' unstagedstr '*'
    fi
    zstyle -t ':vcs_info:*' stagedstr; if [[ $? -eq 2 ]]; then
        zstyle ':vcs_info:*' stagedstr '+'
    fi

    # zstyle ':vcs_info:*:clean:*' check-for-untracked true
    # zstyle ':vcs_info:*:clean:*' check-head true
    # zstyle ':vcs_info:*:clean:*' untrackedstr '.'
    # zstyle ':vcs_info:*:clean:*' headbehindstr '⇣'
    # zstyle ':vcs_info:*:clean:*' headaheadstr '⇡'
    # zstyle ':clean:normal:*' prompt-symbol '❯'
    # zstyle ':clean:root:*' prompt-symbol '#'

    promptinit

    add-zsh-hook chpwd prompt_clean_chpwd
    add-zsh-hook precmd prompt_clean_precmd
    add-zsh-hook preexec prompt_clean_preexec

    prompt_clean_render
}

prompt_clean_render() {
    local prompt_sym root_prompt_sym prompt_username
    zstyle -s ':clean:normal:' prompt-symbol prompt_sym || prompt_sym='❯'
    zstyle -s ':clean:root:' prompt-symbol root_prompt_sym || root_prompt_sym='#'

    # show username@host if logged in through SSH
    [[ "$SSH_CONNECTION" != '' ]] && prompt_username=' %F{255}%n@%m%f'
    # ( which rvm-prompt &> /dev/null ) && rvm_prompt='%F{242}$(rvm-prompt)%f'

    # Construct the new prompt with a clean preprompt.
    local -ah ps1
    ps1=(
        $prompt_newline # Initial newline, for spaciousness.
        '%F{45}%~%f' # Path
        '%(1V. %F{%(3V.83.242)}%1v%2v%(3V. %3v.)%f.)' # VCS status
        '%(4V. %F{215}%4v%f.)' # Execution time
        $prompt_username
        $prompt_newline # Separate preprompt and prompt.
        "%(?.%F{207}.%F{203})%(!.$root_prompt_sym.$prompt_sym)%f " # Prompt symbol
    )


    PS1="${(j..)ps1}"
    PS2='%F{242}%_ %F{37}%(!.#.${PROMPT_SYMBOL:-❯})%f '
}

prompt_clean_preexec() {
    cmd_timestamp=$EPOCHSECONDS
}

prompt_clean_precmd() {
    psvar[4]=`prompt_clean_check_cmd_exec_time`
    unset cmd_timestamp
    vcs_info
    psvar[1]=$vcs_info_msg_0_
    psvar[2]=$vcs_info_msg_1_
    psvar[3]=$vcs_info_msg_2_
}

prompt_clean_chpwd() {
    command git rev-parse --is-inside-work-tree &> /dev/null || return
    (git fetch &> /dev/null &)
}

+vi-git-untracked() {
    if [[ $1 -eq 0 ]] && \
        zstyle -T ":vcs_info:${vcs}:clean:-all-" check-for-untracked && \
        [[ $($vcs rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
        $vcs status --porcelain | grep '??' &> /dev/null
    then
        # This will show the marker if there are any untracked files in repo.
        # If instead you want to show the marker only if there are untracked
        # files in $PWD, use:
        #[[ -n $(git ls-files --others --exclude-standard) ]] ; then
        local sym
        zstyle -s ":vcs_info:${vcs}:clean:-all-" untrackedstr sym || sym='.'
        hook_com[unstaged]+=$sym
    fi
}

+vi-git-arrows() {
    if zstyle -T ":vcs_info:${vcs}:clean:-all-" check-head
    then
        local arrows=$($vcs rev-list --left-right --count HEAD...@'{u}')
        local rev=("${(@z)arrows}")
        local left=$rev[1] right=$rev[2]

        local behind_arrow ahead_arrow
        zstyle -s ":vcs_info:${vcs}:clean:-all-" headbehindstr behind_arrow || behind_arrow='⇣'
        zstyle -s ":vcs_info:${vcs}:clean:-all-" headaheadstr ahead_arrow || ahead_arrow='⇡'

        unset arrows
        (( right > 0 )) && arrows+=${behind_arrow}
        (( left > 0 )) && arrows+=${ahead_arrow}

        [[ -n $arrows ]] || return

        hook_com[action]+=$arrows
    fi
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

