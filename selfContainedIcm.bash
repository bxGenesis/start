#!/bin/bash


#set -v
#set -x

if [ -z "${BASH_VERSION}" ] ; then
    echo "UnSupported Bash"
    exit 1
fi

shopt -s expand_aliases
shopt -s extglob
#shopt

alias _CommentBegin_='cat << _CommentEnd_ > /dev/null'


_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  icmLib        :: /[dblock]/ icmStandaloneLib.bash [[elisp:(org-cycle)][| ]]
_CommentEnd_


#
# NOTYET, Location of lib can be made more flexible
#

scriptSrcRunBase="$( dirname ${BASH_SOURCE[0]} )"
icmPkgRunBase=$(readlink -f ${scriptSrcRunBase}/..)
icmPkgRunLibBashBase="${icmPkgRunBase}/lib/bash"

# if [ ! -d ${icmPkgRunLibBashBase} ] ; then 
#     echo "E: ${icmPkgRunLibBashBase}"
#     exit 1
# fi


# #
# # NOTYET, Location of lib can be made more flexible
# #

# scriptSrcRunBase="$( dirname ${BASH_SOURCE[0]} )"
# icmPkgRunBase=$(readlink -f ${scriptSrcRunBase}/..)
# icmPkgRunLibBashBase="${icmPkgRunBase}/lib/bash"

# if [ ! -d ${icmPkgRunLibBashBase} ] ; then 
#     echo "E: ${icmPkgRunLibBashBase}"
#     exit 1
# fi

# opLibBase="${icmPkgRunLibBashBase}"
# opCfgBase="${icmPkgRunBase}/cgf"
# opBinBase="${icmPkgRunBase}/bin"

opLibBase="${icmPkgRunLibBashBase}"
opBinBase="${icmPkgRunBase}/bin"

#echo ${opLibBase}

# thisGitRoot=$( git rev-parse --show-toplevel 2> /dev/null )


alias integer='typeset -i'
alias OrderedArray='typeset -a'
alias Array='typeset -a'
alias ListFuncs='typeset -F | sed -e s/"declare -f "//' 
alias TagVar='typeset -t'
alias TagVarList='typeset -t | sed -e s/"declare -t "// | cut -d= -f1'

alias TM_trace='tm_fileName=$FUNCNAME; tm_lineNo=$LINENO; tm_trace'
alias LOG_event='tm_fileName=$FUNCNAME; tm_lineNo=$LINENO; log_event'
alias LOG_message='tm_fileName=$FUNCNAME; tm_lineNo=$LINENO; log_event'
alias EH_oops='printf  >&2 "EH_,$FUNCNAME,$LINENO: OOPS"'
alias EH_problem='tm_fileName=$FUNCNAME; tm_lineNo=$LINENO; eh_problem'
alias EH_problemRet='tm_fileName=$FUNCNAME; tm_lineNo=$LINENO; eh_problem; return'
alias EH_fatal='tm_fileName=$FUNCNAME; tm_lineNo=$LINENO; eh_fatal'
alias EH_exit='tm_fileName=$FUNCNAME; tm_lineNo=$LINENO; eh_fatal'
alias EH_assert='opDoAssert eval '
alias opDoAssert='_opDoAssert "${G_myName}" "$FUNCNAME" $LINENO'
alias lpReturn='lpLastRetFuncIsValid=1; lpLastRetFunc=$FUNCNAME; return'
alias G_funcEntry='G_thisFunc=$FUNCNAME; G_thisFuncArgs=$@'
alias opDo='_opDo "${G_myName}" "$FUNCNAME" $LINENO "JUST_DO"'
alias lpDo='_opDo "${G_myName}" "$0" $LINENO "JUST_DO"'
alias EH_retOnFail='errVal=$?; if [[ ${errVal} != 0 ]] ; then  printf  >&2 "EH_,retOnFail,${G_myName}::$FUNCNAME:$LINENO (ret=${errVal} func=${lpLastRetFunc})"; lpLastRetFunc=$FUNCNAME; return ${errVal}; fi'
alias retIfFail='errVal=$?; if [[ ${errVal} != 0 ]] ; then  printf  >&2 "retFail,${G_myName}::$FUNCNAME:$LINENO (ret=${errVal})"; return ${errVal}; fi'
alias retIfSuccess='errVal=$?; if [[ ${errVal} == 0 ]] ; then  printf  >&2 "retSuccess,${G_myName}::$FUNCNAME:$LINENO (ret=${errVal})"; return ${errVal}; fi'



sysOS=${sysOS-}
sysDist=${sysDist-}
sysID=${sysID-}

