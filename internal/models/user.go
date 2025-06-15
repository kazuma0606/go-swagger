// internal/models/user.go
package models

// User構造体 - ユーザー情報を格納
// @Description ユーザー情報
type User struct {
	ID    int    `json:"id" example:"1"`
	Name  string `json:"name" example:"田中太郎"`
	Email string `json:"email" example:"tanaka@example.com"`
	Age   int    `json:"age" example:"25"`
}

// ErrorResponse エラーレスポンス構造体
// @Description エラーレスポンス
type ErrorResponse struct {
	Error string `json:"error" example:"ユーザーが見つかりません"`
}
