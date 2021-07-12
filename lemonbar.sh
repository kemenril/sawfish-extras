#!/bin/zsh


#Make zsh a little less zsh-like
unsetopt EQUALS

#Lemonbar command-line options

#TXTFONT="-xos4-terminus-medium-r-normal--20-200-72-72-c-100-iso10646-1"
#TXTFONT="-adobe-new century schoolbook-medium-r-normal--34-240-100-100-p-181-iso8859-1"
#TXTFONT="-xos4-terminus-medium-r-normal-*-32-320-72-72-c-100-iso10646-1"
#TXTFONT="-xos4-terminus-medium-r-normal-*-28-288-72-72-c-140-iso10646-1"

TXTFONT="xft:ProFontIIx Nerd Font Mono:size=25"

CMDOPTS="-a 40 -u 2 -B #77404040"

echo $CMDOPTS

TEXTCOLOR="white"
SEPCOLOR="blue"
BUTTONCOLOR="green"
PROGRESS="green"
HIGHLIGHTCOLOR="brightgreen"
ICONHLCOLOR="brightwhite"
DIMTEXT='FF777777'

IN_MAXLEN=6

#TMP=""


#Functions to manage our "virtual" bar.
function clear { OTMP=""; }
function output { OTMP="${OTMP}$*"; }
function refresh { echo $OTMP; }

#Just add some space.

function space { 
	output "%{O${1}}"; 
}

#Draw a vertical bar between sections.

function separator {
	space 8 
	color text ${SEPCOLOR}
	output "|"
	space 8
}

#Which color funtion you use will depend on whether you need to 
# immediagely write the color out to the stream.  In that case, use this.
# In the usual case, where you're just getting a color to add to a string,
# use colori below.

function color {
	output `colori $*`;
}

#Syntax is colori <foreground|background|underline> <color>
function colori {
	elem=$1
	color=$2
	if [ -z $elem ];then elem=F;fi
	if [ -z $color ];then color=black;fi
	
	#Translate long element names
	case $elem in
		"foreground"|"text")
			elem=F
		;;
		"background")
			elem=B
		;;
		"underline")
			elem=U
		;;
	esac

	#Apparently X11 no longer comes with rgb.txt, so this is more
	#difficult than it should be.
	case ${color} in
		"black")
			color='FF000000'
			;;
		"brightwhite")
			color='FFFFFFFF'
			;;
		"brightred")
			color='FFFF0000'
			;;
		"brightgreen")
			color='FF00FF00'
			;;
		"brightblue")
			color='FF0000FF'
			;;
		"brightcyan")
			color='FF00FFFF'
			;;
		"brightmagenta")
			color="FFFF00FF"
			;;
		"brightyellow")
			color='FFFFFF00'
			;;
		"red")
			color='FFAA0000'
			;;
		"white")
			color='FFAAAAAA'
			;;
		"green")
			color='FF00AA00'
			;;
		"blue")
			color='FF0000AA'
			;;
		"cyan")
			color='FF00AAAA'
			;;
		"magenta")
			color='FFAA00AA'
			;;
		"yellow")
			color='FFAAAA00'
			;;
		"darkwhite")
			color='FF555555'
			;;
		"darkgreen")
			color='FF005500'
			;;
		"darkblue")
			color='FF000055'
			;;
		"darkcyan")
			color='FF005555'
			;;
		"darkmagenta")
			color='FF550055'
			;;
		"darkyellow")
			color='FF555500'
			;;
	esac

	echo -n "%{${elem}#${color}}"
}

#Now some shortcut functions
function foreground	{ color foreground $*; }
function background	{ color background $*; }

#Syntax is attrubute <on|off|flip> <underline|overline>
function attribute {
	case $1 in
		"on"|"set")
			state='+'
		;;
		"off"|"unset")
			state='-'
		;;
		"flip"|"reverse")
			state='|'
		;;
		*)
			state='|'
	esac
	case $2 in
		"underline"|"under"|"u")
			output "%{${state}u}"
			;;
		"overline"|"over"|"o")
			output "%{${state}o}"
			;;
		esac

}

#Couple more shortcuts
function underline {
	op=$1
	if [ -z "$op" ];then
		op="flip"
	fi
	attribute $op underline 
}

function overline	{ 
	op=$1
	if [ -z "$op" ];then
		op="flip"
	fi
	attribute $op overline 
}

#Syntax is align <leeft|right|center>
function align {
	a=$1
	case $a in
		"left")
			a=l
		;;
		"center")
			a=c
		;;
		"right")
			a=r
		;;
		*)
			a=c
		;;
	esac

	output "%{${a}}"

}

#Syntax is button <command> <label> [button number]
function button {
	cmd=$1
	text=$2
	button=$3
	
	output "%{A${button}:${cmd} &:}${text}%{A}"
}

#Date/time widget

function dt {
	color text ${DIMTEXT}
	output `date|head -c-1`
}

#System load widget

function load {
	color text ${TEXTCOLOR}
	output "Load: "
	color text ${BUTTONCOLOR}
	output `uptime|cut -d, -f3-6|cut -d: -f2|head -c-1`
}

#Draw a user@host indication

function user {
	output `whoami`@`uname -n`
}


#Draw a bar graph to show proportion of some data.

