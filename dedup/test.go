package main

import "fmt"

func name() string {
	return "korv"
}

func main() {
	var tmp string
	for tmp = name(); tmp != "korv"; {

	}
	fmt.Println(tmp)
}
