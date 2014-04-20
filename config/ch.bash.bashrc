# System-wide .bashrc file for interactive bash(1) shells.

# To enable the settings / commands in this file for login shells as well,
# this file has to be sourced in /etc/profile.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

#-------------------------------------------------------------
# History
#-------------------------------------------------------------
# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

export HISTIGNORE="ls:la:ll:l:df:du:clear"

#-------------------------------------------------------------
# Terminal config
#-------------------------------------------------------------

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
shopt -s cdspell # Pour que bash corrige automatiquement les fautes de frappes ex: cd ~/fiml sera remplacÃ© par cd ~/film

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

#-------------------------------------------------------------
# Test colors
#-------------------------------------------------------------

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
	xterm-color) color_prompt=yes;;
	screen*) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
	else
		color_prompt=
	fi
fi



#-------------------------------------------------------------
# Colors
#-------------------------------------------------------------

if [ "$color_prompt" = yes ]; then
	# Normal Colors
	Black='\e[0;30m'        # Black
	Red='\e[0;31m'          # Red
	Green='\e[0;32m'        # Green
	Yellow='\e[0;33m'       # Yellow
	Blue='\e[0;34m'         # Blue
	Purple='\e[0;35m'       # Purple
	Cyan='\e[0;36m'         # Cyan
	White='\e[0;37m'        # White

	# Bold
	BBlack='\e[1;30m'       # Black
	BRed='\e[1;31m'         # Red
	BGreen='\e[1;32m'       # Green
	BYellow='\e[1;33m'      # Yellow
	BBlue='\e[1;34m'        # Blue
	BPurple='\e[1;35m'      # Purple
	BCyan='\e[1;36m'        # Cyan
	BWhite='\e[1;37m'       # White

	# Background
	On_Black='\e[40m'       # Black
	On_Red='\e[41m'         # Red
	On_Green='\e[42m'       # Green
	On_Yellow='\e[43m'      # Yellow
	On_Blue='\e[44m'        # Blue
	On_Purple='\e[45m'      # Purple
	On_Cyan='\e[46m'        # Cyan
	On_White='\e[47m'       # White

	C_NC="\e[m"               # Color Reset


	C_ALERT=${BWhite}${On_Red} # Bold White on red background
fi

#-------------------------------------------------------------
# Functions systems infos
#-------------------------------------------------------------

