# Makefile for Go Fiber CRUD API (Structured Version)

.PHONY: help install run swagger clean build dev test setup migrate-structure fmt vet lint deps

# デフォルトターゲット - ヘルプを表示
help:
	@echo "Available commands:"
	@echo "  install         - Install dependencies"
	@echo "  build           - Build the application"
	@echo "  run             - Run the application"
	@echo "  dev             - Run in development mode with hot reload"
	@echo "  test            - Run tests"
	@echo "  swagger         - Generate Swagger documentation"
	@echo "  clean           - Clean build artifacts"
	@echo "  migrate-structure - Create structured directories"
	@echo "  setup           - Initial project setup"
	@echo "  fmt             - Format code"
	@echo "  vet             - Run go vet"
	@echo "  lint            - Run linters"
	@echo "  deps            - Show dependencies"

# 依存関係のインストール
install:
	go mod download
	go mod tidy
	go get github.com/gofiber/fiber/v2
	go get github.com/swaggo/fiber-swagger
	go install github.com/swaggo/swag/cmd/swag@latest
	go install github.com/cosmtrek/air@latest

# 構造化ディレクトリの作成
migrate-structure:
	@echo "Creating structured project directories..."
	@mkdir -p cmd/api
	@mkdir -p internal/{config,handlers,models,routes,services,repositories}
	@mkdir -p pkg/{middleware,utils}
	@mkdir -p scripts
	@echo "Directory structure created successfully!"

# Swagger文書の生成（構造化後のパス）
swagger:
	swag init -g cmd/api/main.go -o docs

# アプリケーションの実行（構造化後のパス）
run: swagger
	go run cmd/api/main.go

# ビルド（構造化後のパス）
build: swagger
	go build -o bin/api cmd/api/main.go

# 開発モード（ホットリロード）
dev: swagger
	@if [ ! -f .air.toml ]; then \
		echo "Creating .air.toml configuration..."; \
		echo 'root = "."' > .air.toml; \
		echo 'tmp_dir = "tmp"' >> .air.toml; \
		echo '' >> .air.toml; \
		echo '[build]' >> .air.toml; \
		echo 'cmd = "go build -o ./tmp/main cmd/api/main.go"' >> .air.toml; \
		echo 'bin = "./tmp/main"' >> .air.toml; \
		echo 'include_ext = ["go", "tpl", "tmpl", "html"]' >> .air.toml; \
		echo 'exclude_dir = ["assets", "tmp", "vendor", "docs"]' >> .air.toml; \
	fi
	air

# テスト実行
test:
	go test -v ./...

# カバレッジ付きテスト
test-coverage:
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

# クリーンアップ
clean:
	rm -rf bin/
	rm -rf tmp/
	rm -rf docs/
	rm -f coverage.out coverage.html
	@echo "Cleanup completed!"

# コードフォーマット
fmt:
	go fmt ./...

# go vet実行
vet:
	go vet ./...

# リンター実行（golangci-lintがインストールされている場合）
lint:
	@if command -v golangci-lint >/dev/null 2>&1; then \
		golangci-lint run; \
	else \
		echo "golangci-lint not installed. Run: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"; \
	fi

# 依存関係の確認
deps:
	go list -m all

# プロダクションビルド
build-prod: swagger
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o bin/api cmd/api/main.go

# Docker関連
docker-build:
	docker build -t fiber-crud-api .

docker-run:
	docker run -p 3000:3000 fiber-crud-api

# 開発環境のセットアップ（初回のみ実行）
setup: install migrate-structure
	@echo "==================================="
	@echo "プロジェクトのセットアップが完了しました！"
	@echo "==================================="
	@echo ""
	@echo "次のステップ："
	@echo "1. ファイル分割の実行:"
	@echo "   - internal/models/user.go を作成"
	@echo "   - internal/handlers/user.go を作成"
	@echo "   - internal/routes/routes.go を作成"
	@echo "   - cmd/api/main.go を作成"
	@echo ""
	@echo "2. サーバーの起動:"
	@echo "   make run"
	@echo ""
	@echo "3. 開発モード（ホットリロード）:"
	@echo "   make dev"
	@echo ""
	@echo "4. Swagger UI:"
	@echo "   http://localhost:3000/swagger/index.html"
	@echo ""

# レガシーサポート（既存のmain.goでの実行）
run-legacy:
	swag init -g main.go
	go run main.go

# ビルド・テスト・リント を一括実行
check: fmt vet test
	@echo "All checks passed!"

# CI/CD用のビルドとテスト
ci: install swagger fmt vet test build
	@echo "CI pipeline completed successfully!"