# Fiber CRUD API

Go言語の[Fiber](https://gofiber.io/)フレームワークを使用したRESTful CRUD APIのサンプルプロジェクトです。

## 🚀 特徴

- **高速**: Fiber（Express.jsライク）による高パフォーマンス
- **CRUD操作**: ユーザー管理の完全なCRUD機能
- **Swagger統合**: インタラクティブなAPI仕様書とテスト環境
- **構造化設計**: 保守性の高いレイヤードアーキテクチャ
- **ホットリロード**: 開発効率を向上させるlive reload機能
- **日本語対応**: 日本語でのコメントとエラーメッセージ

## 📋 API仕様

### エンドポイント

| メソッド | パス | 説明 |
|---------|------|------|
| `GET` | `/api/v1/users` | 全ユーザー取得 |
| `GET` | `/api/v1/users/{id}` | 特定ユーザー取得 |
| `POST` | `/api/v1/users` | ユーザー作成 |
| `PUT` | `/api/v1/users/{id}` | ユーザー更新 |
| `DELETE` | `/api/v1/users/{id}` | ユーザー削除 |
| `GET` | `/health` | ヘルスチェック |

### データモデル

```json
{
  "id": 1,
  "name": "田中太郎",
  "email": "tanaka@example.com",
  "age": 25
}
```

## 🛠 セットアップ

### 前提条件

- Go 1.18以上
- Git

### インストール

```bash
# リポジトリのクローン
https://github.com/kazuma0606/go-swagger.git
cd fiber-crud-api

# 依存関係のインストールとプロジェクトセットアップ
make setup
```

## 🚀 実行方法

### 開発モード（推奨）

```bash
# ホットリロード付きで実行
make dev
```

### 通常実行

```bash
# 一回だけ実行
make run
```

### プロダクションビルド

```bash
# バイナリをビルド
make build

# 実行
./bin/api
```

## 📚 Swagger UI

このプロジェクトはSwagger UIを統合しており、ブラウザ上でAPIの仕様確認とテストが可能です。

### アクセス方法

サーバー起動後、以下のURLにアクセス：

```
http://localhost:3000/swagger/index.html
```

### Swagger UIでできること

- **API仕様の確認**: 全エンドポイントの詳細な仕様
- **インタラクティブテスト**: ブラウザ上でAPIを直接実行
- **レスポンス確認**: 成功・エラー時のレスポンス例
- **リクエスト生成**: cURLコマンドの自動生成

![Swagger UI Screenshot](https://via.placeholder.com/800x400?text=Swagger+UI+Screenshot)

### Swagger文書の更新

コードを変更した場合、Swagger文書を再生成：

```bash
make swagger
```

## 🧪 APIテスト例

### cURLでのテスト

```bash
# 全ユーザー取得
curl http://localhost:3000/api/v1/users

# ユーザー作成
curl -X POST http://localhost:3000/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name":"山田太郎","email":"yamada@example.com","age":30}'

# 特定ユーザー取得
curl http://localhost:3000/api/v1/users/1

# ユーザー更新
curl -X PUT http://localhost:3000/api/v1/users/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"山田次郎","email":"yamada@example.com","age":31}'

# ユーザー削除
curl -X DELETE http://localhost:3000/api/v1/users/1
```

### JavaScriptでのテスト

```javascript
// ユーザー一覧取得
const response = await fetch('http://localhost:3000/api/v1/users');
const users = await response.json();
console.log(users);

// ユーザー作成
const newUser = await fetch('http://localhost:3000/api/v1/users', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    name: '佐藤花子',
    email: 'sato@example.com',
    age: 28
  })
});
```

## 📁 プロジェクト構造

```
fiber-crud-api/
├── cmd/
│   └── api/
│       └── main.go          # エントリーポイント
├── internal/                # プライベートコード
│   ├── config/
│   │   └── config.go        # 設定管理
│   ├── handlers/            # HTTPハンドラー
│   │   └── user.go
│   ├── models/              # データモデル
│   │   └── user.go
│   └── routes/              # ルート定義
│       └── routes.go
├── docs/                    # Swagger生成ファイル
│   ├── docs.go
│   ├── swagger.json
│   └── swagger.yaml
├── .air.toml               # ホットリロード設定
├── Makefile                # ビルドタスク
├── go.mod
├── go.sum
└── README.md
```

## 📝 開発コマンド

```bash
# ヘルプ表示
make help

# 依存関係インストール
make install

# 開発モード（ホットリロード）
make dev

# 通常実行
make run

# ビルド
make build

# テスト実行
make test

# カバレッジ付きテスト
make test-coverage

# Swagger文書生成
make swagger

# コードフォーマット
make fmt

# 静的解析
make vet

# リンター実行
make lint

# 全体チェック（fmt + vet + test）
make check

# クリーンアップ
make clean
```

## 🔧 設定

環境変数で設定をカスタマイズできます：

```bash
# サーバーアドレス（デフォルト: :3000）
export SERVER_ADDRESS=":8080"

# アプリケーション名（デフォルト: "Fiber CRUD API"）
export APP_NAME="My Custom API"
```

## 🏗 アーキテクチャ

このプロジェクトはレイヤードアーキテクチャを採用しています：

```
┌─────────────────┐
│   Handler層     │ ← HTTPリクエスト/レスポンス処理
├─────────────────┤
│   Service層     │ ← ビジネスロジック（将来拡張用）
├─────────────────┤
│ Repository層    │ ← データアクセス（将来拡張用）
└─────────────────┘
```

## 🚧 今後の拡張予定

- [ ] データベース統合（PostgreSQL/MySQL）
- [ ] JWT認証
- [ ] バリデーション強化
- [ ] ログ機能
- [ ] ユニットテスト追加
- [ ] Docker対応
- [ ] CI/CD パイプライン

## 🤝 コントリビューション

1. このリポジトリをフォーク
2. フィーチャーブランチを作成（`git checkout -b feature/amazing-feature`）
3. 変更をコミット（`git commit -m 'Add amazing feature'`）
4. ブランチにプッシュ（`git push origin feature/amazing-feature`）
5. プルリクエストを作成

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は[LICENSE](LICENSE)ファイルを参照してください。

## 🙋‍♂️ サポート

質問やバグ報告は[Issues](https://github.com/kazuma0606/go-swagger/issues)でお願いします。

---

## 📖 参考資料

- [Fiber公式ドキュメント](https://docs.gofiber.io/)
- [Swagger/OpenAPI仕様](https://swagger.io/specification/)
- [Go公式ドキュメント](https://golang.org/doc/)

**Happy Coding! 🎉**