package repository

import (
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func setupMockDB(t *testing.T) (*gorm.DB, sqlmock.Sqlmock) {
	mockSQL, mock, err := sqlmock.New()
	assert.NoError(t, err)

	dialector := postgres.New(postgres.Config{
		Conn:       mockSQL,
		DriverName: "postgres",
	})

	db, err := gorm.Open(dialector, &gorm.Config{})
	assert.NoError(t, err)

	return db, mock
}

func TestFindByUsername_Success(t *testing.T) {
	db, mock := setupMockDB(t)
	repo := NewUserRepository(db)

	mockRows := sqlmock.NewRows([]string{"username", "password", "role_id"}).
		AddRow("john", "hashed", 2)

	mock.ExpectQuery(`SELECT \* FROM "users" WHERE username = \$1 AND "users"\."deleted_at" IS NULL ORDER BY "users"\."id" LIMIT \$2`).
		WithArgs("john", 1).
		WillReturnRows(mockRows)

	user, err := repo.FindByUsername("john")

	assert.NoError(t, err)
	assert.NotNil(t, user)
	assert.Equal(t, "john", user.Username)
	assert.Equal(t, "hashed", user.Password)
}

func TestFindByUsername_NotFound(t *testing.T) {
	db, mock := setupMockDB(t)
	repo := NewUserRepository(db)

	mock.ExpectQuery(`SELECT .* FROM "users" WHERE username = \$1 ORDER BY "users"."id" LIMIT 1`).
		WithArgs("ghost").
		WillReturnRows(sqlmock.NewRows([]string{"id", "username", "password", "role_id"}))

	user, err := repo.FindByUsername("ghost")

	assert.Error(t, err)
	assert.Nil(t, user)
}