function sysOS_detect {
  if [[ ( -z "${sysOS}" ) && ( -z "${sysDist}" ) ]]; then
    # some systems dont have lsb-release yet have the lsb_release binary and
    # vice-versa
    if [ -e /etc/lsb-release ]; then
      . /etc/lsb-release

      if [ "${sysID}" = "raspbian" ]; then
        sysOS=${sysID}
        sysDist=`cut --delimiter='.' -f1 /etc/debian_version`
      else
        sysOS=${DISTRIB_ID}
        sysDist=${DISTRIB_CODENAME}

        if [ -z "$sysDist" ]; then
          sysDist=${DISTRIB_RELEASE}
        fi
      fi

    elif [ -e /etc/debian_version ]; then
      # some Debians have jessie/sid in their /etc/debian_version
      # while others have '6.0.7'
      sysOS=`cat /etc/issue | head -1 | awk '{ print tolower($1) }'`
      if grep -q '/' /etc/debian_version; then
        sysDist=`cut --delimiter='/' -f1 /etc/debian_version`
      else
        sysDist=`cut --delimiter='.' -f1 /etc/debian_version`
      fi

    elif [ `which lsb_release 2>/dev/null` ]; then
      sysDist=`lsb_release -c | cut -f2`
      sysOS=`lsb_release -i | cut -f2 | awk '{ print tolower($1) }'`

    else
      unknown_sysOS
    fi
  fi

  if [ -z "$sysDist" ]; then
    unknown_sysOS
  fi

  # remove whitespace from SYSOS and sysDist name
  sysOS="${sysOS// /}"
  sysDist="${sysDist// /}"

  #echo "Detected operating system as $sysOS/$sysDist."
}

sysOS_detect

function sysOS_isDebian {
  if [ "${sysOS}" = "debian" ] ; then
    return 0
  else
    return 1
  fi
}

function sysOS_isDeb12 {
  if sysOS_isDebian ; then
    if  [ "${sysDist}" = "12" ] ; then
      return 0
    else
      return 1
    fi
  else
    return 1
  fi
}

function sysOS_isDeb11 {
  if sysOS_isDebian ; then
    if  [ "${sysDist}" = "11" ] ; then
      return 0
    else
      return 1
    fi
  else
    return 1
  fi
}


function _opDoRunOnly {
  #
  # $1: mode
  # $2: msg
  # $3: failed msg
  # $4-: command

  if [[ "${1}X" == "JUST_DOX" ]] ; then
    shift; shift; shift;
    "$@" || err=$?
    return $err
  else
    typeset err=0
    typeset mode="${1}"
    typeset failedMsg="${3}"
    shift; shift; shift;
    "$@" || err=$?
    if [[ $err -ne 0 ]] ; then
      EH_problem "$failedMsg" "$err"
      if [[ "${mode}X" == "EXITX" ]] ; then
        exit $err
      fi
      return $err
    fi
  fi
}

function _opDoShowOnly {
  #
  # $1: mode
  # $2: msg
  # $3: failed msg
  # $4-: command
    if [[ "${BASH_VERSION}" != "" ]] ; then
        #echo -e ${2} 1>&2
        printf "%b \n" "${2}"
    else
        print -u2 "${2}"
    fi
}


function _opDoShowRun {
  #
  # $1: mode
  # $2: msg
  # $3: failed msg
  # $4-: command
  _opDoShowOnly "$@"
  _opDoRunOnly "$@"
}

function shift4ThenEcho {
    shift || exit
    shift || exit
    shift || exit
    shift || exit
    echo $*
}

function G_funcEntryShow {
    echo "${G_myName}:${G_thisFunc}:" 1>&2
}

function _opDoAfterPause {
    #shift
    #shift
    #shift
    #shift
    shift4ThenEcho "$@"
    _pauseForVerification ; if [[ ${skipIt} == "true" ]] ; then return; fi;
    _opDo "$@"
}

function _opDo {
    err=0
    typeset scriptName="$1"; shift || exit 
    typeset functionName="$1"; shift || exit
    typeset lineNumber="$1"; shift || exit
    typeset mode="$1"; shift || exit

    if [[ -z "${__opDo_prevScriptName}" ]] ; then
        export __opDo_prevScriptName=""
    fi
    if [[ -z "${__opDo_prevFunctionName}" ]] ; then
        export __opDo_prevFunctionName=""
    fi
    if [[ "${__opDo_prevScriptName}X" == "${scriptName}X" ]] ; then
        scriptName=""
    else
        __opDo_prevScriptName="${scriptName}"
        scriptName="${scriptName}::"
    fi
    if [[ "${__opDo_prevFunctionName}" == "${functionName}" ]] ; then
        functionName=""
    else
        __opDo_prevFunctionName="${functionName}"
    fi
    
    if [ -z "${G_recordMode}" ] ; then
        lineNumberTag="** [${lineNumber}]"
    else
        lineNumberTag="** [[file:${G_myFullName}::${lineNumber}][${lineNumber}]]"       
    fi

    if [ -z "${G_recordMode}" ] ; then
        scriptFuncName="* ${scriptName}${functionName}" 
    else
        scriptFuncName="* [[file:${G_myFullName}::function ${functionName}][${scriptName}${functionName}]]"             
    fi

    typeset msg
    typeset failedMsg
    dateTag=$( date +%Y%m%d%H%M%S%N )
    case "${G_verbose}" in
        "verbose")
            if [ "${scriptName}" == "" ] ; then
                if [ "${functionName}" == "" ] ; then
                   msg="${lineNumberTag}: $@"
                else
                    #msg="* ${scriptName}${functionName} -- ${dateTag}\n${lineNumber}: $@"
                    msg="${scriptFuncName} -- ${dateTag}\n${lineNumberTag}: $@"
                fi 
            else
                #msg="* ${scriptName}${functionName} -- ${dateTag}\n${lineNumber}: $@"
                msg="${scriptFuncName} -- ${dateTag}\n${lineNumberTag}: $@"             
            fi
            failedMsg="FAILED: ${scriptName}${functionName}${lineNumber}: $@ [ErrCode]="
            ;;
        *)
            msg="$@"
            failedMsg="FAILED: $@ [ErrCode]="
            ;;
    esac
    case "${G_runMode}" in
        "runOnly")
            _opDoRunOnly "$mode" "$msg" "$failedMsg" "$@" || return $?
            ;;
        "showOnly")
            _opDoShowOnly "$mode" "$msg" "$failedMsg" "$@" || return
            ;;
        "showRun")
            _opDoShowRun "$mode" "$msg" "$failedMsg" "$@" || return
            ;;
        "runSafe")
            #runSafe = unprotected: showRun, protected: show
            if [[ ${__opDo_withinCritical} -eq 0 ]] ; then
                _opDoShowRun "$mode" "$msg" "$failedMsg" "$@" || return
            else
                _opDoShowOnly "$mode" "$msg" "$failedMsg" "$@" || return
            fi
            ;;
        "showCritical"|"showProtected")
            #showCritical    = unprotected: run,     protected: show
            if [[ ${__opDo_withinCritical} -eq 0 ]] ; then
                _opDoRunOnly "$mode" "$msg" "$failedMsg" "$@" || return
            else
                _opDoShowOnly "$mode" "$msg" "$failedMsg" "$@" || return
            fi
            ;;
        "showRunCritical"|"showRunProtected")
            #showRunCritical = unprotected: run,     protected: showRun 
            if [[ ${__opDo_withinCritical} -eq 0 ]] ; then
                _opDoRunOnly "$mode" "$msg" "$failedMsg" "$@" || return
            else
                _opDoShowRun "$mode" "$msg" "$failedMsg" "$@" || return
            fi
            ;;
    esac
    return $err
}

