package controllers

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

func setupRouter(controller *UserController) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.Default()
	r.POST("/api/login", controller.Login)
	return r
}

func TestLogin_Success(t *testing.T) {
	mockService := new(MockUserService)
	mockService.On("Login", "admin", "test123").Return("mocked-jwt-token", nil)

	controller := NewUserController(mockService)
	router := setupRouter(controller)

	body := map[string]string{
		"username": "admin",
		"password": "test123",
	}
	jsonBody, _ := json.Marshal(body)

	req, _ := http.NewRequest(http.MethodPost, "/api/login", bytes.NewBuffer(jsonBody))
	req.Header.Set("Content-Type", "application/json")
	recorder := httptest.NewRecorder()

	router.ServeHTTP(recorder, req)

	assert.Equal(t, http.StatusOK, recorder.Code)
	assert.Contains(t, recorder.Body.String(), "mocked-jwt-token")

	mockService.AssertExpectations(t)
}

func TestLogin_InvalidJSON(t *testing.T) {
	controller := NewUserController(new(MockUserService))
	router := setupRouter(controller)

	invalidJSON := `{"username": "admin"}` // password missing

	req, _ := http.NewRequest(http.MethodPost, "/api/login", bytes.NewBuffer([]byte(invalidJSON)))
	req.Header.Set("Content-Type", "application/json")
	recorder := httptest.NewRecorder()

	router.ServeHTTP(recorder, req)

	assert.Equal(t, http.StatusBadRequest, recorder.Code)
	assert.Contains(t, recorder.Body.String(), "Invalid request")
}

func TestLogin_Unauthorized(t *testing.T) {
	mockService := new(MockUserService)
	mockService.On("Login", "admin", "wrongpass").Return("", assert.AnError)

	controller := NewUserController(mockService)
	router := setupRouter(controller)

	body := map[string]string{
		"username": "admin",
		"password": "wrongpass",
	}
	jsonBody, _ := json.Marshal(body)

	req, _ := http.NewRequest(http.MethodPost, "/api/login", bytes.NewBuffer(jsonBody))
	req.Header.Set("Content-Type", "application/json")
	recorder := httptest.NewRecorder()

	router.ServeHTTP(recorder, req)

	assert.Equal(t, http.StatusUnauthorized, recorder.Code)
	assert.Contains(t, recorder.Body.String(), "error")

	mockService.AssertExpectations(t)
}
