// import 'package:flame/game.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/painting.dart';
//
// class MyGame extends FlameGame {
//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();
//     // You can load assets here if needed
//   }
//
//   @override
//   void render(Canvas canvas) {
//     super.render(canvas);
//
//     final center = size / 2;
//     const radius = 50.0;
//
//     final paint = Paint()..color = const Color(0xFF00FF00);
//
//     canvas.drawCircle(Offset(center.x, center.y), radius, paint);
//   }
//
//   @override
//   void update(double dt) {
//     super.update(dt);
//     // Game logic (if any) goes here
//   }
// }
//
//
// class MyWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(20),
//       child: GameWidget.controlled(
//         gameFactory: MyGame.new,
//       ),
//     );
//   }
// }

import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:space_shooter/components/audio_manager.dart';
import 'package:space_shooter/components/enemy.dart';
import 'package:space_shooter/components/pickup.dart';
import 'package:space_shooter/components/shoot_button.dart';
import 'package:flutter/material.dart';
import 'package:space_shooter/components/star.dart';

import 'components/player.dart';
import 'components/screen_shake_component.dart';

class MyGame extends FlameGame with HasCollisionDetection, TapDetector, PanDetector {
  late Player player;
  late JoystickComponent joystick;
  late SpawnComponent _enemySpawner;
  late SpawnComponent _pickupSpawner;
  final Random _random = Random();
  late ShootButton _shootButton;
  int _score = 0;
  late TextComponent _scoreDisplay;
   TextComponent get scoreDisplay => _scoreDisplay;
  int _health = 100;
  late TextComponent _healthDisplayTxt;
  late TextComponent _healthDisplay;
   TextComponent get healthDisplay => _scoreDisplay;
   late AudioManager audioManager;
  // late Timer _difficultyTimer;
  double enemySpeedMultiplier = 1;
  int _nextDifficultyScore = 20;
  int _difficultyIncrement = 10;
  bool _secondMilestoneReached = false;


  late final ScreenShakeComponent _screenShake;


  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await Flame.device.fullScreen();
    await Flame.device.setPortrait();

    // Initialize and add the player
    player = Player()
      ..position = size / 2
      ..anchor = Anchor.center;

    audioManager = AudioManager();
    await add(audioManager);
    audioManager.playMusic();
    // _difficultyTimer = Timer(15, onTick: _increaseDifficulty, repeat: true);
    // _difficultyTimer.start();
    _createStars();

