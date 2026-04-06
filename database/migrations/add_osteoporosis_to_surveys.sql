-- Add osteoporosis risk calculation fields to surveys table
-- Only add risk_level and score (weight, height, imc are in patients table)

ALTER TABLE surveys ADD COLUMN risk_level VARCHAR(20) DEFAULT NULL;
ALTER TABLE surveys ADD COLUMN score INTEGER DEFAULT NULL;

-- Add comments for clarity
COMMENT ON COLUMN surveys.risk_level IS 'Osteoporosis risk level: low, high, or not_applicable. Calculated from age, BMI, gender, and survey responses.';
COMMENT ON COLUMN surveys.score IS 'Osteoporosis survey score (0-6, normalized). Based on 7 yes/no risk factor questions.';

-- Optional: Add index if you plan to query by risk_level
CREATE INDEX idx_surveys_risk_level ON surveys(risk_level) WHERE survey_type = 9;

