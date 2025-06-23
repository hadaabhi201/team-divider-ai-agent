package main

import (
	"log"

	"github.com/gin-gonic/gin"

	"authify/config"
	"authify/internal/db"
	"authify/internal/di"
	"authify/internal/migration"
	"authify/routes"
)

func main() {
	cfg := config.LoadConfig()

	dbContext, err := db.NewDBContext(cfg.DB)
	if err != nil {
		log.Fatalf("❌ Failed to initialize DB: %v", err)
	}

	migration.RunMigrations(dbContext.DB)

	// Setup DI container
	container := di.NewContainer(dbContext.DB, cfg.App)

	// Setup routes
	router := gin.Default()
	routes.SetupRoutes(router, container.UserService)

	log.Printf("🚀 Server starting on :%s", cfg.App.Port)
	if err := router.Run(":" + cfg.App.Port); err != nil {
		log.Fatalf("❌ Failed to start server: %v", err)
	}
}
