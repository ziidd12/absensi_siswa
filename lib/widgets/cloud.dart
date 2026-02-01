import 'package:flutter/material.dart';

class Cloud extends StatelessWidget {
  final String image;
  final double top;
  final double left;

  const Cloud({
    super.key,
    required this.image,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: Image.asset(
        image,
        width: 120,
      ),
    );
  }
}