# Returns system load as percentage, i.e., '40' rather than '0.40)'.
function load()
{
	local SYSLOAD=$(cut -d " " -f1 /proc/loadavg | tr -d '.')
	# System load of the current host.
	echo $((10#$SYSLOAD))       # Convert to decimal.
}

# Returns a color indicating system load.
function load_color()
{
	local SYSLOAD=$(load)
	if [ ${SYSLOAD} -gt ${XLOAD} ]; then
		echo -en ${C_ALERT}
	elif [ ${SYSLOAD} -gt ${MLOAD} ]; then
		echo -en ${Red}
	elif [ ${SYSLOAD} -gt ${SLOAD} ]; then
		echo -en ${BRed}
	else
		echo -en ${Green}
	fi
}

# Returns a color according to free disk space in $PWD.
function disk_color()
{
	echo -en ${Red}
	# No 'write' privilege in the current directory.
	local used=$(command df -P "$PWD" |
			   awk 'END {print $5} {sub(/%/,"")}')
	if [ ${used} -gt 95 ]; then
		echo -en ${C_ALERT}           # Disk almost full (>95%).
	elif [ ${used} -gt 90 ]; then
		echo -en ${BRed}            # Free disk space almost gone.
	else
		echo -en ${BBlue}           # Free disk space is ok.
	fi
}

# Returns a color according to running/suspended jobs.
function job_color()
{
	if [ $(jobs -s | wc -l) -gt "0" ]; then
		echo -en ${BRed}
	elif [ $(jobs -r | wc -l) -gt "0" ] ; then
		echo -en ${BPurple}
	fi
}

function writable_color(){
	if [[ -w "${PWD}" ]]; then
		echo -en ${BBlack}
	elif [ -s "${PWD}" ] ; then
		echo -en ${Red}
	else
		echo -en ${Cyan}
		# Current directory is size '0' (like /proc, /sys etc).
	fi
}


#-------------------------------------------------------------
# Colorfull Terminal
#-------------------------------------------------------------
# http://tldp.org/LDP/abs/html/sample-bashrc.html

if [ "$color_prompt" = yes ]; then
	
	# Test connection type:
	#if [ -n "${SSH_CONNECTION}" ]; then
	_ps_ssh_connection=$(who am i | sed -n 's/.*(\(.*\))/\1/p')
	
	if [[ -z "$_ps_ssh_connection" || "$_ps_ssh_connection" = ":"* ]] ; then
		CNX=${BGreen}        # Connected on local machine.
	else
		CNX=${BRed}        # Connected on remote machine, via ssh
	fi

	# Test user type:
	if [[ ${USER} == "root" ]]; then
		SU=${BRed}           # User is root.
	elif [[ ${USER} != $(logname) ]]; then
		SU=${Red}          # User is not login user.
	else
		# User is normal (well ... most of us are).
		if [[ -z "$_ps_ssh_connection" || "$_ps_ssh_connection" = ":"* ]] ; then
			SU=${BPurple}
		else
			SU=${BGreen}
		fi
	fi

	NCPU=$(grep -c 'processor' /proc/cpuinfo)    # Number of CPUs
	SLOAD=$(( 100*${NCPU} ))        # Small load
	MLOAD=$(( 200*${NCPU} ))        # Medium load
	XLOAD=$(( 400*${NCPU} ))        # Xlarge load


	PS1='${debian_chroot:+($debian_chroot)}'
	# Time of day (with load info):
	PS1=${PS1}"\[\$(load_color)\]\A\[${C_NC}\] "
	# User@Host (with connection type info):
	PS1=${PS1}"\[${SU}\]\u\[${C_NC}\]\[\033[1;30m\]@\[${CNX}\]\H\[\$(writable_color)\]:"
	# PWD (with 'disk space' info): /// \W : last folder; \w: full path
	PS1=${PS1}"\[\$(disk_color)\]\w\[${C_NC}\] "
	# Prompt (with 'job' info):
	PS1=${PS1}"\[\$(job_color)\]$\[${C_NC}\]\$(repositoryStatus) "
	# Set title of current xterm:
	#PS1=${PS1}"\[\e]0;[\u@\h] \w\a\]"

#	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\[\033[1;30m\]@\[\033[01;31m\]\h\[\033[1;30m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
#unset color_prompt force_color_prompt

unset force_color_prompt


#-------------------------------------------------------------
# Repositories : GIT, SVN
#-------------------------------------------------------------
_escape(){
	printf "%q" "$*"
}

repositoryStatus(){
#	return;
	# https://github.com/magicmonty/bash-git-prompt
	# https://github.com/nojhan/liquidprompt/blob/master/liquidprompt

	local gitdir
	gitdir="$(git rev-parse --git-dir 2>/dev/null)"
	[[ $? -ne 0 || ! $gitdir =~ (.*\/)?\.git.* ]] && return
	local branch="$(git symbolic-ref HEAD 2>/dev/null)"
	if [[ $? -ne 0 || -z "$branch" ]] ; then
		# In detached head state, use commit instead
		branch="$(git rev-parse --short HEAD 2>/dev/null)"
	fi
	[[ $? -ne 0 || -z "$branch" ]] && return
	branch="${branch#refs/heads/}"
	branch=$(_escape "$branch")

	local marks=' '
	#local stats=''
	#local stats=`git diff --shortstat`
	local stats=`git diff --numstat 2>/dev/null | awk 'NF==3 {plus+=$2; minus+=$3} END {printf("+%d/-%d\n", plus, minus)}'`


# https://github.com/nojhan/liquidprompt/blob/master/liquidprompt#L730
	stash=$(git stash list 2>/dev/null)
	if [[ ! -z "$stash" ]] ; then
		marks="${marks}%"
	fi

#	branch=`echo $branch | sed -e 's/^ *//g' -e 's/ *$//g'`

#	echo -ne ${Green}"[$branch$stats$marks]"${C_NC}
#	echo -ne " $Green[$stats$marks]$C_NC"
	echo -n " [$branch $stats$marks]"

}


#-------------------------------------------------------------
# Terminal title
#-------------------------------------------------------------


##If this is an xterm set the title to user@host:dir

case "$TERM" in
xterm*|rxvt*|screen*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

#-------------------------------------------------------------
# Autocompletion & command not found
#-------------------------------------------------------------

# enable bash completion in interactive shells
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
	. /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
  fi
fi



# if the command-not-found package is installed, use it
if [ -x /usr/lib/command-not-found -o -x /usr/share/command-not-found/command-not-found ]; then
    function command_not_found_handle {
            # check because c-n-f could've been removed in the meantime
                if [ -x /usr/lib/command-not-found ]; then
           /usr/lib/command-not-found -- "$1"
                   return $?
                elif [ -x /usr/share/command-not-found/command-not-found ]; then
           /usr/share/command-not-found/command-not-found -- "$1"
                   return $?
        else
           printf "%s: command not found\n" "$1" >&2
           return 127
        fi
    }
fi


#-------------------------------------------------------------
# Colors aliases
#-------------------------------------------------------------

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	export LS_OPTIONS='--color=auto'
	eval "`dircolors -b`"
	alias ls='ls --color=auto'
	alias dir='dir --color=auto'
	alias vdir='vdir --color=auto'

	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'

#    alias ls='ls $LS_OPTIONS'
#    alias ll='ls $LS_OPTIONS -lh'
#    alias l='ls $LS_OPTIONS -lAh'
fi

#-------------------------------------------------------------
# Colorfull logs
#-------------------------------------------------------------

logview(){
	ccze -A < $1 | less -R
}
logtail(){
	tail -f $1 | ccze
}

#-------------------------------------------------------------
# Environnement config
#-------------------------------------------------------------

umask 002

#-------------------------------------------------------------
# The 'ls' family
#-------------------------------------------------------------

alias ls='ls -hF --color=auto'
alias l='ls --group-directories-first'
alias ll='ls -l --group-directories-first'
alias la='ll -A'          # show hidden files
alias lx='ll -XB'         # sort by extension
alias lk='ll -Sr'         # sort by size, biggest last
alias lc='ll -tcr'        # sort by and show change time, most recent last
alias lu='ll -tur'        # sort by and show access time, most recent last
alias lt='ll -tr'         # sort by date, most recent last
alias lr='ll -R'          # recursive ls
alias lm='ll |more'       # Pipe through 'more'

#-------------------------------------------------------------
# Other usefull aliases
#-------------------------------------------------------------

alias ..='cd ..'
alias ....='cd ../..'
alias ......='cd ../../..'
alias ........='cd ../../../..'
alias df='df -h'
alias du='du -h'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias gitStashAndPull='git stash && git pull && git stash pop'


#-------------------------------------------------------------
# Personal aliases
#-------------------------------------------------------------

if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi


#-------------------------------------------------------------
# Infos
#-------------------------------------------------------------

#if [ "$color_prompt" = yes ]; then
#	echo -e "${BCyan}This is BASH ${BRed}${BASH_VERSION%.*}${BCyan}\
#	- Display on ${BRed}$DISPLAY${C_NC}"
#fi
#date
if [ -x /usr/games/fortune ]; then
	/usr/games/fortune -s     # Makes our day a bit more fun.... :-)
fi


# CLEAN


unset color_prompt
