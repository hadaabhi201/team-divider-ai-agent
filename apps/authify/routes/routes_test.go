package routes

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// MockUserService mocks the UserService interface
type MockUserService struct {
	mock.Mock
}

func (m *MockUserService) Login(username, password string) (string, error) {
	args := m.Called(username, password)
	return args.String(0), args.Error(1)
}

func TestSetupRoutes_Login(t *testing.T) {
	gin.SetMode(gin.TestMode)

	mockService := new(MockUserService)
	mockService.On("Login", "john", "test123").Return("mocked-token", nil)

	router := gin.New()
	SetupRoutes(router, mockService)

	loginPayload := map[string]string{
		"username": "john",
		"password": "test123",
	}
	body, _ := json.Marshal(loginPayload)

	req, _ := http.NewRequest(http.MethodPost, "/api/login", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)
	assert.Contains(t, w.Body.String(), "mocked-token")

	mockService.AssertExpectations(t)
}
