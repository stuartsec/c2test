// program get gets a URL
package main

/*
 * get.go
 * GET a url
 * By J. Stuart McMurray
 * Created 20190626
 * Last Modified 20190626
 */

import (
	"fmt"
	"log"
	"net/http"
	"net/http/httputil"
	"os"
)

func main() {
	if 2 != len(os.Args) {
		log.Fatalf("Usage: %v url", os.Args[0])
	}
	res, err := http.Get(os.Args[1])
	if nil != err {
		log.Fatalf("Error: %v", err)
	}
	b, err := httputil.DumpResponse(res, true)
	if nil != err {
		log.Fatalf("Error dumping response: %v", err)
	}
	os.Stdout.Write(b)
	fmt.Printf("\n")
}
