# Makefile for structured Fiber CRUD API (Windows Compatible)

.PHONY: help install install-air build run dev dev-simple test clean swagger deps lint fmt vet setup dev-status

# デフォルトターゲット
help:
	@echo "Available commands:"
	@echo "  install         - Install dependencies"
	@echo "  install-air     - Install Air for hot reload"
	@echo "  build           - Build the application"
	@echo "  run             - Run the application"
	@echo "  dev             - Run in development mode with hot reload"
	@echo "  dev-simple      - Run in simple development mode (no hot reload)"
	@echo "  dev-status      - Check development environment status"
	@echo "  test            - Run tests"
	@echo "  swagger         - Generate Swagger documentation"
	@echo "  clean           - Clean build artifacts"
	@echo "  setup           - Initial project setup"
	@echo "  lint            - Run linters"
	@echo "  fmt             - Format code"
	@echo "  vet             - Run go vet"

# 依存関係のインストール
install:
	go mod download
	go mod tidy
	go install github.com/swaggo/swag/cmd/swag@latest

# Airのインストール（個別コマンド）
install-air:
	@echo "Installing Air for hot reload..."
	go install github.com/air-verse/air@latest
	@echo "Air installation completed!"
	@echo "You can now use 'make dev' for hot reload development."

# アプリケーションのビルド
build: swagger
	@if not exist bin mkdir bin
	go build -o bin/api.exe cmd/api/main.go

# アプリケーションの実行 - 既存main.goを優先
run:
	@if exist cmd\api\main.go ( \
		swag init -g cmd/api/main.go -o docs && \
		go run cmd/api/main.go \
	) else ( \
		echo "cmd/api/main.go not found, using existing main.go..." && \
		swag init -g main.go -o docs && \
		go run main.go \
	)

# 開発モード（ホットリロード） - Windows版
dev: swagger
	@echo "Checking for Air installation..."
	@where air >nul 2>&1 && ( \
		echo "Air found! Starting hot reload..." \
	) || ( \
		echo "Air not found. Installing..." && \
		$(MAKE) install-air \
	)
	@if not exist .air.toml ( \
		echo "Creating .air.toml configuration..." && \
		echo root = "." > .air.toml && \
		echo tmp_dir = "tmp" >> .air.toml && \
		echo. >> .air.toml && \
		echo [build] >> .air.toml && \
		echo cmd = "go build -o ./tmp/main.exe cmd/api/main.go" >> .air.toml && \
		echo bin = "./tmp/main.exe" >> .air.toml && \
		echo include_ext = ["go", "tpl", "tmpl", "html"] >> .air.toml && \
		echo exclude_dir = ["assets", "tmp", "vendor", "docs", "bin"] >> .air.toml && \
		echo delay = 1000 >> .air.toml && \
		echo stop_on_root = false >> .air.toml \
	)
	@echo "Starting development server with hot reload..."
	@air -c .air.toml || echo "Air failed. Use 'make dev-simple' instead."

# 開発モード（Airなしの代替案） - 既存main.goを優先
dev-simple:
	@if exist cmd\api\main.go ( \
		echo "Using structured main.go..." && \
		swag init -g cmd/api/main.go -o docs && \
		echo "Running in simple development mode (without hot reload)..." && \
		echo "File changes require manual restart with Ctrl+C and 'make run'." && \
		go run cmd/api/main.go \
	) else ( \
		echo "Using existing main.go..." && \
		swag init -g main.go -o docs && \
		echo "Running in simple development mode (without hot reload)..." && \
		echo "File changes require manual restart with Ctrl+C and 'make run'." && \
		go run main.go \
	)

# 開発モードの状況確認 - Windows版
dev-status:
	@echo "Development environment status:"
	@echo "  Go version: $(shell go version)"
	@where air >nul 2>&1 && ( \
		echo "  Air installed: ✓ Yes" \
	) || ( \
		echo "  Air installed: ✗ No (run 'make install-air')" \
	)
	@if exist .air.toml ( \
		echo "  .air.toml exists: ✓ Yes" \
	) else ( \
		echo "  .air.toml exists: ✗ No (will be created automatically)" \
	)
	@echo.
	@echo "Available development commands:"
	@echo "  make dev        - Hot reload (requires Air)"
	@echo "  make dev-simple - Simple mode (no hot reload)"
	@echo "  make run        - Single run"

