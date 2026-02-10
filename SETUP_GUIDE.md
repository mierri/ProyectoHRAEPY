# 📱 BDI-2 Survey App - Guía de Configuración Completa

## 🎯 Resumen

Esta app Flutter usa:
- **Hive**: Almacenamiento local offline
- **Supabase**: Base de datos en la nube
- **Render** (opcional): Backend API adicional

## ⚙️ Configuración Paso a Paso

### 1. Configurar Supabase

#### a) Crear proyecto
1. Ve a [supabase.com](https://supabase.com)
2. Crea una cuenta y un nuevo proyecto
3. Espera a que se configure (2-3 minutos)

#### b) Crear las tablas
1. En el dashboard de Supabase, ve a **SQL Editor**
2. Copia y ejecuta el contenido de `backend/supabase_schema.sql`
3. Click en **Run** para crear las tablas

#### c) Obtener credenciales
1. Ve a **Settings** → **API**
2. Copia:
   - **URL**: `https://xxxxx.supabase.co`
   - **anon public**: La key pública (empieza con `eyJ...`)

### 2. Configurar la App Flutter

#### a) Instalar dependencias
```bash
flutter pub get
```

#### b) Configurar variables de entorno
1. Abre el archivo `.env` en la raíz del proyecto
2. Reemplaza con tus credenciales:

```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### c) Ejecutar la app
```bash
flutter run
```

### 3. Configurar Backend en Render (Opcional)

Este paso es opcional. La app ya funciona con Supabase directamente.

#### ¿Cuándo usar el backend?
- Si necesitas lógica adicional en el servidor
- Para procesamiento de datos complejo
- Para endpoints personalizados
- Como capa de seguridad adicional

#### Pasos:

1. **Preparar el código**
   ```bash
   cd backend
   npm install
   ```

2. **Configurar variables de entorno**
   - Copia `.env.example` a `.env`
   - Añade tus credenciales de Supabase:
   ```env
   PORT=3000
   SUPABASE_URL=https://xxxxx.supabase.co
   SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```
   
   ⚠️ **Importante**: Usa `SUPABASE_SERVICE_KEY` (no anon key) en el backend

3. **Probar localmente**
   ```bash
   npm run dev
   ```
   
   Visita: `http://localhost:3000/health`

4. **Desplegar en Render**
   
   a) Crear cuenta en [render.com](https://render.com)
   
   b) Nuevo Web Service:
      - Click **New +** → **Web Service**
      - Conecta tu repo de GitHub o sube el código
   
   c) Configuración:
      - **Name**: `bdi2-survey-api`
      - **Environment**: `Node`
      - **Root Directory**: `backend`
      - **Build Command**: `npm install`
      - **Start Command**: `npm start`
   
   d) Variables de entorno:
      - Añade `SUPABASE_URL`
      - Añade `SUPABASE_SERVICE_KEY`
   
   e) Click **Create Web Service**

5. **Actualizar la app Flutter** (si usas el backend)
   
   En `lib/Services/survey_service.dart`:
   ```dart
   static const String renderUrl = 'https://tu-app.onrender.com/api/surveys';
   ```

## 🧪 Probar la Configuración

### Probar Supabase
1. Ejecuta la app Flutter
2. Click en "Agregar Encuesta de Prueba"
3. Verifica en Supabase Dashboard → Table Editor → `surveys`

### Probar Backend (si lo configuraste)
```bash
# Crear encuesta
curl -X POST https://tu-app.onrender.com/api/surveys \
  -H "Content-Type: application/json" \
  -d '{"survey_id": 12345, "responses": [{"questionId": 1, "answerValue": 2}]}'

# Ver encuestas
curl https://tu-app.onrender.com/api/surveys

# Ver estadísticas
curl https://tu-app.onrender.com/api/stats
```

## 📁 Estructura del Proyecto

```
ssapp/
├── lib/
│   ├── config/
│   │   └── supabase_config.dart    # Configuración de Supabase
│   ├── Services/
│   │   └── survey_service.dart     # Servicio de sincronización
│   ├── models/                     # Modelos de datos
│   ├── provider/                   # Lógica de negocio
│   └── main.dart                   # Punto de entrada
├── backend/                        # Backend opcional
│   ├── server.js                   # API Express
│   ├── package.json
│   ├── supabase_schema.sql         # Script de base de datos
│   └── README.md                   # Guía del backend
├── .env                           # Variables de entorno (Flutter)
└── pubspec.yaml                   # Dependencias Flutter
```

## 🔐 Seguridad

### ⚠️ Nunca expongas:
- `SUPABASE_SERVICE_KEY` en el código del frontend
- Archivo `.env` en git

### ✅ Buenas prácticas:
- Usa `anon key` en Flutter
- Usa `service_role key` solo en el backend
- Configura RLS (Row Level Security) en Supabase
- Añade `.env` a `.gitignore`

## 🆓 Planes Gratuitos

### Supabase Free
- ✅ 500 MB de base de datos
- ✅ 2 GB de transferencia mensual
- ✅ 50,000 usuarios activos
- ✅ Perfecto para desarrollo y apps pequeñas

### Render Free
- ✅ 750 horas/mes
- ⏸️ Se suspende tras 15 min de inactividad
- 🐌 Cold start de 30-60 segundos
- ✅ Suficiente para pruebas

## 🐛 Solución de Problemas

### Error: "Invalid API key"
- Verifica que copiaste la key completa
- Confirma que usas `anon key` en Flutter
- Revisa que el `.env` tiene el formato correcto

### Error: "relation 'surveys' does not exist"
- Ejecuta el script SQL en Supabase
- Verifica que las tablas se crearon correctamente

### La app no sincroniza
- Verifica conexión a internet
- Revisa los logs en la consola
- Confirma que las credenciales son correctas

### Backend no responde (Render)
- Primera solicitud puede tardar (cold start)
- Verifica las variables de entorno en Render
- Revisa los logs en Render Dashboard

## 📞 Próximos Pasos

1. ✅ Configura Supabase
2. ✅ Actualiza el archivo `.env`
3. ✅ Ejecuta `flutter pub get`
4. ✅ Prueba la app: `flutter run`
5. ⏭️ (Opcional) Configura backend en Render

## 💡 Consejos

- Empieza solo con Supabase (más simple)
- Añade el backend si necesitas funcionalidad extra
- Usa el plan gratuito para desarrollo
- Considera upgrade para producción

¿Listo para comenzar? 🚀

1. Configura tus credenciales en `.env`
2. Ejecuta `flutter pub get`
3. Inicia la app con `flutter run`
