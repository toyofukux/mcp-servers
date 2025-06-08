# MCP サーバーの Google Cloud Run ホスティングについて

## MCP とは

MCP（Model Context Protocol）は、システム間のリソースをプログラム的に利用可能にするための通信プロトコルです。  
MCP サーバーは、このプロトコルに準拠したツールやリソースを提供し、クライアントからのリクエストに応答します。

## 必須の GitHub Secrets

デプロイに必要な GitHub Secrets を以下に示します。これらすべてのシークレットは、リポジトリの設定で事前に設定する必要があります。
ワークフローには、デプロイ前に必須シークレットの存在を確認する機能が組み込まれており、不足しているシークレットがある場合はデプロイが停止されます。

### グローバルに必要なシークレット（すべての MCP サーバー共通）

- `GCP_PROJECT_ID` - Google Cloud プロジェクト ID
- `GCP_REGION` - デプロイ先リージョン（例: `us-central1`）
- `GCP_SA_KEY` - サービスアカウントの JSON キー（全体をコピー）

### 個別の MCP サーバーに必要なシークレット

- `GH_PERSONAL_ACCESS_TOKEN` - GitHub MCP サーバー用のトークン
- `NOTION_API_TOKEN` - Notion MCP サーバー用の API トークン（OPENAPI_MCP_HEADERS で使用）

## Google Cloud Run でのホスティング

Google Cloud Run は、サーバーレスで Docker コンテナを実行できる Google Cloud のマネージドプラットフォームです。  
以下の特徴があり、MCP サーバーのホスティングに適しています：

- 必要なときだけ稼働するサーバーレス構成（コスト効率良好）
- グローバルに分散した高速なエンドポイント提供
- Docker コンテナとの優れた互換性
- スケールアップ・スケールダウンの柔軟性
- IAM による堅牢な認証機能

## MCP サーバーのデプロイについて

本リポジトリで対応している MCP サーバーは、基本的に Docker コンテナとして構築されています。  
Google Cloud Run 上でこれらの Docker コンテナをデプロイすることを前提としています。

### デプロイの流れ（概要）

1. MCP サーバーごとの Docker イメージ情報を `docker-image.txt` と `version.txt` で管理します。
2. GitHub Actions を用いて CI/CD パイプラインを構築し、Google Cloud Run へのデプロイを自動化します。
3. Google Cloud Run 上で MCP サーバーが稼働し、クライアントからのリクエストに応答します。

### ファイル構成例

- `/mcps/`  
  MCP サーバーごとのディレクトリを配置し、それぞれに `docker-image.txt` と `version.txt` を格納します。

  - `/mcps/github/` - GitHub MCP サーバー
  - `/mcps/notion/` - Notion MCP サーバー

- `.github/workflows/`  
  GitHub Actions のワークフローファイルを配置し、MCP サーバーのビルド・デプロイジョブを定義します。

  - `deploy-mcp-servers.yml` - MCP サーバーのデプロイワークフロー

- `/docs/`  
  MCP サーバー一覧や運用に関するドキュメントを管理します。
  - `github-mcp-server.md` - GitHub MCP サーバーのドキュメント
  - `github-secrets-setup.md` - GitHub Secrets の設定手順

## 本リポジトリで対応している MCP サーバー一覧

- GitHub MCP サーバー (`/mcps/github/`)
- Notion MCP サーバー (`/mcps/notion/`)

各サーバーの詳細なドキュメントは `/docs/` ディレクトリを参照してください。

## GitHub Secrets による認証情報の管理

Google Cloud Run へのデプロイには、以下の GitHub Secrets の設定が必要です：

- `GCP_PROJECT_ID` - Google Cloud プロジェクト ID
- `GCP_REGION` - デプロイ先リージョン（例: `us-central1`）
- `GCP_SA_KEY` - サービスアカウントの JSON キー（base64 エンコードなし）

### サービスアカウント設定手順

1. Google Cloud Console で新しいサービスアカウントを作成します
2. 以下の権限を付与します：
   - Cloud Run 管理者（roles/run.admin）
   - IAM サービスアカウントユーザー（roles/iam.serviceAccountUser）
   - ストレージ管理者（roles/storage.admin）
3. サービスアカウントキー（JSON 形式）をダウンロードします
4. GitHub リポジトリの Settings > Secrets > Actions に上記の Secrets を設定します

## 初期セットアップ

### Google Cloud プロジェクトの設定

1. Google Cloud Console で新しいプロジェクトを作成するか、既存のプロジェクトを選択します。
2. 以下の API を有効化します：
   - Cloud Run API
   - Identity and Access Management (IAM) API
   - Container Registry API または Artifact Registry API
3. サービスアカウントを作成し、必要な権限を付与します（上記の「サービスアカウント設定手順」を参照）。
4. サービスアカウントキー（JSON 形式）をダウンロードし、安全に保管します。

### GitHub リポジトリの設定

1. リポジトリの Settings > Secrets > Actions で以下の Secrets を設定します：
   - `GCP_PROJECT_ID` - Google Cloud プロジェクト ID
   - `GCP_REGION` - デプロイ先リージョン（例: `us-central1`）
   - `GCP_SA_KEY` - サービスアカウントの JSON キー（全体をコピー）
   - `GITHUB_PERSONAL_ACCESS_TOKEN` - GitHub MCP サーバー用のトークン
   - `NOTION_API_TOKEN` - Notion MCP サーバー用の API トークン（OPENAPI_MCP_HEADERS で使用）

### 初回デプロイ

