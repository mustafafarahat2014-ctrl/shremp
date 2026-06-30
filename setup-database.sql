CREATE TABLE IF NOT EXISTS orders (
  id TEXT PRIMARY KEY DEFAULT (gen_random_uuid()::text),
  order_number INTEGER NOT NULL,
  customer_name TEXT NOT NULL,
  phone TEXT NOT NULL,
  address TEXT NOT NULL,
  payment_method TEXT NOT NULL,
  items TEXT NOT NULL,
  total REAL NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION set_order_number_fn()
RETURNS TRIGGER AS $$
BEGIN
  NEW.order_number := COALESCE((SELECT MAX(order_number) FROM orders), 0) + 1;
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_order_number ON orders;
CREATE TRIGGER set_order_number
  BEFORE INSERT ON orders
  FOR EACH ROW
  EXECUTE FUNCTION set_order_number_fn();

DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE orders;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read" ON orders;
DROP POLICY IF EXISTS "Public insert" ON orders;
DROP POLICY IF EXISTS "Public update" ON orders;
DROP POLICY IF EXISTS "Public delete" ON orders;

CREATE POLICY "Public read" ON orders FOR SELECT USING (true);
CREATE POLICY "Public insert" ON orders FOR INSERT WITH CHECK (true);
CREATE POLICY "Public update" ON orders FOR UPDATE USING (true);
CREATE POLICY "Public delete" ON orders FOR DELETE USING (true);