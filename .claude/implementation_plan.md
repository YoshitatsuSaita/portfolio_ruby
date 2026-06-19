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
| upper_phrase | string | 上五（必須） |
| middle_phrase | string | 中七（必須） |
| lower_phrase | string | 下五（必須） |
| kigo | string | 季語（必須） |
| season | integer | enum: spring/summer/autumn/winter/new_year |
| description | text | 作者メモ（任意） |
| status | integer | enum: draft/published（デフォルト draft） |

### Review（評価・寸評）

| カラム | 型 | 備考 |
|---|---|---|
| user_id | references | FK → User |
| haiku_id | references | FK → Haiku |
| score | integer | 1〜5（必須） |
| comment | text | 寸評（任意） |

- 1ユーザーにつき1句1評価（user_id + haiku_id のユニーク制約）
- 自分の俳句には評価できない

### Correction（添削案）

| カラム | 型 | 備考 |
|---|---|---|
| user_id | references | FK → User（添削者） |
| haiku_id | references | FK → Haiku |
| upper_phrase | string | 修正後の上五 |
| middle_phrase | string | 修正後の中七 |
| lower_phrase | string | 修正後の下五 |
| reason | text | 添削理由（必須） |
| status | integer | enum: pending/accepted/rejected（デフォルト pending） |

- 投稿者本人が採用/不採用を決定（Attendance_A の承認フローと同じパターン）

### Favorite（お気に入り）

| カラム | 型 | 備考 |
|---|---|---|
| user_id | references | FK → User |
| haiku_id | references | FK → Haiku |

- user_id + haiku_id の複合ユニーク制約

### KigoExplanation（季語AI解説キャッシュ）

| カラム | 型 | 備考 |
|---|---|---|
| kigo_word | string | 季語（一意インデックス） |
| season | string | 季節 |
| explanation | text | Gemini API で生成した解説文 |

- 同じ季語は再問い合わせしない（DBキャッシュ）
- 俳句投稿時に KigoExplanation を検索 → 未登録なら API で取得して保存
- API 障害時でも俳句の投稿自体はブロックしない（Active Job で非同期取得）

---

## Attendance_A との設計対応

| Attendance_A | 俳句アプリ | パターン |
|---|---|---|
| AttendanceChangeRequest → 上長承認 | Correction → 投稿者が採用/不採用 | 承認ワークフロー |
| AttendanceCorrectionLog | Correction の status で履歴保持 | 変更履歴 |
| OvertimeRequest / ApprovalRequest | Review（評価） | 申請・レビュー |
| admin / superior ロール | admin ロール | 権限管理 |
| 月次勤怠一覧 | マイページの句一覧・季節別一覧 | 一覧表示 |
| CSV エクスポート | 句集エクスポート | データ出力 |

---

## 主要機能（予定）

### 認証・ユーザー
- [ ] ユーザー登録・ログイン・ログアウト
- [ ] Remember me（ログイン記憶）
- [ ] プロフィール編集
- [ ] 管理者によるユーザー管理

### 俳句
- [ ] 俳句の投稿（下書き/公開）
- [ ] 俳句の編集・削除
- [ ] 俳句一覧（ページネーション）
- [ ] 季節別フィルタリング
- [ ] マイページ（自分の俳句一覧）

### 評価（Review）
- [ ] 星評価（1〜5）+ 寸評の投稿
- [ ] 自分の句には評価不可
- [ ] 評価の編集・削除
- [ ] 平均スコアの表示

### 添削（Correction）
- [ ] 添削案の投稿（修正句 + 理由）
- [ ] 投稿者による採用/不採用の決定
- [ ] 添削履歴の表示

### お気に入り（Favorite）
- [ ] お気に入り登録/解除（Turbo でリアルタイム切替）
- [ ] お気に入り一覧ページ

### 季語解説（KigoExplanation + Gemini API）
- [ ] 俳句投稿時に季語解説を自動取得（非同期）
- [ ] 俳句詳細ページに季語解説を表示
- [ ] 解説のDBキャッシュ（同一季語は再取得しない）

### その他
- [ ] ランキング（月間人気句など）
- [ ] Stimulus で五七五の文字数リアルタイムチェック
- [ ] CSV/テキスト形式での句集エクスポート

---

## 未決定事項（後日調整）

- モデルの詳細なバリデーションルール
- ルーティング設計（RESTful リソース構成）
- 画面設計・ワイヤーフレーム
- 実装フェーズの分割と優先順位
- ランキングのロジック（スコア平均？お気に入り数？）
- 季語の入力方式（自由入力 or 選択式）
