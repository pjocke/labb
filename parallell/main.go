package main

import (
	"fmt"
	"sync"
	"time"
)

const maxConcurrency int = 3

func main() {
	sem := make(chan int, maxConcurrency)
	var wg sync.WaitGroup

	for i := 0; i < 5; i++ {
		sem <- 1
		fmt.Printf("%d got lock.\n", i)
		wg.Add(1)
		go func(count int) {
			defer wg.Done()
			fmt.Printf("%d started!\n", count)
			time.Sleep(time.Duration(5-count) * time.Second)
			fmt.Printf("%d done!\n", count)
			<-sem
		}(i)
	}

	wg.Wait()
}
