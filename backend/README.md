# BDI-2 Survey App - Backend API

Backend API para la aplicación de encuestas BDI-2, construido con Express.js y Supabase.

## 🚀 Despliegue en Render

### Pasos para desplegar:

1. **Crear cuenta en Render**
   - Ve a [render.com](https://render.com)
   - Crea una cuenta gratuita

2. **Crear nuevo Web Service**
   - Click en "New +" → "Web Service"
   - Conecta tu repositorio de GitHub
   - O sube el código manualmente

3. **Configuración**
   - **Name**: `bdi2-survey-api` (o el nombre que prefieras)
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Plan**: Free

4. **Variables de entorno** (Dashboard de Render)
   ```
   SUPABASE_URL=tu_url_de_supabase
   SUPABASE_SERVICE_KEY=tu_service_role_key
   ```

5. **Deploy**
   - Click en "Create Web Service"
   - Render automáticamente construirá y desplegará tu app

## 📦 Configuración de Supabase

### 1. Crear proyecto en Supabase

- Ve a [supabase.com](https://supabase.com)
- Crea un nuevo proyecto
- Anota tu URL y las Keys (anon y service_role)

### 2. Crear las tablas

- Ve a SQL Editor en Supabase
- Ejecuta el script `supabase_schema.sql`

### 3. Obtener credenciales

En Settings → API:
- **URL**: `https://xxxxx.supabase.co`
- **anon public key**: Para la app Flutter
- **service_role key**: Para el backend (¡mantener secreto!)

## 🔧 Desarrollo local

```bash
# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales

# Iniciar servidor de desarrollo
npm run dev

# O iniciar en producción
npm start
```

El servidor estará disponible en `http://localhost:3000`

## 📡 Endpoints

### Salud del servidor
- `GET /` - Información básica
- `GET /health` - Estado del servidor

### Encuestas
- `POST /api/surveys` - Crear nueva encuesta
- `GET /api/surveys` - Obtener todas las encuestas
- `GET /api/surveys/:id` - Obtener encuesta específica
- `GET /api/stats` - Estadísticas generales

### Ejemplo de request - Crear encuesta

```bash
curl -X POST https://tu-app.onrender.com/api/surveys \
  -H "Content-Type: application/json" \
  -d '{
    "survey_id": 1234567890,
    "responses": [
      {"questionId": 1, "answerValue": 2},
      {"questionId": 2, "answerValue": 3}
    ]
  }'
```

## 🔒 Seguridad

- Las políticas RLS están configuradas en Supabase
- Usa HTTPS en producción (Render lo proporciona automáticamente)
- Nunca expongas la SERVICE_ROLE_KEY en el frontend
- Considera agregar rate limiting para producción

## 📱 Integración con Flutter

En tu app Flutter, actualiza la URL del backend:

```dart
static const String renderUrl = 'https://tu-app.onrender.com/api/surveys';
```

## 🆓 Plan gratuito de Render

- 750 horas/mes de ejecución
- Suspende después de 15 min de inactividad
- Primera solicitud puede tardar 30-60 segundos (cold start)
- Suficiente para desarrollo y pruebas

## 📊 Monitoreo

- Dashboard de Render: métricas de CPU, memoria, requests
- Logs en tiempo real en Render Dashboard
- Supabase Dashboard: queries, rendimiento de base de datos

## 🐛 Solución de problemas

### El servidor no inicia
- Verifica las variables de entorno
- Revisa los logs en Render Dashboard

### Errores de Supabase
- Verifica que las tablas existen
- Confirma que RLS está configurado correctamente
- Verifica que la SERVICE_KEY es correcta

### Cold starts lentos
- Normal en el plan gratuito de Render
- Considera upgrade a plan pagado para producción

## 📝 Notas

- El plan gratuito de Render es perfecto para desarrollo
- Para producción, considera planes pagados
- Supabase free tier: 500MB database, 2GB transfer/month
