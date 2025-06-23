package di

import (
	"authify/config"
	"authify/repository"
	"authify/services"

	"gorm.io/gorm"
)

type Container struct {
	UserService services.UserService
	UserRepo    repository.UserRepository
}

func NewContainer(db *gorm.DB, appCfg config.AppConfig) *Container {
	userRepo := repository.NewUserRepository(db)
	userService := services.NewUserService(userRepo, appCfg.JWTSecret)

	return &Container{
		UserRepo:    userRepo,
		UserService: userService,
	}
}
