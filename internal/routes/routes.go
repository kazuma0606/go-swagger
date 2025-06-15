// internal/routes/routes.go
package routes

import (
	"fiber-crud-api/internal/handlers"

	"github.com/gofiber/fiber/v2"
)

// SetupUserRoutes ユーザー関連のルートを設定
func SetupUserRoutes(api fiber.Router) {
	users := api.Group("/users")

	users.Get("/", handlers.GetUsers)
	users.Get("/:id", handlers.GetUserByID)
	users.Post("/", handlers.CreateUser)
	users.Put("/:id", handlers.UpdateUser)
	users.Delete("/:id", handlers.DeleteUser)
}
