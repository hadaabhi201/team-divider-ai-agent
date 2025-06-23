package db

import (
	"log"

	"authify/config"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type Context struct {
	DB *gorm.DB
}

func NewDBContext(cfg config.DBConfig) (*Context, error) {
	db, err := gorm.Open(postgres.Open(cfg.DSN()), &gorm.Config{})
	if err != nil {
		return nil, err
	}

	log.Println("✅ Connected to database")
	return &Context{DB: db}, nil
}
