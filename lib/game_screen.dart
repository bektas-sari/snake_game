import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'game_provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final FocusNode _focusNode = FocusNode();
  bool _gameOverDialogShown = false;

  @override
  void initState() {
    super.initState();
    // Focus'u hemen al
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyPress(KeyEvent event, GameProvider gameProvider) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
        case LogicalKeyboardKey.keyW:
          if (gameProvider.direction != Direction.down) {
            gameProvider.changeDirection(Direction.up);
          }
          break;
        case LogicalKeyboardKey.arrowDown:
        case LogicalKeyboardKey.keyS:
          if (gameProvider.direction != Direction.up) {
            gameProvider.changeDirection(Direction.down);
          }
          break;
        case LogicalKeyboardKey.arrowLeft:
        case LogicalKeyboardKey.keyA:
          if (gameProvider.direction != Direction.right) {
            gameProvider.changeDirection(Direction.left);
          }
          break;
        case LogicalKeyboardKey.arrowRight:
        case LogicalKeyboardKey.keyD:
          if (gameProvider.direction != Direction.left) {
            gameProvider.changeDirection(Direction.right);
          }
          break;
        case LogicalKeyboardKey.space:
          gameProvider.togglePlayPause();
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final cellSize = screenWidth * 0.85 / GameProvider.gridSize;
        final gameAreaSize = cellSize * GameProvider.gridSize;

        // Oyun bittiğinde dialog göster
        if (!gameProvider.isPlaying &&
            gameProvider.snake.isNotEmpty &&
            !_gameOverDialogShown) {
          _gameOverDialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showGameOverDialog(context, gameProvider);
          });
        }

        // Oyun yeniden başladığında dialog flag'ini sıfırla
        if (gameProvider.isPlaying) {
          _gameOverDialogShown = false;
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              'Snake Game',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: Focus(
            focusNode: _focusNode,
            onKeyEvent: (node, event) {
              _handleKeyPress(event, gameProvider);
              return KeyEventResult.handled;
            },
            child: GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Skor ve Süre Bilgisi
                      Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[400]!, Colors.blue[600]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'SCORE',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                Text(
                                  '${gameProvider.score}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 40),
                            Column(
                              children: [
                                Text(
                                  'TIME',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                Text(
                                  gameProvider.getFormattedDuration(),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Oyun Alanı
                      GestureDetector(
                        onVerticalDragUpdate: (details) {
                          if (details.primaryDelta! < -1 &&
                              gameProvider.direction != Direction.down) {
                            gameProvider.changeDirection(Direction.up);
                          } else if (details.primaryDelta! > 1 &&
                              gameProvider.direction != Direction.up) {
                            gameProvider.changeDirection(Direction.down);
                          }
                        },
                        onHorizontalDragUpdate: (details) {
                          if (details.primaryDelta! < -1 &&
                              gameProvider.direction != Direction.right) {
                            gameProvider.changeDirection(Direction.left);
                          } else if (details.primaryDelta! > 1 &&
                              gameProvider.direction != Direction.left) {
                            gameProvider.changeDirection(Direction.right);
                          }
                        },
                        child: Container(
                          width: gameAreaSize,
                          height: gameAreaSize,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border.all(
                                color: Colors.blue[300]!,
                                width: 3
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                // Yılanı çiz
                                ...gameProvider.snake.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  Offset pos = entry.value;
                                  bool isHead = index == 0;

                                  return Positioned(
                                    left: pos.dx * cellSize + 2,
                                    top: pos.dy * cellSize + 2,
                                    child: Container(
                                      width: cellSize - 4,
                                      height: cellSize - 4,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isHead
                                              ? [Colors.blue[600]!, Colors.blue[800]!]
                                              : [Colors.blue[400]!, Colors.blue[600]!],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(0.3),
                                            spreadRadius: 1,
                                            blurRadius: 3,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: isHead ? Center(
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ) : null,
                                    ),
                                  );
                                }).toList(),

                                // Yemi çiz
                                Positioned(
                                  left: gameProvider.food.dx * cellSize + 2,
                                  top: gameProvider.food.dy * cellSize + 2,
                                  child: Container(
                                    width: cellSize - 4,
                                    height: cellSize - 4,
                                    decoration: BoxDecoration(
                                      gradient: const RadialGradient(
                                        colors: [Colors.red, Colors.redAccent],
                                        center: Alignment.center,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Başlangıç Ekranı
                                if (gameProvider.snake.isEmpty)
                                  _buildStartOverlay(context, gameProvider),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Kontrol Bilgileri
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'CONTROLS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Keyboard: ↑↓←→ or WASD\nTouchscreen: Swipe gestures\nSpace: Pause/Resume',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Oyun Kontrol Butonları
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (gameProvider.snake.isNotEmpty) ...[
                            ElevatedButton.icon(
                              onPressed: () => gameProvider.togglePlayPause(),
                              icon: Icon(
                                gameProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 20,
                              ),
                              label: Text(
                                gameProvider.isPlaying ? 'Pause' : 'Resume',
                                style: const TextStyle(fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          ElevatedButton.icon(
                            onPressed: () => gameProvider.startGame(),
                            icon: const Icon(Icons.refresh, size: 20),
                            label: const Text(
                              'New Game',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStartOverlay(BuildContext context, GameProvider gameProvider) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.blue.withOpacity(0.1),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[400]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.videogame_asset,
                size: 50,
                color: Colors.white,
              ),
              const SizedBox(height: 15),
              const Text(
                'Snake Game',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Click the button to start',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => gameProvider.startGame(),
                icon: const Icon(Icons.play_arrow, size: 24),
                label: const Text(
                  'START',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[600],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, GameProvider gameProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.blue[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.celebration,
                  size: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                const Text(
                  'CONGRATULATIONS!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Game Completed',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          titlePadding: EdgeInsets.zero,
          content: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Score:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[800],
                            ),
                          ),
                          Text(
                            '${gameProvider.score}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Time:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[800],
                            ),
                          ),
                          Text(
                            gameProvider.getFormattedDuration(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      gameProvider.startGame();
                      _focusNode.requestFocus();
                    },
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text(
                      'Play Again',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _focusNode.requestFocus();
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          actionsPadding: EdgeInsets.zero,
        );
      },
    );
  }
}

class GridPainter extends CustomPainter {
  final int gridSize;
  final double cellSize;

  GridPainter({required this.gridSize, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    // Grid çizgileri kaldırıldı - boş implementation
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}