package migration

import (
	"log"

	"authify/models"

	"gorm.io/gorm"
)

type Migrator struct {
	db *gorm.DB
}

func NewMigrator(db *gorm.DB) *Migrator {
	return &Migrator{db: db}
}

func (m *Migrator) Migrate() error {
	log.Println("🚀 Running DB migrations...")
	return m.db.AutoMigrate(
		&models.Role{},
		&models.User{},
		&models.UserInfo{},
	)
}
