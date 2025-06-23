package routes

import (
	"authify/controllers"
	"authify/services"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(router *gin.Engine, userService services.UserService) {
	userController := controllers.NewUserController(userService)

	api := router.Group("/api")
	{
		api.POST("/login", userController.Login)
	}
}
