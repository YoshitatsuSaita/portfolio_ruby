# 俳句投稿・評価・添削アプリ 実装計画

## 概要

俳句を投稿し、他のユーザーに評価（星 + 寸評）や添削案をもらえる Web アプリ。
Attendance_A に続くポートフォリオ第2弾。

---

## 技術スタック

| 項目 | 技術 |
|---|---|
| フレームワーク | Ruby on Rails 7.1 |
| Ruby | 3.3.0 |
| DB（開発） | MySQL 5.7（Docker） |
| DB（本番） | PostgreSQL（Neon Tech 無料枠） |
| フロントエンド | Hotwire（Turbo + Stimulus）/ Bootstrap / jQuery |
| アセット | Sprockets + Importmap（Node.js不要） |
| 認証 | カスタム認証（bcrypt / has_secure_password） |
| 外部API | Gemini API（Flash, 無料枠）— 季語の解説生成 |
| テスト | RSpec / FactoryBot / Capybara |
| 静的解析 | RuboCop（rubocop-rails, rubocop-rspec） |
| コンテナ | Docker Compose |
| デプロイ | Render.com（free tier, Singapore） |

### ポート割り当て（Attendance_A との競合回避）

| サービス | Attendance_A | 俳句アプリ |
|---|---|---|
| MySQL | 3400 | 3401 |
| Web | 3108 | 3109 |

---

## Attendance_A からの流用ファイル

| ファイル | 状態 | 変更点 |
|---|---|---|
| `Gemfile` | ✅ 済 | faraday 追加、Ruby 3.3.0 |
| `Dockerfile` | ✅ 済 | Ruby 3.3.0、WORKDIR /myapp |
| `docker-compose.yml` | ✅ 済 | ポート 3401/3109 |
| `.rubocop.yml` | ✅ 済 | TargetRubyVersion 3.3 |
| `.claude/skills/coding-convention/SKILL.md` | ✅ 済 | Ruby 3.3.0 |
| `config/database.yml` | ✅ 済 | Docker db サービス接続、本番 PostgreSQL |
| `render.yaml` | ✅ 済 | haiku-app、GEMINI_API_KEY 追加 |

---

## モデル設計

### User（ユーザー）

| カラム | 型 | 備考 |
|---|---|---|
| name | string | 必須 |
| email | string | 必須、一意 |
| password_digest | string | bcrypt |
| admin | boolean | デフォルト false |
| profile_text | text | 自己紹介（任意） |
| remember_digest | string | ログイン記憶用 |

### Haiku（俳句）

| カラム | 型 | 備考 |
|---|---|---|
| user_id | references | FK → User |
| body | string | 句の本文（必須、5〜30文字）。定型・自由律どちらも対応 |
| kigo | string | 季語（必須、自由入力） |
| theme | string | お題（任意） |
| description | text | 作者メモ（任意） |
| status | integer | enum: draft/published/submitted_to_admin（デフォルト draft） |

- draft: 下書き
- published: 一般公開
- submitted_to_admin: 管理者へ投稿（管理者からの評価待ち）
- 管理者投稿の句は、管理者が Review を付けると自動で published に変わる
- ~~season カラム~~ → 削除済み（季語のフリー入力のみで運用）

### Review（評価・添削）

| カラム | 型 | 備考 |
|---|---|---|
| user_id | references | FK → User（評価者） |
| haiku_id | references | FK → Haiku |
| score | integer | 1〜5（必須） |
| comment | text | 寸評（任意） |
| correction_body | string | 添削案（任意）。元の句と比較表示される |
| correction_reason | text | 添削理由（任意） |

- 1ユーザーにつき1句1評価（user_id + haiku_id のユニーク制約）
- 自分の俳句には評価できない
- 添削案は常にそのまま表示される（承認ワークフローなし）。元の句は変更されない
- 投稿者名は評価者から「***」で隠される（ブラインドレビュー）。ボタンを押すと確認可能

### KigoExplanation（季語AI解説キャッシュ）

| カラム | 型 | 備考 |
|---|---|---|
| kigo_word | string | 入力された季語（一意インデックス） |
| canonical_word | string | 正式な季語（崩し表現の場合の元の形。例: 冬月→冬の月）。同一なら null |
| parent_kigo | string | 親季語（子季語の場合のみ。解説なし、名称のみ表示） |
| season | string | 季節。無季の場合は "none" |
| explanation | text | Gemini API で生成した解説文。無季の場合は null |

