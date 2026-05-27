import 'package:flutter/material.dart';

/// Reusable compact GTG logo using local asset.
class GtgSmallLogo extends StatelessWidget {
  final double size;

  const GtgSmallLogo({
    super.key,
    this.size = 54,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/images/GTG Logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
