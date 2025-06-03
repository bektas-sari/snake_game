# Flutter Snake Game 🐍

## 📱 Screenshots

*Add your app screenshots here*

## ✨ Features

- **Smooth Gameplay**: Responsive controls with customizable game speed
- **Modern UI Design**: Beautiful gradient themes and animations
- **Multiple Control Options**:
    - Keyboard controls (Arrow keys, WASD)
    - Touch gestures (Swipe to move)
    - Spacebar for pause/resume
- **Game Statistics**: Real-time score tracking and game duration timer
- **Progressive Difficulty**: Game speed increases every 5 points
- **Responsive Design**: Adapts to different screen sizes
- **Game Over Dialog**: Detailed statistics and restart options

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- An emulator or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/flutter-snake-game.git
   cd flutter-snake-game
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🎮 How to Play

1. **Start**: Tap the "START" button or "New Game"
2. **Move**: Use arrow keys, WASD keys, or swipe gestures
3. **Objective**: Eat the red food to grow and increase your score
4. **Avoid**: Don't hit the walls or your own body
5. **Pause**: Press spacebar or the pause button anytime

### Controls

| Input | Action |
|-------|--------|
| ↑ / W | Move Up |
| ↓ / S | Move Down |
| ← / A | Move Left |
| → / D | Move Right |
| Space | Pause/Resume |
| Swipe | Touch controls |

## 🏗️ Project Structure

```
lib/
├── main.dart           # App entry point and theme configuration
├── game_provider.dart  # Game logic and state management
└── game_screen.dart    # UI components and user interactions
```

### Key Components

- **GameProvider**: Manages game state using Provider pattern
- **GameScreen**: Main UI with responsive design
- **Direction Enum**: Handles snake movement directions

## 🔧 Technical Details

### Architecture

- **State Management**: Provider pattern for reactive UI updates
- **Game Loop**: Timer-based movement system with variable speed
- **Collision Detection**: Boundary and self-collision checking
- **Responsive UI**: Adaptive sizing based on screen dimensions

### Game Mechanics

- **Grid System**: 20x20 game grid
- **Initial Speed**: 300ms intervals
- **Speed Increase**: 20ms faster every 5 points
- **Minimum Speed**: 50ms (maximum difficulty)
- **Snake Growth**: Increases by 1 segment per food consumed

### Performance Features

- Efficient rendering with positioned widgets
- Minimal rebuilds using Consumer pattern
- Optimized collision detection algorithms
- Smooth animations with gradient effects

## 🎨 Customization

### Modify Game Settings

Edit constants in `game_provider.dart`:

```dart
static const int gridSize = 20;              // Grid dimensions
static const int initialSnakeLength = 3;     // Starting snake size
static const Duration initialGameSpeed = Duration(milliseconds: 300);
static const Duration speedIncrement = Duration(milliseconds: 20);
```

### Update Visual Theme

Modify colors and styles in `main.dart` and `game_screen.dart`:

- Primary colors: `Colors.blue[400]` to `Colors.blue[800]`
- Gradient configurations
- Border radius values
- Shadow effects

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🛠️ Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  
dev_dependencies:
  flutter_test:
    sdk: flutter
```

## 🐛 Known Issues

- None currently reported

## 🔮 Future Enhancements

- [ ] High score persistence
- [ ] Sound effects and background music
- [ ] Multiple difficulty levels
- [ ] Multiplayer support
- [ ] Custom themes and skins
- [ ] Achievements system
- [ ] Leaderboards

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Provider package for state management
- Material Design for UI guidelines

---

**Enjoyed the game? Give it a ⭐ on GitHub!**