- 同じ季語は再問い合わせしない（DBキャッシュ）
- **ユーザーが季語解説ボタンを押した時のみ API を呼ぶ**（API 使用頻度を抑える）
- 無季の場合: 「無季」である旨のみを表示（解説なし）
- 子季語の場合: 親季語の名称を併せて表示（親季語の解説は不要）
- 崩し表現の場合: canonical_word に正式な季語を格納し表示（例: 冬月→冬の月）
- AI へのプロンプトは季語の解説のみに限定し、句の内容には触れさせない

---

## Attendance_A との設計対応

| Attendance_A | 俳句アプリ | パターン |
|---|---|---|
| AttendanceChangeRequest → 上長承認 | submitted_to_admin → 管理者評価で公開 | 承認ワークフロー |
| OvertimeRequest / ApprovalRequest | Review（評価・添削統合） | 申請・レビュー |
| admin / superior ロール | admin ロール | 権限管理 |
| 月次勤怠一覧 | マイページの句一覧・季節別一覧 | 一覧表示 |
| CSV エクスポート | 句集エクスポート | データ出力 |

---

## 主要機能（予定）

### 認証・ユーザー
- [x] ユーザー登録・ログイン・ログアウト
- [x] Remember me（ログイン記憶）
- [x] プロフィール編集
- [x] 管理者によるユーザー管理

### 俳句
- [x] 俳句の投稿（下書き/一般公開/管理者投稿）
- [x] お題の設定（任意）
- [x] 俳句の編集・削除
- [x] 俳句一覧（ページネーション）
- [x] お題別フィルタリング
- [x] マイページ（自分の俳句一覧）
- [x] 管理者投稿：管理者が評価するまで非公開、評価後に自動公開
- [x] 管理者向け：評価待ち件数のバッジ表示（Bootstrap badge、評価待ちページへのリンクに付与）

### 評価・添削（Review）
- [x] 星評価（1〜5）+ 寸評の投稿
- [x] 添削案・添削理由の投稿（任意）
- [x] 添削案は元の句と並べて比較表示
- [x] 自分の句には評価不可
- [x] 投稿者名のブラインド表示（***）、評価者がボタンで確認可能
- [x] 評価の編集・削除
- [x] 平均スコアの表示

### 季語解説（KigoExplanation + Gemini API）
- [x] 俳句詳細ページに「季語解説」ボタンを配置（押すまで API 未呼出）
- [x] ボタン押下時に API 取得 → DB キャッシュ → 表示（Turbo で差し替え）
- [x] 無季の場合は「無季」の旨のみ表示
- [x] 子季語の場合は親季語の名称を併せて表示（親の解説は不要）
- [x] 崩し表現の場合は正式な季語を表示（例: 冬月→冬の月）
- [x] AI プロンプトは季語の解説のみ（句の内容には触れない）
- [x] 解説の DB キャッシュ（同一季語は再取得しない）

### その他
- [x] Stimulus で文字数リアルタイムカウント
- [x] CSV/テキスト形式での句集エクスポート

---

## 実装フェーズ

### Phase 1: 環境構築・認証基盤 ✅ 完了

Docker 起動 → DB 作成 → User モデル → 認証。全機能の土台。

- [x] Docker Compose でコンテナ起動確認
- [x] RSpec / FactoryBot の初期設定
- [x] User モデル（マイグレーション、バリデーション、has_secure_password）
- [x] セッション管理（ログイン/ログアウト/Remember me）
- [x] ヘッダー・フッター・レイアウト（Bootstrap）
- [x] ユーザー登録・プロフィール編集
- [x] 管理者によるユーザー管理
- [x] Faker による seed データ

### Phase 2: 俳句の投稿・管理 ✅ 完了

アプリの主機能。CRUD + ステータス管理。

- [x] Haiku モデル（マイグレーション、バリデーション 5〜30文字、enum）
- [x] 俳句の投稿フォーム（body, kigo, theme, description, status 選択）
- [x] Stimulus で文字数リアルタイムカウント（5〜30文字）
- [x] 俳句の編集・削除（自分の句のみ）
- [x] 俳句一覧ページ（published のみ表示、ページネーション）
- [x] お題別フィルタリング
- [x] マイページ（自分の俳句一覧、下書き含む）

### Phase 3: 管理者投稿フロー ✅ 完了

submitted_to_admin ステータスの一連の流れ。

- [x] 投稿フォームに「管理者へ投稿」の選択肢追加
- [x] 管理者向け：評価待ち句一覧ページ
- [x] 評価待ち件数のバッジ表示（Bootstrap badge、ヘッダーリンクに付与）
- [x] 管理者が評価すると自動で published に変更（Phase 4 の Review と連動）

