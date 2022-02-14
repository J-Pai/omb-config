#!/usr/bin/env bash

# Path to your oh-my-bash installation.
export OSH=$HOME/.oh-my-bash

OSH_THEME="font"

completions=(
git
composer
ssh
)

aliases=(
general
)

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

SCM_CT_G4='city-g4'
SCM_CT_G4_CLIENT=''
SCM_CT_G4_CL=''
SCM_CT_G4_DIRTY=''
SCM_CT_G4_CHAR='G-g4'

function scm {
  local working_dir=`pwd -P`
  if [[ -f .git/HEAD ]]; then
    SCM=$SCM_GIT
  elif which git &> /dev/null && [[ -n "$(git rev-parse --is-inside-work-tree 2> /dev/null)" ]]; then
    SCM=$SCM_GIT
  elif [[ -d ${working_dir%%/google3*}/.hg ]]; then
    SCM=$SCM_CT
    SCM_CT_CLIENT=$(pwd -P)
  elif [[ ${working_dir} =~ /google3/* ]]; then
    SCM=$SCM_CT_G4
    SCM_CT_G4_CLIENT=$(pwd -P)
  else
    SCM=$SCM_NONE
  fi
}

function scm_prompt_char {
  if [[ -z $SCM ]]; then scm; fi
  if [[ $SCM == $SCM_GIT ]]; then SCM_CHAR=$SCM_GIT_CHAR
  elif [[ $SCM == $SCM_CT ]]; then SCM_CHAR=$SCM_CT_CHAR
  elif [[ $SCM == $SCM_CT_G4 ]]; then SCM_CHAR=$SCM_CT_G4_CHAR
  else SCM_CHAR=$SCM_NONE_CHAR
  fi
}

function scm_prompt_info_common {
  SCM_DIRTY=0
  SCM_STATE=''

  if [[ ${SCM} == ${SCM_GIT} ]]; then
    if [[ ${SCM_GIT_SHOW_MINIMAL_INFO} == true ]]; then
      git_prompt_minimal_info
    else
      git_prompt_info
    fi
    return
  fi
  [[ ${SCM} == ${SCM_HG} ]] && hg_prompt_info && return
  [[ ${SCM} == ${SCM_CT} ]] && ct_prompt_info && return
  [[ ${SCM} == ${SCM_CT_G4} ]] && ct_g4_prompt_info && return
}

function ct_prompt_vars {
  local details=''
  SCM_STATE=${CT_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
  SCM_BRANCH="$(get_fig_client_name)"

  PID_LIST=""

  tmp=/tmp/${SCM_BRANCH}_fig.tmp
  rm -f $tmp.*

  if [ -z "${STOP_CT_CHECKS}" ]; then
    declare -a figstatus
    while IFS=$'\n' read -r value; do
      figstatus+=("$value")
    done <<< "$( fig_status )"

    modified=${figstatus[0]}
    added=${figstatus[1]}
    deleted=${figstatus[2]}
    unknown=${figstatus[3]}
    unexported=${figstatus[4]}
    obsolete=${figstatus[5]}
    cl=${figstatus[6]}
    description=${figstatus[7]}
    branch=${figstatus[8]}
    if [ -z "$branch" ]; then
      branch="cl/$cl"
    fi
    changename=${figstatus[12]}
    if [ -z "$changename" ]; then
      changename="$branch"
    fi
    has_shelve=""
    # POSIX-compatible way to check whether shelved-directory is non-empty.
    shelve_dir="$( get_fig_client_root )/.hg/shelved/"
    if [ -d "$shelve_dir" ] && /bin/ls -1qA "$shelve_dir" | grep -q .; then
      has_shelve="!"
    fi
    short=${figstatus[13]}

    SCM_BRANCH+=" cl/$branch"
    [ ! -z "$modified" ] && details+=" $modified" && SCM_DIRTY=5
    [ ! -z "$added" ] && details+=" $added" && SCM_DIRTY=4
    [ ! -z "$deleted" ] && details+=" $deleted" && SCM_DIRTY=3
    [ ! -z "$unknown" ] && details+=" $unknown" && SCM_DIRTY=2
    [ ! -z "$unexported" ] && details+=" $unexported" && SCM_DIRTY=1
  fi

  SCM_BRANCH+=${details}

  SCM_PREFIX=${CT_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
  SCM_SUFFIX=${CT_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
}

function ct_prompt_info {
  ct_prompt_vars
  echo -e "${SCM_PREFIX}${SCM_BRANCH}${SCM_STATE}${SCM_SUFFIX}"
}

function ct_g4_prompt_vars {
  SCM_STATE=${CT_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
  SCM_BRANCH="$(get_fig_client_name)"
  SCM_PREFIX=${CT_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
  SCM_SUFFIX=${CT_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
}

function ct_g4_prompt_info {
  ct_g4_prompt_vars
  echo -e "${SCM_PREFIX}${SCM_BRANCH}${SCM_STATE}${SCM_SUFFIX}"
}
