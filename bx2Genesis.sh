#!/bin/bash

dateTag=$( date +%y%m%d%H%M%S )
logFile=~/bx2Genesis-${dateTag}.log

exec &> >(tee "${logFile}")

StandaloneIimBriefDescription="Bx2 Genesis -- Transforms The Distro To The Specified BxPlatform SwProfile"

ORIGIN="
* Revision And Libre-Halaal CopyLeft -- Part Of ByStar -- Best Used With Blee
* Latest Version Available At: http://www.bysource.org/lsip/bx2Genesis.sh
"

####+BEGIN: bx:dblock:bash:top-of-file :vc "cvs" partof: "bystar" :copyleft "halaal+brief"
typeset RcsId="$Id: bx2Genesis.sh,v 1.15 2020-04-06 04:16:35 lsipusr Exp $"
# *CopyLeft*
# Copyright (c) 2011 Neda Communications, Inc. -- http://www.neda.com
# See PLPC-120001 for restrictions.
# This is a Halaal Poly-Existential intended to remain perpetually Halaal.
####+END:

__author__="
* Authors: Mohsen BANAN, http://mohsen.banan.1.byname.net/contact
"

_comment_="
*  [[elisp:(beginning-of-buffer)][Top]] ################ [[elisp:(delete-other-windows)][(1)]]  *Common iimStandaloneLib*
"

####+BEGIN: bx:dblock:global:file-insert :file "/libre/ByStar/InitialTemplates/software/bxDblock/bash/iimStandaloneLib.bash"
#
# /opt/public/osmt/bin/iimStandaloneLib.bash is common code
# which is included in the begining of iimStandalone modules.
# 

if [ -z "${BASH_VERSION}" ] ; then
    echo "UnSupported Bash"
    exit 1
fi

shopt -s expand_aliases
shopt -s extglob
#shopt

alias _CommentBegin_='cat << _CommentEnd_ > /dev/null'


_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  iimLib        :: /[dblock]/ iimStandaloneLib.bash [[elisp:(org-cycle)][| ]]
_CommentEnd_

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
*  [[elisp:(org-cycle)][| ]]  iimLib        :: /[dblock]-End/ iimStandaloneLib.bash [[elisp:(org-cycle)][| ]]
_CommentEnd_


####+END:


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
**  [[elisp:(org-cycle)][| ]]  Overview     ::  [[elisp:(org-cycle)][| ]] 

 This script is part of the instructions for
    Libre Platform Genesis
 as documented in PLPC-110101
 available at:
     http://www.libreservices.org/PLPC/110101
     http://www.neda.com/PLPC/110101


 This and everything else that it brings over
 is Free/Libre Software and 
 the produced service is Libre Services.


 The latest version of this script can be obtained from
   wget -N  http://www.bysource.org/lsip/lpGenesis.sh



This is a STANDALONE script and does NOT rely on any 
osmt scripts.
This is a single file, self contained script which 
augments a generic genesis machine to a state where it 
can use OSMT facilities to be further configured.

Once OSMT has been configured it continues on 
with .../bin/lpSysMgmtSteps.sh


 This script should run with the initial os shell which 
 can be any of:  bash, ksh88, ksh93, pdksh
 It is now converging on bash.


USAGE: 
Run ./lpGenesis.sh help
for details 
Accepts zero or one or two arguments which can be the LOCATION and 
NAME for the host.

 This script should run with the initial os shell which 
 can be any of:  bash, ksh88, ksh93, pdksh


TODO:
  - tar -xf --checkpoint
  - cvs checkout stdout/stderr to /dev/null
  - Create a logfile.
  - Too many packages are being brought over.
  - Make the script verify it is the latest with a wget
  - wget the undo if not already there.
_EOF_
}

function vis_moduleUsage {  cat  << _EOF_
*  [[elisp:(org-cycle)][| ]]  *[Usage:]*
   See -i examples for more details.
_EOF_
}


