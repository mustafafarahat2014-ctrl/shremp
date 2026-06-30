-- ➡️ انسخ الكود ده كله وحطه في Supabase
-- ➡️ روح على SQL Editor في Supabase واعمله Paste واضغط Run
-- ➡️ وخلاص! مفيش حاجة تانية

CREATE TABLE IF NOT EXISTS orders (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
  order_number INTEGER NOT NULL,
  customer_name TEXT NOT NULL,
  phone TEXT NOT NULL,
  address TEXT NOT NULL,
  payment_method TEXT NOT NULL,
  items TEXT NOT NULL,
  total REAL NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW
);

-- عشان الأرقام تزيد تلقائياً
CREATE SEQUENCE IF NOT EXISTS order_seq START 1;
CREATE TRIGGER IF NOT EXISTS set_order_number
  BEFORE INSERT ON orders
  BEGIN
    SELECT COALESCE(
      (SELECT MAX(order_number) FROM orders), 0
    ) + 1 INTO NEW.order_number;
  END;

-- عشان الـ Realtime تشتغل
ALTER PUBLICATION supabase_realtime ADD TABLE orders;

-- صلاحيات: أي حد يقدر يقرأ ويكتب (للمواقع الثابتة)
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read" ON orders FOR SELECT USING (true);
CREATE POLICY "Public insert" ON orders FOR INSERT WITH CHECK (true);
CREATE POLICY "Public update" ON orders FOR UPDATE USING (true);
CREATE POLICY "Public delete" ON orders FOR DELETE USING (true);