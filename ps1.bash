U="$USER"
[ "$USER" == "dustyisawilson" ] && U="emmaly"

dwps_start_fg=0
dwps_start_bg=0
dwps_user_fg=82
dwps_user_bg=235
dwps_usersep_fg=2
dwps_usersep_bg=${dwps_user_bg}
dwps_dir_fg=190
dwps_dir_bg=19
dwps_dirsep_fg=99
dwps_dirsep_fg=9
dwps_dirsep_bg=${dwps_dir_bg}
dwps_dirlock_fg=9
dwps_dirlock_bg=${dwps_dir_bg}
dwps_git_fg=231
dwps_git_bg=28
dwps_gitsep_fg=9
dwps_gitsep_bg=${dwps_git_bg}
dwps_load_fg=82
dwps_load_bg=235
dwps_loadsep_fg=9

dwps_symbol_vc=""
dwps_symbol_ln=""
dwps_symbol_locked=""
dwps_symbol_rca=""
dwps_symbol_roa=""
dwps_symbol_lca=""
dwps_symbol_loa=""

dwps_cs_reset="\[\e[0m\]"
dwps_cs_dim="\[\e[2m\]"

function dwps.ps1 {
	[ -z "${dwps_start_bg_orig}" ] && dwps_start_bg_orig="${dwps_start_bg}"
	dwps_start_bg="${dwps_start_bg_orig}"

	local GIT_STATUS GIT_OTHER GIT_MODIFY_UNSTAGED GIT_MODIFY_STAGED GIT_ADD_UNSTAGED GIT_ADD_STAGED GIT_DELETE_UNSTAGED GIT_DELETE_STAGED
	if $(dwps.git.test); then
		GIT_STATUS="$(git status --porcelain)"
		dwps_start_bg=2
		if [ $? ]; then
			GIT_OTHER="$(echo "${GIT_STATUS}" | grep -E '^\s*\?\?\s' | wc -l)"
			GIT_MODIFY_UNSTAGED="$(echo "${GIT_STATUS}" | grep -E '^ M\s' | wc -l)"
			GIT_MODIFY_STAGED="$(echo "${GIT_STATUS}" | grep -E '^M\s' | wc -l)"
			GIT_ADD_UNSTAGED="$(echo "${GIT_STATUS}" | grep -E '^ A\s' | wc -l)"
			GIT_ADD_STAGED="$(echo "${GIT_STATUS}" | grep -E '^A\s' | wc -l)"
			GIT_DELETE_UNSTAGED="$(echo "${GIT_STATUS}" | grep -E '^ D\s' | wc -l)"
			GIT_DELETE_STAGED="$(echo "${GIT_STATUS}" | grep -E '^D\s' | wc -l)"
			if [ "$GIT_MODIFY_STAGED" -gt 0 -o "$GIT_ADD_STAGED" -gt 0 -o "$GIT_DELETE_STAGED" -gt 0 ]; then
				dwps_start_bg=226
			fi
			if [ "$GIT_OTHER" -gt 0 -o "$GIT_MODIFY_UNSTAGED" -gt 0 -o "$GIT_ADD_UNSTAGED" -gt 0 -o "$GIT_DELETE_UNSTAGED" -gt 0 ]; then
				dwps_start_bg=1
			fi
		fi
	fi

	PS1=""
	dwps.colorset end
	dwps.text "\n"
	dwps.colorset start
	dwps.sep start user no
	dwps.colorset user
	dwps.text " "
	dwps.text "$U"
	dwps.colorset usersep
	dwps.text "@"
	dwps.colorset user
	dwps.text "\h"
	dwps.sep user dir
	dwps.colorset dir
	dwps.dir
	dwps.colorset dirlock
	dwps.dirlock
	if [ -z $(dwps.git.test) ]; then
		dwps.sep dir end
	else
		dwps.sep dir git
		dwps.git
		dwps.sep git end
	fi
	dwps.colorset end
	dwps.text "\n"
	dwps.text "\$ "
}

function dwps.text {
	PS1="${PS1}$*"
}