    _screenShake = ScreenShakeComponent();
    add(_screenShake);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // _difficultyTimer.update(dt);
  }

  void startGame() async {
    // await _createJoystick();
    await _createPlayer();
    // _createShootButton();
    _createEnemySpawner();
    _createPickupSpawner();
    _createScoreDisplay();
    _createHealthDisplay();
    _createHealthDisplayTxt();
    // add(Enemy(position: Vector2(200, 0)));

  }
  // void _startDifficultyTimer() {
  //   final interval = 30 + _random.nextInt(15); // 30–45 seconds
  //   _difficultyTimer = Timer(interval.toDouble(), onTick: () {
  //     _increaseDifficulty();
  //     _startDifficultyTimer(); // Restart with new interval
  //   });
  //   _difficultyTimer.start();
  // }

  void shakeCamera({double intensity = 10, double duration = 0.3}) {
    _screenShake.shake(intensity: intensity, duration: duration);
  }

  @override
  void render(Canvas canvas) {
    // Apply screen shake translation
    canvas.save();
    canvas.translate(_screenShake.position.x, _screenShake.position.y);
    // Render the game
    super.render(canvas);
    // Restore the canvas
    canvas.restore();
  }



  void _increaseDifficulty() {
    enemySpeedMultiplier += 0.3;
    enemySpeedMultiplier = enemySpeedMultiplier.clamp(1.0,20.0);

    final currentMin = _enemySpawner.minPeriod ?? 1.0;
    final currentMax = _enemySpawner.maxPeriod ?? 2.0;

    final newMin = (currentMin - 0.1).clamp(0.05, 0.5);
    final newMax = (currentMax - 0.2).clamp(0.2, 1.0);

    _enemySpawner.minPeriod = newMin;
    _enemySpawner.maxPeriod = newMax;

    debugPrint(
      'Difficulty increased: speed x$enemySpeedMultiplier, spawn every ${newMin.toStringAsFixed(2)}s - ${newMax.toStringAsFixed(2)}s',
    );
  }

  Future<void> _createPlayer() async {
    player = Player()
      ..anchor = Anchor.center
      ..position = Vector2(size.x / 2, size.y * 0.8);
    add(player);
  }

  Future<void> _createJoystick() async {
    joystick = JoystickComponent(
        knob: SpriteComponent(
          sprite: await loadSprite('joystick_knob.png'),
          size: Vector2.all(50),
        ),
        background: SpriteComponent(
          sprite: await loadSprite('joystick_background.png'),
          size: Vector2.all(100),
        ),
        anchor: Anchor.bottomLeft,
        position: Vector2(20, size.y - 20),
        priority: 10);
    add(joystick);
  }

  void _createShootButton() {
    _shootButton = ShootButton();
    add(_shootButton);
  }

  void _createEnemySpawner() {
    _enemySpawner = SpawnComponent.periodRange(
      factory: (index) => Enemy(position: _generateSpwanPosition()),
      minPeriod: 0.2,
      maxPeriod: 0.7,
      selfPositioning: true,
    );
    add(_enemySpawner);
  }

  void _createPickupSpawner() {
    _pickupSpawner = SpawnComponent.periodRange(
      factory: (index) => Pickup(position: _generateSpwanPosition(),pickupType: PickupType.values[_random.nextInt(PickupType.values.length)]),
      minPeriod: 7.0,
      maxPeriod: 10.0,
      selfPositioning: true,
    );
    add(_pickupSpawner);
  }

  Vector2 _generateSpwanPosition() {

    // return Vector2(10 + _random.nextDouble() * (size.x - 10 * 2), -100);

    const double topPadding = 20;


    final double x = Random().nextDouble() * (size.x - 10 * 2 );
    final double y = topPadding;

    return Vector2(x, y);
  }

  void _createScoreDisplay(){
    _score = 0;

    _scoreDisplay = TextComponent(
      text: '0',
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 20),
      priority: 10,
      textRenderer: TextPaint(
        style:  TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black, offset: Offset(2, 2),
            blurRadius: 2,)
          ]
        ),
      ),
    );
    add(_scoreDisplay);
  }

  void incrementScore(int amount) {
    _score += amount;
    _scoreDisplay.text = _score.toString();

    if (_score >= _nextDifficultyScore) {
      _increaseDifficulty();

      if (_nextDifficultyScore == 20) {
        _nextDifficultyScore = 35;
      } else if (_nextDifficultyScore == 35) {
        _nextDifficultyScore = 50;
      } else {
        _nextDifficultyScore += 10;
      }
    }

    final ScaleEffect popEffect = ScaleEffect.to(
      Vector2.all(1.2),
      EffectController(
        duration: 0.05,
        alternate: true,
        curve: Curves.easeInOut,
      ),
    );
    _scoreDisplay.add(popEffect);
  }


  void _createHealthDisplay(){
    _health = 100;
    _healthDisplay = TextComponent(
      text: '100',
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 1.15, size.y / 1.05),
      priority: 10,
      textRenderer: TextPaint(
        style:  TextStyle(
          color:  Colors.green,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black, offset: Offset(2, 2),
            blurRadius: 2,)
          ]
        ),
      ),
    );
    add(_healthDisplay);
  }

  void _createHealthDisplayTxt(){
    _healthDisplayTxt = TextComponent(
      text: 'Health         %',
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 1.25, size.y / 1.05),
      priority: 10,
      textRenderer: TextPaint(
        style:  TextStyle(
          color: Colors.green,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black, offset: Offset(2, 2),
            blurRadius: 2,)
          ]
        ),
      ),
    );
    add(_healthDisplayTxt);
  }


  void incrementHealth(int amount) {
    _health += amount;
    _health = _health.clamp(0, 100); // Prevent health from going above 100
    _healthDisplay.text = _health.toString();

    // Update color based on health
    Color healthColor;
    if (_health < 30) {
      healthColor = Colors.red;
    } else if (_health < 60) {
      healthColor = Colors.orange;
    } else {
      healthColor = Colors.green;
    }

    _healthDisplay.textRenderer = TextPaint(
      style: TextStyle(
        color: healthColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 2),
        ],
      ),
    );

    _healthDisplayTxt.textRenderer = TextPaint(
      style: TextStyle(
        color: healthColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 2),
        ],
      ),
    );

    final ScaleEffect popEffect = ScaleEffect.to(
      Vector2.all(1.2),
      EffectController(
        duration: 0.05,
        alternate: true,
        curve: Curves.easeInOut,
      ),
    );
    _healthDisplay.add(popEffect);
  }


  void _createStars(){
    for(int i = 0; i < 50; i++){
      add(Star()..priority = -10);
    }
  }




  void playerdied(){
    overlays.add('GameOver');
    pauseEngine();
  }

  void restartGame() {
    children.whereType<PositionComponent>().forEach((component) {
      if (component is Enemy || component is Pickup) {
        remove(component);
      }
    },);

    /// reset enemy and pickups
    _enemySpawner.timer.start();
    _pickupSpawner.timer.start();

    ///  Reset difficulty values
    enemySpeedMultiplier = 1;
    _nextDifficultyScore = 20;
    _enemySpawner.minPeriod = 0.2;
    _enemySpawner.maxPeriod = 0.7;


    /// reset score
    _score = 0;
    _scoreDisplay.text = '0';
    _health = 100;
    _healthDisplay.text = '100';

    _healthDisplay.textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.green,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 2),
        ],
      ),
    );

    _healthDisplayTxt.textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.green,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 2),
        ],
      ),
    );

    /// create new player
    _createPlayer();

    resumeEngine();
  }

  void quitGame(){

    children.whereType<PositionComponent>().forEach((component) {
      if (component is! Star) {
        remove(component);
      }
    },);

    remove(_enemySpawner);
    remove(_pickupSpawner);

    overlays.add('Title');

    resumeEngine();
  }
}