function _opDoAssert {
    typeset err=0
    typeset scriptName="$1"; shift || exit 
    typeset functionName="$1"; shift || exit
    typeset lineNumber="$1"; shift || exit
    scriptName="${scriptName}::"
    lineNumber="[${lineNumber}]"
    typeset failedMsg="ASSERTION FAILED: ${scriptName}${functionName}${lineNumber}: $@ [ErrCode]="
    "$@" || err=$?
    if [[ $err -ne 0 ]] ; then
        EH_problem "$failedMsg" "$err"
        exit $err
    fi
}


tm_trace() {
  # $1 = traceNu
  # $2 = traceString

  if [ ${traceLevel} ] ; then
    if test $1 -le ${traceLevel} ; then
      shift
      printf >&2 "TM_,${tm_fileName},${tm_setFile},${tm_lineNo}: $*\n"
    fi
  fi
}

log_event() {
  printf >&2 "LOG_,${tm_fileName},${tm_setFile},${tm_lineNo}: $*\n"
}

eh_problem() {
  printf >&2 "EH_,${G_myName},${tm_fileName},${tm_lineNo}: PROBLEM: $*\n"
}

eh_fatal() {
  printf >&2 "EH_,${tm_fileName},${tm_lineNo}: FATAL $*\n"
  exit 1
}

function vis_runFunc {
  #EH_assert [[ $# -gt 0 ]]
  typeset func=$1
  shift
  ${func} "$@"
}