1. 以下のコマンドで変更をコミットし、リポジトリにプッシュします：

```bash
git add .
git commit -m "Google Cloud Run 向けの MCP サーバー設定"
git push origin main
```

2. GitHub Actions が自動的に実行され、MCP サーバーが Google Cloud Run にデプロイされます。
3. デプロイが完了したら、Google Cloud Console で Cloud Run サービスを確認し、サービス URL を取得します。

## 環境変数管理

### ローカルコンテナ起動時の環境変数管理

- ローカルでの開発時は、Docker コマンドを直接使用して各 MCP サーバーのコンテナを起動します。
- 環境変数は親リポジトリの `env/` ディレクトリに `.env.<server_name>` 形式で配置してください。
- 例: `env/.env.github`

```
GITHUB_PERSONAL_ACCESS_TOKEN=your_token_here
OTHER_ENV_VAR=value
```

- GitHub MCP サーバーを起動する場合:

```bash
# 環境変数ファイルから変数を読み込む
IMAGE=$(cat mcps/github/docker-image.txt)
VERSION=$(cat mcps/github/version.txt)
FULL_IMAGE="${IMAGE}:${VERSION}"

# Docker コンテナを起動
docker pull $FULL_IMAGE
docker run -d --name mcp-github-container -p 8080:8080 --env-file env/.env.github $FULL_IMAGE
```

- Notion MCP サーバーを起動する場合:

```bash
# 環境変数ファイルから変数を読み込む
IMAGE=$(cat mcps/notion/docker-image.txt)
VERSION=$(cat mcps/notion/version.txt)
FULL_IMAGE="${IMAGE}:${VERSION}"

# Docker コンテナを起動
docker pull $FULL_IMAGE
docker run -d --name mcp-notion-container -p 8081:8080 --env-file env/.env.notion $FULL_IMAGE
```

- コンテナを停止する場合:

```bash
docker stop mcp-github-container
docker rm mcp-github-container

docker stop mcp-notion-container
docker rm mcp-notion-container
```

- 環境変数の追加や変更があった場合は、対応する `.env` ファイルを編集してください。
- 必須の環境変数（例: `GITHUB_PERSONAL_ACCESS_TOKEN`）は必ず設定してください。
- `.env` ファイルは Git 管理から除外することを推奨します（`.gitignore`に追加）。

### Google Cloud Run デプロイ時の環境変数管理

- 本番環境の MCP サーバーには、GitHub Actions デプロイ時に環境変数を設定する必要があります。
- 環境変数はワークフローファイル（`.github/workflows/deploy-mcp-servers.yml`）で設定します。
- 秘密情報を含む環境変数は GitHub Secrets を使用し、以下のようにデプロイコマンドに追加できます：

```yaml
gcloud run deploy $SERVICE_NAME \
  --image $DEPLOY_IMAGE \
  # 他のオプション
  --set-env-vars="KEY1=${{ secrets.VALUE1 }},KEY2=${{ secrets.VALUE2 }}"
```

- 実際のデプロイに必要な環境変数は、各 MCP サーバーのドキュメントを参照してください。

#### Notion MCP サーバーの環境変数について

Notion MCP サーバーは、`OPENAPI_MCP_HEADERS` という特別な環境変数を使用します。これは Notion の認証トークンと API バージョンを含む JSON 形式のヘッダー情報です：

```json
{
  "Authorization": "Bearer ntn_****",
  "Notion-Version": "2022-06-28"
}
```

GitHub Actions では、これを以下のように設定しています：

```yaml
NOTION_HEADERS="{\"Authorization\":\"Bearer ${{ secrets.NOTION_API_TOKEN }}\",\"Notion-Version\":\"2022-06-28\"}"
--set-env-vars="OPENAPI_MCP_HEADERS=$NOTION_HEADERS"
```

GitHub Secrets には`NOTION_API_TOKEN`という名前で Notion の API トークン（`ntn_`で始まる）を設定してください。

## MCP クライアントの認証設定

Google Cloud Run にデプロイされた MCP サーバーにアクセスするには、以下のいずれかの方法で認証を行います：

1. **サービスアカウントキーによる認証**:

   - ID トークンを取得して Authorization ヘッダーに設定します。
   - mcp-remote を使用する場合:
     ```bash
     export MCP_REMOTE_HEADERS='{"Authorization": "Bearer $(gcloud auth print-identity-token)"}'
     ```

2. **IAM 認証**:

   - Google Cloud の IAM 権限により、特定のユーザーやサービスアカウントにのみアクセスを許可します。
   - デプロイ後、以下のコマンドで権限を付与します：

     ```bash
     # 特定のユーザーにアクセス権を付与
     gcloud run services add-iam-policy-binding mcp-github \
       --region=$REGION \
       --member="user:user@example.com" \
       --role="roles/run.invoker"

     # 特定のサービスアカウントにアクセス権を付与
     gcloud run services add-iam-policy-binding mcp-github \
       --region=$REGION \
       --member="serviceAccount:my-sa@project-id.iam.gserviceaccount.com" \
       --role="roles/run.invoker"
     ```

3. **MCP クライアント (例：Claude) での設定**:
   - MCP サーバーの URL は、デプロイ後に表示される Cloud Run サービスの URL を使用します。
   - 例: `https://mcp-github-abc123def-an.a.run.app`
   - ヘッダー設定例:
     ```json
     {
       "Authorization": "Bearer ID_TOKEN_HERE"
     }
     ```
   - AI サービスの設定インターフェースでこれらの値を設定してください。
