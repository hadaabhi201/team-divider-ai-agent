package models

import (
	"gorm.io/gorm"
)

// User table
type User struct {
	gorm.Model
	Username string   `gorm:"uniqueIndex;not null"`
	Password string   `gorm:"not null"`
	UserInfo UserInfo `gorm:"constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
	RoleID   uint
	Role     Role
}
