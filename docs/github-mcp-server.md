# Github MCP サーバーの Google Cloud Run 管理・デプロイ

## 概要

このドキュメントは、自分が使用する複数の Github MCP サーバーを Google Cloud Run 上で管理・デプロイする手順をまとめたものです。

## 1. MCP サーバーの配置と管理

- 複数の MCP サーバーを管理する場合、リポジトリ内で以下のようにディレクトリを分けて管理することを推奨します。

```
/mcps/
  github-mcp-server/
  other-mcp-server/
```

- 各サーバーは独立した Google Cloud Run サービスとしてデプロイ可能な構成にします。

## 2. Google Cloud Run 設定

- Notion や GitHub などの公式 MCP サーバーを利用する場合は、多くの場合公開レジストリに Docker イメージが既に公開されているため、Dockerfile は不要です。

- 公式サーバー用に `docker-image.txt` ファイルを用意し、使用するイメージのパスを記載します。例えば:

```
/mcps/github-mcp-server/docker-image.txt
/mcps/notion-mcp-server/docker-image.txt
```

- `docker-image.txt` の例:

```
ghcr.io/github/mcp-server
```

- 各 MCP サーバーのルートディレクトリに `version.txt` ファイルを作成し、現在のバージョンを記録します。
  これは GitHub Actions でのデプロイ時にバージョンを識別するために使用します。

```
/mcps/github-mcp-server/version.txt
/mcps/other-mcp-server/version.txt
```

- バージョンファイルの例:

```
1.0.0
```

## 3. ローカル動作確認

- 公式 Docker イメージを使ってローカルでテストする場合：

```bash
cd mcps/github-mcp-server
# docker-image.txtからイメージを取得し、バージョンを指定してプル
IMAGE=$(cat docker-image.txt)
VERSION=$(cat version.txt)
docker pull ${IMAGE}:${VERSION}
docker run -p 8080:8080 ${IMAGE}:${VERSION}
```

- MCP クライアント側では認証ヘッダーを送信できる mcp-remote を使用する必要があります。
- Claude などの MCP クライアントに mcp-remote 経由でローカルの MCP サーバーとして設定し、動作を確認します。

## 4. バージョン管理とデプロイ

- バージョンアップ時には `version.txt` ファイルを更新し、commit/push します。
- GitHub Actions が設定されており、バージョンの変更を検知して自動的にデプロイを実行します。
- デプロイの詳細な手順は `.github/workflows/deploy-mcp-servers.yml` に記述されています。

## 5. 認証設定

- Google Cloud Run サービスは認証ありでデプロイされます (`--allow-unauthenticated=false`)。
- MCP クライアントは適切な認証ヘッダーを送信できる mcp-remote を使用する必要があります。
- 認証の設定例：

```
# MCP クライアント側 (mcp-remote 使用)
export MCP_REMOTE_HEADERS='{"Authorization": "Bearer YOUR_TOKEN"}'
```

- 認証情報は Google Cloud IAM でサービスアカウントを作成し、必要最小限の権限を付与してください。
- サービスアカウントのキーは GitHub Secrets に安全に保管します。

## 6. まとめ

- 複数の MCP サーバーをディレクトリ単位で分離し、それぞれ独立して Google Cloud Run にデプロイします。
- デプロイは `version.txt` の更新とプッシュによって GitHub Actions で自動化されます。
- Cloud Run サービスは認証ありでデプロイされ、mcp-remote を使用して安全にアクセスします。
- 認証情報は GitHub Secrets と Google Cloud IAM で安全に管理します。
