# Proceso de CI/CD — ProyectoHRAEPY

Diseñado para un equipo pequeño (~3 personas) con una app Flutter. El objetivo es: código limpio en `main`, releases predecibles, y cero "funciona en mi máquina".

---

## Ramas permanentes

| Rama | Propósito |
|------|-----------|
| `main` | Código de producción. Siempre compila, siempre pasa tests. |
| `develop` | Integración continua. Aquí se juntan las features antes de ir a producción. |

> **Regla de oro:** nadie hace push directo a `main`. Todo entra por PR desde `develop`.

---

## Ramas temporales

### Features
```
feature/<nombre-corto>
```
- Se crean desde `develop`
- Se mergean a `develop` vía PR
- Se eliminan al mergear

Ejemplos: `feature/consent-flow`, `feature/offline-sync`, `feature/ghq-survey`

### Fixes en producción (hotfix)
```
hotfix/<descripción>
```
- Se crean desde `main` cuando hay un bug crítico en producción
- Se mergean a `main` **y** a `develop`
- Se eliminan al mergear

### Releases
```
release/v1.x.x
```
- Se crean desde `develop` cuando se va a hacer una entrega
- Solo se permiten bugfixes en esta rama (no features nuevas)
- Al terminar se mergea a `main` y a `develop`

---

## Flujo día a día

```
main ←──── (solo releases y hotfixes)
  ↑
develop ←── (integración de features)
  ↑
feature/xxx  feature/yyy  feature/zzz
```

### 1. Empezar una feature
```bash
git checkout develop
git pull origin develop
git checkout -b feature/mi-feature
```

### 2. Trabajar y hacer commits
```bash
git add .
git commit -m "feat: descripción corta de qué hace"
git push origin feature/mi-feature
```

### 3. Abrir PR a `develop`
- En GitHub: **base: develop** ← compare: feature/mi-feature
- Agregar descripción breve de qué cambia y cómo probar
- Al menos **1 aprobación** antes de mergear
- Eliminar la rama después del merge (GitHub lo hace automático si lo configuras)

### 4. Release
```bash
git checkout develop
git pull origin develop
git checkout -b release/v1.2.0

# Solo bugfixes aquí, no features nuevas
# Al terminar:
git checkout main
git merge release/v1.2.0
git tag v1.2.0
git push origin main --tags

git checkout develop
git merge release/v1.2.0
git branch -d release/v1.2.0
git push origin --delete release/v1.2.0
```

---

## Convención de commits

Usar el formato [Conventional Commits](https://www.conventionalcommits.org/):

```
<tipo>: <descripción en presente>
```

| Tipo | Cuándo usarlo |
|------|--------------|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug |
| `refactor` | Cambio de código sin cambiar comportamiento |
| `style` | Cambios de UI/estilos sin lógica |
| `test` | Agregar o arreglar tests |
| `chore` | Dependencias, config, tareas de mantenimiento |
| `docs` | Solo documentación |

Ejemplos:
```
feat: add two-screen informed consent flow
fix: resolve render issues on small screens
refactor: extract participant card into reusable widget
```

---

## CI con GitHub Actions

Crear `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [develop]
  pull_request:
    branches: [develop, main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: stable

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze
        run: flutter analyze

      - name: Run tests
        run: flutter test

      - name: Build APK (check que compila)
        run: flutter build apk --debug
```

Esto se ejecuta automáticamente en cada PR y en cada push a `develop`. Si falla, no se puede mergear.

---

## Protección de ramas (configurar en GitHub)

En **Settings → Branches → Branch protection rules**:

### Para `main`:
- [x] Require a pull request before merging
- [x] Require approvals: **1**
- [x] Require status checks to pass (el CI de arriba)
- [x] Do not allow bypassing the above settings

### Para `develop`:
- [x] Require a pull request before merging
- [x] Require status checks to pass

---

## Versionado

Usar [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`

- **PATCH** (1.0.**1**): bugfix
- **MINOR** (1.**1**.0): nueva funcionalidad sin romper nada
- **MAJOR** (**2**.0.0): cambio que rompe compatibilidad (raro en apps móviles)

Actualizar `version` en `pubspec.yaml` en cada release:
```yaml
version: 1.2.0+5  # nombre+buildNumber
```

---

## Resumen visual

```
feature/consent  ──►──►──► PR ──► develop
feature/reports  ──►──►──────────► develop
                                      │
                              (cuando está listo)
                                      ▼
                              release/v1.2.0
                                  │     │
                                  ▼     ▼
                                main  develop
                                  │
                               tag v1.2.0
                            (distribuir APK)
```
