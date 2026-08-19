color() {
  local fg="" bg="" bold=""
  [ -n "$1" ] && [ "$1" != "0" ] && fg="\033[38;2;${1}m"
  [ -n "$2" ] && [ "$2" != "0" ] && bg="\033[48;2;${2}m"
  [ "$3" = "1" ] && bold="\033[1m"
  printf "\001%s%s%s\002%s\001\033[00m\002" "$bold" "$fg" "$bg" "$4"
}

_prompt() {
  local exit_code=$?
  local git="" docker=""

  local status_icon=$([ "$exit_code" -eq 0 ] && color "135;175;223" 0 1 '✔' || color "255;99;71" 0 1 '✘')
  local uid_color=$([ "$UID" -eq 0 ] && echo "255;64;64" || echo "127;255;0")

  if [ -z "${HOSTNAME_COLOR}" ]; then
    local _hash=$(printf '%s' "$HOSTNAME" | md5sum)
    export HOSTNAME_COLOR="$(( 16#${_hash:0:2} % 131 + 100 ));$(( 16#${_hash:2:2} % 131 + 100 ));$(( 16#${_hash:4:2} % 131 + 100 ))"
    unset _hash
  fi

  local git_branch=$(git branch --show-current 2> /dev/null || true)
  [ -z "$git_branch" ] && git_branch=$(git rev-parse --short HEAD 2> /dev/null || true)
  [ -n "$git_branch" ] && git="$(color "170;95;95" 0 1 '[')$(color "229;115;115" 0 1 "${git_branch}")$(color "170;95;95" 0 1 ']') "

  if [ -e /.dockerenv ] || [ -e /run/.containerenv ]; then
    docker="$(color "140;105;180" 0 1 '[')$(color "170;120;220" 0 1 'docker')$(color "140;105;180" 0 1 ']') "
  fi

  local prefix=$(color "0;0;0" "$HOSTNAME_COLOR" 1 ' ')
  local user=$(color "$HOSTNAME_COLOR" 0 1 '\u@\h')
  local cwd=$(color "135;175;223" 0 1 '\w')
  local uid=$(color "$uid_color" 0 1 '\$')

  export PS1="${prefix} ${user}:${cwd} ${docker}${git}\n${prefix} ${status_icon} ${uid} "
}

export PROMPT_COMMAND="_prompt"
