# GitHub Secrets の設定

このドキュメントでは、MCP サーバーを Google Cloud Run にデプロイするために必要な GitHub Secrets の設定方法について説明します。

## 前提条件

- GitHub リポジトリの管理者権限
- Google Cloud Platform のプロジェクト作成・管理権限
- 各 MCP サーバーに必要なアクセストークン（GitHub, Notion など）

## 必要な GitHub Secrets

### グローバル設定（すべての MCP サーバーに共通）

1. **`GCP_PROJECT_ID`**  
   Google Cloud Platform のプロジェクト ID

   - Google Cloud Console > プロジェクト情報から取得できます
   - 例: `my-mcp-project-12345`

2. **`GCP_REGION`**  
   Google Cloud Run をデプロイするリージョン

   - Google Cloud サービスをデプロイするリージョンを指定します
   - 例: `us-central1`, `asia-northeast1`
   - [利用可能なリージョン一覧](https://cloud.google.com/run/docs/locations)

3. **`GCP_SA_KEY`**  
   Google Cloud Platform のサービスアカウントキー（JSON 形式）

   - サービスアカウントの作成手順:
     1. Google Cloud Console > IAM > サービスアカウント > 「サービスアカウントを作成」
     2. 必要な権限: `Cloud Run Admin`, `Storage Admin`, `Service Account User`
     3. キーを作成（JSON 形式）し、その内容を丸ごとコピー

### MCP サーバー固有の設定

1. **`GH_PERSONAL_ACCESS_TOKEN`**  
   GitHub MCP サーバーで使用する GitHub Personal Access Token

   - GitHub アカウント > Settings > Developer settings > Personal access tokens
   - 必要なスコープ: `repo`, `read:user`, `user:email`
   - 注意: このトークンは定期的にローテーションすることをお勧めします

2. **`NOTION_API_TOKEN`**  
   Notion MCP サーバーで使用する Notion API トークン

   - [Notion Developers](https://developers.notion.com/) でアプリケーションを登録して取得
   - 必要な権限: `read_content`, `read_user`, `read_database`

## シークレットの設定方法

1. GitHub リポジトリにアクセスします
2. リポジトリの「Settings」タブをクリックします
3. 左側のメニューから「Secrets and variables」>「Actions」を選択します
4. 「New repository secret」ボタンをクリックします
5. 「Name」フィールドにシークレット名（上記の太字で示されている名前）を入力します
6. 「Value」フィールドに対応する値を入力します
7. 「Add secret」ボタンをクリックして保存します
8. 必要なすべてのシークレットについてこの手順を繰り返します

## シークレット存在確認システム

デプロイワークフローには、必要なシークレットの存在を確認する機能が組み込まれています。シークレットが不足している場合、以下のように動作します:

1. グローバルな必須シークレット（`GCP_PROJECT_ID`, `GCP_SA_KEY`, `GCP_REGION`）が不足している場合:

   - デプロイワークフロー全体が開始前に停止します
   - エラーメッセージに不足しているシークレットが表示されます

2. 特定の MCP サーバーに必要なシークレットが不足している場合:
   - その MCP サーバーのデプロイのみが停止します
   - 他の MCP サーバーは通常どおりデプロイされます

## トラブルシューティング

シークレットに関連する一般的な問題と解決策:

- **デプロイワークフローが失敗する**: GitHub Actions のログを確認し、シークレットの不足に関するエラーメッセージを探します
- **"Secret not found" エラー**: シークレット名が正確に一致していることを確認してください
- **権限エラー**: Google Cloud サービスアカウントに必要な権限がすべて付与されていることを確認してください
- **トークンの有効期限切れ**: GitHub や Notion のトークンが有効であることを確認してください
