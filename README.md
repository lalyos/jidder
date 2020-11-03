
kubectl plugin for generating reusable bash functions.
Two function types can be generated:

- **jid** : wrapping `kubectl get -o jsonpath=...`
- **jid-cols** : wrapping `kubectl get -o custom-columns=...`

In both case the jsonpath is interactively contstructed, with the help of [jid](https://github.com/simeji/jid) (Json Incremental Digger)

## Usage

It is a single binary ready to use on Linux/OSX, or it can be used as a kubectl-plugin.

... TODO: ascicast ...

## Installation - standalone

```
curl -Lo /usr/local/bin/jidder https://github.com/lalyos/jidder/releases/download/tip/jidder-$(uname)
chmod +x /usr/local/bin/jidder
```

## Installation - standalone kubectl plugin

```
curl -Lo /usr/local/bin/kubectl-jid https://github.com/lalyos/jidder/releases/download/tip/jidder-$(uname)
chmod +x /usr/local/bin/kubectl-jid
```

## Installation - krew kubectl plugin

First make sure krew is [installed](https://krew.sigs.k8s.io/docs/user-guide/setup/install/)
```
$ kubectl krew version
OPTION            VALUE
GitTag            v0.4.0
...
```

Until it gets into the offitial krew plugin index, it can be isntalled from a custom plugin repo:
```
$ kubectl krew index add lalyos https://github.com/lalyos/krew-index.git

$ kubectl krew install lalyos/jid
```

## Dependecies

Altough strictly speaking there are dependencies like:
- [jid](https://github.com/simeji/jid)
- [survey](https://github.com/AlecAivazis/survey)
- [fzf](https://github.com/junegunn/fzf)
But they are included in the single binary

Even [staic bash](https://github.com/robxu9/bash-static) is included via [go-basher](https://github.com/progrium/go-basher)