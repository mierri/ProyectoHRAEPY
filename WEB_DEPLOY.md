# Version web

Esta app ya incluye soporte para Flutter Web.

## Ajustes hechos para web

- Se mantiene el flujo principal de pacientes, investigaciones y encuestas.
- El TTS se oculta en navegador para evitar problemas de compatibilidad.
- Los reportes permiten:
  - descargar PDF
  - imprimir PDF
  - descargar Excel

## Build web

Desde la raiz del proyecto:

```bash
flutter pub get
flutter build web --release
```

La salida queda en:

```bash
build/web
```

## Publicacion

La carpeta `build/web` se puede subir tal cual a un hosting estatico, por ejemplo:

- Netlify
- Vercel
- Firebase Hosting
- servidor interno del hospital

## Notas

- En web, la experiencia recomendada es usar Chrome o Edge.
- La descarga de PDF y Excel se hace directamente desde el navegador.
- La impresion del PDF abre el flujo de impresion del navegador/sistema.
- Si usan una sola computadora dentro del consultorio, esta version web puede fijarse como acceso directo en el escritorio.