function vis_reRunAsRoot {
    EH_assert [[ $# -gt 0 ]]

    globalReRunRetVal=0

    runId=$( id -u )
    if [ "${runId}" != "0" ] ; then
        #ANT_raw "Re Invokation as root:"
        #opDo sudo ${opBinBase}/${G_myName} -i runFunc $@
        #export G_runMode="runOnly"
        opDo sudo ${G_myFullName} ${G_commandOptions} -i runFunc $@
        globalReRunRetVal=$?
        #ANT_raw retVal=${globalReRunRetVal}
        lpReturn 0
    else
        lpReturn 127
    fi
}


FN_fileSymlinkUpdate() {
  # $1 is the source/origin  name (should exist)
  # $2 is the target name (gets created)

  if  test $# -ne 2 ; then
    EH_problem "$0 requires two args: Args=$*"
    return 1
  fi

  if test -a $1 ;   then  # Src file exists
    if test  -h $2 ;     then
      printf "$2 already a symlink, removing it\n"
      ls -l $2 1>&2
      /bin/rm $2
      printf "running: ln -s $1 $2 "
      ln -s $1 $2
    elif test -a $2 ; then
      # The target should not have existed before
      printf "$2 exists: skiping $0 of $1\n"
      ls -l $2 1>&2
    else
      ln -s $1 $2
      ls -l $2 1>&2
    fi
  else
    printf "No $1: skiping $0 of $1\n"
  fi
}

#alias continueAfterThis='echo "${G_myName}::$0:$LINENO"; _continueAfterThis; if [[ ${skipIt} == "true" ]] ; then return; fi;'
alias continueAfterThis='_continueAfterThis; if [[ ${skipIt} == "true" ]] ; then return; fi;'

function _continueAfterThis {
    #echo "About to: $*"
    if [ ${G_humanUser} != "TRUE" ] ; then
        return
    fi
    echo -n "Hit enter to continue, \"skip\" to skip or \"EXIT\" to exit: "
    skipIt=false
    while read line ; do
        if [[ "${line}_" == "SKIP_"  || "${line}_" == "skip_" ]] ; then
        echo "Skiped"
            skipIt=true
            break
        fi

        if [[ "${line}_" == "EXIT_"  || "${line}_" == "exit_" ]] ; then
            exit
        fi

        if [[ "${line}_" == "_" ]] ; then
            #echo "Continuing ...."
            break
        fi

        echo "HA! ${line} -- Say Again"
        echo -n "Hit enter to continue, \"skip\" to skip or \"EXIT\" to exit: "
    done
}



_CommentBegin_
####+BEGIN: bx:dblock:global:file-insert-cond :cond "./blee.el" :file "/libre/ByStar/InitialTemplates/software/plusOrg/dblock/inserts/topControls.org"
*      ================
*  /Controls/ ::  [[elisp:(org-cycle)][| ]]  [[elisp:(show-all)][Show-All]]  [[elisp:(org-shifttab)][Overview]]  [[elisp:(progn (org-shifttab) (org-content))][Content]] | [[file:Panel.org][Panel]] | [[elisp:(blee:ppmm:org-mode-toggle)][Nat]] | [[elisp:(bx:org:run-me)][Run]] | [[elisp:(bx:org:run-me-eml)][RunEml]] | [[elisp:(delete-other-windows)][(1)]] | [[elisp:(progn (save-buffer) (kill-buffer))][S&Q]]  [[elisp:(save-buffer)][Save]]  [[elisp:(kill-buffer)][Quit]] [[elisp:(org-cycle)][| ]]
** /Version Control/ ::  [[elisp:(call-interactively (quote cvs-update))][cvs-update]]  [[elisp:(vc-update)][vc-update]] | [[elisp:(bx:org:agenda:this-file-otherWin)][Agenda-List]]  [[elisp:(bx:org:todo:this-file-otherWin)][ToDo-List]] 
####+END:
_CommentEnd_

_CommentBegin_
*      ================
*  [[elisp:(beginning-of-buffer)][Top]] ################ [[elisp:(delete-other-windows)][(1)]] CONTENTS-LIST ################
_CommentEnd_

function vis_moduleDescription {  cat  << _EOF_
*  [[elisp:(org-cycle)][| ]]  *[Description:]*
**  [[elisp:(org-cycle)][| ]]  Xrefs        :: *[Related/Xrefs:]*  <<Xref-Here->>  -- External Documents  [[elisp:(org-cycle)][| ]]
**  [[elisp:(org-cycle)][| ]]  Panel        :: [[file:/libre/ByStar/InitialTemplates/activeDocs/blee/syncUpdate/virBox/fullUsagePanel-en.org::Xref-][Panel Roadmap Documentation]] [[elisp:(org-cycle)][| ]]
_EOF_
}

function vis_moduleUsage {  cat  << _EOF_
*  [[elisp:(org-cycle)][| ]]  *[Usage:]*
   See -i examples for more details.
_EOF_
}

function vis_moduleStatus {  cat  << _EOF_
*  [[elisp:(org-cycle)][| ]]  *[Status:]*
** TODO [#B] [[elisp:(org-cycle)][| ]]  Next Steps    ::  Redirect stderr to be colored  [[elisp:(org-cycle)][| ]]
    http://serverfault.com/questions/59262/bash-print-stderr-in-red-color
   SCHEDULED: <2016-08-02 Tue>
** TODO [#B] [[elisp:(org-cycle)][| ]]  Next Steps    ::  We are ready to add virshInstall to virtBuild   [[elisp:(org-cycle)][| ]]
    SCHEDULED: <2016-07-31 Sun>
_EOF_
}

_CommentBegin_
*  [[elisp:(beginning-of-buffer)][Top]] ################ [[elisp:(delete-other-windows)][(1)]]  *Examples and IIFs*
_CommentEnd_


_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  IIM Wide      :: G_postParamHook  [[elisp:(org-cycle)][| ]]
_CommentEnd_

function G_postParamHook {
    EH_assert [[ $# -eq 0 ]]
}


_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  Examples      :: Examples  [[elisp:(org-cycle)][| ]]
_CommentEnd_


function vis_examples {
    typeset extraInfo="-h -v -n showRun -r basic"
    #typeset extraInfo=""
    typeset runInfo="-p ri=lsipusr:passive"

    typeset examplesInfo="${extraInfo} ${runInfo}"

    visLibExamplesOutput ${G_myName} 
  cat  << _EOF_
$( examplesSeperatorTopLabel "${G_myName}" )
_EOF_
}

noArgsHook() {
  vis_examples
}

_CommentBegin_
*  [[elisp:(beginning-of-buffer)][Top]] ################ [[elisp:(delete-other-windows)][(1)]]  *Common iimStandaloneActions*
_CommentEnd_


####+BEGIN: bx:dblock:global:file-insert :file "/libre/ByStar/InitialTemplates/software/bxDblock/bash/iimStandaloneActions.bash"
#
# /opt/public/osmt/bin/iimStandaloneLib.bash is common code
# which is included at the end of iimStandalone modules.
# 


_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  iimActions    :: /[dblock]/ iimStandaloneActions.bash [[elisp:(org-cycle)][| ]]
_CommentEnd_

function visLibExamplesOutput {
    # $1=callingsName
    cat  << _EOF_
$( examplesSeperatorChapter "COMMON SEEDED EXAMPLES" )
${1} -i examplesCommonSeeded
${1} -i visit
${1} -i describe
${1} -i examples
_EOF_
}

function vis_examplesCommonSeeded {
 cat  << _EOF_
$( examplesSeperatorChapter "COMMON EXAMPLES" )
${G_myName} -i showMe
${G_myName} -i seedHelp
${G_myName} -n showOnly -T 9 -i help
${G_myName} -i runFunc func args
${G_myName} -i visit
_EOF_
}


function examplesSeperatorTopLabel {
 cat  << _EOF_
###############################  $@  #################################
_EOF_
}


function examplesSeperatorChapter {
 cat  << _EOF_
#################  $@  #################
_EOF_
}


function examplesSeperatorSection {
 cat  << _EOF_
=================  $@  =================
_EOF_
}


function examplesSeperatorSubSection {
 cat  << _EOF_
-----------------  $@  -----------------
_EOF_
}

function vis_showMe {
 cat  << _EOF_
--- Program Parameters
RcsId=${RcsId}
G_argsOrig=${G_argsOrig}
G_progName=${G_progName}
G_myName=${G_myName}
G_myInvokedName=${G_myInvokedName}
G_myFullName=${G_myFullName}
G_runMode=${G_runMode}
G_verbose=${G_verbose}
G_checkMode=${G_checkMode}
G_forceMode=${G_forceMode}
--- OSMT Configurable Parameters
opShellVersion=${.sh.version}
opBase=${opBase}
--- User Parameters
opRunAcctName=${opRunAcctName}
_EOF_
# Also Trace Level
# NOTYET, Also show other relevant opBase and config parameters

  printf -- "--- OSMT INFO ---"
  # NOTYET, test that it exists, use the right variable
  cat /etc/osmtInfo
}

function vis_seedHelp {
 cat  << _EOF_

The following features are available to all scripts based on
seedActions.sh and seedSubjectActions.sh

Tracing:     -T <runLevelNumber>  -- Ex: ${G_myName} -T 9
Run Mode:    -n <runMode>         -- Ex: ${G_myName} -n runSafe
Record Mode: -r <recordMode>      -- Ex: ${G_myName} -r basic
Verbose:     -v                   -- Ex: ${G_myName} -v
Elaborate:   -e                   -- Ex: ${G_myName} -e elaborationTextIsIgnored
Force Mode:  -f                   -- Ex: ${G_myName} -f
Check Mode:  -c                   -- Ex: ${G_myName} -c fast

Tracing
=======
            DEFAULT: -T 0

            Trace Number Conventions:

            0: No Tracing
            1: Application Basic Info
            2: Application General Info
            3: Application Function Entry and Exit
            4: Application Debugging
            5: Wrappers Library
            6: Seed Script
            7: Seed Supporting Libraries (eg, doLib.sh)
            8: ocp_library
            9: Quick Debug, usually temporary

Run Mode:
=========
           DEFAULT: runOnly

G_runMode=
   showOnly:           at opDo* just show the args always return 0
   runOnly:            at opDo* just execute
   showRun:            at opDo both runOnly and showOnly
   runSafe:            at opDo both show and run, but if protected
                       then just show
   showProtected:      Run everything and don't show except for
                       show only protected
   showRunProtected:   Run everything and don't show except for
                       run and show rotected

runSafe = unprotected: showRun, protected: show
showProtected = unprotected: run, protected: show
showRunProtected = unprotected: run, protected: showRun 

Verbose Mode:
=============

G_verbose=
   verbose        When Set, verbose format (eg, line nu, time tag, ...)
                  of Tracing and RunMode are selected.

Force Mode:
=============

G_forceMode=
   force          When Set, force/overwrite mode of operation
                  is selected.

Check Mode:
===========

G_checkMode={fast,strict,full}
   fast:          1) Skip asserting and consistency checks.
                  2) Do less than default, invoker will 
                     compensate
   strict:        Do asserts and consistency checks.
   full:          1) Do more than default

_EOF_
}


####
FN_nonDirsPart() {
    echo `basename "$1"`
}


function FN_absolutePathGet {
  # $1 = given file

  if  test  $# -ne 1 ; then
    return 1
  fi

  typeset givenFile=$1

  if [ "${givenFile}" == "" ] ; then
      return 1
  fi

  # Similar to expand-file-name in elisp
  # Convert filename NAME to absolute, and canonicalize it.
  # 

  givenFile=`eval /bin/echo "${givenFile}"`

  local absPath=""

  if [ -d "${givenFile}" ] ; then
      (cd ${givenFile}; pwd -P)
  else
      absPath=$(
  case $givenFile in
    */*) cd ${givenFile%/*} ;;
  esac
  pwd -P
)/${givenFile##*/}
  fi

  echo ${absPath}
}


if [[ "${BASH_VERSION}X" != "X" ]] ; then
    alias ANT_cooked='tm_fileName=$FUNCNAME; tm_lineNo=$LINENO; ant_cooked'
    alias ANV_cooked='tm_fileName=$FUNCNAME; tm_lineNo=$LINENO; anv_cooked'
else
    alias ANT_cooked='tm_fileName=$0; tm_lineNo=$LINENO; ant_cooked'
    alias ANV_cooked='tm_fileName=$0; tm_lineNo=$LINENO; anv_cooked'
fi


alias stdOutput='print -r --'

function ANT_raw {
    #print -u2 -r -- "$*"
    printf --  1>&2  "$*\n"         
    #( printf  "$*\n" ) > /dev/stdout
}

function ANV_raw {
  if [[ "${G_verbose}_" == "verbose_" ]] ; then
      #print -u2 -r -- "$*"
      printf  1>&2  "$*\n"     
  fi
}

function ant_cooked {
    #print -u2 -r -- "NOTE,${G_myName},${tm_fileName},${tm_lineNo}: $*"
    if [ -z "${G_recordMode}" ] ; then
        printf  1>&2 "NOTE,${G_myName},${tm_fileName},${tm_lineNo}: $*\n"  
    else
        printf  1>&2 "** NOTE,${G_myName},${tm_fileName},${tm_lineNo}: $*\n"  
    fi
}

function anv_cooked {
  if [[ "${G_verbose}_" == "verbose_" ]] ; then
      #print -u2 -r -- "NOTE,${G_myName},${tm_fileName},${tm_lineNo}: $*"
    if [ -z "${G_recordMode}" ] ; then
        printf  1>&2 "NOTE,${G_myName},${tm_fileName},${tm_lineNo}: $*\n"  
    else
        printf  1>&2 "** [[file:${G_myFullName}::${tm_lineNo}][inBaseDirDo]] $*\n"  
    fi
  fi
}


# {{{ Describe

function vis_describeLocal {
    cat  << _EOF_
_EOF_
}

# }}}


function lpSilentPushd {                                                                   
    if (("$#" > 0)); then
        pushd "$@" > /dev/null
    else
        cd $HOME
    fi
}

function lpSilentPopd {                                                                   
        popd "$@" > /dev/null
}


function lpPushd {                                                                   
    if (("$#" > 0)); then
        pushd "$@" > /dev/null
        ANV_cooked "Pushded to $( pwd )"
    else
        cd $HOME
    fi
}

function lpPopd {                                                                   
        popd "$@" > /dev/null
        ANV_cooked "Popded to $( pwd )"
}


function vis_inBaseDirDo {
    inBaseDirDo "$@"
}

function inBaseDirDo {
    G_funcEntry
    function describeF {  G_funcEntryShow; cat  << _EOF_
Arg-1 =${baseDir} is a baseDirectory.
Arg-2 and REST =${doCommand} are the command to do. 
If baseDirectory exists, we go there and ${doCommand}.
_EOF_
    }
    EH_assert [[ $# -ge 2 ]]

    typeset baseDir=$1

    shift

    typeset doCommand=$@

    if [ -d ${baseDir} ] ;  then
        lpSilentPushd ${baseDir}
        if [ -z "${G_recordMode}" ] ; then
            #printf  1>&2 "Misiing ** -- In $( pwd ) Running: ${doCommand}\n"  
            ANV_cooked "In $( pwd ) Running: ${doCommand}"          
        else
            #printf  1>&2 "NOT Missing ** -- In $( pwd ) Running: ${doCommand}\n"           
            ANV_cooked "In $( pwd ) Running: ${doCommand}"          
        fi
        ${doCommand}
        lpSilentPopd > /dev/null
    else
        EH_problem "Missing ${baseDir} -- Skiping:  ${doCommand}"
        lpReturn 101
    fi

    lpReturn
}


# AttrType=AttrValue Parsing  "leftSide=rightSide"

ATTR_leftSide() {
    # Escapes all non alphanumeric characters.
    typeset key=`echo "$1" | perl -p -e 'if (/([^=]+)=(.+)*/) { my $a=$1; $a =~ s/([^A-Za-z0-9])/\\\\$1/g; $_=$a; } else { die "Cannot find key"; }'` || exit
    #print ${1%%=*}
    print $key
}

ATTR_rightSide() {
    #print ${1#*=}
    # Escapes all non alphanumeric characters.
    typeset value=`echo "$1" | perl -p -e 'if (/([^=]+)=(.+)/) { my $a=$2; $a =~ s/([^A-Za-z0-9])/\\\\$1/g; $_=$a; } else { $_=""; }'` || exit
    print $value
}

function Equal_leftSide {
 echo ${1%%=*}
}

function Equal_rightSide {
  echo ${1##*=}
}


function Column_leftSide {
 echo ${1%%:*}
}

function Column_rightSide {
  echo ${1##*:}
}

function Plus_leftSide {
 echo ${1%%+*}
}

function Plus_rightSide {
  echo ${1#*+}
}


############## USED TO START HERE #############
#. ${opBase}/lib/ocp-lib.sh

# opBasePathSet

#systemName=`uname -n`
#devlOsType=`uname -s`


###

[[ ":$PATH:" != *":/usr/sbin:"* ]] && PATH="/usr/sbin:${PATH}"
[[ ":$PATH:" != *":/sbin:"* ]] && PATH="/sbin:${PATH}"
[[ ":$PATH:" != *":/usr/bin:"* ]] && PATH="/usr/bin:${PATH}"
[[ ":$PATH:" != *":/usr/local/bin:"* ]] && PATH="/usr/local/bin:${PATH}"
[[ ":$PATH:" != *":.:"* ]] && PATH=".:${PATH}"

# Get options (defaults immediately below):

badUsage=
traceLevel=

Array paramInfo
loadFiles=""

#G_checkMode=""
#G_forceMode=""

G_argsOrig="$@"
G_progName=`FN_nonDirsPart ${0}`

G_humanUser=FALSE

TM_trace 9 ${G_argsOrig}

dotMeParamTmpFile=/tmp/${G_progName}.dotMe.$$

G_runMode="runOnly"
G_runModeCmndOption=" -n runOnly "

G_recordMode=""
G_recordModeCmndOption=""

G_paramCmndOption=""

while getopts e:T:c:i:p:l:u?n:r:vfh c
do
    case $c in
    T)
        case $OPTARG in
        *[!0-9]* )
            echo "$0: -T requires a numeric option"
            badUsage=TRUE
            ;;
        [0-9]* )
            traceLevel=$OPTARG
            ;;
        esac
        ;;
    i)
        visibleFunction="${OPTARG}"   # rest of argv is passed to visibleFunction
        ;;
    p)
        # MB-2018 -- I am not sure why this was needed
        #leftSide=`ATTR_leftSide "${OPTARG}"`
        #rightSide=`ATTR_rightSide "${OPTARG}"`
        #echo "${leftSide}"="${rightSide}" >> ${dotMeParamTmpFile}
        
        echo "${OPTARG}" >> ${dotMeParamTmpFile}

        G_paramCmndOption=" -p ${OPTARG} ${G_paramCmndOption}"
       ;;
    l)
        loadFiles="${loadFiles} ${OPTARG}"
        G_myName=`FN_nonDirsPart ${OPTARG}`
        G_myInvokedName=${OPTARG}
        ;;

    c)
        G_checkMode="${OPTARG}"
        G_checkCmndOption=" -c "
        ;;

    e)
        # Elaboration Text SimplyIgnored
        elaborationTextSimplyIgnored="${OPTARG}"
        ;;

    n)
        case ${OPTARG} in 
            "runOnly")
                G_runMode="runOnly"
                G_runModeCmndOption=" -n runOnly "
                ;;
            "showOnly")
                G_runMode="showOnly"
                G_runModeCmndOption=" -n showOnly "
                ;;
            "seeRun")
                G_runMode="seeRun"
                G_runModeCmndOption=" -n seeRun "
                ;;
            "showRun")
                G_runMode="showRun"
                G_runModeCmndOption=" -n showRun "
                ;;
            "runSafe")
                G_runMode="runSafe"
                G_runModeCmndOption=" -n runSafe "
                ;;
            "showProtected")
                G_runMode="showProtected"
                G_runModeCmndOption=" -n showProtected "
                ;;
            "showRunProtected")
                G_runMode="showRunProtected"
                G_runModeCmndOption=" -n showRunProtected "
                ;;
            *)
                badUsage=TRUE
                ;;
        esac
        ;;

    r)
        case ${OPTARG} in 
            "basic")
                G_recordMode="basic"
                G_recordModeCmndOption=" -r basic "
                ;;
            *)
                G_recordMode="${OPTARG}"
                G_recordModeCmndOption=" -r ${OPTARG} "
                ##badUsage=TRUE
                ;;
        esac
        ;;

    v)
        G_verbose="verbose"
        G_verboseCmndOption=" -v "
        ;;

    f)
        G_forceMode="force"
        G_forceModeCmndOption=" -f "
        ;;

    h)
        G_humanUser=TRUE
        G_humanCmndOption=" -h "
        ;;

    u | \?)
        badUsage=TRUE
        ;;
    esac
