package main

import (
	"crypto/tls"
	"fmt"
	"github.com/go-pg/pg/v10"
	"github.com/go-pg/pg/v10/orm"
	"net/http"
	"os"
	"strconv"
	"time"
)

type Access struct {
	Host string
	Date string
}

// createSchema creates database schema for User and Story models.
func createSchema(db *pg.DB) error {
	models := []interface{}{
		(*Access)(nil),
	}

	for _, model := range models {
		err := db.Model(model).CreateTable(&orm.CreateTableOptions{
			IfNotExists: true,
		})
		if err != nil {
			return err
		}
	}
	return nil
}

func builder(db *pg.DB) func(w http.ResponseWriter, req *http.Request) {
	hostname, _ := os.Hostname()
	fmt.Printf("host=%s\n", hostname)
	return func(w http.ResponseWriter, req *http.Request) {
		fmt.Println("/")
		now := time.Now()
		access := &Access{
			Host: hostname,
			Date: strconv.Itoa(int(now.Unix())),
		}
		_, err := db.Model(access).Insert()
		if err != nil {
			fmt.Println(err)
		}
		var accesses []Access
		err = db.Model(&accesses).Select()
		if err != nil {
			fmt.Println(err)
		}
		fmt.Fprintf(w, "Host : %s\n\n", hostname)
		for _, a := range accesses {
			fmt.Fprintf(w, "%s - %s \n\n", a.Date, a.Host)
		}
	}
}

func healthz(w http.ResponseWriter, req *http.Request) {
	fmt.Println("/healthz")
	fmt.Fprintf(w, "ok\n")
}

func main() {
	username := os.Getenv("PG_USERNAME")
	password := os.Getenv("PG_PASSWORD")
	url := os.Getenv("PG_URL")
	db_name := os.Getenv("PG_DB")
	db := pg.Connect(&pg.Options{
		User:      username,
		Password:  password,
		Database:  db_name,
		Addr:      url,
		TLSConfig: &tls.Config{InsecureSkipVerify: true},
	})
	defer db.Close()
	createSchema(db)
	http.HandleFunc("/", builder(db))
	http.HandleFunc("/healthz", healthz)
	fmt.Println("Starting")
	http.ListenAndServe(":10000", nil)
}
