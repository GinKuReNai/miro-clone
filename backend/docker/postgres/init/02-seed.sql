-- マスターデータ
INSERT INTO roles (id, name) VALUES
  (1, 'owner'),
  (2, 'editor');

INSERT INTO card_types (id, name) VALUES
  (1, 'text'),
  (2, 'image'),
  (3, 'shape');

INSERT INTO colors (id, name, hex_code) VALUE
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
