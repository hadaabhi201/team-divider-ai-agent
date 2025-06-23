package utility

import "testing"

func TestHashAndCheckPassword(t *testing.T) {
	password := "test123"

	// Hash the password
	hashed, err := HashPassword(password)
	if err != nil {
		t.Fatalf("HashPassword() error: %v", err)
	}

	// Ensure hashed password is not equal to original
	if hashed == password {
		t.Error("Hashed password should not match plain password")
	}

	// Test matching password
	if !CheckPasswordHash(password, hashed) {
		t.Error("CheckPasswordHash() should return true for matching password")
	}

	// Test incorrect password
	if CheckPasswordHash("wrongpassword", hashed) {
		t.Error("CheckPasswordHash() should return false for incorrect password")
	}
}
