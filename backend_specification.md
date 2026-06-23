# Dokumen Spesifikasi Backend & Database — Warteg App

Dokumen ini mendefinisikan cetak biru teknis (technical blueprint) untuk implementasi backend aplikasi Warteg, baik diimplementasikan menggunakan arsitektur **Supabase (Serverless + PostgreSQL)** maupun **Node.js (Express/NestJS + Prisma)**.

---

## 1. Skema Database Relasional (SQL DDL Migrations)

Eksekusi perintah SQL berikut pada PostgreSQL / Supabase SQL Editor untuk membuat seluruh tabel beserta relasinya.

```sql
-- Aktifkan Ekstensi UUID & Kriptografi jika belum tersedia
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =========================================================================
-- 1. TABEL: users
-- =========================================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- =========================================================================
-- 2. TABEL: products
-- =========================================================================
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    category VARCHAR(30) NOT NULL CHECK (category IN ('nasi', 'lauk', 'sayur', 'minuman', 'snack')),
    is_available BOOLEAN NOT NULL DEFAULT true,
    image_url VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- =========================================================================
-- 3. TABEL: addresses
-- =========================================================================
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    label VARCHAR(50) NOT NULL, -- cth: 'Rumah', 'Kantor'
    receiver_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    full_address TEXT NOT NULL,
    note TEXT,
    is_selected BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- =========================================================================
-- 4. TABEL: drivers
-- =========================================================================
CREATE TABLE drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    vehicle_number VARCHAR(20) NOT NULL,
    photo_url VARCHAR(255),
    rating NUMERIC(2, 1) NOT NULL DEFAULT 5.0 CHECK (rating BETWEEN 0.0 AND 5.0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- =========================================================================
-- 5. TABEL: promos
-- =========================================================================
CREATE TABLE promos (
    code VARCHAR(30) PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    discount_percent INTEGER NOT NULL CHECK (discount_percent BETWEEN 1 AND 100),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- =========================================================================
-- 6. TABEL: orders
-- =========================================================================
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    address_id UUID REFERENCES addresses(id) ON DELETE SET NULL,
    delivery_type VARCHAR(20) NOT NULL DEFAULT 'delivery' CHECK (delivery_type IN ('delivery', 'pickup')),
    payment_name VARCHAR(50) NOT NULL,
    payment_image VARCHAR(255),
    subtotal INTEGER NOT NULL CHECK (subtotal >= 0),
    ongkir INTEGER NOT NULL DEFAULT 0 CHECK (ongkir >= 0),
    discount INTEGER NOT NULL DEFAULT 0 CHECK (discount >= 0),
    total INTEGER NOT NULL CHECK (total >= 0),
    seller_note TEXT,
    status VARCHAR(30) NOT NULL DEFAULT 'belumBayar' 
        CHECK (status IN ('belumBayar', 'tungguKonfirmasi', 'diproses', 'diantar', 'siapDiambil', 'selesai', 'dibatalkan')),
    va_number VARCHAR(50),
    expired_at TIMESTAMP WITH TIME ZONE NOT NULL,
    cancel_expired_at TIMESTAMP WITH TIME ZONE,
    accepted_by_admin BOOLEAN NOT NULL DEFAULT false,
    driver_id UUID REFERENCES drivers(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- =========================================================================
-- 7. TABEL: order_items
-- =========================================================================
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    price INTEGER NOT NULL CHECK (price >= 0),
    add_ons JSONB NOT NULL DEFAULT '[]'::jsonb
);

-- =========================================================================
-- 8. TABEL: chats
-- =========================================================================
CREATE TABLE chats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    sender_role VARCHAR(20) NOT NULL CHECK (sender_role IN ('user', 'admin')),
    text TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT false,
    is_system BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- =========================================================================
-- 9. TABEL: notifications
-- =========================================================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);
```

---

## 2. Supabase Row Level Security (RLS) Policies

Jika menggunakan Supabase, wajib mengaktifkan RLS untuk mencegah eksploitasi data antar user.

### A. Tabel `users`
*   **Aktifkan RLS**: `ALTER TABLE users ENABLE ROW LEVEL SECURITY;`
*   **Polisi**:
    ```sql
    -- Pengguna hanya boleh melihat data profil mereka sendiri
    CREATE POLICY "Users can read own profile" ON users
        FOR SELECT TO authenticated
        USING (auth.uid() = id);

    -- Pengguna dapat mengubah nama/password profil mereka sendiri
    CREATE POLICY "Users can update own profile" ON users
        FOR UPDATE TO authenticated
        USING (auth.uid() = id);
    ```

