package main

import (
	"log"
	"fmt"
    "net/http"
    "html"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Pong, %q", html.EscapeString(r.URL.Path))
	})
	
	log.Fatal(http.ListenAndServe(":8080", nil))
}