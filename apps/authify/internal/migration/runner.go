package migration

import (
	"log"

	"gorm.io/gorm"
)

func RunMigrations(db *gorm.DB) {
	// Run DB migrations
	migrator := NewMigrator(db)
	if err := migrator.Migrate(); err != nil {
		log.Fatalf("❌ Migration failed: %v", err)
	}

	// Seed default data
	if err := Seed(db); err != nil {
		log.Fatalf("❌ Seeding failed: %v", err)
	}

	log.Println("✅ Migration and seeding complete.")
}
