// In screen_shake_component.dart
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class ScreenShakeComponent extends PositionComponent {
  final Random _random = Random();

  void shake({double intensity = 10.0, double duration = 0.3}) {
    final segments = 5;
    final segmentDuration = duration / segments;

    final effects = <Effect>[];

    // Create random shake movements
    for (var i = 0; i < segments; i++) {
      final offset = Vector2(
        _random.nextDouble() * intensity * 2 - intensity,
        _random.nextDouble() * intensity * 2 - intensity,
      );

      effects.add(
        MoveEffect.by(
          offset,
          EffectController(duration: segmentDuration / 2),
        ),
      );

      effects.add(
        MoveEffect.by(
          -offset,
          EffectController(duration: segmentDuration / 2),
        ),
      );
    }

    // Add the sequence effect
    add(
      SequenceEffect(
        effects,
        onComplete: () => position = Vector2.zero(),
      ),
    );
  }
}