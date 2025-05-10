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