function vis_moduleStatus {  cat  << _EOF_
*  [[elisp:(org-cycle)][| ]]  *[Status:]*
** TODO [#B] [[elisp:(org-cycle)][| ]]  Problem      ::  CVS and ttf-microsoft Fonts Prompts   [[elisp:(org-cycle)][| ]]
   ttf-mscorefonts-installer Failure to download extra data files
   SCHEDULED: <2016-07-31 Sun>
** TODO [#A] [[elisp:(org-cycle)][| ]]  Problem      ::  opDo has not been implemented   [[elisp:(org-cycle)][| ]]
   SCHEDULED: <2016-07-31 Sun>
** TODO [#B] [[elisp:(org-cycle)][| ]]  Problem      ::  lsipusr has not been added to sudoers   [[elisp:(org-cycle)][| ]]
   SCHEDULED: <2016-07-31 Sun>
** TODO [#B] [[elisp:(org-cycle)][| ]]  Next Steps   ::  Add anon or auth to options  [[elisp:(org-cycle)][| ]]
   SCHEDULED: <2016-07-31 Sun>
** TODO [#B] [[elisp:(org-cycle)][| ]]  Next Steps   ::  Change basicIoC to basicBxoC (BxO Container)  [[elisp:(org-cycle)][| ]]
   SCHEDULED: <2016-07-31 Sun>
** TODO [#A] [[elisp:(org-cycle)][| ]]  Problem      ::  magit is missing lceEmacsAdmin.sh   [[elisp:(org-cycle)][| ]]
   SCHEDULED: <2016-07-31 Sun>
_EOF_
}

_CommentBegin_
*  [[elisp:(beginning-of-buffer)][Top]] ################ [[elisp:(delete-other-windows)][(1)]]  *Examples and IIFs*
_CommentEnd_


_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  Examples      :: Examples [[elisp:(org-cycle)][| ]]
_CommentEnd_


function vis_examples {
    typeset extraInfo="-h -v -n showRun -r basic"
    #typeset extraInfo=""
    typeset runInfo="-p ri=lsipusr:passive"

    typeset examplesInfo="${extraInfo} ${runInfo}"

    visLibExamplesOutput ${G_myName} 
  cat  << _EOF_
$( examplesSeperatorTopLabel "${G_myName}" )
$( examplesSeperatorChapter "Bx2Genesis.sh Renew" )
${G_myName} ${extraInfo} -i renewMe
$( examplesSeperatorChapter "Bx2 Targeted Software Profiles" )
${G_myName} ${extraInfo} -i miniBlee
$( examplesSeperatorSection "Software Profiles (SwP) -- Bx2 Ref Model " )
${G_myName} ${extraInfo} -i baseIoC            # Blee + Ability To Import Io
${G_myName} ${extraInfo} -i baseIoC atNeda     # Blee + Ability To Import Io
${G_myName} ${extraInfo} -i userService        # Internal Services
${G_myName} ${extraInfo} -i externalService    # Public Internet Services
${G_myName} ${extraInfo} -i developer          # UserService + All the extras
${G_myName} ${extraInfo} -i virtHost           # A Host For KVM
$( examplesSeperatorSection "BxP Generic Characters" )
${G_myName} ${extraInfo} -i blup  # Bx Light User Platform (BxP-User-SwP + BMIC) 
${G_myName} ${extraInfo} -i bmup  # Bx Mobile Usage Platform
${G_myName} ${extraInfo} -i bdip  # Bx Developer Internal Platform
${G_myName} ${extraInfo} -i busp  # Bx User Service Platform
${G_myName} ${extraInfo} -i bxsp  # Bx External Service Platform 
$( examplesSeperatorChapter "Current Platform Info" )
${G_myName} ${extraInfo} -i opRunDistFamilySet
${G_myName} ${extraInfo} -i profile
${G_myName} ${extraInfo} -i status
$( examplesSeperatorChapter "Developer Examples" )
${G_myName} ${extraInfo} -i devExamples
_EOF_
}


_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  Dev Examples  :: Developer Examples [[elisp:(org-cycle)][| ]]
_CommentEnd_


function vis_devExamples {
    typeset extraInfo="-h -v -n showRun"
    #typeset extraInfo=""
    typeset runInfo="-p ri=lsipusr:passive"

    typeset examplesInfo="${extraInfo} ${runInfo}"

    #visLibExamplesOutput ${G_myName}
    vis_examples
  cat  << _EOF_
$( examplesSeperatorTopLabel "${G_myName}" )
$( examplesSeperatorChapter "Developer Examples" )
${G_myName} ${extraInfo} -i identity
${G_myName} ${extraInfo} -i welcomeMessage
_EOF_
}


noArgsHook() {
    #vis_examples
    vis_devExamples    
}


_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  IIFs          :: Unsorted BxGenesis.sh |  [[elisp:(org-cycle)][| ]]
_CommentEnd_


opRunMachineArch=`uname -m`
typeset osType=`uname -s`
#typeset hostName=`uname -n`
typeset hostName=genesis1

typeset location="far"
typeset far_ShortCut=""
typeset atNeda_ShortCut="route -n add -net 198.62.92.0/24 gw 192.168.0.23"

dateTag=`date +%y%m%d%H%M%S`

_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  IIFs          :: ifNotCleanThenlpGenesisUndo |  [[elisp:(org-cycle)][| ]]
_CommentEnd_



function ifNotCleanThenlpGenesisUndo {
  isClean="TRUE"

  if [ -d /here ] ; then 
    isClean="FALSE"
  elif [ -f /bin/osmtKsh ] ; then 
    isClean="FALSE"
  elif [ -f /etc/osmtInfo ] ; then 
    isClean="FALSE"
  else
    isClean="TRUE"
  fi
  
  if [ "${isClean}_" == "FALSE_" ] ; then
    echo "A Previous OSMT installation was observed"
    echo "We will next remove the old installation"
    echo "Use SKIP if you DONT wish to remove the old installation"

    continueAfterThis

    lpGenesisUndo
  fi
}


_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  IIFs          :: renewMe |  [[elisp:(org-cycle)][| ]]
_CommentEnd_



function vis_renewMe {
    if [ -f "./bx2Genesis.sh" ] ; then
       opDo mv ./bx2Genesis.sh ./bx2Genesis.sh-$( date +%y%m%d%H%M%S )
    fi
    opDo wget -O ./bx2Genesis.sh  http://www.bysource.org/lsip/bx2Genesis.sh
    opDo chmod ugo+x ./bx2Genesis.sh
}


_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  IIFs          :: lpGenesisUndo |  [[elisp:(org-cycle)][| ]]
_CommentEnd_



function lpGenesisUndo {

echo "removing any route shortcuts"

route -n delete -net 198.62.92.0/24 gw 192.168.0.23

netstat -r -n
continueAfterThis

echo "About to Undo Account"
continueAfterThis

/opt/public/osmt/bin/opAcctUsers.sh -h -v -n showRun -i acctDeleteAndRemoveHomeDir lsipusr


continueAfterThis

echo "RUNNING: /bin/rm -r -f /here"
/bin/rm -r -f /here

echo "RUNNING: /bin/rm -r -f  /opt"
/bin/rm -r -f  /opt

echo "RUNNING: /bin/rm /bin/osmtKsh"
/bin/rm /bin/osmtKsh

echo "RUNNING: /bin/rm /etc/osmtInfo"
/bin/rm /etc/osmtInfo 

}


_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  IIFs          :: adjustSourcesList |  [[elisp:(org-cycle)][| ]]
_CommentEnd_



function adjustSourcesList {

  case ${opRunDistFamily} in
    "UBUNTU"|"DEBIAN")
	  echo  "About To: Adjust (eliminate cdrom) sources.list"; continueAfterThis

	  if [ -f /etc/apt/sources.list.orig ] ; then 
	      cp /etc/apt/sources.list /etc/apt/sources.list.$$
	  else
	      cp -p /etc/apt/sources.list /etc/apt/sources.list.orig
	  fi

	  grep -v "cdrom" /etc/apt/sources.list > /tmp/sources.NoCdrom.$$

	  mv /tmp/sources.NoCdrom.$$ /etc/apt/sources.list

	  apt-get update
       ;;
    "MAEMO")

	  echo "/etc/apt/sources.list is assumed to be good"
       ;;
    "REDHAT"|"SOLARIS"|"UNKNOWN"|"UNSUPPORTED")
	  echo "Unsupported distribution: ${opRunDistFamily}"
	  return 1
       ;;
    *)
	  echo "Oops distribution: ${opRunDistFamily}"
	  return 1
       ;;
  esac

}


_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  IIFs          :: installCVS |  [[elisp:(org-cycle)][| ]]
_CommentEnd_



function installCVS {
  case ${opRunDistFamily} in
    "UBUNTU"|"DEBIAN")
	  echo  "About To: Install cvs"; continueAfterThis
	  apt-get install cvs
	  apt-get install sudo
       ;;
    "MAEMO")
	  echo  "About To: Install cvs"; continueAfterThis
	  apt-get -y install wget
	  wget http://www.bybinary.org/republish/maemo/4.x/armel/cvs
	  mv cvs /usr/bin/cvs
	  chmod 755 /usr/bin/cvs
       ;;
    "REDHAT"|"SOLARIS"|"UNKNOWN"|"UNSUPPORTED")
	  echo "Unsupported distribution: ${opRunDistFamily}"
	  return 1
       ;;
    *)
	  echo "Oops distribution: ${opRunDistFamily}"
	  return 1
       ;;
  esac
}

