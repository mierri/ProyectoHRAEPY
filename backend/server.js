const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Inicializar cliente de Supabase
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY // Usa SERVICE_KEY en el backend, no ANON_KEY
);

// Middleware
app.use(cors());
app.use(express.json());

// Rutas de salud
app.get('/', (req, res) => {
  res.json({ message: 'BDI-2 Survey API', status: 'running' });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Crear nueva encuesta
app.post('/api/surveys', async (req, res) => {
  try {
    const { survey_id, patient_id, responses } = req.body;

    // Validación básica
    if (!survey_id || !responses || !Array.isArray(responses)) {
      return res.status(400).json({ 
        error: 'Datos inválidos. Se requiere survey_id y responses (array)' 
      });
    }

    // Si hay patient_id, verificar que existe
    if (patient_id) {
      const { data: patientExists } = await supabase
        .from('patients')
        .select('patient_id')
        .eq('patient_id', patient_id)
        .maybeSingle();
      
      if (!patientExists) {
        return res.status(400).json({ 
          error: 'El paciente especificado no existe' 
        });
      }
    }

    // Insertar encuesta
    const { data: surveyData, error: surveyError } = await supabase
      .from('surveys')
      .insert({
        survey_id,
        patient_id: patient_id || null,
        created_at: new Date().toISOString(),
        synced: true
      })
      .select()
      .single();

    if (surveyError) throw surveyError;

    // Insertar respuestas
    const responsesData = responses.map(r => ({
      survey_id: survey_id,
      question_id: r.questionId,
      answer_value: r.answerValue
    }));

    const { error: responsesError } = await supabase
      .from('responses')
      .insert(responsesData);

    if (responsesError) throw responsesError;

    res.status(201).json({
      success: true,
      data: surveyData
    });

  } catch (error) {
    console.error('Error al crear encuesta:', error);
    res.status(500).json({ 
      error: 'Error al procesar la encuesta',
      details: error.message 
    });
  }
});

// Obtener todas las encuestas
app.get('/api/surveys', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('surveys')
      .select('*, responses(*)')
      .order('created_at', { ascending: false });

    if (error) throw error;

    res.json({
      success: true,
      data,
      count: data.length
    });

  } catch (error) {
    console.error('Error al obtener encuestas:', error);
    res.status(500).json({ 
      error: 'Error al obtener encuestas',
      details: error.message 
    });
  }
});

// Obtener encuesta por ID
app.get('/api/surveys/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const { data, error } = await supabase
      .from('surveys')
      .select('*, responses(*)')
      .eq('id', id)
      .single();

    if (error) throw error;

    if (!data) {
      return res.status(404).json({ error: 'Encuesta no encontrada' });
    }

    res.json({
      success: true,
      data
    });

  } catch (error) {
    console.error('Error al obtener encuesta:', error);
    res.status(500).json({ 
      error: 'Error al obtener la encuesta',
      details: error.message 
    });
  }
});

// Obtener estadísticas
app.get('/api/stats', async (req, res) => {
  try {
    const { data: surveys, error: surveyError } = await supabase
      .from('surveys')
      .select('id');

    if (surveyError) throw surveyError;

    const { data: responses, error: responsesError } = await supabase
      .from('responses')
      .select('answer_value');

    if (responsesError) throw responsesError;

    // Calcular promedios y estadísticas
    const totalSurveys = surveys.length;
    const totalResponses = responses.length;
    const averageScore = totalResponses > 0 
      ? responses.reduce((sum, r) => sum + r.answer_value, 0) / totalResponses 
      : 0;

    res.json({
      success: true,
      stats: {
        totalSurveys,
        totalResponses,
        averageScore: averageScore.toFixed(2),
        timestamp: new Date().toISOString()
      }
    });

  } catch (error) {
    console.error('Error al obtener estadísticas:', error);
    res.status(500).json({ 
      error: 'Error al obtener estadísticas',
      details: error.message 
    });
  }
});

// ==================== PACIENTES ====================