function dwps.colorset {
	local FIELD="$1"
	local VALFG=""
	local VALBG=""
	eval VALFG="\$dwps_${FIELD}_fg"
	eval VALBG="\$dwps_${FIELD}_bg"
	PS1="${PS1}${dwps_cs_reset}"
	[ ! -z "$VALFG" ] && PS1="${PS1}\[\e[38;5;${VALFG}m\]"
	[ ! -z "$VALBG" ] && PS1="${PS1}\[\e[48;5;${VALBG}m\]"
}

function dwps.sep {
	local FIELDFROM="$1"
	local FIELDTO="$2"
	local NOWRAPSPACE="$3"
	local SEP="${4:-${dwps_symbol_rca}}"
	local SPACE=""
	[ -z "$NOWRAPSPACE" ] && SPACE=" "
	local VALFG=""
	local VALBG=""
	eval VALFG="\$dwps_${FIELDFROM}_bg"
	eval VALBG="\$dwps_${FIELDTO}_bg"
	PS1="${PS1}${SPACE}${dwps_cs_reset}"
	[ ! -z "$VALFG" ] && PS1="${PS1}\[\e[38;5;${VALFG}m\]"
	[ ! -z "$VALBG" ] && PS1="${PS1}\[\e[48;5;${VALBG}m\]"
	PS1="${PS1}${SEP}${SPACE}"
}

function dwps.dir {
	local SEP=" $(dwps.colorset dirsep)${dwps_symbol_roa}$(dwps.colorset dir) "
	local WD="$PWD"
	WD="${WD/#$HOME/\~}"
	WD="${WD#/}"
	IFS="/"
	local N=""
	for PART in ${WD}; do
		[ ! -z "$N" ] && PS1="${PS1}${SEP}"
		N=y
		PS1="${PS1}$PART"
	done
	unset IFS
	if [ -z "$WD" ]; then
		PS1="${PS1}/"
	fi
}

function dwps.dirlock {
	test -w "$(pwd)" || PS1="${PS1} ${dwps_symbol_locked}"
}

function dwps.git.test {
	git rev-parse --is-inside-work-tree 2>/dev/null
}

function dwps.git {
	local GIT_PS1="$(__git_ps1)"
	GIT_PS1="${GIT_PS1# }"
	GIT_PS1="${GIT_PS1//\(/}"
	GIT_PS1="${GIT_PS1//\)/}"
	PS1="${PS1}${GIT_PS1}:$(git rev-parse --short HEAD 2>/dev/null)"
	if [ ! -z "${GIT_OTHER}" -a "${GIT_OTHER}" -gt 0 ]; then
		PS1="${PS1} o${GIT_OTHER}"
	fi
	if [ ! -z "${GIT_MODIFY_UNSTAGED}" -a "${GIT_MODIFY_UNSTAGED}" -gt 0 ]; then
		PS1="${PS1} m${GIT_MODIFY_UNSTAGED}"
	fi
	if [ ! -z "${GIT_MODIFY_STAGED}" -a "${GIT_MODIFY_STAGED}" -gt 0 ]; then
		PS1="${PS1} M${GIT_MODIFY_STAGED}"
	fi
	if [ ! -z "${GIT_ADD_UNSTAGED}" -a "${GIT_ADD_UNSTAGED}" -gt 0 ]; then
		PS1="${PS1} a${GIT_ADD_UNSTAGED}"
	fi
	if [ ! -z "${GIT_ADD_STAGED}" -a "${GIT_ADD_STAGED}" -gt 0 ]; then
		PS1="${PS1} A${GIT_ADD_STAGED}"
	fi
	if [ ! -z "${GIT_DELETE_UNSTAGED}" -a "${GIT_DELETE_UNSTAGED}" -gt 0 ]; then
		PS1="${PS1} d${GIT_DELETE_UNSTAGED}"
	fi
	if [ ! -z "${GIT_DELETE_STAGED}" -a "${GIT_DELETE_STAGED}" -gt 0 ]; then
		PS1="${PS1} D${GIT_DELETE_STAGED}"
	fi
}

export PROMPT_COMMAND=dwps.ps1
