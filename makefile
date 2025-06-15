# Makefile for Go Fiber CRUD API

.PHONY: install run swagger clean

# 依存関係のインストール
install:
	go mod init fiber-crud-api
	go get github.com/gofiber/fiber/v2
	go get github.com/gofiber/swagger
	go get github.com/swaggo/swag/cmd/swag
	go install github.com/swaggo/swag/cmd/swag@latest

# Swagger文書の生成
swagger:
	swag init -g main.go

# アプリケーションの実行
run: swagger
	go run main.go

# ビルド
build: swagger
	go build -o app main.go

# クリーンアップ
clean:
	rm -f app
	rm -rf docs/

# 開発用：ファイル変更時に自動再起動
dev:
	go install github.com/cosmtrek/air@latest
	air

# テスト実行
test:
	go test -v ./...

# セットアップ（初回のみ実行）
setup: install
	@echo "プロジェクトのセットアップが完了しました。"
	@echo "次のコマンドでサーバーを起動してください："
	@echo "make run"
	@echo ""
	@echo "Swagger UIは以下のURLでアクセスできます："
	@echo "http://localhost:3000/swagger/"