### B. Tabel `products`
*   **Aktifkan RLS**: `ALTER TABLE products ENABLE ROW LEVEL SECURITY;`
*   **Polisi**:
    ```sql
    -- Siapapun (termasuk pembeli anonim/belum login) boleh melihat daftar menu
    CREATE POLICY "Anyone can read products" ON products
        FOR SELECT TO anon, authenticated
        USING (true);

    -- Hanya admin yang boleh menambah, mengubah, atau menghapus produk
    CREATE POLICY "Only admin can write products" ON products
        FOR ALL TO authenticated
        USING (
            EXISTS (
                SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role = 'admin'
            )
        );
    ```

### C. Tabel `addresses`
*   **Aktifkan RLS**: `ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;`
*   **Polisi**:
    ```sql
    -- Pengguna hanya boleh CRUD alamat milik mereka sendiri
    CREATE POLICY "Users can CRUD own addresses" ON addresses
        FOR ALL TO authenticated
        USING (auth.uid() = user_id);
    ```

### D. Tabel `orders` & `order_items`
*   **Aktifkan RLS**: `ALTER TABLE orders ENABLE ROW LEVEL SECURITY;`
*   **Polisi**:
    ```sql
    -- Pengguna boleh melihat data transaksi miliknya sendiri
    CREATE POLICY "Users can read own orders" ON orders
        FOR SELECT TO authenticated
        USING (auth.uid() = user_id);

    -- Pengguna boleh menaruh pesanan baru (checkout)
    CREATE POLICY "Users can insert own orders" ON orders
        FOR INSERT TO authenticated
        WITH CHECK (auth.uid() = user_id);

    -- Admin dapat melihat dan mengedit semua status pesanan
    CREATE POLICY "Admin can access all orders" ON orders
        FOR ALL TO authenticated
        USING (
            EXISTS (
                SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role = 'admin'
            )
        );
    ```

### E. Tabel `chats`
*   **Aktifkan RLS**: `ALTER TABLE chats ENABLE ROW LEVEL SECURITY;`
*   **Polisi**:
    ```sql
    -- User boleh membaca chat jika order tersebut miliknya
    CREATE POLICY "Users can read order chats" ON chats
        FOR SELECT TO authenticated
        USING (
            EXISTS (
                SELECT 1 FROM orders WHERE orders.id = order_id AND orders.user_id = auth.uid()
            ) OR EXISTS (
                SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role = 'admin'
            )
        );

    -- User boleh mengirim pesan chat
    CREATE POLICY "Users can post to chats" ON chats
        FOR INSERT TO authenticated
        WITH CHECK (
            auth.uid() = sender_id
        );
    ```

---

## 3. Database Triggers (Otomatisasi Server)

### A. Otomatisasi Reset Flag Alamat Utama
Ketika pengguna memilih alamat baru sebagai alamat utama (`is_selected = true`), sistem harus mengubah alamat lain milik pengguna tersebut menjadi `false`.

```sql
CREATE OR REPLACE FUNCTION reset_previous_default_address()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_selected = true THEN
        UPDATE addresses 
        SET is_selected = false 
        WHERE user_id = NEW.user_id AND id <> NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_reset_default_address
BEFORE INSERT OR UPDATE ON addresses
FOR EACH ROW
EXECUTE FUNCTION reset_previous_default_address();
```

### B. Memicu Notifikasi Otomatis pada Perubahan Status Pesanan
Setiap kali admin mengubah status pesanan (`status`), secara otomatis buat baris notifikasi baru di tabel `notifications` agar ditangkap oleh pembeli via real-time stream.

