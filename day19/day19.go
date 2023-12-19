package main

import (
	"fmt"
	"os"
	"strings"
)

type Val struct {
	a int
	m int
	s int
	x int
}

type FPtr struct {
	cmp func(Val) bool
	res string
}

type Workflow struct {
	name      string
	functions []FPtr
}

func has_conditions(s string) bool {
	for _, i := range s {
		if i == ':' {
			return true
		}
	}
	return false
}

func get_next(v Val, w Workflow, m map[string]Workflow) Workflow {
	for _, f := range w.functions {
		if f.cmp(v) {
			return m[f.res]
		}
	}
	fmt.Println("error")
	return Workflow{}
}

func string_to_workflow(s string) Workflow {
	split := strings.
}

func main() {
	dat, _ := os.ReadFile("test.txt")
	split := strings.Split(string(dat), "\n")
	fmt.Println("Ans:", 1)
}

// ----------------------------------------------------------------
