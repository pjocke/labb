package main

import (
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"os"
)

var backend string

func healthz(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(200)
}

func ping(w http.ResponseWriter, r *http.Request) {
	res, err := http.Get(fmt.Sprintf("http://%s/pong", backend))
	if err != nil {
		w.WriteHeader(500)
		io.WriteString(w, err.Error())
		return
	}
	tmp, err := ioutil.ReadAll(res.Body)
	if err != nil {
		w.WriteHeader(500)
		io.WriteString(w, err.Error())
		return
	}
	io.WriteString(w, fmt.Sprintf("ping is %s\n", tmp))
}

func main() {
	var ok bool
	backend, ok = os.LookupEnv("BACKEND_SERVER")
	if !ok {
		os.Exit(1)
	}

	http.HandleFunc("/healthz", healthz)
	http.HandleFunc("/ping", ping)

	err := http.ListenAndServe(":8080", nil)
	if errors.Is(err, http.ErrServerClosed) {
		fmt.Println("Server closed.")
	} else if err != nil {
		fmt.Print(err.Error())
	}
}
