package main

import (
	"fmt"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGHUP, syscall.SIGINT, syscall.SIGTERM)

	cursor := []byte{'|', '/', '-', '\\', '|', '/', '-', '\\'}
	i := 0
	for {
		fmt.Printf("\r%c", cursor[i])
		if i < len(cursor)-1 {
			i++
		} else {
			i = 0
		}

		select {
		case sig := <-sigs:
			switch sig {
			case syscall.SIGINT:
				fmt.Printf("\n\nInterrupted.\n")
				os.Exit(0)
			case syscall.SIGTERM:
				fmt.Printf("\n\nTerminated.\n")
				os.Exit(0)
			case syscall.SIGHUP:
				fmt.Printf("\n\nHung up.\n")
			}
		case <-time.After(100 * time.Millisecond):
			continue
		}
	}
}