```sql
CREATE OR REPLACE FUNCTION create_order_notification()
RETURNS TRIGGER AS $$
DECLARE
    notif_title VARCHAR(150);
    notif_msg TEXT;
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        CASE NEW.status
            WHEN 'tungguKonfirmasi' THEN
                notif_title := 'Menunggu Konfirmasi ⏳';
                notif_msg := 'Restoran sedang memverifikasi pembayaran pesanan Anda.';
            WHEN 'diproses' THEN
                notif_title := 'Pesanan Diproses 🍳';
                notif_msg := 'Koki Warteg sedang menyiapkan pesanan lezat Anda.';
            WHEN 'diantar' THEN
                notif_title := 'Pesanan Sedang Diantar 🛵';
                notif_msg := 'Driver sedang meluncur membawa pesanan Anda.';
            WHEN 'siapDiambil' THEN
                notif_title := 'Siap Diambil 🥡';
                notif_msg := 'Pesanan Anda sudah siap. Silakan ambil di outlet Warteg.';
            WHEN 'selesai' THEN
                notif_title := 'Pesanan Selesai ✅';
                notif_msg := 'Terima kasih telah memesan di Warteg! Selamat menikmati makanan Anda.';
            WHEN 'dibatalkan' THEN
                notif_title := 'Pesanan Dibatalkan ❌';
                notif_msg := 'Pesanan Anda telah dibatalkan.';
            ELSE
                RETURN NEW;
        END CASE;

        INSERT INTO notifications (user_id, title, message, order_id)
        VALUES (NEW.user_id, notif_title, notif_msg, NEW.id);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_order_status_notification
AFTER UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION create_order_notification();
```

---

## 4. Logika Integrasi Webhook Gateway Pembayaran (Midtrans)

Untuk menangani konfirmasi pembayaran otomatis, endpoint API `/api/payments/callback` menerima callback HTTPS POST dari payment gateway.

### Logika Algoritma Webhook:
1.  **Validasi Tanda Tangan**: Verifikasi hash HMAC SHA512 dari Midtrans untuk menghindari transaksi palsu.
    $$\text{Signature Key} = \text{hash\_sha512}(\text{order\_id} + \text{status\_code} + \text{gross\_amount} + \text{ServerKey})$$
2.  **Pemrosesan Status**:
    *   Jika `transaction_status` = `settlement`, ubah status pesanan menjadi `diproses`.
    *   Jika `transaction_status` = `expire` / `cancel` / `deny`, ubah status pesanan menjadi `dibatalkan`.
3.  **Payload Request Webhook (JSON)**:
    ```json
    {
      "transaction_time": "2026-06-17 20:15:00",
      "transaction_status": "settlement",
      "status_message": "midtrans payment notification",
      "status_code": "200",
      "signature_key": "9a0d890cf2c125ae6a2bb53dfc54d2bb6d4d890cf2c...",
      "payment_type": "bank_transfer",
      "order_id": "order-9988-7766",
      "gross_amount": "18500.00"
    }
    ```
4.  **Response Webhook**: Kembalikan status HTTP `200 OK` ke server payment gateway sebagai tanda callback berhasil diterima.

---

## 5. Implementasi Pilihan Stack Backend

### Pilihan A: Supabase Serverless Setup
*   **Supabase Realtime**: Aktifkan fitur "Realtime" pada tabel `chats` dan `notifications` di Supabase Dashboard agar Flutter Client dapat melakukan stream pembaruan secara instan (`supabase.from('chats').stream(...)`).
*   **Edge Functions (TypeScript)**: Tulis file `index.ts` di direktori `./supabase/functions/payment-callback` untuk memproses Webhook Midtrans dan jalankan perintah `supabase deploy`.

### Pilihan B: Node.js + Prisma ORM Backend Setup
*   **Struktur Folder Proyek**:
    ```text
    ├── src/
    │   ├── controllers/    # Handler request API
    │   ├── middlewares/    # Auth (JWT) & Role Middleware
    │   ├── models/         # Definis data model
    │   ├── routes/         # Endpoint API router
    │   └── index.ts        # Entrypoint server (Express)
    ├── prisma/
    │   └── schema.prisma   # Skema relasi ORM
    └── package.json
    ```
*   **JWT Middleware Template (Node.js)**:
    ```typescript
    import { Request, Response, NextFunction } from 'express';
    import jwt from 'jsonwebtoken';

    export const authenticateToken = (req: Request, res: Response, next: NextFunction) => {
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(' ')[1];

        if (!token) return res.status(401).json({ error: 'Akses ditolak, token tidak disertakan' });

        jwt.verify(token, process.env.JWT_SECRET as string, (err, user) => {
            if (err) return res.status(403).json({ error: 'Token kedaluwarsa atau tidak valid' });
            req.user = user;
            next();
        });
    };

    export const requireRole = (role: 'user' | 'admin') => {
        return (req: Request, res: Response, next: NextFunction) => {
            if (req.user?.role !== role) {
                return res.status(403).json({ error: 'Anda tidak memiliki hak akses untuk fitur ini' });
            }
            next();
        };
    };
    ```
