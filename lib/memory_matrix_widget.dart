import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'animated_tile.dart';
import 'memory_matrix_controller.dart';

class MemoryMatrixWidget extends StatefulWidget {

  final MemoryMatrixController mmController;

  const MemoryMatrixWidget({required this.mmController, super.key});

  @override
  State<MemoryMatrixWidget> createState() =>
      _MemoryMatrixWidgetState();
}

class _MemoryMatrixWidgetState extends State<MemoryMatrixWidget>
    with TickerProviderStateMixin {

  late Timer levelTimer;
  ValueNotifier<bool?> startGameNotifier = ValueNotifier(null);
  ValueNotifier<int?> levelTimerNotifier = ValueNotifier(null);
  ValueNotifier<bool> gameCompleteNotifier = ValueNotifier(false);
  
  @override
  void initState() {
    widget.mmController.addListener(() {
      if (startGameNotifier.value != null && startGameNotifier.value!) {
        widget.mmController.startLevel(onTimeout: () {
          widget.mmController.levels[widget.mmController.currentLevel].initialOverride.value = false;
        },);
      }
    });
    super.initState();
  }

  void startTimer() {
    levelTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (levelTimer.tick > 4) {
        levelTimer.cancel();
        startGameNotifier.value = true;
        levelTimerNotifier.value = null;
        //Start current Level
        if (mounted) {
          startCurrentLevel();
        }
      } else {
        levelTimerNotifier.value = levelTimer.tick;
      }
    });
  }

  void startCurrentLevel() {
    widget.mmController.startLevel(onTimeout: () {
      widget.mmController.levels[widget.mmController.currentLevel].initialOverride.value = false;
    },);
  }

  void nextLevel() {
    if (widget.mmController.currentLevel == widget.mmController.levels.length - 1) {
      gameCompleteNotifier.value = true;
    } else {
      widget.mmController.nextLevel();
    }
  }

  void previousLevel() {
    if (widget.mmController.currentLevel == 0) {
      widget.mmController.levels[widget.mmController.currentLevel].reset();
      startCurrentLevel();
    } else {
      widget.mmController.previousLevel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: startGameNotifier,
      builder: (context, startGame, _) {
        if (startGame !=  null) {
          return ValueListenableBuilder(
            valueListenable: gameCompleteNotifier,
            builder: (context, gameComplete, _) {
              if (!gameComplete) {
                return AnimatedBuilder(
                  animation: widget.mmController,
                  builder: (context, _) {
                    final level = widget.mmController
                        .levels[widget.mmController.currentLevel];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Level ${widget.mmController.currentLevel + 1}", style: const TextStyle(color: Color(0xff4f5049), fontSize: 20, fontWeight: FontWeight.w500),),
                        const SizedBox(height: 10,),
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            widget.mmController
                                .levels[widget.mmController.currentLevel],
                            level.initialOverride
                          ]),
                          builder: (context, _) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xff4f5049),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black38),
                              ),
                              child: GridView.builder(
                                shrinkWrap: true,
                                itemCount: level.max,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: level.crossAxisCount,
                                  childAspectRatio: 1,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                ),
                                itemBuilder: (context, index) {
                                  // debugPrint("${index} isCorrect: ${level.correctOptions.contains(index + level.min)}");
                                  return AnimatedTile(
                                    // key: ValueKey(index),
                                    screen: this,
                                    isCorrect: level.correctOptions.contains(index + level.min),
                                    onTileClick: (isCorrect) {
                                      if (!level.isDone) {
                                        if (isCorrect) {
                                          if ((level.currentScore / 10) + 1 <= level.count ) {
                                            level.correctClick();
                                            if ((level.currentScore / 10) == level.count) {
                                              Future.delayed( const Duration(seconds: 1), nextLevel);
                                              level.isDone = true;
                                            }
                                          }
                                        } else {
                                          if (level.currentFails + 1 <= 2) {
                                            level.incorrectClick();
                                            if (level.currentFails >= 2) {
                                              Future.delayed(const Duration(seconds: 1), previousLevel);
                                              level.isDone = true;
                                            }
                                          }
                                        }
                                      } else {
                                        debugPrint("Level ${level.index} completed");
                                      }
                                    },
                                    initialOverride: level.initialOverride.value ?? true,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                return Container(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Total Score: ${getTotalScore()}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),),
                      const SizedBox(height: 20,),
                      Text("Total Fails: ${getTotalFails()}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),),
                      const SizedBox(height: 20,),
                      GestureDetector(
                        onTap: () {
                          widget.mmController.restartGame();
                          gameCompleteNotifier.value = false;
                        },
                        child: const Icon(
                          Icons.restart_alt_sharp,
                          size: 50,
                          color: Color(0xff4f5049),
                        ),
                      ),
                      const Text("Restart Game", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),),
                    ],
                  ),
                );
              }
            },
          );
        } else {
          return ValueListenableBuilder(
            valueListenable: levelTimerNotifier,
            builder: (context, levelTimerVal, _) {
              if (levelTimerVal != null) {
                //Show level start timer
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black38, width: 1),
                  ),
                  child: Text("$levelTimerVal", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),),
                );
              } else {
                //Start level after click gesture
                return GestureDetector(
                  onTap: () {
                    startTimer();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black38, width: 1),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Start Game",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                            textAlign: TextAlign.center),
                        Text("After 4 seconds the game will start",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                            textAlign: TextAlign.center)
                      ],
                    ),
                  ),
                ); 
              }
          },);
        }
      },
    );
  }

  int getTotalScore() {
    int totalScore = 0;
    for (var e in widget.mmController.levels) {
      totalScore += (e.currentScore - e.currentFails * 10);
    }
    return totalScore;
  }

  int getTotalFails() {
    int totalFails = 0;
    for (var e in widget.mmController.levels) {
      totalFails += e.currentFails;
    }
    return totalFails;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

