-- Migration: add_consent_checkboxes_and_contact
-- Agrega checkboxes personalizados por investigación y datos de contacto del participante.

-- Tabla de checkboxes de consentimiento definidos por el investigador
CREATE TABLE IF NOT EXISTS investigation_consent_checkboxes (
  id            SERIAL PRIMARY KEY,
  investigation_id INTEGER NOT NULL REFERENCES investigations(id) ON DELETE CASCADE,
  label         TEXT NOT NULL,
  sort_order    INTEGER NOT NULL DEFAULT 0,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_consent_checkboxes_investigation
  ON investigation_consent_checkboxes(investigation_id);

-- Datos de contacto del participante por investigación
ALTER TABLE investigation_participants
  ADD COLUMN IF NOT EXISTS email  TEXT,
  ADD COLUMN IF NOT EXISTS phone1 TEXT,
  ADD COLUMN IF NOT EXISTS phone2 TEXT;
