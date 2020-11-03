set -eo pipefail

debug() {
    if ((DEBUG)); then
       echo "===> [${FUNCNAME[1]}] $*" 1>&2
    fi
}

shell() {
  declare desc="starts an interactive shell with golang interop"

  DEBUG=1 bash --rcfile <(cat $BASH_SOURCE; echo 'PS1="INNER> "')
}

preview() {
  trap "rm -f $HOME/pipe" EXIT
  if [[ ! -p $HOME/pipe  ]]; then
    mkfifo $HOME/pipe
  fi

  while true; do
    while read line; do
      #echo === $line
      clear
      eval $(base64 -d <<<"$line")
    done < $HOME/pipe
  done
}

base() {
  (set -x; echo "$@"; set +x) 2>&1 >/dev/null \
  | sed -n '1 s/^\+ echo //p' \
  | base64 -w0
  echo
}

psend() {
  debug "psend ... $@"
  if [[ -e $HOME/pipe ]] ;then
    debug PIPE ...
    base "$@" > $HOME/pipe
  else
    echo "---> preview"
    "$@"
  fi
}

declare -A cols

addCol() {
  cn=$(( ${#cols[@]} / 2 ))
  cols[name-${cn}]="$1"
  cols[path-${cn}]="$2"
}

printCols() {
  cn=$(( ${#cols[@]} / 2 - 1))
  for i in $(seq 0 $cn );  do
    [[ $i -gt 0 ]] && echo -n ','
    echo -n "${cols[name-$i]}:${cols[path-$i]}"
  done
}

jidder() {
    declare resType=$1
    shift || true

    #: ${resType:? required}
    if ! [[ $resType ]]; then
      resType=$(kubectl api-resources -o name --sort-by=name | fzf --prompt="choose a type:>")
    fi

    if ! [[ $(kubectl get ${resType} "$@" -o jsonpath='{range .items[*]}XXX{end}') ]];then
        echo "zero ${resType} found ..."
        return
    fi

    addCol name .metadata.name
    psend kubectl get ${resType} "$@" -o custom-columns="$(printCols)"

    echo "=== declare custom columns (type: 'q' to end)"
    local col
    while ! [[ $col == 'q' ]]; do
      read -p "next column name: " col
      if [[ $col != "q" ]]; then
        jpath=$(kubectl get ${resType} "$@" -o json | jidq ".items[0]." )
        addCol "${col}" "${jpath}"
      fi
      psend kubectl get ${resType} "$@" -o custom-columns="$(printCols)"
    done

    cmd=$"kubectl get ${resType} $@ -o custom-columns=\"$(printCols)\""
    echo "---> $cmd"
    eval "$cmd"
    echo "---> kx-${resType}() { $cmd ; }"
}

main() {
    if [[ $1 =~ :: ]]; then
    debug DIRECT-COMMAND  ...
    command=${1#::}
    shift
    $command "$@"
  else
    debug default-command
    if [[ $SELF =~ kubectl ]]; then
      debug "kubectl PLUGIN mode SELF=$SELF"
      cmd=${SELF#*kubectl-}
      ## convert between kebab and snake style
      ${cmd//_/-} "$@"
    else
      ## default command if invoked directly
      jid "$@"
    fi
  fi
}