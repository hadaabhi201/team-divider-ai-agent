package migration

import (
	"log"

	"authify/models"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

func Seed(db *gorm.DB) error {
	// Seed roles
	roles := []models.Role{
		{Name: "admin"},
		{Name: "general"},
	}

	for _, role := range roles {
		if err := db.FirstOrCreate(&role, models.Role{Name: role.Name}).Error; err != nil {
			return err
		}
	}

	// Get the actual roles with their IDs
	var adminRole, generalRole models.Role
	if err := db.First(&adminRole, "name = ?", "admin").Error; err != nil {
		return err
	}
	if err := db.First(&generalRole, "name = ?", "general").Error; err != nil {
		return err
	}

	// Hash password "test123"
	passwordHash, err := bcrypt.GenerateFromPassword([]byte("test123"), bcrypt.DefaultCost)
	if err != nil {
		return err
	}

	// Seed users
	users := []struct {
		User     models.User
		UserInfo models.UserInfo
	}{
		{
			User: models.User{
				Username: "adminuser",
				Password: string(passwordHash),
				RoleID:   adminRole.ID,
			},
			UserInfo: models.UserInfo{
				FirstName: "Admin",
				LastName:  "User",
				Email:     "admin@example.com",
			},
		},
		{
			User: models.User{
				Username: "generaluser",
				Password: string(passwordHash),
				RoleID:   generalRole.ID,
			},
			UserInfo: models.UserInfo{
				FirstName: "General",
				LastName:  "User",
				Email:     "general@example.com",
			},
		},
	}

	for _, pair := range users {
		user := pair.User
		userInfo := pair.UserInfo

		// Create user
		if err := db.FirstOrCreate(&user, models.User{Username: user.Username}).Error; err != nil {
			return err
		}

		// Link user info
		userInfo.UserID = user.ID
		if err := db.FirstOrCreate(&userInfo, models.UserInfo{UserID: user.ID}).Error; err != nil {
			return err
		}
	}

	log.Println("✅ Seeding completed.")
	return nil
}
