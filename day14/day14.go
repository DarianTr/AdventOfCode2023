package main

import (
	"bytes"
	"fmt"
	"os"
)

func to_east(input *[100][]byte) {
	for i := 0; i < 100; i++ {
		next := len(input[0]) - 1
		for j := len(input[0]) - 1; j >= 0; j-- {
			if input[i][j] == 'O' {
				input[i][j] = '.'
				input[i][next] = 'O'
				if next != 0 {
					next -= 1
				}
			}
			if input[i][j] == '#' {
				next = j + 1
				if j != 0 {
					next = j - 1
				}
			}
		}
	}
}

func to_west(input *[100][]byte) {
	for i := 0; i < 100; i++ {
		next := 0
		for j := 0; j < len(input[0]); j++ {
			if input[i][j] == 'O' {
				input[i][j] = '.'
				input[i][next] = 'O'
				next += 1
			}
			if input[i][j] == '#' {
				next = j + 1
			}
		}
	}
}

func to_south(input *[100][]byte) {
	for i := 0; i < len(input[0]); i++ {
		next := 100 - 1
		for j := 99; j >= 0; j-- {
			if input[j][i] == 'O' {
				input[j][i] = '.'
				input[next][i] = 'O'
				if next != 0 {
					next -= 1
				}
			}
			if input[j][i] == '#' {
				next = j + 1
				if j != 0 {
					next = j - 1
				}
			}
		}
	}
}

func to_north(input *[100][]byte) {
	for i := 0; i < len(input[0]); i++ {
		next := 0
		for j := 0; j < 100; j++ {
			if input[j][i] == 'O' {
				input[j][i] = '.'
				input[next][i] = 'O'
				next += 1
			}
			if input[j][i] == '#' {
				next = j + 1
			}
		}
	}
}

func rotate(input *[100][]byte) {
	to_north(input)
	to_west(input)
	to_south(input)
	to_east(input)
}

func flatten(i [100][]byte) string {
	flat_arr := []byte{}
	for _, row := range i {
		flat_arr = append(flat_arr, row...)
	}
	return string(flat_arr)
}

func calc(input [100][]byte) int {
	total := 0
	for i := 99; i >= 0; i-- {
		for _, c := range input[99-i] {
			if c == 'O' {
				total += i + 1
			}
		}
	}
	return total
}

func cycles(input [100][]byte) int {
	key := flatten(input)
	lookup := make(map[string]int)
	counter := 1000000000
	for counter > 0 {
		fmt.Println("calc: ", calc(input))
		_, err := lookup[key]
		if err {
			fmt.Println("out", counter)
			break
		}
		lookup[key] = counter
		rotate(&input)
		key = flatten(input)
		counter -= 1
	}
	found_cycle := 1000000000 - counter
	first_appearence := 1000000000 - lookup[key]
	cycle_size := found_cycle - first_appearence
	ans := (1000000000 - first_appearence) % cycle_size
	fmt.Println(found_cycle, first_appearence, cycle_size, ans)
	counter = 0
	for counter < ans {
		rotate(&input)
		counter += 1
	}
	return calc(input)
}

func main() {
	dat, _ := os.ReadFile("puzzle.txt")
	split := bytes.Split(dat, []byte("\n"))
	ans := cycles([100][]byte(split))
	fmt.Println("Ans:", ans)
}