done

G_commandOptions="${G_checkCmndOption} ${G_runModeCmndOption} ${G_verboseCmndOption} ${G_humanCmndOption} ${G_forceModeCmndOption} ${G_paramCmndOption}"
#echo "G_commandOptions=${G_commandOptions}"

typeset myOptind=$OPTIND

function opMyFullNameGet {
  typeset firstChar=${G_myInvokedName:0:1}

  if [[ "${firstChar}X" == "/X" ]] ; then 
    G_myFullName=${G_myInvokedName}
    G_myFullName=$( FN_absolutePathGet ${G_myFullName} )
    return 
  fi
  
  if [[ -f ${G_myInvokedName} ]] ; then
    G_myFullName=${PWD}/${G_myInvokedName}
  else
    G_myFullName=`which ${G_myName}`
  fi

  G_myFullName=$( FN_absolutePathGet ${G_myFullName} )
  
  if [[ ! -f ${G_myFullName} ]] ; then
     printf  >&2  ${G_myFullName} not found
     return 1
  fi
}

opMyFullNameGet


if [[ "${G_forceMode}_" != "_" ]] ; then
    export G_forceMode="${G_forceMode}"
fi
if [[ "${G_checkMode}_" != "_" ]] ; then
    export G_checkMode="${G_checkMode}"
    #print -u2 G_checkMode="${G_checkMode}"
