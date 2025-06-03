import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

enum Direction { up, down, left, right }

class GameProvider extends ChangeNotifier {
  static const int gridSize = 20;
  static const int initialSnakeLength = 3;
  static const Duration initialGameSpeed = Duration(milliseconds: 300);
  static const Duration speedIncrement = Duration(milliseconds: 20);

  List<Offset> _snake = [];
  Offset _food = Offset.zero;
  Direction _direction = Direction.right;
  bool _isPlaying = false;
  int _score = 0;
  Timer? _timer;
  Duration _currentSpeed = initialGameSpeed;
  DateTime? _gameStartTime;
  Duration _gameDuration = Duration.zero;

  List<Offset> get snake => _snake;
  Offset get food => _food;
  bool get isPlaying => _isPlaying;
  int get score => _score;
  Direction get direction => _direction;
  Duration get gameDuration => _gameDuration;

  GameProvider() {
    // Oyun başlangıçta başlamaz
  }

  void startGame() {
    _snake = [];
    int startX = gridSize ~/ 2;
    int startY = gridSize ~/ 2;
    for (int i = 0; i < initialSnakeLength; i++) {
      _snake.add(Offset((startX - i).toDouble(), startY.toDouble()));
    }
    _direction = Direction.right;
    _generateFood();
    _score = 0;
    _currentSpeed = initialGameSpeed;
    _isPlaying = true;
    _gameStartTime = DateTime.now();
    _gameDuration = Duration.zero;

    _timer?.cancel();
    _timer = Timer.periodic(_currentSpeed, (Timer timer) {
      _moveSnake();
    });
    notifyListeners();
  }

  void _generateFood() {
    final random = Random();
    Offset newFood;
    do {
      newFood = Offset(
          random.nextInt(gridSize).toDouble(),
          random.nextInt(gridSize).toDouble());
    } while (_snake.contains(newFood));
    _food = newFood;
  }

  void _moveSnake() {
    if (!_isPlaying) return;

    // Oyun süresini güncelle
    if (_gameStartTime != null) {
      _gameDuration = DateTime.now().difference(_gameStartTime!);
    }

    Offset head = _snake.first;
    Offset newHead;

    switch (_direction) {
      case Direction.up:
        newHead = Offset(head.dx, head.dy - 1);
        break;
      case Direction.down:
        newHead = Offset(head.dx, head.dy + 1);
        break;
      case Direction.left:
        newHead = Offset(head.dx - 1, head.dy);
        break;
      case Direction.right:
        newHead = Offset(head.dx + 1, head.dy);
        break;
    }

    // Duvarlara çarpma kontrolü
    if (newHead.dx < 0 ||
        newHead.dx >= gridSize ||
        newHead.dy < 0 ||
        newHead.dy >= gridSize) {
      _gameOver();
      return;
    }

    // Kendi kendine çarpma kontrolü
    if (_snake.contains(newHead)) {
      _gameOver();
      return;
    }

    _snake.insert(0, newHead);

    // Yem yeme kontrolü
    if (newHead == _food) {
      _score++;
      _generateFood();
      _increaseSpeed(); // Hızı artır
    } else {
      _snake.removeLast();
    }

    notifyListeners();
  }

  void _increaseSpeed() {
    // Her 5 puanda hızı artır
    if (_score % 5 == 0 && _score > 0) {
      int newMilliseconds = _currentSpeed.inMilliseconds - speedIncrement.inMilliseconds;
      if (newMilliseconds > 50) { // Minimum hız sınırı
        _currentSpeed = Duration(milliseconds: newMilliseconds);
        _timer?.cancel();
        _timer = Timer.periodic(_currentSpeed, (Timer timer) {
          _moveSnake();
        });
      }
    }
  }

  void changeDirection(Direction newDirection) {
    // Ters yöne gitmeyi engelle
    if ((_direction == Direction.up && newDirection == Direction.down) ||
        (_direction == Direction.down && newDirection == Direction.up) ||
        (_direction == Direction.left && newDirection == Direction.right) ||
        (_direction == Direction.right && newDirection == Direction.left)) {
      return;
    }
    _direction = newDirection;
  }

  void _gameOver() {
    _isPlaying = false;
    _timer?.cancel();
    if (_gameStartTime != null) {
      _gameDuration = DateTime.now().difference(_gameStartTime!);
    }
    notifyListeners();
  }

  void togglePlayPause() {
    if (_isPlaying) {
      _timer?.cancel();
    } else {
      if (_snake.isEmpty) {
        startGame();
        return;
      }
      _timer = Timer.periodic(_currentSpeed, (Timer timer) {
        _moveSnake();
      });
    }
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  String getFormattedDuration() {
    int minutes = _gameDuration.inMinutes;
    int seconds = _gameDuration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}