# 📘 Manual para el cliente — Sistema de Pacientes y Encuestas (Departamento de Psicología HRAEPY)

> Este documento explica, en lenguaje simple y sin tecnicismos, qué es la aplicación, cómo está construida, dónde viven los datos y cómo se publican las actualizaciones. Está pensado para que cualquier persona del hospital, sin conocimientos de programación, entienda el sistema que están usando.

---

## 1. ¿Qué es esta aplicación?

Es un sistema para que el Departamento de Psicología del hospital pueda:

- Registrar y administrar **pacientes**.
- Aplicar **encuestas y tests clínicos** (19 instrumentos distintos: depresión, ansiedad, calidad de vida, memoria, hábitos, etc.).
- Agrupar pacientes y encuestas dentro de **investigaciones/estudios**, con su consentimiento informado.
- Generar **reportes con gráficos**, y descargarlos en **PDF o Excel**.
- Crear **encuestas propias y personalizadas**, sin que nadie tenga que programar.
- Seguir funcionando **aunque no haya internet**, y sincronizar los datos automáticamente cuando la conexión vuelve.

Funciona tanto en **tablets/celulares Android** como en una **computadora, desde el navegador web**.

---

## 2. ¿Con qué está construida? (explicado sin tecnicismos)

Toda aplicación moderna se apoya en distintas "piezas" de tecnología, cada una con un trabajo específico. Acá va la lista, explicada con analogías simples:

### 🧱 Flutter (el lenguaje/herramienta de programación)

Es la herramienta con la que se construyó la aplicación. Su ventaja principal es que **se escribe una sola vez y funciona en varios lugares**: en el celular (Android) y en la computadora (navegador web), sin tener que hacer dos aplicaciones separadas ni duplicar el trabajo cada vez que se corrige algo o se agrega una función nueva.

Es una tecnología usada por empresas grandes a nivel mundial (por ejemplo, Google es quien la creó), lo cual da estabilidad y soporte a largo plazo.

### ☁️ Supabase (donde viven los datos, en la nube)

Es el **servicio que guarda la información de forma segura en internet**: pacientes, encuestas, respuestas, usuarios. Se puede pensar como una **caja fuerte digital compartida**, a la que la app se conecta para guardar y traer datos.

Incluye además el sistema de **inicio de sesión** (usuario y contraseña) para que solo el personal autorizado del hospital pueda entrar al sistema.

Puntos importantes de seguridad:
- Cada usuario solo puede iniciar sesión con credenciales creadas específicamente para el hospital (no es un registro abierto a cualquiera).
- Los datos están protegidos con reglas de acceso a nivel de base de datos (lo que en el mundo técnico se llama *Row Level Security*), que impiden que alguien sin permiso pueda leer o modificar información.

### 💾 Hive (guardado local, en el dispositivo)

Es lo que permite que la aplicación **siga funcionando sin conexión a internet**. Cuando un consultorio no tiene señal o wifi, los datos igual se guardan dentro del celular o computadora, y **apenas vuelve la conexión, se sincronizan automáticamente** con la nube (Supabase), sin que la persona tenga que hacer nada manual (aunque también existe un botón para forzar la sincronización si se desea).

Esto evita que se pierda información por cortes de conexión, algo común en consultorios u hospitales.

### 📊 Generación de reportes (PDF / Excel / gráficos)

La app puede transformar los resultados de las encuestas en:
- **Gráficos visuales** (barras, líneas, etc.), para entender resultados de un vistazo.
- **Archivos PDF**, listos para imprimir o adjuntar a una historia clínica.
- **Archivos Excel**, para quienes prefieran analizar los datos en una planilla.

### 🔊 Lectura en voz alta (accesibilidad)

Algunas encuestas pueden leerse en voz alta desde la propia app, pensado para pacientes con dificultades de lectura o visión. (Esta función solo está disponible en la versión para celular/tablet, no en la versión web, por compatibilidad de navegadores).

### 📶 Detección de conexión a internet

La app sabe, en todo momento, si hay o no conexión a internet, y muestra indicadores visuales de qué datos están sincronizados y cuáles quedan pendientes de subir a la nube.

---

## 3. ¿Dónde se actualiza y publica el sistema?

Acá es donde entran **GitHub** y **Vercel**, dos herramientas que muchas veces generan dudas porque son "invisibles" para el usuario final, pero son las que hacen posible que el sistema mejore con el tiempo de forma ordenada y segura.

### 🗂️ GitHub — el "historial de cambios" del proyecto

GitHub es como un **Google Drive especializado para código**, pero con superpoderes:

- Guarda **todo el historial** de cada cambio que se hizo en el sistema, quién lo hizo y cuándo.
- Permite que el equipo de desarrollo trabaje de forma **ordenada y sin pisarse el trabajo entre sí**: cada mejora o corrección se prueba primero por separado, antes de sumarse a la versión "oficial" que usa el hospital.
- Sirve como **respaldo permanente** del proyecto: si algo se rompe o hay que volver atrás, siempre se puede recuperar una versión anterior que funcionaba bien.

