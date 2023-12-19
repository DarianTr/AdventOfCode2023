package main

import (
	"bytes"
	"fmt"
	"os"
)

func main() {
	dat, _ := os.ReadFile("puzzle.txt")
	split := bytes.Split(dat, []byte("\n"))
	ans := cycles([100][]byte(split))
	fmt.Println("Ans:", ans)
}
