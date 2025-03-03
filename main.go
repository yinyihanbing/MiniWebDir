package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path"
)

var logDir string
var wwwDir string
var port int

func main() {
	flag.StringVar(&logDir, "logDir", "logs", "日志目錄")
	flag.StringVar(&wwwDir, "wwwDir", "www", "指定靜態資源目錄")
	flag.IntVar(&port, "port", 8181, "指定伺服器監聽的端口號")
	flag.Parse()

	createDirIfNotExist := func(path string) {
		if _, err := os.Stat(path); os.IsNotExist(err) {
			if err := os.Mkdir(path, os.ModePerm); err != nil {
				log.Fatal(err)
			}
		}
	}

	createDirIfNotExist(logDir)
	createDirIfNotExist(wwwDir)

	logFile, err := os.OpenFile(path.Join(logDir, "server.log"), os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0666)
	if err != nil {
		log.Fatal(err)
	}
	defer logFile.Close()

	multiWriter := io.MultiWriter(os.Stdout, logFile)
	log.SetOutput(multiWriter)

	fs := http.FileServer(http.Dir(wwwDir))
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Cache-Control", "no-store")
		fs.ServeHTTP(w, r)
	})
	log.Printf("伺服器已啟動, 端口:%d", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%d", port), nil))
}
