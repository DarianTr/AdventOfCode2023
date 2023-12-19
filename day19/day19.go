package main

import (
	"bytes"
	"fmt"
	"os"
)

type Val struct {
	a int
	m int
	s int
	x int
}

type FPtr struct {
	cmp func (Val) bool
	res string
}

type Workflow struct {
	name string
	functions []FPtr
}


func get_next(v Val, w Workflow, m map[string]Workflow)

func main() {
	dat, _ := os.ReadFile("test.txt")
	split := bytes.Split(dat, []byte("\n"))
	fmt.Println("Ans:", 1)
}