// Crear o actualizar paciente
app.post('/api/patients', async (req, res) => {
  try {
    const { patient_id, name, gender, birth_date } = req.body;

    // Validación básica
    if (!patient_id || !name || !gender || !birth_date) {
      return res.status(400).json({ 
        error: 'Datos inválidos. Se requiere patient_id, name, gender y birth_date' 
      });
    }

    // Validar género
    if (!['Masculino', 'Femenino'].includes(gender)) {
      return res.status(400).json({ 
        error: 'Género inválido. Debe ser Masculino o Femenino' 
      });
    }

    // Insertar o actualizar paciente (upsert)
    const { data, error } = await supabase
      .from('patients')
      .upsert({
        patient_id,
        name,
        gender,
        birth_date,
        created_at: new Date().toISOString()
      }, { onConflict: 'patient_id' })
      .select()
      .single();

    if (error) throw error;

    res.status(201).json({
      success: true,
      data
    });

  } catch (error) {
    console.error('Error al crear paciente:', error);
    res.status(500).json({ 
      error: 'Error al procesar el paciente',
      details: error.message 
    });
  }
});

// Obtener todos los pacientes
app.get('/api/patients', async (req, res) => {
  try {
    const { search } = req.query;
    
    let query = supabase
      .from('patients')
      .select('*')
      .order('created_at', { ascending: false });

    // Búsqueda por nombre si se proporciona
    if (search) {
      query = query.ilike('name', `%${search}%`);
    }

    const { data, error } = await query;

    if (error) throw error;

    res.json({
      success: true,
      data,
      count: data.length
    });

  } catch (error) {
    console.error('Error al obtener pacientes:', error);
    res.status(500).json({ 
      error: 'Error al obtener pacientes',
      details: error.message 
    });
  }
});

// Obtener paciente por ID
app.get('/api/patients/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const { data, error } = await supabase
      .from('patients')
      .select('*')
      .eq('patient_id', id)
      .single();

    if (error) throw error;

    if (!data) {
      return res.status(404).json({ error: 'Paciente no encontrado' });
    }

    res.json({
      success: true,
      data
    });

  } catch (error) {
    console.error('Error al obtener paciente:', error);
    res.status(500).json({ 
      error: 'Error al obtener el paciente',
      details: error.message 
    });
  }
});

// Actualizar paciente
app.put('/api/patients/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, gender, birth_date } = req.body;

    // Validar género si se proporciona
    if (gender && !['Masculino', 'Femenino'].includes(gender)) {
      return res.status(400).json({ 
        error: 'Género inválido. Debe ser Masculino o Femenino' 
      });
    }

    const updateData = {};
    if (name) updateData.name = name;
    if (gender) updateData.gender = gender;
    if (birth_date) updateData.birth_date = birth_date;

    const { data, error } = await supabase
      .from('patients')
      .update(updateData)
      .eq('patient_id', id)
      .select()
      .single();

    if (error) throw error;

    if (!data) {
      return res.status(404).json({ error: 'Paciente no encontrado' });
    }

    res.json({
      success: true,
      data
    });

  } catch (error) {
    console.error('Error al actualizar paciente:', error);
    res.status(500).json({ 
      error: 'Error al actualizar el paciente',
      details: error.message 
    });
  }
});

// Obtener encuestas de un paciente
app.get('/api/patients/:id/surveys', async (req, res) => {
  try {
    const { id } = req.params;

    const { data, error } = await supabase
      .from('surveys')
      .select('*, responses(*)')
      .eq('patient_id', id)
      .order('created_at', { ascending: false });

    if (error) throw error;

    res.json({
      success: true,
      data,
      count: data.length
    });

  } catch (error) {
    console.error('Error al obtener encuestas del paciente:', error);
    res.status(500).json({ 
      error: 'Error al obtener encuestas',
      details: error.message 
    });
  }
});

// Eliminar paciente
app.delete('/api/patients/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const { error } = await supabase
      .from('patients')
      .delete()
      .eq('patient_id', id);

    if (error) throw error;

    res.json({
      success: true,
      message: 'Paciente eliminado correctamente'
    });

  } catch (error) {
    console.error('Error al eliminar paciente:', error);
    res.status(500).json({ 
      error: 'Error al eliminar el paciente',
      details: error.message 
    });
  }
});

// Manejo de errores 404
app.use((req, res) => {
  res.status(404).json({ error: 'Ruta no encontrada' });
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en puerto ${PORT}`);
  console.log(`📊 API disponible en http://localhost:${PORT}`);
});

module.exports = app;
