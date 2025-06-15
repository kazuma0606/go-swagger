package main

import (
	"log"
	"strconv"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	fiberSwagger "github.com/swaggo/fiber-swagger" // 正しいimport

	_ "fiber-crud-api/docs"
)

// User構造体 - ユーザー情報を格納
// @Description ユーザー情報
type User struct {
	ID    int    `json:"id" example:"1"`
	Name  string `json:"name" example:"田中太郎"`
	Email string `json:"email" example:"tanaka@example.com"`
	Age   int    `json:"age" example:"25"`
}

// エラーレスポンス構造体
// @Description エラーレスポンス
type ErrorResponse struct {
	Error string `json:"error" example:"ユーザーが見つかりません"`
}

// メモリ上のデータストア
var users []User
var nextID = 1

// @title Fiber CRUD API
// @version 1.0
// @description Go FiberでのCRUD操作のサンプルAPI
// @host localhost:3000
// @BasePath /api/v1
// @schemes http
func main() {
	initSampleData()
	app := fiber.New()
	app.Use(cors.New())

	// Swagger UIのエンドポイント
	app.Get("/swagger/*", fiberSwagger.WrapHandler)

	// APIルート
	api := app.Group("/api/v1")
	setupUserRoutes(api)

	log.Println("サーバーを起動しています... http://localhost:3000")
	log.Println("Swagger UI: http://localhost:3000/swagger/index.html")
	log.Fatal(app.Listen(":3000"))
}

func setupUserRoutes(api fiber.Router) {
	users := api.Group("/users")
	users.Get("/", getUsers)
	users.Get("/:id", getUserByID)
	users.Post("/", createUser)
	users.Put("/:id", updateUser)
	users.Delete("/:id", deleteUser)
}

func initSampleData() {
	users = []User{
		{ID: 1, Name: "田中太郎", Email: "tanaka@example.com", Age: 25},
		{ID: 2, Name: "佐藤花子", Email: "sato@example.com", Age: 30},
		{ID: 3, Name: "鈴木一郎", Email: "suzuki@example.com", Age: 28},
	}
	nextID = 4
}

// @Summary 全ユーザー取得
// @Description 登録されている全てのユーザーを取得
// @Tags users
// @Accept json
// @Produce json
// @Success 200 {array} User
// @Router /users [get]
func getUsers(c *fiber.Ctx) error {
	return c.JSON(users)
}

// @Summary ユーザー詳細取得
// @Description 指定されたIDのユーザー詳細を取得
// @Tags users
// @Accept json
// @Produce json
// @Param id path int true "ユーザーID"
// @Success 200 {object} User
// @Failure 400 {object} ErrorResponse
// @Failure 404 {object} ErrorResponse
// @Router /users/{id} [get]
func getUserByID(c *fiber.Ctx) error {
	id, err := strconv.Atoi(c.Params("id"))
	if err != nil {
		return c.Status(400).JSON(ErrorResponse{Error: "無効なIDです"})
	}

	for _, user := range users {
		if user.ID == id {
			return c.JSON(user)
		}
	}

	return c.Status(404).JSON(ErrorResponse{Error: "ユーザーが見つかりません"})
}

// @Summary ユーザー作成
// @Description 新しいユーザーを作成
// @Tags users
// @Accept json
// @Produce json
// @Param user body User true "ユーザー情報（IDは自動生成されるため不要）"
// @Success 201 {object} User
// @Failure 400 {object} ErrorResponse
// @Router /users [post]
func createUser(c *fiber.Ctx) error {
	var newUser User

	if err := c.BodyParser(&newUser); err != nil {
		return c.Status(400).JSON(ErrorResponse{Error: "リクエストボディが無効です"})
	}

	if newUser.Name == "" || newUser.Email == "" {
		return c.Status(400).JSON(ErrorResponse{Error: "名前とメールは必須です"})
	}

	newUser.ID = nextID
	nextID++
	users = append(users, newUser)

	return c.Status(201).JSON(newUser)
}

// @Summary ユーザー更新
// @Description 指定されたIDのユーザー情報を更新
// @Tags users
// @Accept json
// @Produce json
// @Param id path int true "ユーザーID"
// @Param user body User true "更新するユーザー情報"
// @Success 200 {object} User
// @Failure 400 {object} ErrorResponse
// @Failure 404 {object} ErrorResponse
// @Router /users/{id} [put]
func updateUser(c *fiber.Ctx) error {
	id, err := strconv.Atoi(c.Params("id"))
	if err != nil {
		return c.Status(400).JSON(ErrorResponse{Error: "無効なIDです"})
	}

	var updatedUser User
	if err := c.BodyParser(&updatedUser); err != nil {
		return c.Status(400).JSON(ErrorResponse{Error: "リクエストボディが無効です"})
	}

	if updatedUser.Name == "" || updatedUser.Email == "" {
		return c.Status(400).JSON(ErrorResponse{Error: "名前とメールは必須です"})
	}

	for i, user := range users {
		if user.ID == id {
			updatedUser.ID = id
			users[i] = updatedUser
			return c.JSON(updatedUser)
		}
	}

	return c.Status(404).JSON(ErrorResponse{Error: "ユーザーが見つかりません"})
}

// @Summary ユーザー削除
// @Description 指定されたIDのユーザーを削除
// @Tags users
// @Accept json
// @Produce json
// @Param id path int true "ユーザーID"
// @Success 200 {object} map[string]string
// @Failure 400 {object} ErrorResponse
// @Failure 404 {object} ErrorResponse
// @Router /users/{id} [delete]
func deleteUser(c *fiber.Ctx) error {
	id, err := strconv.Atoi(c.Params("id"))
	if err != nil {
		return c.Status(400).JSON(ErrorResponse{Error: "無効なIDです"})
	}

	for i, user := range users {
		if user.ID == id {
			users = append(users[:i], users[i+1:]...)
			return c.JSON(map[string]string{"message": "ユーザーが削除されました"})
		}
	}

	return c.Status(404).JSON(ErrorResponse{Error: "ユーザーが見つかりません"})
}
