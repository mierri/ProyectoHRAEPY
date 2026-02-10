-- SQL para crear las tablas en Supabase
-- Ejecuta este script en el SQL Editor de Supabase
-- IMPORTANTE: Este script es idempotente, puede ejecutarse múltiples veces

-- Tabla de pacientes
CREATE TABLE IF NOT EXISTS patients (
    patient_id BIGINT PRIMARY KEY,
    name TEXT NOT NULL,
    gender TEXT NOT NULL CHECK (gender IN ('Masculino', 'Femenino')),
    birth_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de encuestas
CREATE TABLE IF NOT EXISTS surveys (
    survey_id BIGINT PRIMARY KEY,
    patient_id BIGINT REFERENCES patients(patient_id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    synced BOOLEAN DEFAULT TRUE
);

-- Tabla de respuestas
CREATE TABLE IF NOT EXISTS responses (

    survey_id BIGINT PRIMARY KEY REFERENCES surveys(survey_id) ON DELETE CASCADE,
    question_id INTEGER NOT NULL,
    answer_value INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_surveys_survey_id ON surveys(survey_id);
CREATE INDEX IF NOT EXISTS idx_surveys_created_at ON surveys(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_surveys_patient_id ON surveys(patient_id);
CREATE INDEX IF NOT EXISTS idx_responses_survey_id ON responses(survey_id);

-- Habilitar Row Level Security (RLS)
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE surveys ENABLE ROW LEVEL SECURITY;
ALTER TABLE responses ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes si las hay
DROP POLICY IF EXISTS "Permitir insertar pacientes" ON patients;
DROP POLICY IF EXISTS "Permitir leer pacientes" ON patients;
DROP POLICY IF EXISTS "Permitir actualizar pacientes" ON patients;
DROP POLICY IF EXISTS "Permitir insertar encuestas" ON surveys;
DROP POLICY IF EXISTS "Permitir leer encuestas" ON surveys;
DROP POLICY IF EXISTS "Permitir insertar respuestas" ON responses;
DROP POLICY IF EXISTS "Permitir leer respuestas" ON responses;

-- Políticas para pacientes
CREATE POLICY "Permitir insertar pacientes" ON patients
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Permitir leer pacientes" ON patients
    FOR SELECT
    USING (true);

CREATE POLICY "Permitir actualizar pacientes" ON patients
    FOR UPDATE
    USING (true);

-- Políticas para encuestas
CREATE POLICY "Permitir insertar encuestas" ON surveys
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Permitir leer encuestas" ON surveys
    FOR SELECT
    USING (true);

-- Políticas para respuestas
CREATE POLICY "Permitir insertar respuestas" ON responses
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Permitir leer respuestas" ON responses
    FOR SELECT
    USING (true);

-- Comentarios para documentación
COMMENT ON TABLE patients IS 'Tabla de información de pacientes';
COMMENT ON TABLE surveys IS 'Tabla principal de encuestas BDI-2';
COMMENT ON TABLE responses IS 'Respuestas individuales de cada encuesta';
COMMENT ON COLUMN patients.patient_id IS 'ID único del paciente';
COMMENT ON COLUMN patients.birth_date IS 'Fecha de nacimiento del paciente';
COMMENT ON COLUMN surveys.survey_id IS 'ID único de la encuesta generado por la app';
COMMENT ON COLUMN surveys.patient_id IS 'ID del paciente asociado a la encuesta';
COMMENT ON COLUMN responses.question_id IS 'ID de la pregunta contestada';
COMMENT ON COLUMN responses.answer_value IS 'Valor de la respuesta (0-3)';
