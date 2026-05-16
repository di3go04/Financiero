import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ConfettiOverlay {
  static void show(BuildContext context) {
    final overlayState = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: IgnorePointer(
          child: Lottie.network(
            'https://assets9.lottiefiles.com/packages/lf20_u4yrau.json',
            repeat: false,
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}


