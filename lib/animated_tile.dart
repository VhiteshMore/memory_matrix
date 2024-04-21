import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';

// class AnimatedTile extends StatefulWidget {
//   final Function(bool) onTileClick;
//   final bool isCorrect;
//   final double height;
//   final double width;
//   final bool initialOverride;
//
//   AnimatedTile(
//       {required this.onTileClick,
//         required this.isCorrect,
//         this.height = 50,
//         this.width = 50,
//         this.initialOverride = false,
//         super.key});
//
//   @override
//   State<AnimatedTile> createState() => _AnimatedTileState();
// }
//
// class _AnimatedTileState extends State<AnimatedTile> with SingleTickerProviderStateMixin{
//
//   late AnimationController _animationController;
//   late Animation<double> _animation;
//
//   @override
//   void initState() {
//     _animationController =
//         AnimationController(vsync: this, duration: const Duration(seconds: 1));
//     _animation = Tween<double>(begin: 0, end: pi).animate(
//         CurvedAnimation(parent: _animationController, curve: Curves.linear))
//       ..addStatusListener((status) {});
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _animation,
//       builder: (context, _) {
//         // debugPrint("Animation Value: ${_animationController.hashCode}");
//         return Transform(
//           transform: Matrix4.identity()
//             ..setEntry(3, 2, 0.001)
//             ..rotateX(_animation.value),
//           alignment: Alignment.center,
//           child: GestureDetector(
//             onTap: widget.initialOverride ? null : () {
//               widget.onTileClick(widget.isCorrect);
//               if (!_animationController.isCompleted) {
//                 _animationController.forward();
//               }
//             },
//             child: widget.initialOverride ? _realTile() :
//             _animation.value != pi ? Container(
//               constraints: BoxConstraints(minHeight: widget.height, minWidth: widget.width),
//               decoration: BoxDecoration(
//                 color: Colors.lime,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: Colors.black38),
//               ),
//             ) : _realTile(),
//           ),
//         );
//       },
//     );
//   }
//
//   Container _realTile() {
//     return Container(
//       constraints: BoxConstraints(minHeight: widget.height, minWidth: widget.width),
//       decoration: BoxDecoration(
//         color: widget.isCorrect ? Colors.blueAccent : Colors.red,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.black38),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     debugPrint("Disposing animation tile}");
//     _animationController.dispose();
//     super.dispose();
//   }
//
// }

class AnimatedTile extends StatelessWidget {
  final Function(bool) onTileClick;
  final TickerProvider screen;
  final bool isCorrect;
  final double height;
  final double width;
  final bool initialOverride;

  late AnimationController _animationController;
  late Animation<double> _animation;

  AnimatedTile(
      {required this.onTileClick,
      required this.isCorrect,
      required this.screen,
        this.height = 50,
        this.width = 50,
        this.initialOverride = false,
      super.key}) {
    _animationController =
        AnimationController(vsync: screen, duration: const Duration(milliseconds: 500));
    _animation = Tween<double>(begin: 0, end: pi).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear))
      ..addStatusListener((status) {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        // debugPrint("Animation Value: ${_animationController.hashCode}");
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_animation.value),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: initialOverride ? null : () {
              onTileClick(isCorrect);
              if (!_animationController.isCompleted) {
                _animationController.forward();
              }
            },
            child: initialOverride ? _realTile() :
            _animation.value != pi ? Container(
              constraints: BoxConstraints(minHeight: height, minWidth: width),
              decoration: BoxDecoration(
                color: const Color(0xffd9d9d9),
                borderRadius: BorderRadius.circular(4),
                // border: Border.all(color: Colors.black38),
              ),
            ) : _realTile(),
          ),
        );
      },
    );
  }

  Container _realTile() {
    return Container(
      constraints: BoxConstraints(minHeight: height, minWidth: width),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.cyanAccent : Colors.redAccent,
        borderRadius: BorderRadius.circular(4),
        // border: Border.all(color: Colors.black38),
      ),
    );
  }

}
