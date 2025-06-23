package utility

import (
	"testing"
	"time"

	"authify/models"
)

func TestGenerateAndParseJWT(t *testing.T) {
	secret := "testsecret123"
	user := &models.User{
		RoleID:   1,
		Username: "john_doe",
		Role:     models.Role{Name: "admin"},
	}

	// Generate JWT
	tokenStr, err := GenerateJWT(user, secret)
	if err != nil {
		t.Fatalf("GenerateJWT failed: %v", err)
	}
	if tokenStr == "" {
		t.Fatal("Generated token is empty")
	}

	// Parse JWT
	claims, err := ParseJWT(tokenStr, secret)
	if err != nil {
		t.Fatalf("ParseJWT failed: %v", err)
	}

	// Validate claims
	if claims.UserID != user.ID {
		t.Errorf("Expected UserID %d, got %d", user.ID, claims.UserID)
	}
	if claims.Username != user.Username {
		t.Errorf("Expected Username %s, got %s", user.Username, claims.Username)
	}
	if claims.Role != user.Role.Name {
		t.Errorf("Expected Role %s, got %s", user.Role.Name, claims.Role)
	}
	if time.Until(claims.ExpiresAt.Time) <= 0 {
		t.Error("Token is already expired or has invalid expiry")
	}
}
