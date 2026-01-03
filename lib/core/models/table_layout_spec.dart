import 'dart:ui';

/// Calculates the table rectangle based on screen size
/// Centered, full-width table that matches screenshot proportions
class TableLayoutSpec {
  final Rect tableRect;

  TableLayoutSpec._(this.tableRect);

  factory TableLayoutSpec.from(Size s) {
    final w = s.width * 0.96;
    final h = s.height * 0.72; // matches screenshot proportions
    final left = (s.width - w) / 2;
    final top = (s.height - h) / 2 - s.height * 0.04;
    return TableLayoutSpec._(Rect.fromLTWH(left, top, w, h));
  }

}

