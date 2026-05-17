# Prosper - App de Gestión Financiera Personal

Prosper es una aplicación móvil moderna y minimalista para la gestión de finanzas personales, construida con **Flutter** y **Supabase**.

## Características (MVP)

- **Onboarding y Autenticación**: Registro/Inicio de sesión con Supabase Auth.
- **Conexión Bancaria**: Integración con Plaid (Sandbox) para vincular cuentas reales.
- **Categorización Automática**: Clasificador basado en reglas para organizar tus gastos.
- **Presupuestos Inteligentes**: Sugerencias basadas en tu historial de gastos.
- **Proyecciones**: Visualiza tu saldo futuro a 30 días.
- **Alertas**: Detección de cargos duplicados y suscripciones.

## Tecnologías Utilizadas

- **Frontend**: Flutter (BLoC para gestión de estado).
- **Backend**: Supabase (PostgreSQL, Auth, Edge Functions).
- **Integraciones**: Plaid (Open Banking).
- **UI**: Material 3, Google Fonts (Inter), fl_chart.

## Requisitos Previos

- Flutter SDK instalado (>= 3.0.0).
- Una cuenta en [Supabase](https://supabase.com/).
- Una cuenta en [Plaid](https://plaid.com/) (para el Client ID y Secret).

## Configuración del Proyecto

1. **Clonar el repositorio**.
2. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```
3. **Configurar Supabase**:
   - Crea un nuevo proyecto en Supabase.
   - Ejecuta las migraciones SQL proporcionadas en el dashboard de Supabase para crear las tablas necesarias.
   - Actualiza las credenciales en `lib/main.dart`:
     ```dart
     url: 'TU_SUPABASE_URL',
     anonKey: 'TU_SUPABASE_ANON_KEY',
     ```
4. **Ejecutar la aplicación**:
   ```bash
   flutter run
   ```

## Estructura del Proyecto

- `lib/core/`: Temas, utilidades y motores de lógica.
- `lib/data/`: Repositorios y servicios de API (Supabase, Plaid).
- `lib/logic/`: BloCs y Cubits para la lógica de negocio.
- `lib/models/`: Modelos de datos.
- `lib/ui/`: Pantallas y componentes visuales.

## Notas de Desarrollo

- El motor de categorización actual es basado en reglas. Se puede extender a ML mediante Supabase Edge Functions y la API de Gemini.
- Las proyecciones se calculan localmente usando la media de ingresos y gastos de los últimos 90 días.