function bashAsOsmtKsh {
   echo  "About to Link /bin/bash to /bin/osmtKsh, Will run:"
   echo "ln -s /bin/bash  /bin/osmtKsh"

   continueAfterThis
   ln -s /bin/bash  /bin/osmtKsh
}

function setupRouteShortCuts {

  echo "Setting Up Route Short Cut (if applicable) For ${location}:"

  if [[ "${location}_" == "atNeda_" ]] ; then
    sudo apt install net-tools
    echo "Running: ${atNeda_ShortCut}"
    `${atNeda_ShortCut}`

    netstat -r -n
    continueAfterThis
  fi
}


_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  IIFs          :: step2_getOsmts -- lsipEnabled State |  [[elisp:(org-cycle)][| ]]
_CommentEnd_



function step2_getOsmt {
  echo  "About To: Get OSMT"; continueAfterThis
  mkdir -p /here/opt/public
  cd /here/opt/public

  echo "RUNNING: cvs -d :pserver:anoncvs@cvs.bysource.org:/rep1 checkout -d osmt public/dist-osmt"
  cvs -d :pserver:anoncvs@cvs.bysource.org:/rep1 checkout -d osmt public/dist-osmt 1>> /dev/null

  mkdir -p /opt/public
  ln -s /here/opt/public/osmt /opt/public/osmt
  export PATH=/opt/public/osmt/bin:${PATH}
}

