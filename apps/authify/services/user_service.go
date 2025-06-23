package services

import (
	"errors"

	"authify/repository"
	"authify/utility"
)

type UserService interface {
	Login(username, password string) (string, error)
}

type userService struct {
	userRepo  repository.UserRepository
	jwtSecret string
}

func NewUserService(userRepo repository.UserRepository, jwtSecret string) UserService {
	return &userService{
		userRepo:  userRepo,
		jwtSecret: jwtSecret,
	}
}

func (s *userService) Login(username, password string) (string, error) {
	user, err := s.userRepo.FindByUsername(username)
	if err != nil {
		return "", errors.New("invalid username or password")
	}

	if !utility.CheckPasswordHash(password, user.Password) {
		return "", errors.New("invalid username or password")
	}

	return utility.GenerateJWT(user, s.jwtSecret)
}