### Phase 4: 評価・添削 ✅ 完了

Review モデル。ブラインドレビュー + 添削案。

- [x] Review モデル（マイグレーション、バリデーション、ユニーク制約）
- [x] 評価フォーム（score, comment, correction_body, correction_reason）
- [x] 自分の句には評価不可の制御
- [x] 投稿者名のブラインド表示（***）、ボタンで確認（Stimulus）
- [x] 添削案と元の句の比較表示
- [x] 評価の編集・削除
- [x] 平均スコアの表示
- [x] 管理者の評価で submitted_to_admin → published への自動遷移（Phase 3 完成）

### Phase 5: 季語解説（Gemini API 連携） ✅ 完了

外部 API 連携。独立性が高いため後半に配置。

- [x] KigoExplanation モデル（マイグレーション、ユニークインデックス）
- [x] Gemini API サービスクラス（faraday、プロンプト設計）
- [x] 俳句詳細ページに「季語解説」ボタン配置
- [x] ボタン押下 → API 取得 → DB キャッシュ → Turbo Frame で表示差し替え
- [x] 無季の判定と表示
- [x] 子季語の親季語表示
- [x] 崩し表現の正式季語表示
- [x] API エラー時のハンドリング（タイムアウト、レート制限）

### Phase 6: 仕上げ ✅ 完了

- [x] CSV/テキスト形式での句集エクスポート
- [x] seed データの整備（デモ用ユーザー・俳句・評価・季語解説キャッシュ）
- [x] 全体の動作確認・バグ修正

### Phase 7: デプロイ

- [ ] Render.com へのデプロイ（PostgreSQL、環境変数設定）

---

## Phase 1 完了時の状態（2026-06-20）

- RSpec: 26 examples, 0 failures
- RuboCop: 20 files, 0 offenses
- Seed: 管理者1名 + 一般ユーザー1名 + Faker 60名
- Docker: MySQL 5.7 (port 3401) + Web (port 3109)
- テストアカウント: admin@example.com / test@example.com（パスワード: password）

## Phase 2 完了時の状態（2026-06-21）

- RSpec: 47 examples, 0 failures
- RuboCop: 0 offenses
- Seed: 俳句8句（公開）+ 下書き1句を追加
- 設計変更: season カラム削除（季節タブ不要、季語のフリー入力のみ）、フィルタはお題のみ
- i18n: default_locale を :ja に設定、全 UI を日本語化
- Stimulus: 文字数リアルタイムカウント（char-count コントローラ）

## Phase 3 完了時の状態（2026-06-22）

- RSpec: 55 examples, 0 failures
- RuboCop: 0 offenses
- Seed: 管理者投稿2句を追加（計 俳句11句）
- 追加機能: 投稿フォームに「管理者へ投稿」、評価待ち一覧（管理者のみ）、バッジ表示
- アクセス制御: 非公開句の show は本人または管理者のみ閲覧可

## Phase 4 完了時の状態（2026-06-22）

- RSpec: 75 examples, 0 failures
- RuboCop: 0 offenses
- Seed: 評価13件（うち添削1件）を追加
- Review モデル: score(1-5), comment, correction_body, correction_reason
- ユニーク制約: user_id + haiku_id（1ユーザー1句1評価）
- 自分の句評価不可バリデーション、管理者評価で自動公開コールバック
- ブラインドレビュー: blind-author Stimulus コントローラで投稿者名を***表示
- 添削案: 元の句との比較表示

## Phase 5 完了時の状態（2026-06-22）

- RSpec: 88 examples, 0 failures
- RuboCop: 0 offenses
- KigoExplanation モデル: kigo_word（ユニーク）, canonical_word, parent_kigo, season, explanation
- GeminiApiService: faraday で Gemini API（gemini-2.0-flash-lite）を呼び出し、DB キャッシュ
- Turbo Frame: 季語解説ボタン押下で API 取得 → 表示差し替え（ページ遷移なし）
- webmock gem を追加（テスト用 HTTP スタブ）
- 技術スタック更新: Gemini API は引き続き利用可能（CLI 終了は無関係）

## Phase 6 完了時の状態（2026-06-22）

- RSpec: 92 examples, 0 failures
- RuboCop: 0 offenses（自作ファイルのみ）
- CSV/テキストエクスポート: マイ俳句ページからダウンロード
- Seed: テストユーザー公開句・お題付き俳句・季語解説キャッシュ3件を追加
- デモ用データ: ユーザー62名、俳句12句、評価13件、季語解説3件

## 未決定事項（後日調整）

- 画面設計・ワイヤーフレーム
