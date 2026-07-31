import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders one bottom-nav SVG icon tinted with [color] — the same asset is
/// reused for the selected and unselected state, just tinted differently.
class BottomNavIcon extends StatelessWidget {
  final String svgIconPath;
  final Color color;

  const BottomNavIcon({super.key, required this.svgIconPath, required this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      svgIconPath,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
