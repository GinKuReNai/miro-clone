
## API設計
### Auth

| Method | Endpoint        | Description  |
| ------ | --------------- | ------------ |
| POST   | `/api/register` | ユーザー登録       |
| POST   | `/api/login`    | ログイン         |
| POST   | `/api/logout`   | ログアウト        |
| POST   | `/api/password` | パスワード変更      |
| GET    | `/api/me`       | 自分のユーザー情報を取得 |

### User
|Method|Endpoint|Description|
|---|---|---|
|GET|`/api/users/:id`|ユーザー情報を取得|#

### Board
| Method | Endpoint          | Description  |     |
| ------ | ----------------- | ------------ | --- |
| GET    | `/api/boards`     | 自分のボード一覧を取得  |     |
| POST   | `/api/boards`     | ボード作成        |     |
| GET    | `/api/boards/:id` | ボード詳細を取得     |     |
| PATCH  | `/api/boards/:id` | ボードタイトルなどの編集 |     |
| DELETE | `/api/boards/:id` | ボード削除        |     |

### Canvas
| Method | Endpoint                                   | Description            |
| ------ | ------------------------------------------ | ---------------------- |
| GET    | `/api/boards/:board_id/objects`            | ボード上のオブジェクト一覧取得        |
| POST   | `/api/boards/:board_id/objects`            | 新しいオブジェクト（カード、図形など）を追加 |
| PATCH  | `/api/boards/:board_id/objects/:object_id` | オブジェクトの位置・内容を編集        |
| DELETE | `/api/boards/:board_id/objects/:object_id` | オブジェクト削除               |

#### Data Structure
```json
{
  "id": "card-123",
  "type": "card",                // 図形などが増えればtypeも使える
  "position": { "x": 100, "y": 200 }, // 座標をフロントエンド側から送信する
  "size": { "width": 200, "height": 100 },
  "content": "Let's brainstorm!",
  "created_by": "user-456",
  "board_id": "board-001"
}
```

### Cursor(Web Socket)

| Method | Endpoint                        | Description          |
| ------ | ------------------------------- | -------------------- |
| GET    | `/api/boards/:board_id/cursors` | ボード上の他ユーザーのカーソル位置を取得 |
| POST   | `/api/boards/:board_id/cursors` | 自分のカーソル位置を送信         |
|        |                                 |                      |
#### Channel
- `cursor:move` – カーソル移動をブロードキャスト
- `object:update` – オブジェクトの位置や内容の更新
- `object:create` – オブジェクトの新規作成
- `object:delete` – オブジェクトの削除
- `selection:change` – 範囲選択の変更

#### Usage
1. 自分のマウスが動いた時に、定期的に座標情報をWebSocketで送信する
	- `socket.emit('cursor:move', {x, y, userId })` 
2. 他ユーザーの座標をWebSocketで受信する
	- `socket.on('cursor:move', data => updateOtherCursor(data))`



## DB設計
```sql
-- ユーザー
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    password_hash CHAR(64) NOT NULL, -- SHA256ハッシュ
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);

-- セッション（論理削除しない）
CREATE TABLE sessions (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL,
    expired_at TIMESTAMP NOT NULL
);

-- ボード
CREATE TABLE boards (
    id UUID PRIMARY KEY,
    owner_id UUID NOT NULL REFERENCES users(id),
    title VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);

-- ボード参加者の役割マスター
CREATE TABLE roles (
    id INTEGER PRIMARY KEY, -- 例: 1=owner, 2=editor
    name TEXT NOT NULL UNIQUE
);

-- ボード参加者
CREATE TABLE board_members (
    id UUID PRIMARY KEY,
    board_id UUID NOT NULL REFERENCES boards(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id INTEGER NOT NULL REFERENCES roles(id),
    joined_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP,
    UNIQUE (board_id, user_id)
);

-- カードタイプマスター
CREATE TABLE card_types (
    id INTEGER PRIMARY KEY, -- 例: 1=text, 2=image, 3=shape
    name TEXT NOT NULL UNIQUE
);

-- カラー定義マスター
CREATE TABLE colors (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE, -- 例: "red", "light-red", "dark-red", etc
    hex_code CHAR(7) NOT NULL -- 例: "#FF0000"
);

-- スタイル（色など）
CREATE TABLE styles (
    id UUID PRIMARY KEY,
    fill_color_id INTEGER REFERENCES colors(id),
    border_color_id INTEGER REFERENCES colors(id),
    border_width FLOAT,
    deleted_at TIMESTAMP
);

-- カード
CREATE TABLE cards (
    id UUID PRIMARY KEY,
    board_id UUID NOT NULL REFERENCES boards(id) ON DELETE CASCADE,
    type_id INTEGER NOT NULL REFERENCES card_types(id),
    style_id UUID REFERENCES styles(id),
    content JSONB NOT NULL,
    position_x FLOAT NOT NULL,
    position_y FLOAT NOT NULL,
    width FLOAT,
    height FLOAT,
    z_index INTEGER NOT NULL DEFAULT 0,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP
);
```

```sql
INSERT INTO roles (id, name) VALUES (1, 'owner'), (2, 'editor');

INSERT INTO card_types (id, name) VALUES
  (1, 'text'),
  (2, 'image'),
  (3, 'shape');

INSERT INTO colors (id, name, hex_code) VALUES
  (1, 'red', '#FF0000'),
  (2, 'light-red', '#FF6666'),
  (3, 'dark-red', '#990000'),
  (4, 'orange', '#FFA500'),
  (5, 'yellow', '#FFFF00'),
  (6, 'green', '#00FF00'),
  (7, 'blue', '#0000FF'),
  (8, 'indigo', '#4B0082'),
  (9, 'purple', '#800080'),
  (10, 'white', '#FFFFFF'),
  (11, 'black', '#000000'),
  (12, 'light-blue', '#ADD8E6'),
  (13, 'dark-blue', '#00008B');
```

