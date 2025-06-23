package config

import (
	"github.com/joho/godotenv"

	"fmt"
	"log"
	"os"
)

type Config struct {
	App AppConfig
	DB  DBConfig
}

type AppConfig struct {
	Port      string
	JWTSecret string
}

type DBConfig struct {
	Host     string
	Port     string
	User     string
	Password string
	Name     string
	SSLMode  string
}

// LoadConfig initializes and returns the full application config
func LoadConfig() *Config {
	// Try loading .env only if not in production
	env := os.Getenv("GO_ENV")
	var envFile string

	if env == "development" {
		envFile = ".env"
	} else {
		envFile = "/vault/secrets/production.env"
	}

	if err := godotenv.Load(envFile); err != nil {
		log.Printf("⚠️ Could not load env file %s: %v", envFile, err)
	}

	appCfg := AppConfig{
		Port:      getEnvOrDefault("PORT", "8080"),
		JWTSecret: getEnvOrDefault("JWT_SECRET", "supersecretkey"),
	}

	dbCfg := DBConfig{
		Host:     getEnvOrDefault("DB_HOST", ""),
		Port:     getEnvOrDefault("DB_PORT", ""),
		User:     getEnvOrDefault("DB_USERNAME", ""),
		Password: getEnvOrDefault("DB_PASSWORD", ""),
		Name:     getEnvOrDefault("DB_NAME", ""),
		SSLMode:  getEnvOrDefault("DB_SSLMODE", ""),
	}

	log.Printf("HOST %s", dbCfg.Host)
	log.Printf("HOST %s", dbCfg.Password)

	if appCfg.Port == "8080" {
		log.Println("⚠️ PORT not set in env, defaulting to 8080")
	}

	return &Config{
		App: appCfg,
		DB:  dbCfg,
	}
}

func getEnvOrDefault(key, defaultVal string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return defaultVal
}

// DSN returns the formatted PostgreSQL connection string
func (cfg DBConfig) DSN() string {
	return fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		cfg.Host, cfg.Port, cfg.User, cfg.Password, cfg.Name, cfg.SSLMode,
	)
}
