# MoCA Test - Capacidades de Dibujo Implementadas

## Resumen de Mejoras

Se ha agregado capacidad de dibujo táctil al test MoCA para tabletas, permitiendo que los pacientes dibujen directamente en la pantalla.

## ✨ Características Implementadas

### 1. **Canvas de Dibujo Interactivo**
- Canvas táctil con trazo suave y preciso
- Fondo blanco con bordes definidos
- Botón para borrar el dibujo completo
- Confirmación antes de borrar para evitar accidentes

### 2. **Test del Trazo Alterno (Trail Making)**
- Círculos numerados y letrados mostrados en pantalla
- Secuencia visual: 1→A→2→B→3→C→4→D→5→E
- Círculo verde para inicio (1)
- Círculo rojo para final (E)
- Guías visuales semi-transparentes en el fondo
- El paciente dibuja la línea conectando los círculos

### 3. **Dibujo del Cubo 3D**
- Imagen de referencia de un cubo tridimensional
- Mostrado semi-transparente en el fondo
- El paciente puede copiar el dibujo directamente sobre la guía
- Evaluación de si el dibujo es tridimensional y tiene todas las líneas

### 4. **Dibujo del Reloj**
- Círculo guía sutil en gris
- Espacio para dibujar el contorno, números y manecillas
- Evaluación por componentes (contorno, números, manecillas)
- Indicación clara: "Marque las 10:10"

### 5. **Denominación con Imágenes**
- Imágenes visuales de los animales (emojis grandes)
- 🐴 Caballo (con alternativas: poni, yegua, potro)
- 🐯 Tigre
- 🦆 Pato
- Tarjetas visuales grandes y claras
- Información de respuestas alternativas aceptables

## 📦 Paquetes Utilizados

```yaml
signature: ^5.5.0  # Para el canvas de dibujo táctil
```

## 🎨 Interfaz de Usuario

### Canvas de Dibujo
- **Tamaño**: Ajustable por sección (400-500px de altura)
- **Color del trazo**: Negro (3px de ancho)
- **Fondo**: Blanco con imágenes guía semi-transparentes (30% opacidad)
- **Bordes**: Azul secundario con opacidad del 30%

### Controles
- **Botón Borrar**: Rojo con confirmación
- **Diseño responsive**: Adaptado para tablets

## 🔧 Archivos Modificados

1. **`pubspec.yaml`**
   - Agregado paquete `signature: ^5.5.0`

2. **`lib/widgets/drawing_canvas.dart`** (NUEVO)
   - Widget genérico `DrawingCanvas`
   - `TrailMakingCanvas` con círculos numerados/letrados
   - `CubeDrawingCanvas` con imagen 3D de referencia
   - `ClockDrawingCanvas` con círculo guía
   - Painters personalizados para cada tipo

3. **`lib/screens/moca_test_screen.dart`**
   - Agregados controladores de firma para cada sección de dibujo
   - Integrados los nuevos widgets de canvas
   - Actualizada la sección de denominación con imágenes de animales
   - Evaluación integrada con checkboxes

## 🎯 Uso para el Evaluador

### Test del Trazo Alterno
1. El paciente ve los círculos numerados y letrados
2. Dibuja una línea continua siguiendo la secuencia
3. El evaluador marca si el trazo fue correcto (sin cruces)

### Dibujo del Cubo
1. El paciente ve la imagen de referencia del cubo
2. Dibuja encima o al lado de la referencia
3. El evaluador marca si el dibujo es 3D y tiene todas las líneas

### Dibujo del Reloj
1. El paciente dibuja el círculo y los números
2. Dibuja las manecillas marcando las 10:10
3. El evaluador evalúa 3 componentes:
   - ✓ Contorno (1 punto)
   - ✓ Números (1 punto)
   - ✓ Manecillas (1 punto)

### Denominación
1. Se muestra la imagen del animal (emoji grande)
2. El paciente nombra el animal
3. El evaluador marca si la respuesta fue correcta

## 💡 Ventajas para Tabletas

✅ **Interacción Natural**: El paciente dibuja con el dedo o stylus
✅ **Sin Papel**: Todo digital, más ecológico
✅ **Guías Visuales**: Imágenes de referencia claras
✅ **Fácil Corrección**: Botón para borrar y volver a intentar
✅ **Evaluación Rápida**: Checkboxes para el evaluador
✅ **Espacios Amplios**: Diseñado para pantallas táctiles grandes

## 🚀 Próximos Pasos (Opcionales)

- [ ] Exportar los dibujos como imágenes PNG
- [ ] Análisis automático de patrones de dibujo
- [ ] Comparación con dibujos de referencia usando ML
- [ ] Guardar los dibujos en la base de datos
- [ ] Historial de dibujos del paciente

## 📱 Requerimientos

- **Dispositivo**: Tablet con pantalla táctil
- **Tamaño mínimo**: 10 pulgadas recomendado
- **Sistema**: Android/iOS compatible con Flutter
- **Entrada**: Touch screen o stylus

---

**Nota**: Los dibujos actualmente no se guardan en la base de datos (pendiente implementación backend). La evaluación y puntuación se realiza manualmente por el profesional de salud.