function progressbar {
	integer PERCENT=$1
	#Needs to be integer for the test statements
	color text ${SEPCOLOR}
	output "["
	#Our bar is five characters wide.
	# Each character represents 20 percent.
	color text ${PROGRESS}
	for U in {1..5};do
		if [ ${PERCENT} -ge 15 ];then
			if [ ${U} -gt 3 ];then
				color text brightred
			fi
			output '='
		elif [ ${PERCENT} -gt 10 ];then
			output '_'
		elif [ ${PERCENT} -gt 5 ];then
			output '.'
		else
			output ' '
		fi
		PERCENT=`expr ${PERCENT} - 20`
	done
	color text ${SEPCOLOR}
	output "]"

}

#CPU usage widget with bar graph/percentage

function cpu {
	IDLE=`iostat -c |grep '^ '|awk '{print $6}'`
	#Use the shell to do some of the math, because BC is nuts, and
	# octave is a little heavy.
	float USED="(100-${IDLE})"
	#USED=`octave --eval "disp(round(100-${IDLE}))"`
#	USED=`echo -n "   ${USED}"|tail -c 3`
	TRUNC=`printf %.02f $USED`
	color text ${TEXTCOLOR}
	output "CPU: "
	progressbar ${TRUNC}
	color text ${DIMTEXT}
	output "("
	color text ${BUTTONCOLOR}
	output "${TRUNC}%"
	color text ${DIMTEXT}
	output ")"


}

#Memory widget with bar graph/percentage

function memory {
	FREE=`free -m|grep '^Mem:'`
	TOTALMEM=`echo $FREE|awk '{print $2}'`
	#Shell math again
	# Ignore the cosmological constant down there.  For some reason,
	# free doesn't actually report the total exactly right.  Kernel
	# allocation?
	let TOTALMEMGB="(((${TOTALMEM}+2048)/1024))"
	USEDMEM=`echo $FREE|awk '{print $3}'`
	FREEMEM=`echo $FREE|awk '{print $4}'`
	float USEDPCT="((${USEDMEM}/${TOTALMEM}.0)*100.0)"
	TRUNCPCT=`printf "%0.02f" $USEDPCT`
	#USEDPCT=`octave --eval "disp(round((${USEDMEM}/${TOTALMEM})*100))"`
	#Go ahead and pad this for use in the display
#	USEDPCT=`echo -n "   ${USEDPCT}"|tail -c 3`
	color text ${TEXTCOLOR}
	output "Mem: "
	color text ${DIMTEXT}
	output "0 "
	progressbar ${TRUNCPCT}
	color text ${DIMTEXT}
	output "${TOTALMEMGB}GB ("
	color text ${BUTTONCOLOR}
	output "${TRUNCPCT}%"
	color text ${DIMTEXT}
	output ") "

}

#Draw an icon label; that is, a $BUTTONCOLOR string enclosed in 
# a $SEPCOLOR $1 and $2
function iconlabel {
	LHS=$1
	shift
	RHS=$1
	shift
	colori text ${SEPCOLOR}
	colori underline ${SEPCOLOR}
	underline on
	overline on
	echo -n $LHS
	colori text ${BUTTONCOLOR}
	echo -n $*
	colori text ${SEPCOLOR}
	echo -n $RHS
	underline off
	overline off
}

#This is an icon which does a single thing when you click on it.  
# Used for running applications, but also for the pager.
function dockicon {
	command=$1
	name=$2
	if [ -z "$name" ];then 
		name=$command
	fi
	button "$command" "`iconlabel '[' ']' "$name"`"
}

#The pager widget.  Note that it's hard-wired for four desktops, but
# you could just change that 4 to as many as you like.

function pager {
	THISDESK=`sawfish-client -e "(+ current-workspace 1)"`
	color text ${BUTTONCOLOR}
	button "sawfish-client -e \"(previous-workspace 1)\"" "<<"
	for DESK in {1..4};do
		if [ "$DESK" == "$THISDESK" ];then
			dockicon "sawfish-client -e \"(select-workspace-from-first (- $DESK 1))\"" "`colori text ${HIGHLIGHTCOLOR}`${DESK}"
		else
			dockicon "sawfish-client -e \"(select-workspace-from-first (- $DESK 1))\"" "$DESK"
		fi
	done
	color text ${BUTTONCOLOR}
	button "sawfish-client -e \"(next-workspace 1 )\"" ">>"
}



#This is an icon-box icon.
function boxicon {
	RESTORE="sawfish-client -e \"(uniconify-window (get-window-by-id $1))\""
#	MENU="$1"
	ID=$1
	shift
	#Make the label slightly weird so that it stands out.
	LABEL=`iconlabel "[" "" "$*"`
	LABEL="${LABEL}`underline off``overline off``colori text ${ICONHLCOLOR}`> "
	button ${RESTORE} ${LABEL}
}

#This builds the icon box
function iconbox {
	WINLIST="(mapcar (lambda (window) (concat \"boxicon \" (number->string (window-id window)) \" '\" (substring (window-name window) 0 (clamp (length (window-name window)) 0 ${IN_MAXLEN})) \"';\")) (filter-windows window-iconified-p))"
	eval `sawfish-client -e ${WINLIST}|tr -d '()"'` >/dev/null
}

#This part actually describes the bar.

while (sleep 1);do
	clear
	#This block draws the bar in whatever current state.
	align left 
	color text ${TEXTCOLOR}
	space 30
	pager
	space 30
	separator
	dockicon urxvt
	space 8
	dockicon "chromium --force-device-scale-factor=1.6" chromium
	space 8
	dockicon mathematica
	separator
	iconbox
	separator

	align right
	cpu
	separator
	memory
	separator
	load
	separator
	dt
	refresh
done | lemonbar ${CMDOPTS} -f 'xft:ProFontIIx Nerd Font Mono:size=12' |sh >/dev/null