function step2_getOsmtBx2 {
  echo  "About To: Get OSMT"; continueAfterThis
  mkdir -p /here/opt/public
  cd /here/opt/public

  echo "RUNNING: cvs -d :pserver:anoncvs@cvs.bysource.org:/rep1 checkout -d osmt.bx2 public/dist-osmt.bx2"
  cvs -d :pserver:anoncvs@cvs.bysource.org:/rep1 checkout -d osmt.bx2 public/dist-osmt.bx2 1>> /dev/null

  mkdir -p /opt/public
  ln -s /here/opt/public/osmt.bx2 /opt/public/osmt
  export PATH=/opt/public/osmt/bin:${PATH}
}


_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  IIFs          :: selectIntraGenesis1 |  [[elisp:(org-cycle)][| ]]
_CommentEnd_


function selectIntraGenesis1 {

  export PATH=/opt/public/osmt/bin:${PATH}
  typeset osmtSiteName="nedaPlus"

  echo "About To run:"
  echo "opSysIdentities.sh -v -n showRun -p opSiteName=${osmtSiteName} -i osmtIdentitySet ${hostName}"

  continueAfterThis

  opSysIdentities.sh -v -n showRun -p opSiteName=${osmtSiteName} -i osmtIdentitySet ${hostName}

  echo "About to run:"
  echo "cat /etc/osmtInfo"

  continueAfterThis
  
  cat /etc/osmtInfo

}


_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  IIFs          :: step5_run_lpSysMgmtSteps |  [[elisp:(org-cycle)][| ]]
_CommentEnd_


