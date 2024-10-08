import 'package:flutter/material.dart';

class FadeInPiece extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FadeInPiece({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  _FadeInPieceState createState() => _FadeInPieceState();
}

class _FadeInPieceState extends State<FadeInPiece> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

// GameBoard 클래스의 build 메서드 내부에서 CustomPaint를 FadeInPiece로 감싸기
