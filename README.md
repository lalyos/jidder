
kubectl plugin for generating reusable bash functions.
This is 2 plugins in one binary:

- **jid** : bash function to get a single json-path value, wraps `kubectl get -o jsonpath=...`
- **jid-cols** : bash function to print a custom table, wraps `kubectl get -o custom-columns=...`

In both case the jsonpath is interactively contstructed, with the help of [jid](https://github.com/simeji/jid) (Json Incremental Digger)

## Installation A. - standalone kubectl plugin

```
curl -Lo /usr/local/bin/kubectl-jid https://github.com/lalyos/jidder/releases/download/tip/jidder-$(uname)
chmod +x /usr/local/bin/kubectl-jid
cp /usr/local/bin/kubectl-jid /usr/local/bin/kubectl-jid_cols
```

## Installation B. - krew kubectl plugin

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
$ kubectl krew install lalyos/jid-cols
```

## Usage - jid

[![asciicast](images/jid-demo.svg)](https://asciinema.org/a/qF2XJuJjLzj95Cs3t3fxZSkuZ?autoplay=1)

To start step-by-step first interactively select the resourceType,
and only print the generated helper function
```
$ kubectl jid
```

If you know beforhand which resource type you want to work with, you can preselect it as the first argument:
```
$ kubectl jid node
```

If you want to use the generated function right away, instead of copy pasting:
```
$ eval $(kubectl jid)
```

## Usage - jid-cols

[![asciicast](images/jid-cols-demo.svg)](https://asciinema.org/a/0OQgeAW3TSXhZ4yhtY1Z2Osza?autoplay=1)

Lets say you want to create a new table list of **nodes** with custom columns
```
$ kubectl jid-cols node
```

- follow on-screen instructions to add new columns (NAME is by default the first column)
- after each column you will se a preview of the table

As an example you can select 3 columns:
- next column name: **ip** path: `.items[0].metadata.name`
- next column name: **os** path: `.items[0].status.addresses[1].address`
- next column name: **version** path: `.items[0].status.nodeInfo.kubeletVersion`
- next column name: **q** to quit

```
kcc-node() { kubectl get node  -o custom-columns="NAME:.metadata.name,IP:.status.addresses[1].address,OS:.metadata.labels.kubernetes\.io/os,VERSION:.status.nodeInfo.kubeletVersion" ; }
```


If you want to use the generated function right away, instead of copy pasting:
```
$ eval $(kubectl jid)
```

## Dependecies

Altough strictly speaking there are dependencies like:
- [jid](https://github.com/simeji/jid)
- [survey](https://github.com/AlecAivazis/survey)
- [fzf](https://github.com/junegunn/fzf)
But they are included in the single binary

Even [staic bash](https://github.com/robxu9/bash-static) is included via [go-basher](https://github.com/progrium/go-basher)