import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Splash extends Notifier<bool> {
  @override
  bool build() {
    _startSplashTimer();
    return true; // splash is active
  }

  void _startSplashTimer() {
    Timer(const Duration(seconds: 3), () {
      state = false; // splash finished
    });
  }
}

final splashProvider = NotifierProvider<Splash, bool>(() {
  return Splash();
});
