package models

import "gorm.io/gorm"

// Role table
type Role struct {
	gorm.Model
	Name  string `gorm:"uniqueIndex;not null"`
	Users []User
}
