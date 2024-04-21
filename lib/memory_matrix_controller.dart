import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:memory_matrix/utility.dart';

enum LevelState {
  noState,start,paused,finished,inProgress;
}

class MemoryMatrixController extends ChangeNotifier{

  final List<MMLevel> levels;

  MemoryMatrixController({required this.levels, int? currentIndex}) {
    if (currentIndex != null) {
      _currentLevelIndex = currentIndex;
    }
  }

  int get currentLevel => _currentLevelIndex;

  int _currentLevelIndex = 0;

  Timer? startTimer;

  startLevel({ required VoidCallback onTimeout}) {
    startTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick > 4) {
        onTimeout();
        if (startTimer != null) {
          startTimer!.cancel();
          startTimer = null;
        }
      }
    });
  }

  void restartGame() {
    for (var e in levels) {
      e.reset();
      e.initialOverride = ValueNotifier(null);
      e.resetCorrectOptions();
    }
    _currentLevelIndex = 0;
    notifyListeners();
  }

  void nextLevel() {
    if (_currentLevelIndex < levels.length) {
      _currentLevelIndex++;
      notifyListeners();
    }
  }

  void previousLevel() {
    if (_currentLevelIndex > 0) {
      levels[_currentLevelIndex].reset();
      _currentLevelIndex--;
      levels[_currentLevelIndex].reset();
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  void dispose() {
    super.dispose();
  }

}

class MMLevel extends ChangeNotifier {

  final int index;
  final int min;
  final int max;
  final int count;
  final int crossAxisCount;
  late ValueNotifier<bool?> initialOverride;

  MMLevel({required this.index, required this.min, required this.max, required this.count, required this.crossAxisCount}) {
    correctOptions = Utility().generateRandomNumbersInRangeWithoutRepeats(min, max, count);
    initialOverride = ValueNotifier(null);
    debugPrint("correctOptions $correctOptions");
  }

  bool isDone = false;
  List<int> correctOptions = [];
  int _score = 0;
  int _fails = 0;

  int get currentScore => _score;

  int get currentFails => _fails;

  int correctClick() {
    _score += 10;
    // notifyListeners();
    return _score;
  }

  reset() {
    _score = 0;
    _fails = 0;
    isDone = false;
    initialOverride.value = null;
  }

  void setInitialOverride(bool value) {
    initialOverride.value = value;
  }

  void resetCorrectOptions() {
    correctOptions = Utility().generateRandomNumbersInRangeWithoutRepeats(min, max, count);
  }

  int incorrectClick() {
    // _score -= 10;
    _fails++;
    // notifyListeners();
    return _fails;
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

}