package main

import (
	"errors"
	"fmt"
	"io"
	"net/http"
)

func pong(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "pong")
}

func main() {
	http.HandleFunc("/pong", pong)

	err := http.ListenAndServe(":8080", nil)
	if errors.Is(err, http.ErrServerClosed) {
		fmt.Println("Server closed.")
	} else if err != nil {
		fmt.Print(err.Error())
	}
}
