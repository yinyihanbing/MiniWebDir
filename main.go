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
	flag.StringVar(&dir, "dir", "data/www", "指定靜態資源目錄")
	flag.IntVar(&port, "port", 8181, "指定伺服器監聽的端口號")
	flag.Parse()

	if _, err := os.Stat(dir); os.IsNotExist(err) {
		if err := os.Mkdir(dir, os.ModePerm); err != nil {
			log.Fatal(err)
		}
	}

	logDir := "data/log"
	if _, err := os.Stat(logDir); os.IsNotExist(err) {
		if err := os.Mkdir(logDir, os.ModePerm); err != nil {
			log.Fatal(err)
		}
	}

	logFile, err := os.OpenFile(fmt.Sprintf("%s/server.log", logDir), os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0666)
	if err != nil {
		log.Fatal(err)
	}
	defer logFile.Close()
	log.SetOutput(logFile)

	fs := http.FileServer(http.Dir(dir))
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Cache-Control", "no-store")
		fs.ServeHTTP(w, r)
	})
	log.Printf("伺服器已啟動, 端口:%d", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%d", port), nil))
}
