#!/usr/bin/env bash

# Path to your oh-my-bash installation.
export OSH=$HOME/.oh-my-bash

OSH_THEME="doubletime_multiline"

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

function scm {
  local working_dir=`pwd`
  if [[ -f .git/HEAD ]]; then
    SCM=$SCM_GIT
  elif which git &> /dev/null && [[ -n "$(git rev-parse --is-inside-work-tree 2> /dev/null)" ]]; then
    SCM=$SCM_GIT
  elif [[ $working_dir == "${GOOG}${USER}/"* ]]; then
    SCM=$SCM_CT
    SCM_CT_CLIENT=$(pwd)
  else
    SCM=$SCM_NONE
  fi
}

function scm_prompt_char {
  if [[ -z $SCM ]]; then scm; fi
  if [[ $SCM == $SCM_GIT ]]; then SCM_CHAR=$SCM_GIT_CHAR
  elif [[ $SCM == $SCM_CT ]]; then SCM_CHAR=$SCM_CT_CHAR
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
}

function ct_prompt_vars {
  local details=''
  SCM_STATE=${CT_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
  SCM_BRANCH_CLEANED="${SCM_CT_CLIENT#${GOOG}${USER}/}"
  SCM_BRANCH="${SCM_BRANCH_CLEANED%/google3*}"

  PID_LIST=""

  tmp=/tmp/${SCM_BRANCH}_fig.tmp
  rm -f $tmp.*
  hg cls . -T{verbosename} 1>$tmp.name 2> /dev/null & pid=$!
  PID_LIST+=" $pid"
  hg status --rev . -T{status} 1>>$tmp.unstaged 2> /dev/null & pid=$! # unstaged
  PID_LIST+=" $pid"
  hg status --rev .^ -T{status} 1>>$tmp.staged 2> /dev/null & pid=$! # staged
  PID_LIST+=" $pid"

  wait $PID_LIST

  SCM_CT_CL=$(<$tmp.name)

  if [[ "${SCM_CT_CL}" != "" ]]; then
    SCM_BRANCH+=" ${SCM_CT_CL}"
    local untracked_unstaged_status_str=$(<$tmp.unstaged)
    local staged_count=$(awk -F"(M|A|R)" '{print NF-1}' <<< "$(<$tmp.staged)")
    local unstaged_count=$(awk -F"(M|A|R)" '{print NF-1}' <<< "$untracked_unstaged_status_str")
    local untracked_count=$(awk -F"?" '{print NF-1}' <<< "$untracked_unstaged_status_str")
    local missing_count=$(awk -F"!" '{print NF-1}' <<< "$untracked_unstaged_status_str")
    [[ "${staged_count}" -gt 0 ]] && details+=" ${SCM_GIT_STAGED_CHAR}${staged_count}" && SCM_DIRTY=4
    [[ "${unstaged_count}" -gt 0 ]] && details+=" ${SCM_GIT_UNSTAGED_CHAR}${unstaged_count}" && SCM_DIRTY=3
    [[ "${untracked_count}" -gt 0 ]] && details+=" ${SCM_GIT_UNTRACKED_CHAR}${untracked_count}" && SCM_DIRTY=2
    [[ "${missing_count}" -gt 0 ]] && details+=" !:${missing_count}" && SCM_DIRTY=1
  fi

  SCM_BRANCH+=${details}

  SCM_PREFIX=${CT_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
  SCM_SUFFIX=${CT_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
}

function ct_prompt_info {
  ct_prompt_vars
  echo -e "${SCM_PREFIX}${SCM_BRANCH}${SCM_STATE}${SCM_SUFFIX}"
}