function step5_run_lpSysMgmtSteps {
    echo ""
    echo "Now that OSMT has been configured, the"
    echo "rest of the configuration, can be done"
    echo "lpSysMgmtSteps.sh"
    echo ""
    echo "You can run lpSysMgmtSteps.sh if it is does not complete properly"

  case ${opRunDistFamily} in
    "UBUNTU"|"DEBIAN")
    echo  "About To Run:" 
    echo  "export PATH=/opt/public/osmt/bin:${PATH}; lpSysMgmtSteps.sh -h -v -n showRun -p developer=noedit -i restartFromIdle" 

    continueAfterThis

    export PATH=/opt/public/osmt/bin:${PATH}
    #lpSysMgmtSteps.sh -h -v -n showRun  -p developer=noedit -i stepByStep
    #lpSysMgmtSteps.sh -h -v -n showRun  -p developer=noedit -i restartFromIdle
    if [ "${G_humanUser}" != "TRUE" ] ; then
	opDo lpSysMgmtSteps.sh -v -n showRun  -p developer=lsipusr -i restartFromIdle
    else
	opDo lpSysMgmtSteps.sh -h -v -n showRun  -p developer=lsipusr -i restartFromIdle
    fi
       ;;
    "MAEMO")
    echo  "About To Run:" 
    echo  "export PATH=/opt/public/osmt/bin:${PATH}; lpMaemoMgmtSteps.sh -h -v -n showRun -p developer=noedit -i restartFromIdle" 

    continueAfterThis

    export PATH=/opt/public/osmt/bin:/usr/local/bin:${PATH}
    lpMaemoMgmtSteps.sh -h -v -n showRun  -p developer=noedit -i restartFromIdle
       ;;
    "REDHAT"|"SOLARIS"|"UNKNOWN"|"UNSUPPORTED")
	  echo "Unsupported distribution: ${opRunDistFamily}"
	  return 1
       ;;
    *)
	  echo "Oops distribution: ${opRunDistFamily}"
	  return 1
       ;;
  esac
}


_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  IIFs          :: welcomeMessage |  [[elisp:(org-cycle)][| ]]
_CommentEnd_


function vis_welcomeMessage {
    echo ""
    echo "Welcome to the Libre Services Integration Platform (LSIP)"
    echo "installation script"
    echo ""
    echo "First we will install the Libre Platform and then"
    echo "we will configure this host with the chosen configuration"
    echo ""
    echo "You are about to install the Libre Platform"
    echo "When in doubt, hit enter and select the default"

    echo opRunDistFamily=${opRunDistFamily}
    echo opRunDistGeneration=${opRunDistGeneration}
    echo opRunDistGenNu=${opRunDistGenNu}


    continueAfterThis
}


_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  IIFs          :: installKsh93 |  [[elisp:(org-cycle)][| ]]
_CommentEnd_



function installKsh93 {

  case ${opRunDistFamily} in
    "UBUNTU"|"DEBIAN")
	  # echo  "About To: Get ksh93"; continueAfterThis
  
	  case ${opRunMachineArch} in
	  "i686"|"i586"|"i386")
	  #    mkdir -p /here/opt/public/mma/multiArch/Linux/i686/bin
	  #    cd /here/opt/public/mma/multiArch/Linux/i686/bin
	  #    wget http://www.bysource.org/mma/multiArch/Linux/i686/bin/ksh93
	  #    chmod 775 ksh93
	  #    mkdir -p /opt/public
	  #    ln -s /here/opt/public/mma /opt/public
	  #    ln -s /opt/public/mma/multiArch/Linux/i686/bin/ksh93 /bin/osmtKsh

	     echo "Skipping Ksh93 for ${opRunDistFamily} -- ${opRunMachineArch}"
	     mkdir -p /opt/public
	     ln -s /bin/bash /bin/osmtKsh
	     ;;
          *)

	     echo "Skipping Ksh93 for ${opRunDistFamily} -- ${opRunMachineArch}"
	     mkdir -p /opt/public
	     ln -s /bin/bash /bin/osmtKsh
	     ;;
          esac
	  ;;
    "MAEMO")
	  echo  "About To: Get ksh93"; continueAfterThis
	  echo "Skipping Ksh93 for ${opRunDistFamily} -- ${opRunMachineArch}"
	  mkdir -p /opt/public
          ln -s /bin/bash /bin/osmtKsh
       ;;
    "REDHAT"|"SOLARIS"|"UNKNOWN"|"UNSUPPORTED")
	  echo "Unsupported distribution: ${opRunDistFamily}"
	  return 1
       ;;
    *)
	  echo "Oops distribution: ${opRunDistFamily}"
	  return 1
       ;;
  esac
}


_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  IIFs          :: endOfLpInstallMessage |  [[elisp:(org-cycle)][| ]]
_CommentEnd_



