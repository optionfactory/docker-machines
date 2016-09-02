color() {
  local fg=$(test "0" -eq "$1" && echo "" || echo "\e[38;5;${1}m")
  local bg=$(test "0" -eq "$2" && echo "" || echo "\e[48;5;${2}m")
  local bold=$(test "0" -eq "$3" && echo "" || echo "\e[1m")
  echo -en "\[${bold}${fg}${bg}\]${4}\[\e[00m\]"
}
 
_prompt() {
  [ "$?" -eq "0" ] && local last_result="$(color 111 0 1 '⚙')" || local last_result="$(color 203 0 1 '⚠')"
  local IFS=" "  
  if [ -z "${HOSTNAME_COLOR}" ]; then    
    local MIN_COLOR=104
    local MAX_COLOR=229
    HASH=$(echo "${HOSTNAME}"|md5sum | cut --characters=1-8)
    export HOSTNAME_COLOR=$(echo -en $(( 16#${HASH} % (${MAX_COLOR} - ${MIN_COLOR}) + ${MIN_COLOR} )))
  fi
 
  local prefix=$(color 0 ${HOSTNAME_COLOR} 1 ' ')
  local user=$(color ${HOSTNAME_COLOR} 0 1 '\u@\h')
  local cwd=$(color 111 0 1 '\w')
 
  if [ "$(hg root 2> /dev/null)" ]; then
    local hg="$(color 118 0 1 '◖')$(color 118 0 1 $(hg branch))$(color 118 0 1 '◗')"
  fi
  if [ "$(git rev-parse --show-toplevel 2> /dev/null)" ]; then
    local git="$(color 196 0 1 '◖')$(color 196 0 1 $(git branch|grep '*' |cut -c3-))$(color 196 0 1 '◗')"
  fi
  if [  "0" != "$(grep -c docker /proc/self/cgroup)" ]; then
    local docker="$(color 140 0 1 '◖docker◗')"    
  fi
  local uid_color=$([ "$UID" = "0" ] && echo -en "196" || echo -en "118")
  local uid=$(color $uid_color 0 1 '\$')
 
  export PS1="${prefix} ${user}:${cwd} $hg$git$docker\n${prefix} ${last_result}  ${uid} "
}

export PROMPT_COMMAND="_prompt"
