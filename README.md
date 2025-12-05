# 🕵️ IMPOSTOR - Who is the Spy?

Un juego social de deducción desarrollado en Flutter con un tema Cyberpunk/Noir.

## 📱 Características

### Módulo de Configuración
- ✅ Gestión dinámica de jugadores (mínimo 3)
- ✅ Selector de categorías en grilla con opción "Seleccionar todas"
- ✅ Slider para definir número de impostores
- ✅ Opción para que el impostor vea la categoría o no

### Motor Lógico del Juego (Game Engine)
- ✅ 8 categorías predefinidas con 15 palabras cada una
- ✅ Algoritmo de asignación aleatoria usando `Random.secure()` (criptográficamente seguro)
- ✅ Fisher-Yates shuffle para distribución uniforme de roles
- ✅ Selección aleatoria de categoría y palabra secreta

### Flujo Pass-the-Device
- ✅ Pantalla de transición con nombre del jugador
- ✅ Botón "mantener presionado" para ver rol
- ✅ Revelación animada para ciudadanos (palabra secreta)
- ✅ Revelación animada para impostores (alerta roja + "Shhh...")
- ✅ Estado neutro al soltar

### Fase de Debate y Votación
- ✅ Timer opcional configurable (1-10 minutos)
- ✅ Lista de jugadores con estado (activo/eliminado)
- ✅ Toggle para marcar jugadores eliminados
- ✅ Botón para revelar identidades

### UI/UX
- ✅ Material Design 3 con tema oscuro Cyberpunk/Noir
- ✅ Colores neón vibrantes (Cyan, Magenta, Verde, Rojo)
- ✅ Animaciones implícitas suaves
- ✅ Feedback háptico (vibración) al revelar impostor
- ✅ Transiciones fluidas entre pantallas

## 🛠 Stack Tecnológico

- **Framework**: Flutter (última versión estable)
- **State Management**: Riverpod
- **UI**: Material Design 3
- **Fuentes**: Google Fonts (Orbitron, Rajdhani)
- **Háptica**: vibration package

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada
├── core/
│   ├── models/                  # Modelos de datos inmutables
│   │   ├── player.dart          # Modelo de jugador
│   │   ├── category.dart        # Modelo de categoría y palabras
│   │   ├── game_state.dart      # Estado del juego
│   │   └── models.dart          # Barrel file
│   ├── providers/               # Providers de Riverpod
│   │   ├── game_provider.dart   # Game Engine y providers
│   │   └── providers.dart       # Barrel file
│   └── theme/                   # Tema de la aplicación
│       ├── app_theme.dart       # Tema Cyberpunk/Noir
│       └── theme.dart           # Barrel file
└── ui/
    ├── screens/                 # Pantallas principales
    │   ├── setup_screen.dart    # Configuración del juego
    │   ├── role_reveal_screen.dart  # Revelación de roles
    │   ├── debate_screen.dart   # Fase de debate
    │   ├── results_screen.dart  # Resultados finales
    │   └── screens.dart         # Barrel file
    └── widgets/                 # Widgets reutilizables
        ├── common_widgets.dart  # NeonCard, NeonButton, etc.
        └── widgets.dart         # Barrel file
```

## 🎮 Cómo Jugar

1. **Configuración**: Agrega al menos 3 jugadores, selecciona categorías y número de impostores.
2. **Revelación de Roles**: Cada jugador mantiene presionado para ver su rol en privado.
3. **Debate**: Discutan sobre el tema. Cada jugador describe algo relacionado con la palabra.
4. **Votación**: Marquen quién creen que es el impostor.
5. **Resultados**: Revelen las identidades y vean quién ganó.

## 🔐 Algoritmo de Asignación Aleatoria

El juego utiliza `Random.secure()` para generar números aleatorios criptográficamente seguros, garantizando que la asignación de roles sea verdaderamente impredecible.

```dart
// Algoritmo Fisher-Yates Shuffle
static List<T> _shuffle<T>(List<T> list) {
  final shuffled = List<T>.from(list);
  for (int i = shuffled.length - 1; i > 0; i--) {
    final j = _secureRandom.nextInt(i + 1);
    final temp = shuffled[i];
    shuffled[i] = shuffled[j];
    shuffled[j] = temp;
  }
  return shuffled;
}
```

## 🚀 Instalación

```bash
# Clonar repositorio
git clone [repository-url]

# Instalar dependencias
flutter pub get

# Ejecutar aplicación
flutter run
```

## 📦 Dependencias

```yaml
dependencies:
  flutter_riverpod: ^2.4.9   # State management
  google_fonts: ^6.1.0       # Fuentes Orbitron y Rajdhani
  vibration: ^2.0.1          # Feedback háptico
```

## 🎨 Paleta de Colores

| Color | Hex | Uso |
|-------|-----|-----|
| Cyan Neón | `#00F5FF` | Color primario |
| Magenta Neón | `#FF00FF` | Color secundario |
| Verde Neón | `#39FF14` | Éxito/Ciudadano |
| Rojo Neón | `#FF3131` | Peligro/Impostor |
| Dorado Neón | `#FFD700` | Advertencia |
| Negro Profundo | `#0D0D0D` | Fondo |

## 📄 Licencia

Este proyecto está bajo la licencia MIT.