En términos simples, el equipo trabaja con un sistema de "versión oficial en uso" y "versiones de prueba", y los cambios nuevos solo pasan a producción después de ser revisados por al menos otra persona del equipo. Esto reduce muchísimo el riesgo de que un error llegue a la versión que usan los pacientes o el personal del hospital.

### 🌐 Vercel — la publicación automática de la versión web

Vercel es el servicio que **hospeda y publica automáticamente la versión web** de la aplicación (la que se usa desde el navegador, sin instalar nada).

El flujo es así:

1. El equipo de desarrollo termina una mejora o corrección y la integra a la versión oficial del proyecto (en GitHub).
2. Automáticamente, **Vercel detecta ese cambio**, construye la nueva versión de la aplicación web y la publica en internet.
3. La próxima vez que alguien entra a la dirección web del sistema, ya está viendo la versión actualizada — **sin que nadie tenga que instalar nada ni hacer pasos manuales**.

Es un proceso completamente automatizado: nadie tiene que "subir archivos a un servidor" a mano. Esto reduce errores humanos y asegura que la versión publicada sea siempre la que fue revisada y aprobada por el equipo.

> 📌 En resumen: **GitHub es el lugar donde se controla y revisa el código**, y **Vercel es el servicio que toma esa versión aprobada y la publica automáticamente en internet** para que el hospital la use desde el navegador.

### 📱 ¿Y la versión para Android?

La versión para celular/tablet (Android) se genera como un archivo instalable (APK) a partir de esa misma versión oficial del código, y se comparte con el hospital para su instalación cuando corresponde a una nueva entrega.

---

## 4. ¿Qué incluye la aplicación? (resumen funcional)

| Módulo | ¿Qué permite hacer? |
|---|---|
| **Pacientes** | Registrar, editar y consultar pacientes atendidos. |
| **Encuestas clínicas** | Aplicar 19 instrumentos distintos (depresión, ansiedad, calidad de vida, memoria, hábitos, barreras de asistencia, determinantes sociales, etc.). |
| **Constructor de encuestas** | Crear encuestas propias del hospital, definiendo preguntas y niveles de interpretación, sin programar. |
| **Investigaciones** | Agrupar pacientes, consentimiento informado y encuestas dentro de un estudio de investigación. |
| **Reportes** | Ver estadísticas, gráficos, y exportar resultados en PDF o Excel, por tipo de encuesta o por investigación. |
| **Modo offline** | Seguir trabajando sin conexión; los datos se sincronizan automáticamente al recuperar internet. |
| **Usuarios y accesos** | Inicio de sesión seguro, solo para personal autorizado del hospital. |
| **Multiplataforma** | Funciona en Android y en la Web (computadora), con la misma información sincronizada. |

---

## 5. Seguridad y privacidad de los datos

- El acceso a la aplicación requiere **usuario y contraseña**; no es de acceso público.
- La información de pacientes se guarda en un servicio en la nube (Supabase) con **reglas de seguridad que restringen quién puede ver o modificar cada dato**.
- Las claves técnicas sensibles (las que permitirían administrar la base de datos completa) **nunca se incluyen en la aplicación ni en el navegador**; solo se usan del lado seguro del servidor.
- Todo cambio de código pasa por una **revisión de al menos otra persona del equipo** antes de llegar a la versión que usa el hospital.

---

## 6. Preguntas frecuentes

**¿Si se corta internet en el consultorio, se pierde el trabajo?**
No. La app sigue funcionando y guardando todo localmente. Cuando vuelve la conexión, sincroniza sola.

**¿Quién puede ver los datos de los pacientes?**
Solo las personas que tengan un usuario y contraseña creados específicamente para el hospital.

**¿Cómo se actualiza la aplicación?**
La versión web se actualiza sola, automáticamente, cada vez que el equipo de desarrollo publica una mejora aprobada. La versión Android se actualiza instalando un nuevo archivo cuando el equipo entrega una nueva versión.

**¿Se puede perder información al actualizar?**
No debería: los cambios se prueban en un ambiente separado antes de aplicarse a la versión oficial, y todo el historial de versiones queda guardado por si hiciera falta volver atrás.

**¿Necesito instalar algo para usar la versión web?**
No. Solo se necesita un navegador (se recomienda Chrome o Edge) y conexión a internet la primera vez.

---

## 7. Glosario rápido

| Término | En simple |
|---|---|
| **Flutter** | La herramienta con la que se construyó la app; permite que funcione en Android y en la Web con el mismo código. |
| **Supabase** | El servicio en la nube donde se guardan los datos y se maneja el inicio de sesión. |
| **Hive** | El "cuaderno local" donde la app guarda datos en el dispositivo cuando no hay internet. |
| **GitHub** | El sistema donde se guarda el historial de cambios del código y se revisan las mejoras antes de publicarlas. |
| **Vercel** | El servicio que publica automáticamente la versión web en internet. |
| **Sincronización** | El proceso de subir a la nube los datos que se guardaron localmente mientras no había internet. |
| **PDF / Excel** | Formatos de exportación para imprimir o analizar los resultados de las encuestas. |

---

*Para documentación técnica más detallada (dirigida al equipo de desarrollo), ver [README.md](README.md) y el resto de la documentación en la raíz del proyecto.*
