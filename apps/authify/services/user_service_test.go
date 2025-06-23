package services

import (
	"errors"
	"testing"

	"authify/models"
	"authify/utility"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// MockUserRepository is a mock implementation of UserRepository
type MockUserRepository struct {
	mock.Mock
}

func (m *MockUserRepository) FindByUsername(username string) (*models.User, error) {
	args := m.Called(username)
	user, ok := args.Get(0).(*models.User)
	if !ok {
		return nil, args.Error(1)
	}
	return user, args.Error(1)
}

func TestUserService_Login_Success(t *testing.T) {
	mockRepo := new(MockUserRepository)
	hashedPassword, _ := utility.HashPassword("test123")

	mockUser := &models.User{
		Username: "john",
		Password: hashedPassword,
		Role:     models.Role{Name: "admin"},
	}

	mockRepo.On("FindByUsername", "john").Return(mockUser, nil)

	service := NewUserService(mockRepo, "test-secret")
	token, err := service.Login("john", "test123")

	assert.NoError(t, err)
	assert.NotEmpty(t, token)
	mockRepo.AssertExpectations(t)
}

func TestUserService_Login_InvalidPassword(t *testing.T) {
	mockRepo := new(MockUserRepository)

	mockUser := &models.User{
		Username: "john",
		Password: "$2a$10$invalidHashedPassword",
		Role:     models.Role{Name: "admin"},
	}

	mockRepo.On("FindByUsername", "john").Return(mockUser, nil)

	service := NewUserService(mockRepo, "test-secret")
	token, err := service.Login("john", "wrong-password")

	assert.Error(t, err)
	assert.Empty(t, token)
	mockRepo.AssertExpectations(t)
}

func TestUserService_Login_UserNotFound(t *testing.T) {
	mockRepo := new(MockUserRepository)

	mockRepo.On("FindByUsername", "john").Return(nil, errors.New("not found"))

	service := NewUserService(mockRepo, "test-secret")
	token, err := service.Login("john", "any-password")

	assert.Error(t, err)
	assert.Empty(t, token)
	mockRepo.AssertExpectations(t)
}