fi


#defaultLoadFile=${mmaBinDistBase}/bin/`FN_prefix $0`.load
#    TM_trace 7 "Loading ${defaultLoadFile}"

#if test -f ${defaultLoadFile} ; then
#    TM_trace 7 "Loading ${defaultLoadFile}"
#    . ${defaultLoadFile}
#fi

#
# Load In Parameter Specificication Code 
# and possibly item_ code ...
# 
#

for i in ${loadFiles} ; do
    if test -f ${i} ; then
        TM_trace 7 "Pre Loading: $i"
        loadSegment="PRE"
        . ${i}
    else
        EH_problem "${i} not found: skiping it."
        usage=TRUE
        #exit
    fi
done

#opParamMandatoryVerify
#
# Now that we have all the parameters, get the job done.
#

#
# Bring in post load code
# 

#TM_trace 7  "loadSegment=${loadSegment}"

if [ "${loadSegment}_" == "POST_" ] ; then
for i in ${loadFiles} ; do
    if test -f ${i} ; then
        TM_trace 7 "Post Loading: $i"
        . ${i}
    else
        EH_problem "${i} not found: skiping it."
        usage=TRUE
        #exit
    fi
done
fi

G_preParamHookVal=`ListFuncs | egrep '^G_preParamHook$'`
if [ "${G_preParamHookVal}X" != "X" ] ;   then
  G_preParamHook 
