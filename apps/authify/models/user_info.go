package models

import "gorm.io/gorm"

// UserInfo table
type UserInfo struct {
	gorm.Model
	UserID    uint `gorm:"uniqueIndex"` // One-to-one with User
	FirstName string
	LastName  string
	Email     string
}
