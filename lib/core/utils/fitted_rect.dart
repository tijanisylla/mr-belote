import 'dart:ui';
import 'package:flutter/material.dart';

/// Computes the destination rect of an image when rendered with a specific BoxFit
/// This tells us where the image actually lands on screen
Rect fittedImageRect({
  required Size imageSize,
  required Size screenSize,
  required BoxFit fit,
}) {
  final fitted = applyBoxFit(fit, imageSize, screenSize);
  final dst = fitted.destination;

  final dx = (screenSize.width - dst.width) / 2.0;
  final dy = (screenSize.height - dst.height) / 2.0;

  return Rect.fromLTWH(dx, dy, dst.width, dst.height);
}

