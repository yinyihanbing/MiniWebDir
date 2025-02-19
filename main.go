package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
)

var dir string
var port int

func main() {
	flag.StringVar(&dir, "dir", "./", "指定靜態資源目錄")
	flag.IntVar(&port, "port", 8080, "指定伺服器監聽的端口號")
	flag.Parse()

	if _, err := os.Stat(dir); os.IsNotExist(err) {
		log.Fatal(err)
	}

	fs := http.FileServer(http.Dir(dir))
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fs.ServeHTTP(w, r)
	})
	log.Printf("伺服器已啟動, 端口:%d", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%d", port), nil))
}
