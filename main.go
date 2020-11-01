package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/AlecAivazis/survey/v2"
	fzf "github.com/junegunn/fzf/src"
	"github.com/lalyos/go-basher"
	"github.com/simeji/jid"
)

func mysurvey(args []string) {
	answer := ""
	page := 10
	if p, err := strconv.Atoi(os.Getenv("SURVEY_PAGE")); err == nil {
		page = p
	}

	prompt := &survey.Select{
		Message:  args[0],
		Options:  args[1:],
		PageSize: page,
	}
	survey.AskOne(prompt, &answer, survey.WithStdio(os.Stdin, os.Stderr, os.Stderr))
	fmt.Println(answer)
}

func myfzf(args []string) {
	oldArgs := os.Args
	defer func() { os.Args = oldArgs }()
	os.Args = []string{oldArgs[0]}
	os.Args = append(os.Args, args...)
	fzf.Run(fzf.ParseOptions(), "")
}

func jidq(args []string) {
	trim := 0

	query := ".items[0]."
	if len(args) > 0 {
		query = args[0]
		trim = strings.Count(query, ".")
	}
	if len(args) == 2 {
		if t, err := strconv.Atoi(args[1]); err == nil {
			trim = t
		} else {
			trim = 0
		}
	}

	e, err := jid.NewEngine(os.Stdin, &jid.EngineAttribute{
		DefaultQuery: query,
	})
	if err != nil {
		panic(err)
	}
	e.Run()

	for i, k := range e.GetQuery().StringGetKeywords() {
		if i >= trim {
			if k[0] != '[' {
				fmt.Print(".")
			}
			fmt.Print(strings.ReplaceAll(k, ".", "\\."))
		}
	}
}

func main() {
	basher.Application(map[string]func([]string){
		"jidq":   jidq,
		"fzf":    myfzf,
		"survey": mysurvey,
	}, []string{
		"cmd/main.bash",
	}, Asset, true)
}
