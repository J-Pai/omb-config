#!/usr/bin/env bash

# Path to your oh-my-bash installation.
export OSH=$HOME/.oh-my-bash

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-bash is loaded.
OSH_THEME="bobby"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_OSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $OSH/custom?
# OSH_CUSTOM=/path/to/new-custom-folder

# THEME_CLOCK_FORMAT="%H:%M:%S"

# Which completions would you like to load? (completions can be found in ~/.oh-my-bash/completions/*)
# Custom completions may be added to ~/.oh-my-bash/custom/completions/
# Example format: completions=(ssh git bundler gem pip pip3)
# Add wisely, as too many completions slow down shell startup.
completions=(
git
composer
ssh
)

# Which aliases would you like to load? (aliases can be found in ~/.oh-my-bash/aliases/*)
# Custom aliases may be added to ~/.oh-my-bash/custom/aliases/
# Example format: aliases=(vagrant composer git-avh)
# Add wisely, as too many aliases slow down shell startup.
aliases=(
general
)

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-bash/plugins/*)
# Custom plugins may be added to ~/.oh-my-bash/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
git
bashmarks
)

source $OSH/oh-my-bash.sh
SCM_GIT_SHOW_MINIMAL_INFO=false
PROMPT_DIRTRIM=0

SCM_CT='city'
SCM_CT_CLIENT=''
SCM_CT_CL=''
SCM_CT_DIRTY=''
SCM_CT_CHAR='G'

function scm {
  local working_dir=`pwd`
  if [[ -f .git/HEAD ]]; then
    SCM=$SCM_GIT
  # elif which git &> /dev/null && [[ -n "$(git rev-parse --is-inside-work-tree 2> /dev/null)" ]]; then
  #   SCM=$SCM_GIT
  # elif [[ -d .hg ]]; then
  #   SCM=$SCM_HG
  # elif which hg &> /dev/null && [[ -n "$(hg root 2> /dev/null)" ]]; then
  #   SCM=$SCM_HG
  # elif [[ -d .svn ]]; then
  #   SCM=$SCM_SV
  elif [[ $working_dir == "${GOOG}${USER}/"* ]]; then
    SCM=$SCM_CT
    IFS="/" client=($working_dir)
    SCM_CT_CLIENT=${client[5]}
    pending=$(${GF} -F'%change0%|%depotFile0%' pending)
    IFS="|" cl_opened=($pending)
    SCM_CT_CL=${cl_opened[0]}
    SCM_CT_DIRTY=${cl_opened[1]}
  else
    SCM=$SCM_NONE
  fi
}

function scm_prompt_char {
  if [[ -z $SCM ]]; then scm; fi
  if [[ $SCM == $SCM_GIT ]]; then SCM_CHAR=$SCM_GIT_CHAR
  # elif [[ $SCM == $SCM_HG ]]; then SCM_CHAR=$SCM_HG_CHAR
  # elif [[ $SCM == $SCM_SVN ]]; then SCM_CHAR=$SCM_SVN_CHAR
  elif [[ $SCM == $SCM_CT ]]; then SCM_CHAR=$SCM_CT_CHAR
  else SCM_CHAR=$SCM_NONE_CHAR
  fi
}

function scm_prompt_info_common {
  SCM_DIRTY=0
  SCM_STATE=''

  if [[ ${SCM} == ${SCM_GIT} ]]; then
    if [[ ${SCM_GIT_SHOW_MINIMAL_INFO} == true ]]; then
      # user requests minimal git status information
      git_prompt_minimal_info
    else
      # more detailed git status
      git_prompt_info
    fi
    return
  fi

  # TODO: consider adding minimal status information for hg and svn
  # [[ ${SCM} == ${SCM_HG} ]] && hg_prompt_info && return
  # [[ ${SCM} == ${SCM_SVN} ]] && svn_prompt_info && return
  [[ ${SCM} == ${SCM_CT} ]] && ct_prompt_info && return
}

function ct_prompt_vars {
  local details=''
  SCM_STATE=${CT_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
  SCM_BRANCH=""
  SCM_BRANCH="${SCM_CT_CLIENT}"
  [[ "${SCM_CT_CL}" != "" ]] && \
    SCM_BRANCH+=" cl/${SCM_CT_CL}"
  [[ "${SCM_CT_DIRTY}" != "" ]] && \
    SCM_DIRTY=1 && \
    SCM_STATE=${CT_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}

  SCM_PREFIX=${CT_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
  SCM_SUFFIX=${CT_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
}

function ct_prompt_info {
  ct_prompt_vars
  echo -e "${SCM_PREFIX}${SCM_BRANCH}${SCM_STATE}${SCM_SUFFIX}"
}
# User configuration
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-bash libs,
# plugins, and themes. Aliases can be placed here, though oh-my-bash
# users are encouraged to define aliases within the OSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias bashconfig="mate ~/.bashrc"
# alias ohmybash="mate ~/.oh-my-bash"