# テストの実行
test:
	go test -v ./...

# カバレッジ付きテスト
test-coverage:
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

# Swagger文書の生成 - 自動判定
swagger:
	@if exist cmd\api\main.go ( \
		swag init -g cmd/api/main.go -o docs \
	) else ( \
		swag init -g main.go -o docs \
	)

# ビルド成果物のクリーンアップ - Windows版
clean:
	@if exist bin rmdir /s /q bin
	@if exist tmp rmdir /s /q tmp
	@if exist docs rmdir /s /q docs
	@if exist coverage.out del coverage.out
	@if exist coverage.html del coverage.html
	@if exist .air.toml del .air.toml
	@echo "Cleanup completed!"

# コードフォーマット
fmt:
	go fmt ./...

# go vet実行
vet:
	go vet ./...

# リンター実行 - Windows版
lint:
	@where golangci-lint >nul 2>&1 && ( \
		golangci-lint run \
	) || ( \
		echo "golangci-lint not installed. Install with:" && \
		echo "go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest" \
	)

# 依存関係の確認
deps:
	go list -m all

# セキュリティチェック - Windows版
security:
	@where gosec >nul 2>&1 && ( \
		gosec ./... \
	) || ( \
		echo "gosec not installed. Install with:" && \
		echo "go install github.com/securecodewarrior/gosec/v2/cmd/gosec@latest" \
	)

# プロダクションビルド - Windows版
build-prod: swagger
	@if not exist bin mkdir bin
	set CGO_ENABLED=0&& set GOOS=linux&& go build -a -installsuffix cgo -o bin/api cmd/api/main.go

# Docker関連
docker-build:
	docker build -t fiber-crud-api .

docker-run:
	docker run -p 3000:3000 fiber-crud-api

# 開発環境のセットアップ（初回のみ）- Windows版
setup: install
	@echo "Creating project structure..."
	@if not exist cmd\api mkdir cmd\api
	@if not exist internal mkdir internal
	@if not exist internal\config mkdir internal\config
	@if not exist internal\handlers mkdir internal\handlers
	@if not exist internal\models mkdir internal\models
	@if not exist internal\repositories mkdir internal\repositories
	@if not exist internal\repositories\interfaces mkdir internal\repositories\interfaces
	@if not exist internal\services mkdir internal\services
	@if not exist internal\services\interfaces mkdir internal\services\interfaces
	@if not exist internal\routes mkdir internal\routes
	@if not exist pkg mkdir pkg
	@if not exist pkg\middleware mkdir pkg\middleware
	@if not exist pkg\utils mkdir pkg\utils
	@if not exist docs mkdir docs
	@if not exist scripts mkdir scripts
	@echo.
	@echo "==================================="
	@echo "Project setup complete!"
	@echo "==================================="
	@echo.
	@echo "Next steps:"
	@echo "1. Create your structured files:"
	@echo "   - internal\models\user.go"
	@echo "   - internal\handlers\user.go"
	@echo "   - internal\routes\routes.go"
	@echo "   - cmd\api\main.go"
	@echo.
	@echo "2. Development options:"
	@echo "   make install-air  # Install hot reload tool"
	@echo "   make dev          # Hot reload development"
	@echo "   make dev-simple   # Simple development"
	@echo "   make run          # Single run"
	@echo.
	@echo "3. Check status:"
	@echo "   make dev-status"
	@echo.

# 全体チェック
check: fmt vet test
	@echo "All checks passed!"

# CI/CD用
ci: install swagger fmt vet test build
	@echo "CI pipeline completed successfully!"

# レガシーサポート（既存のmain.goでの実行）
run-legacy:
	swag init -g main.go
	go run main.go

# 簡単な開発用ホットリロード（Airの代替）
dev-watch:
	@echo "Starting simple file watcher..."
	@echo "Press Ctrl+C to stop, then restart with 'make run'"
	@go run cmd/api/main.go

# PowerShell用のAirインストール
install-air-powershell:
	@echo "Installing Air using PowerShell..."
	@powershell -Command "go install github.com/air-verse/air@latest"
	@echo "Air installation completed!"
	@echo "If Air is not found, add Go bin to PATH:"
	@echo "$$env:PATH += \";$$(go env GOPATH)\bin\""