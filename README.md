# zsh-clean
![Showcase](_README/img.png?raw=true)

A [pure](https://github.com/sindresorhus/pure) varient however.

Clean is not pure and pure is not clean

## Installation

Now integrates directly with [zsh prompt](https://github.com/zsh-users/zsh/blob/627c91357c29e6fbe8b32d1b5f17f02d555d8360/Functions/Prompts/promptinit#L200)

1. Add to your this repo to your `fpath`
2. Select your theme with `prompt clean`

### [antigen](https://github.com/zsh-users/antigen)

```zsh
antigen bundle BrandonRoehl/zsh-clean
```

### zsh stock

```zsh
autoload -U promptinit
fpath=($prompt_themes /path/to/repo)
promptinit

prompt clean
```

## Configuration

Add styles to your `.zshrc` these are the defaults

```zsh

## Checking vcs
# Global vcs_info
# Check if there are modifications and staged changes
zstyle ':vcs_info:*' get-revision true
# Clean only
# Check for untracked files
zstyle ':vcs_info:*' check-for-untracked true
# Check for prompt arrows up and down
zstyle ':vcs_info:*' check-head true

## Symbols
# Modified sym
zstyle ':vcs_info:*' unstagedstr '*'
# Staged sym
zstyle ':vcs_info:*' stagedstr '+'
# Untracked sym
zstyle ':vcs_info:*:clean:*' untrackedstr '.'
# Your head is behind remote
zstyle ':vcs_info:*:clean:*' headbehindstr '⇣'
# Your head is ahead remote
zstyle ':vcs_info:*:clean:*' headaheadstr '⇡'
# Prompt symbol
zstyle ':clean:normal:*' prompt-symbol '❯'
# Prompt symbol as root user
zstyle ':clean:root:*' prompt-symbol '#'

# Note that the * can be replaced with the vcs
# Example these are the symbols that will be used in a git repo
zstyle ':vcs_info:git:*' unstagedstr 'G*'
zstyle ':vcs_info:git:*' stagedstr 'G+'
zstyle ':vcs_info:git:clean:*' untrackedstr 'G.'
# only works with the vcs_info ones matching :vcs_info:svn:context:-all-
```

## Goals

Pure's main goal is to produce a really minimalistic setup and nothing
in the prompt.

While as in clean's main goal is to produce a clean code base with no
dependencies as well as supporting tons of customization.

So customizing the prompt to be supper crazy and over the top complicated
Or be a single line

## Differences

| Pure | Clean |
|------|-------|
| Requires Dependencies | Doesn't |
| Isn't customizable | Can completly replace the prompt |
| Custom methods for vcs | Uses `vcs_info` hooks |
| Doesn't show breakdown of vcs | Shows the breakdown like most other git prompts |
| Only works with git | Works with `git` `hg` `svn` and all others that `vcs_info` supports |


