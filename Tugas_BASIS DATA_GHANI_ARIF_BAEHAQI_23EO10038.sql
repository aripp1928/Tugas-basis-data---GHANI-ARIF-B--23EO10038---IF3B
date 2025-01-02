-- Create table barang
CREATE TABLE barang (
    kode INT,
    nama VARCHAR(100),
    harga INT,
    jumlah INT
);

-- Add column to table barang
ALTER TABLE barang
ADD COLUMN keterangan TEXT;

-- Drop column from table barang
ALTER TABLE barang 
DROP COLUMN keterangan;

-- Rename column in table barang
ALTER TABLE barang 
RENAME COLUMN nama TO nama_barang;

-- Create table barang with NOT NULL and DEFAULT
CREATE TABLE barang (
    kode INT NOT NULL,
    nama_barang VARCHAR(100) NOT NULL,
    harga INT NOT NULL DEFAULT 1000,
    jumlah INT NOT NULL DEFAULT 0,
    waktu_dibuat TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Truncate table barang
TRUNCATE TABLE barang;

-- Drop table barang
DROP TABLE barang;

-- Create table products
CREATE TABLE products (
    id VARCHAR(10) NOT NULL,
    nama VARCHAR(100) NOT NULL,
    keterangan TEXT,
    harga INT NOT NULL,
    jumlah INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- Insert data into table products
INSERT INTO products (id, nama, harga, jumlah)
VALUES 
    ('P0001', 'Ayam Geprek Sambal Matah', 20000, 100),
    ('P0002', 'Ayam Geprek Original', 25000, 100),
    ('P0003', 'Ayam Bakar Bumbu Seafood', 35000, 100),
    ('P0004', 'Ayam Goreng Upin-Ipin', 30000, 100),
    ('P0005', 'Ayam Bakar Bumbu Seadanya', 35000, 100);

-- Select all data from table products
SELECT * FROM products;

-- Add primary key constraint to table products
ALTER TABLE products
ADD PRIMARY KEY (id);

-- Add enum type PRODUCT_CATEGORY
CREATE TYPE PRODUCT_CATEGORY AS ENUM ('Makanan', 'Minuman', 'Lain-lain');

-- Add category column to table products
ALTER TABLE products
ADD COLUMN category PRODUCT_CATEGORY;

-- Update category values in table products
UPDATE products
SET category = 'Makanan'
WHERE id IN ('P0001', 'P0002', 'P0003', 'P0004', 'P0005');

-- Add new products
INSERT INTO products (id, nama, harga, jumlah, category)
VALUES 
    ('P0006', 'Air Tawar', 2000, 100, 'Minuman'),
    ('P0007', 'Es Tawar', 5000, 100, 'Minuman'),
    ('P0008', 'Es Teller', 20000, 100, 'Minuman'),
    ('P0009', 'Es Janda Muda', 25000, 100, 'Minuman');

-- Add foreign key relationship between tables
CREATE TABLE wishlist (
    id SERIAL NOT NULL,
    id_produk VARCHAR(10) NOT NULL,
    keterangan TEXT,
    PRIMARY KEY (id),
    CONSTRAINT fk_wishlist_produk FOREIGN KEY (id_produk) REFERENCES products (id)
);

-- Insert data into wishlist
INSERT INTO wishlist (id_produk, keterangan)
VALUES 
    ('P0001', 'Ayam Bakar Kalasan'),
    ('P0002', 'Ayam Bakar Banyumas'),
    ('P0003', 'Ayam Bakar Pesawat Terbang');

-- Join wishlist and products
SELECT p.id, p.nama, w.keterangan
FROM wishlist w
JOIN products p ON w.id_produk = p.id;

-- Create table categories and add relationship to products
CREATE TABLE categories (
    id VARCHAR(10) NOT NULL,
    nama VARCHAR(100) NOT NULL,
    PRIMARY KEY (id)
);

INSERT INTO categories (id, nama)
VALUES 
    ('C0001', 'Makanan'),
    ('C0002', 'Minuman');

ALTER TABLE products
ADD COLUMN id_category VARCHAR(10);

ALTER TABLE products
ADD CONSTRAINT fk_product_category FOREIGN KEY (id_category) REFERENCES categories (id);

UPDATE products
SET id_category = CASE 
    WHEN category = 'Makanan' THEN 'C0001'
    WHEN category = 'Minuman' THEN 'C0002'
END;

ALTER TABLE products
DROP COLUMN category;

-- Advanced SQL commands
-- JSONB handling, transactions, indexing, and schema management
-- Example: Create table with JSONB
CREATE TABLE produk_laptop (
    id SERIAL PRIMARY KEY,
    nama TEXT NOT NULL,
    details JSONB
);

-- Insert JSON data into produk_laptop
INSERT INTO produk_laptop (nama, details)
VALUES (
    'Laptop',
    '{
        "brand": "Leknopo",
        "model": "Thinkmat",
        "harga": "Rp 50.000.000",
        "specs": {
            "cpu": "Core i9",
            "ram": "32GB",
            "storage": "1TB SSD NVME",
            "vga": "Nvidia GTX 3080"
        }
    }'
);

-- Query JSONB data
SELECT nama, details->>'brand' AS brand
FROM produk_laptop;

-- Update nested JSONB data
UPDATE produk_laptop
SET details = jsonb_set(details, '{specs, storage}', '"2TB SSD NVME"')
WHERE nama = 'Laptop';

-- Delete nested field from JSONB
UPDATE produk_laptop
SET details = details #- '{specs, cpu}'
WHERE nama = 'Laptop';

-- Create index on JSONB field
CREATE INDEX idx_produk_details_tags ON produk_laptop USING GIN (details->'tags');

-- Join examples with multiple tables
-- One-to-many relationship example
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    total INT NOT NULL,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders_detail (
    id_product VARCHAR(10) NOT NULL,
    id_order INT NOT NULL,
    harga INT NOT NULL,
    jumlah INT NOT NULL,
    PRIMARY KEY (id_product, id_order),
    CONSTRAINT fk_orders_detail_product FOREIGN KEY (id_product) REFERENCES products(id),
    CONSTRAINT fk_orders_detail_order FOREIGN KEY (id_order) REFERENCES orders(id)
);

-- Insert example data into orders and orders_detail
INSERT INTO orders (total) VALUES (150000), (200000);

INSERT INTO orders_detail (id_product, id_order, harga, jumlah)
VALUES 
    ('P0001', 1, 20000, 2),
    ('P0002', 1, 30000, 2),
    ('P0003', 2, 50000, 2);

-- View joined data
SELECT o.id AS order_id, o.total, p.nama AS product_name, od.harga, od.jumlah
FROM orders o
JOIN orders_detail od ON o.id = od.id_order
JOIN products p ON od.id_product = p.id;

-- Create table peserta
CREATE TABLE peserta (
    id VARCHAR(36) PRIMARY KEY,
    nama VARCHAR(255) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
    nomor_handphone VARCHAR(50) NOT NULL
);

-- Create table pengajar
CREATE TABLE pengajar (
    id VARCHAR(36) PRIMARY KEY,
    nama VARCHAR(255) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
    nomor_handphone VARCHAR(50) NOT NULL
);

-- Create table kurikulum
CREATE TABLE kurikulum (
    id VARCHAR(36) PRIMARY KEY,
    kode VARCHAR(100) UNIQUE,
    nama VARCHAR(200),
    aktif BOOLEAN
);

-- Create table kelas
CREATE TABLE kelas (
    id VARCHAR(36) PRIMARY KEY,
    id_pengajar VARCHAR(36) NOT NULL,
    nama VARCHAR(100) NOT NULL UNIQUE,
    hari VARCHAR(10) NOT NULL,
    waktu_mulai TIME NOT NULL,
    waktu_selesai TIME NOT NULL,
    CONSTRAINT fk_kelas_pengajar FOREIGN KEY (id_pengajar) REFERENCES pengajar(id)
);

-- Create table peserta_kelas
CREATE TABLE peserta_kelas (
    id_peserta VARCHAR(36),
    id_kelas VARCHAR(36),
    PRIMARY KEY (id_peserta, id_kelas),
    CONSTRAINT fk_peserta_kelas_peserta FOREIGN KEY (id_peserta) REFERENCES peserta(id),
    CONSTRAINT fk_peserta_kelas_kelas FOREIGN KEY (id_kelas) REFERENCES kelas(id)
);
