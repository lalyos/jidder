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

chooseRes() {
  declare desc="Interactively choose a k8s resource type"

  resType=$(survey "Choose type" node pod deploy svc ingress --show-all--)
  if [[ $resType == --show-all-- ]];then
    all=$(kubectl api-resources -oname --sort-by=name)
    resType=$(SURVEY_PAGE=20 survey "Choose type" ${all})
  fi
  echo ${resType}
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
    echo "---> preview" 1>&2
    "$@" 1>&2
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
    echo -n "${cols[name-$i]^^}:${cols[path-$i]}"
  done
}

jid() {
  declare desc="kubectl jsonpath function generator with interactive json digger"

  if [[ $# -eq 0 ]]; then
    resType=$(chooseRes)
  else
    resType=$1
    shift || true
  fi
  if ! [[ $(kubectl get ${resType} -oname) ]];then
    echo "zero ${resType} found ..."
    return
  fi

  jpath=$(kubectl get ${resType} -o json | jidq ".items[0]." 0)
  #jpath=$(kubectl get ${resType} -o json | jidq ".items[0]." )

  cat <<EOF
  kjid-${resType}() { kubectl get ${resType} -o jsonpath="{${jpath}}"; }
  && type kjid-${resType} 1>&2
  && kjid-${resType}
EOF
}

jid-cols() {
  declare desc="kubectl custom-columns function generator with jsonpath interactive digger"
  declare resType=$1

  if [[ $# -eq 0 ]]; then
    #resType=$(kubectl api-resources -o name --sort-by=name | fzf --prompt="choose a type:>")
    resType=$(chooseRes)
  else
    resType=$1
    shift || true
  fi

  if ! [[ $(kubectl get ${resType} "$@" -o jsonpath='{range .items[*]}XXX{end}') ]];then
      echo "zero ${resType} found ..."
      return
  fi

  addCol name .metadata.name
  psend kubectl get ${resType} "$@" -o custom-columns="$(printCols)"

  echo "=== declare custom columns (type: 'q' to end)" 1>&2
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
  cat <<EOF
  kcc-${resType}() { $cmd; }
  && type kcc-${resType} 1>&2
  && kcc-${resType}
EOF
}

usage() {
  declare desc="Prints usage hints"
  declare cmd=${1:-jidder}

  cat <<EOF 1>&2
Usage: kubectl $cmd [resourceType]
  A bash function will be generated. Wrapping: kubectl get -o ...
  The json-path will be interactively contstructed.

  If you want to use the generated function in your actual shell,
  cancel with CTRL-C and use:

  eval \$(kubectl $cmd)

EOF
}

VERSION=0.0.1
version() {
  declare cmd=${1:-jidder}
  echo "${cmd}: $VERSION" 1>&2
  exit 0
}

main() {
  cmd=${SELF#*kubectl-}
  ## convert between kebab and snake style
  cmd=${cmd//_/-}

  if [[ $1 =~ :: ]]; then
    debug DIRECT-COMMAND  ...
    command=${1#::}
    shift
    $command "$@"
  else
    if [[ $1 == --version ]];then
      version $cmd
    fi

    debug default-command
    if [[ $SELF =~ kubectl ]]; then
      debug "kubectl PLUGIN mode SELF=$SELF"
      [[ "$@" ]] || usage $cmd
      ${cmd} "$@"
    else
      ## default command if invoked directly
      [[ "$@" ]] || usage $cmd
      jid "$@"
    fi
  fi
}