function endOfLpInstallMessage {
    echo ""
    echo "Libre Platform has been successfully installed"
    echo ""
    echo "Next we will configure your host"

    continueAfterThis
}


_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  IIFs          :: opRunDistFamilySet |  [[elisp:(org-cycle)][| ]]
_CommentEnd_



vis_opRunDistFamilySet () {

  opRunDistFamily="UNKNOWN"
  
  if grep buntu /etc/issue ; then
    opRunDistFamily="UBUNTU"
  elif grep "Debian GNU/Linux" /etc/issue ; then
    opRunDistFamily="DEBIAN"
 elif grep "maemo" /etc/issue ; then
    opRunDistFamily="MAEMO"
 elif grep "Red Hat" /etc/issue ; then
    opRunDistFamily="REDHAT"
 elif grep "Solaris" /etc/issue ; then
    opRunDistFamily="SOLARIS"
  else
    opRunDistFamily="UNSUPPORTED"
  fi

  opRunDistGeneration="UNKNOWN"
  case ${opRunDistFamily} in
    "UBUNTU")
	      if grep "14.04" /etc/issue ; then
		opRunDistGeneration="1404"
		opRunDistGenNu="14.04"
	      elif grep "Xenial" /etc/issue ; then
		opRunDistGeneration="1604"
		opRunDistGenNu="16.04"
	      elif grep "16.04" /etc/issue ; then
		opRunDistGeneration="1604"
		opRunDistGenNu="16.04"
	      elif grep  "Beaver" /etc/issue ; then  # LTS
		opRunDistGeneration="1804"
		opRunDistGenNu="18.04"
	      elif grep  "18.04" /etc/issue ; then  # LTS
		opRunDistGeneration="1804"
		opRunDistGenNu="18.04"
	      elif grep  "Focal" /etc/issue ; then  # LTS
		opRunDistGeneration="2004"
		opRunDistGenNu="20.04"
	      elif grep  "20.04" /etc/issue ; then  # LTS
		opRunDistGeneration="2004"
		opRunDistGenNu="20.04"
	      else
		opRunDistGeneration="UNSUPPORTED"
		opRunDistGenNu="UNSUPORTED"
	      fi
       ;;
    "DEBIAN")
	      if grep "3.1" /etc/issue ; then
		opRunDistGeneration="SARGE"
		opRunDistGenNu="3.1"
	      elif grep "4.0" /etc/issue ; then
		opRunDistGeneration="ETCH"
		opRunDistGenNu="4.0"
	      elif grep "5.0" /etc/issue ; then
		opRunDistGeneration="LENNY"
		opRunDistGenNu="5.0"
	      elif grep "squeeze" /etc/issue ; then
		opRunDistGeneration="SQUEEZE"
		opRunDistGenNu="6.0"
	      elif grep "6.0" /etc/issue ; then
		opRunDistGeneration="SQUEEZE"
		opRunDistGenNu="6.0"
	      elif grep "7.0" /etc/issue ; then
		opRunDistGeneration="7"
		opRunDistGenNu="7.0"
	      elif grep "sid" /etc/issue ; then
		opRunDistGeneration="SID"
		opRunDistGenNu="UNSTABLE"
	      else
		opRunDistGeneration="UNSUPPORTED"
		opRunDistGenNu="UNSUPORTED"
	      fi
       ;;
    "MAEMO")
	      if grep "OS2008" /etc/issue ; then
		opRunDistGeneration="OS2008"
		opRunDistGenNu="2008"
	      elif grep "OS2009" /etc/issue ; then
		opRunDistGeneration="OS2009"
		opRunDistGenNu="2009"
	      fi
       ;;
    "REDHAT")
	     opRunDistGeneration="UNSUPPORTED"
       ;;
    "SOLARIS")
	     opRunDistGeneration="UNSUPPORTED"
       ;;
    "UNKNOWN")
	       opRunDistGeneration="UNSUPPORTED"
       ;;
    "UNSUPPORTED")
		   opRunDistGeneration="UNSUPPORTED"
       ;;
    *)
       opRunDistGeneration="UNSUPPORTED"
	EH_oops ;
       return
       ;;
  esac

    echo opRunDistFamily=${opRunDistFamily}
    echo opRunDistGeneration=${opRunDistGeneration}
    echo opRunDistGenNu=${opRunDistGenNu}

}