fi

#
# EXECUTE PARAMETER ASSIGNMENTS
#

function iimParamFuncsInvoke {
    EH_assert [[ $# -eq 0 ]]
    declare iimParamFuncsList=$( declare -F | grep iimParam_ | sed -e s/"declare -f "// | cut -d= -f1 )
    for thisFunc in ${iimParamFuncsList} ; do
        #opDo ${thisFunc} # NOTYET, subject this to tracing
        ${thisFunc}
    done
}

iimParamFuncsInvoke

if [[ -f ${dotMeParamTmpFile} ]] ; then
  . ${dotMeParamTmpFile}
  rm ${dotMeParamTmpFile}
fi


G_postParamHookVal=`ListFuncs | egrep '^G_postParamHook$'`
if [ "${G_postParamHookVal}X" != "X" ] ;   then
  G_postParamHook 
fi


#
# VERIFY COMPLETENESS OF REQUIRED PARAMETERS
#
function opParamMandatoryVerify {

  #if [[ "${BASH_VERSION}_" != "_" ]] ; then
    # Because bash does not implement 
    # typeset -t, this feature is not
    # functional in bash
  #  return 0
  #fi

  typeset retVal=0
  typeset i=""

  paramsList=`TagVarList`
  
  for i in ${paramsList} ; do
    if  [ "${i}X" == "X" ] ; then continue; fi;
      printf "if [ \"\${$i}_\" == \"MANDATORY_\" ] || [ \"\${$i}_\" == \"mandatory_\" ] ; then echo \"$i must be specified\"; badUsage=TRUE; fi;" > ${dotMeParamTmpFile}

      #cat ${dotMeParamTmpFile}
      . ${dotMeParamTmpFile}
  done

  if [[ "${badUsage}" == "TRUE" ]] ; then
    exit 1
  fi

  FN_fileRmIfThere ${dotMeParamTmpFile}

  return ${retVal}
}


# BEGIN item_ FUNCTIONS

# END item_ FUNCTIONS


#  BEGIN do_ FUNCTIONS

#  END OF DO_ FUNCTIONS


function dash_i_set {
    if [ "${dash_i}" = "" ] ; then
        dash_i="-i"
    elif [ "${dash_i}" = "nil" ] ; then
        dash_i=""
    else
        EH_problem "Oops"
        exit 1
    fi
}

function usage {

  # to get subject specific itemCmd_ lines

  printf >&2 "Usage: ${G_myName} [ -T traceLevel ] [ -u ] [ -p parameter=value ] [-i visibleFunction] \n"
    
    visFuncsList=`ListFuncs | egrep '^vis_'`
    printf >&2 "Usage: visibleFunction is one of: "
    for i in ${visFuncsList}
    do
      printf >&2 "${i##vis_} "
    done
    printf >&2 "\n"

}


#########  EXECUTION STARTS HERE ############

#G_validateOption ${action}  "${actionValidList}"

#G_validateRunOS "${runOSValidList}"


#
# REPORT USAGE PROBLEMS
#

if [ ${badUsage} ]
then
    usage
    exit 1
fi

#shift `expr $OPTIND - 1`
shift `expr $myOptind - 1`

G_argv="$@"

#TM_trace 9 Args="$@"

#
# PERFORM REQUESTED TASKS
#

if [ ! -z "${G_recordMode}" ] ; then
    trap iimRecordEnd EXIT
    #trap iimRecordEnd ERR    
fi

if [ "${visibleFunction}X" != "X" ]
then
    #echo "running ${visibleFunction}"
    if [ ! -z "${G_recordMode}" ] ; then
        iimRecordBegin
    fi
    
    vis_${visibleFunction} "$@"
    exitCode=$?

    if [ ! -z "${G_recordMode}" ] ; then        
        iimRecordEnd
    fi
    
    exit ${exitCode}
fi

function runNoArgsHook {
  noArgsHookVal=`ListFuncs | egrep '^noArgsHook$'`
  if [ "${noArgsHookVal}X" != "X" ] ;   then
    noArgsHook "$@"
  else
    echo "No action taken. Specify options."
    usage
  fi
  exit
}

if [ ! -z "${G_recordMode}" ] ; then
    iimRecordBegin
fi

runNoArgsHook "$@"
exitCode=$?

if [ ! -z "${G_recordMode}" ] ; then    
    iimRecordEnd
fi

exit ${exitCode}
