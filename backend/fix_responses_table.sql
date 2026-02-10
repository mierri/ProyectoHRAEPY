-- Arreglar la tabla responses para permitir múltiples respuestas por encuesta
-- Ejecuta este script en el SQL Editor de Supabase

-- Eliminar la tabla existente (cuidado: esto borra todos los datos)
DROP TABLE IF EXISTS responses CASCADE;

-- Recrear la tabla con estructura correcta
CREATE TABLE responses (
    id BIGSERIAL PRIMARY KEY,
    survey_id BIGINT NOT NULL REFERENCES surveys(survey_id) ON DELETE CASCADE,
    question_id INTEGER NOT NULL,
    answer_value INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(survey_id, question_id)
);

-- Índices para mejorar el rendimiento
CREATE INDEX idx_responses_survey_id ON responses(survey_id);
CREATE INDEX idx_responses_question_id ON responses(question_id);

-- Habilitar Row Level Security
ALTER TABLE responses ENABLE ROW LEVEL SECURITY;

-- Políticas RLS
DROP POLICY IF EXISTS "Permitir insertar respuestas" ON responses;
DROP POLICY IF EXISTS "Permitir leer respuestas" ON responses;

CREATE POLICY "Permitir insertar respuestas" ON responses
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Permitir leer respuestas" ON responses
    FOR SELECT
    USING (true);

-- Comentarios
COMMENT ON TABLE responses IS 'Respuestas individuales de cada encuesta BDI-2';
COMMENT ON COLUMN responses.survey_id IS 'ID de la encuesta a la que pertenece';
COMMENT ON COLUMN responses.question_id IS 'ID de la pregunta (1-21 para BDI-2)';
COMMENT ON COLUMN responses.answer_value IS 'Valor de la respuesta (0-3)';