_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  IIFs          :: opRunDistFamilyShow |  [[elisp:(org-cycle)][| ]]
_CommentEnd_



vis_opRunDistFamilyShow () {

  #opRunDistFamily=""

  if [ "${opRunDistFamily}_" == "_" ]  ; then
    echo "Need to run -- opSysIdentities.sh -i osmtInfoExpand"
    echo ${G_myName} -v -n showRun  -i opRunDistFamilySet
  else

    echo opRunDistFamily=${opRunDistFamily}
    echo opRunDistGeneration=${opRunDistGeneration}
  fi
}



_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  IIFs          :: EXECTUTION Order |  [[elisp:(org-cycle)][| ]]
_CommentEnd_


function vis_baseIoC {
    if [ $# -eq 0 ] ; then
	location="far"
    elif [ $# -eq 1 ] ; then
	if [ "$1" == "far" -o "$1" == "atNeda" ] ; then
	    location=$1
	else
	    printf "Bad Args: $@\n"
	    usage
	    return 2
	fi
    else
	echo "Too Many Args -- $# -- $@"
	usage
	return 2
    fi

    opDo echo "Start Date:"
    opDo date
    
    opDo vis_opRunDistFamilySet

    #vis_opRunDistFamilyShow

    opDo vis_welcomeMessage

    opDo ifNotCleanThenlpGenesisUndo

    opDo setupRouteShortCuts

    #step1_getNecessarySoftware
   
    opDo adjustSourcesList
    opDo installCVS

    opDo step2_getOsmtBx2

    opDo installKsh93
    #bashAsOsmtKsh

    opDo selectIntraGenesis1
    #step4_determineNetwork

    opDo endOfLpInstallMessage

    opDo step5_run_lpSysMgmtSteps

    opDo echo "End Date:"
    opDo date

    opDo echo -n "Installation Completed -- Hit enter to continue, \"skip\" to skip or \"EXIT\" to exit: "
    opDo read line
    
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




#opBasePathSet

#systemName=`uname -n`
#devlOsType=`uname -s`


###

#PATH=/usr/sbin:/usr/bin:/sbin

# Get options (defaults immediately below):

badUsage=
traceLevel=

Array paramInfo
loadFiles=""

#G_checkMode=""
#G_forceMode=""

G_argsOrig="$@"
#G_progName=`FN_nonDirsPart ${0}`
G_progName=$( basename ${0} )
G_myName=${G_progName}
G_myInvokedName=${0}

G_humanUser=FALSE

#TM_trace 9 ${G_argsOrig}

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
       leftSide=`ATTR_leftSide "${OPTARG}"`
       rightSide=`ATTR_rightSide "${OPTARG}"`
  
       echo "${leftSide}"="${rightSide}" >> ${dotMeParamTmpFile}

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
		badUsage=TRUE
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

  typeset absPath=`
  case $givenFile in
    */*) cd ${givenFile%/*} ;;
  esac
  pwd -P
`/${givenFile##*/} 

  echo ${absPath}
}


function opMyFullNameGet {
    #set -x
    typeset firstChar=${G_myInvokedName:0:1}

    if [ "${firstChar}" == "/" ] ; then 
	G_myFullName=${G_myInvokedName}
	G_myFullName=$( FN_absolutePathGet ${G_myFullName} )
	return 
    fi
    
    if [[ -f ${G_myInvokedName} ]] ; then
	G_myFullName=${PWD}/${G_myInvokedName}
    else
	G_myFullName=$( which ${G_myName} )
    fi

    G_myFullName=$( FN_absolutePathGet ${G_myFullName} )

    if [[ ! -f ${G_myFullName} ]] ; then
	echo "${G_myFullName} not found"
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


G_preParamHookVal=`ListFuncs | egrep '^G_preParamHook$'`
if [ "${G_preParamHookVal}X" != "X" ] ;   then
  G_preParamHook 
fi

#
# EXECUTE PARAMETER ASSIGNMENTS
#


if [[ -f ${dotMeParamTmpFile} ]] ; then
  . ${dotMeParamTmpFile}
  rm ${dotMeParamTmpFile}
fi


G_postParamHookVal=`ListFuncs | egrep '^G_postParamHook$'`
if [ "${G_postParamHookVal}X" != "X" ] ;   then
  G_postParamHook 
fi


_CommentBegin_
**  [[elisp:(org-cycle)][| ]]  IimSeed      :: iimRecordBegin  [[elisp:(org-cycle)][| ]]
_CommentEnd_

function iimRecordBegin {
    typeset dateTag=$( date +%y%m%d%H%M%S%N )
    typeset userIdTag=$( id -u -n )

    typeset recordingBaseDir="/tmp"

    if [[ -d "/var/log/bisos/iim/bash" ]] ; then
	recordingBaseDir="/var/log/bisos/iim/bash"
    fi

    logFile=${recordingBaseDir}/${userIdTag}-${G_myName}-${dateTag}-log.org
    
    exec &> >(tee "${logFile}")
    printf "Started Logging To ${logFile}\n"
    cat  << _EOF_
${G_myName}  ${G_argsOrig} 
at ${G_myFullName} started at 
$( date ) by $( id -u -n) 
*  /Controls/ ::  [[elisp:(org-cycle)][| ]]  [[elisp:(show-all)][Show-All]]  [[elisp:(org-shifttab)][Overview]]  [[elisp:(progn (org-shifttab) (org-content))][Content]] | [[file:Panel.org][Panel]] | [[elisp:(blee:ppmm:org-mode-toggle)][Nat]] | [[elisp:(bx:org:run-me)][Run]] | [[elisp:(bx:org:run-me-eml)][RunEml]] | [[elisp:(delete-other-windows)][(1)]] | [[elisp:(progn (save-buffer) (kill-buffer))][S&Q]]  [[elisp:(save-buffer)][Save]]  [[elisp:(kill-buffer)][Quit]] [[elisp:(org-cycle)][| ]]
** /Version Control/ ::  [[elisp:(call-interactively (quote cvs-update))][cvs-update]]  [[elisp:(vc-update)][vc-update]] | [[elisp:(bx:org:agenda:this-file-otherWin)][Agenda-List]]  [[elisp:(bx:org:todo:this-file-otherWin)][ToDo-List]] 
_EOF_
}


_CommentBegin_
**  [[elisp:(org-cycle)][| ]]  IimSeed      :: iimRecordEnd  [[elisp:(org-cycle)][| ]]
_CommentEnd_

iimRecordEndedP="false"

function iimRecordEnd {
    if [ ${iimRecordEndedP} != "false" ] ; then
	return
    fi	
    printf "End Logging To ${logFile}\n"
    date
    cat  << _EOF_
* Parameters:
#+STARTUP: content
_EOF_
    iimRecordEndedP="true"
}



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
      echo "if [ \"\${$i}_\" == \"MANDATORY_\" ] || [ \"\${$i}_\" == \"mandatory_\" ] ; then echo \"$i must be specified\"; badUsage=TRUE; fi;" > ${dotMeParamTmpFile}

      #cat ${dotMeParamTmpFile}
      . ${dotMeParamTmpFile}
  done

  if [[ "${badUsage}" == "TRUE" ]] ; then
    exit 1
  fi

  FN_fileRmIfThere ${dotMeParamTmpFile}

  return ${retVal}
}

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

# needed for ubuntu 1804

#G_validateOption ${action}  "${actionValidList}"

#G_validateRunOS "${runOSValidList}"


#
# REPORT USAGE PROBLEMS
#

if [ ${badUsage} ] ; then
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

_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  iimActions    :: /[dblock]-End/ iimStandaloneActions.bash [[elisp:(org-cycle)][| ]]
_CommentEnd_

####+END:



_CommentBegin_
*  [[elisp:(beginning-of-buffer)][Top]] ################ [[elisp:(delete-other-windows)][(1)]]  *End Of Editable Text*
_CommentEnd_

####+BEGIN: bx:dblock:bash:end-of-file :type "basic"
_CommentBegin_
*  [[elisp:(org-cycle)][| ]]  Common        ::  /[dblock] -- End-Of-File Controls/ [[elisp:(org-cycle)][| ]]
_CommentEnd_
#+STARTUP: showall
#local variables:
#major-mode: sh-mode
#fill-column: 90
# end:
####+END:
