package main

import "fmt"

func search(haystack []int, needle int) int {
	start := 0
	end := len(haystack) - 1

	var index int
	for {
		index = start + (end-start)/2

		if needle == haystack[index] {
			return index
		} else if needle < haystack[index] {
			end = index - 1
		} else if needle > haystack[index] {
			start = index + 1
		}
	}
}

func main() {
	var input []int = []int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10}

	n := 10
	i := search(input, n)
	fmt.Printf("Index of %d is %d\n", n, i)
}
