// internal/config/config.go
package config

import "os"

type Config struct {
	ServerAddress string
	AppName       string
}

func Load() *Config {
	return &Config{
		ServerAddress: getEnv("SERVER_ADDRESS", ":3000"),
		AppName:       getEnv("APP_NAME", "Fiber CRUD API"),
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
