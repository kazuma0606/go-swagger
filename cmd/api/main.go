// cmd/api/main.go
package main

import (
	"log"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	fiberSwagger "github.com/swaggo/fiber-swagger"

	"fiber-crud-api/internal/config"
	"fiber-crud-api/internal/handlers"
	"fiber-crud-api/internal/routes"

	_ "fiber-crud-api/docs" // Swagger docs
)

// @title Fiber CRUD API
// @version 1.0
// @description Go FiberでのCRUD操作のサンプルAPI
// @host localhost:3000
// @BasePath /api/v1
// @schemes http
func main() {
	// 設定の読み込み
	cfg := config.Load()

	// サンプルデータの初期化
	handlers.InitSampleData()

	// Fiberアプリケーションの初期化
	app := fiber.New(fiber.Config{
		AppName: cfg.AppName,
	})

	// ミドルウェアの設定
	app.Use(cors.New())

	// Swagger UIのエンドポイント
	app.Get("/swagger/*", fiberSwagger.WrapHandler)

	// ヘルスチェック
	app.Get("/", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"message": "Fiber CRUD API",
			"version": "1.0.0",
			"swagger": "http://localhost:3000/swagger/index.html",
		})
	})

	// APIルートの設定
	api := app.Group("/api/v1")
	routes.SetupUserRoutes(api)

	// サーバー起動
	log.Printf("サーバーを起動しています... http://localhost%s", cfg.ServerAddress)
	log.Printf("Swagger UI: http://localhost%s/swagger/index.html", cfg.ServerAddress)

	if err := app.Listen(cfg.ServerAddress); err != nil {
		log.Fatal("サーバー起動エラー:", err)
	}
}
