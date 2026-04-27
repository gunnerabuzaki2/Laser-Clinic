-- =============================================================================
--  Supabase Migration Script
--  Run this in the Supabase SQL Editor (Dashboard → SQL Editor → New Query)
-- =============================================================================

-- 1. Create the doctors table (managed via Supabase dashboard only)
CREATE TABLE IF NOT EXISTS doctors (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name       TEXT NOT NULL,
  education  TEXT NOT NULL DEFAULT '',
  join_date  DATE NOT NULL DEFAULT CURRENT_DATE,
  age        INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable Row Level Security (allow authenticated users to read)
ALTER TABLE doctors ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read doctors"
  ON doctors FOR SELECT
  TO authenticated
  USING (true);

-- 2. Add doctor_id and pulses columns to existing sessions table
ALTER TABLE sessions
  ADD COLUMN IF NOT EXISTS doctor_id UUID REFERENCES doctors(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS pulses    INTEGER DEFAULT 0;

-- 3. (Optional) Create an index on sessions.doctor_id for faster report queries
CREATE INDEX IF NOT EXISTS idx_sessions_doctor_id ON sessions(doctor_id);
