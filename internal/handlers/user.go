// internal/handlers/user.go
package handlers

import (
	"strconv"

	"fiber-crud-api/internal/models"

	"github.com/gofiber/fiber/v2"
)

// メモリ上のデータストア（グローバル変数として一時的に保持）
var users []models.User
var nextID = 1

// InitSampleData サンプルデータの初期化
func InitSampleData() {
	users = []models.User{
		{ID: 1, Name: "田中太郎", Email: "tanaka@example.com", Age: 25},
		{ID: 2, Name: "佐藤花子", Email: "sato@example.com", Age: 30},
		{ID: 3, Name: "鈴木一郎", Email: "suzuki@example.com", Age: 28},
	}
	nextID = 4
}

// GetUsers 全ユーザー取得
// @Summary 全ユーザー取得
// @Description 登録されている全てのユーザーを取得
// @Tags users
// @Accept json
// @Produce json
// @Success 200 {array} models.User
// @Router /users [get]
func GetUsers(c *fiber.Ctx) error {
	return c.JSON(users)
}

// GetUserByID ユーザー詳細取得
// @Summary ユーザー詳細取得
// @Description 指定されたIDのユーザー詳細を取得
// @Tags users
// @Accept json
// @Produce json
// @Param id path int true "ユーザーID"
// @Success 200 {object} models.User
// @Failure 400 {object} models.ErrorResponse
// @Failure 404 {object} models.ErrorResponse
// @Router /users/{id} [get]
func GetUserByID(c *fiber.Ctx) error {
	id, err := strconv.Atoi(c.Params("id"))
	if err != nil {
		return c.Status(400).JSON(models.ErrorResponse{Error: "無効なIDです"})
	}

	for _, user := range users {
		if user.ID == id {
			return c.JSON(user)
		}
	}

	return c.Status(404).JSON(models.ErrorResponse{Error: "ユーザーが見つかりません"})
}

// CreateUser ユーザー作成
// @Summary ユーザー作成
// @Description 新しいユーザーを作成
// @Tags users
// @Accept json
// @Produce json
// @Param user body models.User true "ユーザー情報（IDは自動生成されるため不要）"
// @Success 201 {object} models.User
// @Failure 400 {object} models.ErrorResponse
// @Router /users [post]
func CreateUser(c *fiber.Ctx) error {
	var newUser models.User

	if err := c.BodyParser(&newUser); err != nil {
		return c.Status(400).JSON(models.ErrorResponse{Error: "リクエストボディが無効です"})
	}

	if newUser.Name == "" || newUser.Email == "" {
		return c.Status(400).JSON(models.ErrorResponse{Error: "名前とメールは必須です"})
	}

	newUser.ID = nextID
	nextID++
	users = append(users, newUser)

	return c.Status(201).JSON(newUser)
}

// UpdateUser ユーザー更新
// @Summary ユーザー更新
// @Description 指定されたIDのユーザー情報を更新
// @Tags users
// @Accept json
// @Produce json
// @Param id path int true "ユーザーID"
// @Param user body models.User true "更新するユーザー情報"
// @Success 200 {object} models.User
// @Failure 400 {object} models.ErrorResponse
// @Failure 404 {object} models.ErrorResponse
// @Router /users/{id} [put]
func UpdateUser(c *fiber.Ctx) error {
	id, err := strconv.Atoi(c.Params("id"))
	if err != nil {
		return c.Status(400).JSON(models.ErrorResponse{Error: "無効なIDです"})
	}

	var updatedUser models.User
	if err := c.BodyParser(&updatedUser); err != nil {
		return c.Status(400).JSON(models.ErrorResponse{Error: "リクエストボディが無効です"})
	}

	if updatedUser.Name == "" || updatedUser.Email == "" {
		return c.Status(400).JSON(models.ErrorResponse{Error: "名前とメールは必須です"})
	}

	for i, user := range users {
		if user.ID == id {
			updatedUser.ID = id
			users[i] = updatedUser
			return c.JSON(updatedUser)
		}
	}

	return c.Status(404).JSON(models.ErrorResponse{Error: "ユーザーが見つかりません"})
}

// DeleteUser ユーザー削除
// @Summary ユーザー削除
// @Description 指定されたIDのユーザーを削除
// @Tags users
// @Accept json
// @Produce json
// @Param id path int true "ユーザーID"
// @Success 200 {object} map[string]string
// @Failure 400 {object} models.ErrorResponse
// @Failure 404 {object} models.ErrorResponse
// @Router /users/{id} [delete]
func DeleteUser(c *fiber.Ctx) error {
	id, err := strconv.Atoi(c.Params("id"))
	if err != nil {
		return c.Status(400).JSON(models.ErrorResponse{Error: "無効なIDです"})
	}

	for i, user := range users {
		if user.ID == id {
			users = append(users[:i], users[i+1:]...)
			return c.JSON(map[string]string{"message": "ユーザーが削除されました"})
		}
	}

	return c.Status(404).JSON(models.ErrorResponse{Error: "ユーザーが見つかりません"})
}
